@App.module "ProjectsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: (params) ->
      {project} = params

      projectView = @getProjectView(project)

      @listenTo projectView, "client:url:clicked", ->
        App.execute "gui:external:open", project.get("clientUrl")

      @listenTo projectView, "stop:clicked ok:clicked" , ->
        App.config.closeProject().then ->
          App.vent.trigger "start:projects:app"

      @show projectView

      options = {
        headless: params.headless
        onChromiumRun: (src, options = {}) ->
          App.execute "start:chromium:run", src, options
      }

      if options.headless
        options.morgan = false

      _.defer => @runProject(project, options)

    runProject: (project, options) ->
      App.config.runProject(project.get("path"), options)
        .then (config) ->
          project.setClientUrl(config.clientUrl, config.clientUrlDisplay)
          App.execute "start:id:generator", config.idGeneratorUrl
          if options.headless
            options.onChromiumRun(config.clientUrl + "#/tests/cypress_api.coffee?__ui=satellite", {headless: true})

        .catch (err) ->
          project.setError(err)

    getProjectView: (project) ->
      new Show.Project
        model: project