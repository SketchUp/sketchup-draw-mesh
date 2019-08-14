# Copyright 2019 Trimble Inc
# Licensed under the MIT license

require 'sketchup.rb'
require 'extensions.rb'

module Examples
  module DrawMesh

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('Draw Mesh Example', 'ex_draw_mesh/main')
      ex.description = 'SketchUp Ruby API example drawing shaded polygons to the viewport.'
      ex.version     = '1.0.0'
      ex.copyright   = 'Trimble Inc. © 2019'
      ex.creator     = 'SketchUp'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end

  end # module DrawMesh
end # module Examples
