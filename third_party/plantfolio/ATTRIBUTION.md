# Plantfolio plant data

Source: Luminoid, Plantfolio Common Plants, copyright 2026.
Repository: https://github.com/Luminoid/plantfolio-common-plants
Pinned version: bbb364534cfbca28168085897ac9f2ff00a151a5
Dataset: https://raw.githubusercontent.com/Luminoid/plantfolio-common-plants/bbb364534cfbca28168085897ac9f2ff00a151a5/dist/common_plants.json

License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
https://creativecommons.org/licenses/by-nc-sa/4.0/
The upstream license notice is included in LICENSE in this directory.

myGrovia selects 297 household ornamental entries from the 980-entry source
using the Houseplants categories and the exclusions in catalog_scope.json, and bundles them in assets/data/catalog.json. The adapted
data remains under CC BY-NC-SA 4.0. Descriptions combine the original description,
commonExamples, origin, and careTips with section labels. Light enums become
readable labels, temperature arrays become ranges, and summerInterval supplies
an initial watering estimate. This is not a guaranteed schedule or climate model.
The one missing interval in the selected catalog remains null and require a user-supplied schedule.

Four original display-name/scientific-name labels are retained in the seed tool.
Some source entries describe plant groups rather than exclusive species records.
Other names use the upstream typeName without guessing scientific names.
No Wikipedia text or invented plant facts are added. Attribution is available
in the app through Dictionary > About & sources and each Read more dialog.

Photographs have separate licenses; Plantfolio does not supply or license them.
See ../catalog_photos/README.md and manifest.json for verified Wikimedia source
pages, photographers, licenses, identity checks, and resizing details. Current
coverage is recorded in assets/data/catalog.json and the photo manifest. Missing verified photos use the team's
original illustration. The four old photographs without recorded provenance
have been removed; they are not bundled or used by current tests.

The pinned upstream source is retained as source.json for reproducibility. It is
not bundled as the runtime Dictionary. Old catalog rows and licensed photographs
are retained on upgrades to preserve previously saved collections.
