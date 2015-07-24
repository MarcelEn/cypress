@App.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  windows = {}

  API =
    startChromium: (src, options = {}) ->
      if win = windows.chromium
        win.close(true)

      if not src
        throw new Error("Missing src for tests to run. Cannot start Chromium.")

      _.defaults options,
        headless: false

      chromium = App.request "gui:open", src, {
        show: !options.headless
        frame: !options.headless
        position: "center"
        width: 1024
        width: 768
        title: "Running Tests"
      }

      chromium.once "document-end", ->
        App.config.chromium(chromium.window, options)

      windows.chromium = chromium

  App.commands.setHandler "start:chromium:run", (src, options) ->
    API.startChromium(src, options)