#!/usr/bin/env bash

# Make dist/ directory, if none exists
if [ ! -r ./dist ]; then
    echo "Creating dist/ directory..."
    mkdir dist/
fi

# Generate presentation.html
echo "Generating presentation.html..."
docker run --rm -v $PWD:/documents asciidoctor/docker-asciidoctor asciidoctor-revealjs -r asciidoctor-diagram -a revealjs_transition=slide -a revealjs_slideNumber=true -a revealjs_width=1100 -a revealjs_height=700 'presentation.adoc' -o 'presentation.html'

mv -f presentation.html dist/presentation.html
cp -r reveal.js/ dist/

# Install m30pm/node_modules, if not already installed
if [ ! -r ./m30pm/node_modules ]; then
    echo "Installing node_modules..."
    docker run --rm -v $PWD:/src -w /src node bash -c "cd m30pm && npm ci"
fi

# Build the unified model
echo "Building unified model..."
docker run --rm -v $PWD:/src -w /src node bash -c "node m30pm/buildUnifiedModel.js && cp dist/architecture.yaml dist/architecture.yml"

# Generate architecture.adoc from liquid template
echo "Generating architecture.adoc..."
docker run --rm -v $PWD:/src -w /src node node m30pm/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/architecture.adoc.liquid --out=dist/architecture.adoc

# generate index.html
echo "Generating index.html..."
docker run --rm -v $PWD:/src -w /src asciidoctor/docker-asciidoctor asciidoctor dist/architecture.adoc -r asciidoctor-diagram -o dist/index.html

# Generate pdf-theme.yml from liquid template
echo "Generating pdf-theme.yml..."
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:liquidoc 'bundle exec liquidoc -d dist/architecture.yml -t templates/pdf-theme.yml.liquid -o dist/pdf-theme.yml'

# Generate architecture.pdf
echo "Generating architecture.pdf..."
docker run --rm -v $PWD:/src -w /src asciidoctor/docker-asciidoctor asciidoctor dist/architecture.adoc -o dist/architecture.pdf -r asciidoctor-pdf -r asciidoctor-diagram -b pdf -a pdf-theme=dist/pdf-theme.yml
