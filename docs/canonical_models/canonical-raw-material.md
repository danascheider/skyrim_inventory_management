# Canonical::RawMaterial

The `Canonical::RawMaterial` model represents materials present in Skyrim that are used solely or primarily for smithing or building. This diverse model can include ores, ingots, gemstones, pelts, and building materials such as iron fittings, locks or nails. These items, along with other items used for smithing or building, can be associated to the items they are used to create or improve via the `Canonical::Material` join model.

The astute reader may notice that some of these raw materials, such as ingots and building materials, are themselves crafted using other materials. Currently, `Canonical::RawMaterial` models don't have any associations for the materials used to create them. There is a [card](https://trello.com/c/vSt8rfoY/373-handle-edge-case-where-raw-materials-are-craftable) to undertake this work.
