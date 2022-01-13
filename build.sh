#!/usr/bin/env bash

docker run --rm -v $PWD:/documents asciidoctor/docker-asciidoctor asciidoctor-revealjs -r asciidoctor-diagram -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.8.0 -a revealjs_transition=slide -a revealjs_slideNumber=true -a revealjs_width=1100 -a revealjs_height=700 -D dist '*.adoc' -o 'index.html'
