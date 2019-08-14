# Copyright 2019 Trimble Inc
# Licensed under the MIT license

module Examples
  module DrawMesh
    class DrawMeshTool

      def initialize
        @triangles = []
        @normals = []
        @edges = []
        update_mesh
      end

      def activate
        view = Sketchup.active_model.active_view
        view.invalidate
      end

      def deactivate(view)
        view.invalidate
      end

      def suspend(view)
        view.invalidate
      end

      def resume(view)
        view.invalidate
      end

      def getExtents
        bounds = Geom::BoundingBox.new
        bounds.add(@triangles) unless @triangles.empty?
        bounds
      end

      def draw(view)
        view.drawing_color = Sketchup::Color.new(128, 0, 0)
        if OPTIONS.use_light
          view.draw(GL_TRIANGLES, @triangles, normals: @normals)
        else
          view.draw(GL_TRIANGLES, @triangles)
        end

        if OPTIONS.draw_edges
          view.line_stipple = ''
          view.line_width = 1
        view.drawing_color = Sketchup::Color.new(255, 128, 0)
          view.draw(GL_LINES, @edges)
        end
      end

      private

      def update_mesh
        model = Sketchup.active_model
        entities = model.active_entities
        faces = entities.grep(Sketchup::Face)

        kPoints = Geom::PolygonMesh::MESH_POINTS
        kUVQFront = Geom::PolygonMesh::MESH_UVQ_FRONT
        kUVQBack = Geom::PolygonMesh::MESH_UVQ_BACK
        kNormals = Geom::PolygonMesh::MESH_NORMALS

        flags = kPoints | kUVQFront | kUVQBack | kNormals # equals to 7

        faces.each { |face|
          mesh = face.mesh(flags)
          mesh.polygons.each { |polygon|
            polygon.each { |i|
              @triangles << mesh.point_at(i.abs)
              @normals << mesh.normal_at(i.abs)
            }
          }
        }

        offset = model.bounds.width * 1.5
        @triangles.each { |pt| pt.offset!(X_AXIS, offset) }

        @edges = []
        @triangles.each_slice(3) { |triangle|
          triangle.each_with_index { |point, i1|
            i2 = (i1 + 1) % 3
            @edges << triangle[i1]
            @edges << triangle[i2]
          }
        }

        nil
      end

    end
  end # module DrawMesh
end # module Examples
