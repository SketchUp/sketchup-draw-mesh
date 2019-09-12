# Copyright 2019 Trimble Inc
# Licensed under the MIT license

require 'sketchup.rb'

require 'ex_draw_mesh/draw_mesh_tool'

module Examples
  module DrawMesh

    class Options
      attr_accessor :use_light
      attr_accessor :draw_edges
      attr_accessor :draw_textures
    end

    OPTIONS = Options.new


    def self.draw_shaded
      Sketchup.active_model.select_tool(DrawMeshTool.new)
    end

    unless file_loaded?(__FILE__)
      cmd_screen_polygons = UI::Command.new('Draw Mesh') {
        self.draw_shaded
      }.tap { |cmd|
        cmd.tooltip = 'Draw Mesh'
      }

      cmd_toggle_light = UI::Command.new('Toggle Light') {
        OPTIONS.use_light = !OPTIONS.use_light
        Sketchup.active_model.active_view.invalidate # Hack!
      }.tap { |cmd|
        cmd.tooltip = 'Toggle Light'
        cmd.set_validation_proc {
          OPTIONS.use_light ? MF_CHECKED : MF_ENABLED
        }
      }

      cmd_toggle_edges = UI::Command.new('Toggle Edges') {
        OPTIONS.draw_edges = !OPTIONS.draw_edges
        Sketchup.active_model.active_view.invalidate # Hack!
      }.tap { |cmd|
        cmd.tooltip = 'Toggle Edges'
        cmd.set_validation_proc {
          OPTIONS.draw_edges ? MF_CHECKED : MF_ENABLED
        }
      }

      cmd_toggle_textures = UI::Command.new('Toggle Textures') {
        OPTIONS.draw_textures = !OPTIONS.draw_textures
        Sketchup.active_model.active_view.invalidate # Hack!
      }.tap { |cmd|
        cmd.tooltip = 'Toggle Textures'
        cmd.set_validation_proc {
          OPTIONS.draw_textures ? MF_CHECKED : MF_ENABLED
        }
      }

      title = 'Draw Mesh'

      plugins_menu = UI.menu('Plugins')
      menu = plugins_menu.add_submenu(title)
      menu.add_item(cmd_screen_polygons)
      menu.add_separator
      menu.add_item(cmd_toggle_light)
      menu.add_item(cmd_toggle_textures)
      menu.add_item(cmd_toggle_edges)

      toolbar = UI.toolbar(title)
      toolbar.add_item(cmd_screen_polygons)
      toolbar.add_separator
      toolbar.add_item(cmd_toggle_light)
      toolbar.add_item(cmd_toggle_textures)
      toolbar.add_item(cmd_toggle_edges)
      toolbar.restore

      file_loaded(__FILE__)
    end

    # Examples::DrawMesh.reload
    def self.reload()
      original_verbose = $VERBOSE
      $VERBOSE = nil
      pattern = File.join(__dir__, '**/*.rb')
      x = Dir.glob(pattern).each { |file|
        load file
      }
      x.length
    ensure
      $VERBOSE = original_verbose
    end

  end # module DrawMesh
end # module Examples
