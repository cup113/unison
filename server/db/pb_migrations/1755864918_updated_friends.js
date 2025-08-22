/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2965180291")

  // update collection data
  unmarshal({
    "updateRule": "@request.auth.id = user2.id"
  }, collection)

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "bool1981675086",
    "name": "accepted",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2965180291")

  // update collection data
  unmarshal({
    "updateRule": null
  }, collection)

  // remove field
  collection.fields.removeById("bool1981675086")

  return app.save(collection)
})
