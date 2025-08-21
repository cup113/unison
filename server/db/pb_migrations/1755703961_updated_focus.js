/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2844193794")

  // add field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "bool56683945",
    "name": "isCompleted",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2844193794")

  // remove field
  collection.fields.removeById("bool56683945")

  return app.save(collection)
})
