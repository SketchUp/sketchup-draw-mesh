# Copyright 2019 Trimble Inc
# Licensed under the MIT license

module Examples
  module DrawMesh
    class DrawMeshTool

      def initialize
        @triangles = []
        @normals = [] # Vertex Normals
        @uvs = [] # Vertex UVs
        @edges = []
        @texture_id = 0;
        update_mesh
      end

      def activate
        view = Sketchup.active_model.active_view

        if textured_material?(view.model)
          material = view.model.materials.current
          image_rep = material.texture.image_rep
          @texture_id = view.load_texture(image_rep)
        end

        view.invalidate
      end

      def deactivate(view)
        view.release_texture(@texture_id) if @texture_id
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

      # @param [Sketchup::View] view
      def draw(view)
        options = {}
        options[:normals] = @normals if OPTIONS.use_light

        draw_textures = OPTIONS.draw_textures && @texture_id
        if draw_textures
          options[:texture] = @texture_id
          options[:uvs] = @uvs
        end

        view.drawing_color = Sketchup::Color.new(128, 0, 0)
        view.draw(GL_TRIANGLES, @triangles, **options)

        if OPTIONS.draw_edges
          view.line_stipple = ''
          view.line_width = 1
          view.drawing_color = Sketchup::Color.new(255, 128, 0)
          view.draw(GL_LINES, @edges)
        end
      end

      private

      # @param [Sketchup::Model]
      def textured_material?(model)
        material = model.materials.current
        material && material.texture
      end

      # @param [Array] uvq
      # @return [Geom::Point3d] uv
      def uvq2uv(uvq)
        Geom::Point3d.new(uvq.x / uvq.z, uvq.y / uvq.z, 1.0)
      end

      def update_mesh
        model = Sketchup.active_model
        entities = model.active_entities
        faces = entities.grep(Sketchup::Face)

        kPoints = Geom::PolygonMesh::MESH_POINTS
        kUVQFront = Geom::PolygonMesh::MESH_UVQ_FRONT
        kUVQBack = Geom::PolygonMesh::MESH_UVQ_BACK
        kNormals = Geom::PolygonMesh::MESH_NORMALS

        flags = kPoints | kUVQFront | kUVQBack | kNormals

        faces.each { |face|
          mesh = face.mesh(flags)
          mesh.polygons.each { |polygon|
            polygon.each { |i|
              @triangles << mesh.point_at(i.abs)
              @normals << mesh.normal_at(i.abs)
              @uvs << uvq2uv(mesh.uv_at(i.abs, true))
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
