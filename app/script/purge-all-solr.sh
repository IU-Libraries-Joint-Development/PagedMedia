#! /bin/sh

SOLR_HOME='http://localhost:8983/solr'

function clear_core {
  curl "${SOLR_HOME}/${1}/update?commit=true" \
       -H 'Content-Type: text/xml' \
       --data-binary '<delete><query>*:*</query></delete>'
}

clear_core development

clear_core test
