/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_539700888")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX `idx_e7AsSmtdkE` ON `focusTodo` (`focus`)"
    ]
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_539700888")

  // update collection data
  unmarshal({
    "indexes": []
  }, collection)

  return app.save(collection)
})
