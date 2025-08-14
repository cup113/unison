/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_113564862")

  // update field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "number3495063588",
    "max": null,
    "min": null,
    "name": "estimation",
    "onlyInt": true,
    "presentable": false,
    "required": true,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_113564862")

  // update field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "number3495063588",
    "max": null,
    "min": null,
    "name": "estimation",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
})
