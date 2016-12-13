package starling.extensions
{
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.getTimer;

    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.DisplayObjectContainer;

    import starling.display.Mesh;
    import starling.display.Sprite3D;
    import starling.events.Event;
    import starling.rendering.IndexData;
    import starling.rendering.MeshEffect;
    import starling.rendering.Painter;
    import starling.rendering.VertexData;
    import starling.styles.MeshStyle;
    import starling.textures.Texture;
    import starling.utils.MathUtil;
    import starling.utils.MatrixUtil;
    import starling.utils.rad2deg;

    public class Mesh3D extends Mesh
    {
        private static const E:Number = 0.00001;

        private var _style:MeshStyle;
        private var _effect:MeshEffect;

        private var _rotationX:Number;
        private var _rotationY:Number;
        private var _scaleZ:Number;
        private var _pivotZ:Number;
        private var _z:Number;

        private var _transformationMatrix:Matrix;
        private var _transformationMatrix3D:Matrix3D;
        private var _transformationChanged:Boolean;
        private var _is2D:Boolean;

        /** Helper objects. */
        private static var sHelperPoint:Vector3D    = new Vector3D();
        private static var sHelperPointAlt:Vector3D = new Vector3D();
        private static var sHelperMatrix:Matrix3D   = new Matrix3D();

        private static var sProjectionMatrix:Matrix3D;

        /** Creates an empty Sprite3D. */
        public function Mesh3D(vertexData:VertexData, indexData:IndexData)
        {
            //_is2D = false;

            super(vertexData, indexData, new Mesh3DStyle());

            _scaleZ = 1.0;
            _rotationX = _rotationY = _pivotZ = _z = 0.0;
            _transformationMatrix = new Matrix();
            _transformationMatrix3D = new Matrix3D();
            _is2D = true;  // meaning: this 3D object contains only 2D content
            setIs3D(false); // meaning: this display object supports 3D transformations




            addEventListener(Event.ADDED, onAddedChild);
            addEventListener(Event.REMOVED, onRemovedChild);
        }

        /** @inheritDoc */
//        override public function render(painter:Painter):void
//        {
//            if (_is2D) super.render(painter);
//            else
//            {
//                painter.finishMeshBatch();
//                painter.pushState();
//                painter.state.transformModelviewMatrix3D(transformationMatrix3D);
//
//                super.render(painter);
//
//                painter.finishMeshBatch();
//                painter.excludeFromCache(this);
//                painter.popState();
//            }
//        }

        override public function setStyle(meshStyle:MeshStyle=null,
                                          mergeWithPredecessor:Boolean=true):void
        {
            //super.setStyle(meshStyle, false);
            _style = meshStyle;
            _effect = meshStyle.createEffect();
        }

        override public function render(painter:Painter):void
        {
            painter.finishMeshBatch();
            painter.drawCount += 1;
            painter.prepareToDraw();
            painter.excludeFromCache(this);

            syncBuffers();

            _effect.render(0, indexData.numTriangles);

            //traceOutput();
        }

        private function traceOutput():void
        {
            trace("mvp:", _effect.mvpMatrix3D.rawData);

            var tmp:Vector3D;

            var v0:Point = vertexData.getPoint(0, "position");
            var v1:Point = vertexData.getPoint(1, "position");
            var v2:Point = vertexData.getPoint(2, "position");
            var v3:Point = vertexData.getPoint(3, "position");

            trace("v0:", v0);
            tmp = _effect.mvpMatrix3D.transformVector(new Vector3D(v0.x, v0.y, 1, 0));
            tmp.project();
            trace("v0 transform:", tmp);

            trace("v1:", v1);
            tmp = _effect.mvpMatrix3D.transformVector(new Vector3D(v1.x, v1.y, 1, 0));
            tmp.project();
            trace("v1 transform:", tmp);

            trace("v2:", v2);
            tmp = _effect.mvpMatrix3D.transformVector(new Vector3D(v2.x, v2.y, 1, 0));
            tmp.project();
            trace("v2 transform:", tmp);

            trace("v3:", v3);
            tmp = _effect.mvpMatrix3D.transformVector(new Vector3D(v3.x, v3.y, 1, 0));
            tmp.project();
            trace("v3 transform:", tmp);
        }

        private function syncBuffers():void
        {
            _effect.uploadVertexData(vertexData);
            _effect.uploadIndexData(indexData);

            updateMatrices();

            var w:Number = Starling.current.stage.stageWidth;
            var h:Number = Starling.current.stage.stageHeight;
            sProjectionMatrix = perspectiveProjection(60, w / h, 0.1, 2048);
            //sProjectionMatrix = orthographicProjection();

            //_effect.texture = texture;

            _effect.mvpMatrix3D.identity();
            _effect.mvpMatrix3D.append(_transformationMatrix3D);
            _effect.mvpMatrix3D.append(sProjectionMatrix);
        }

//        protected function perspectiveProjection(fov:Number=90,
//                                                 aspect:Number=1, near:Number=1, far:Number=2048):Matrix3D {
//            var y2:Number = near * Math.tan(fov * Math.PI / 360);
//            var y1:Number = -y2;
//            var x1:Number = y1 * aspect;
//            var x2:Number = y2 * aspect;
//
//            var a:Number = 2 * near / (x2 - x1);
//            var b:Number = 2 * near / (y2 - y1);
//            var c:Number = (x2 + x1) / (x2 - x1);
//            var d:Number = (y2 + y1) / (y2 - y1);
//            var q:Number = -(far + near) / (far - near);
//            var qn:Number = -2 * (far * near) / (far - near);
//
//            return new Matrix3D(Vector.<Number>([
//                a, 0, 0, 0,
//                0, b, 0, 0,
//                c, d, q, -1,
//                0, 0, qn, 0
//            ]));
//        }

        protected function perspectiveProjection(fov:Number=90,
                                                 aspect:Number=1, near:Number=1, far:Number=2048):Matrix3D {

//            trace("nearClipPlantHeight:", 2 * near * Math.tan(fov * Math.PI / 360));
//            trace("farClipPlantHeight:", 2 * far * Math.tan(fov * Math.PI / 360));
//            trace("4ClipPlantHeight:", 2 * 4 * Math.tan(fov * Math.PI / 360));

            var a:Number = 1 / (Math.tan(fov * Math.PI / 360) * aspect);
            var b:Number = 1 / Math.tan(fov * Math.PI / 360);
            var c:Number = -(far + near) / (far - near);
            var d:Number = -2 * near * far / (far - near);

            return new Matrix3D(Vector.<Number>([
                a, 0, 0, 0,
                0, b, 0, 0,
                0, 0, c, -1,
                0, 0, d, 0
                ]));
        }

        protected function orthographicProjection(size:Number = 4, aspect:Number=1, near:Number=10, far:Number=50):Matrix3D {
            var a:Number = 1 / (aspect * size);
            var b:Number = 1 / size;
            var c:Number = -2 / (far - near);
            var d:Number = -(far + near) / (far - near);

            return new Matrix3D(Vector.<Number>([
                a, 0, 0, 0,
                0, b, 0, 0,
                0, 0, c, 0,
                0, 0, d, 1
            ]));

        }

        /** @inheritDoc */
        override public function hitTest(localPoint:Point):DisplayObject
        {
            if (_is2D) return super.hitTest(localPoint);
            else
            {
                if (!visible || !touchable) return null;

                // We calculate the interception point between the 3D plane that is spawned up
                // by this sprite3D and the straight line between the camera and the hit point.

                sHelperMatrix.copyFrom(transformationMatrix3D);
                sHelperMatrix.invert();

                stage.getCameraPosition(this, sHelperPoint);
                MatrixUtil.transformCoords3D(sHelperMatrix, localPoint.x, localPoint.y, 0, sHelperPointAlt);
                MathUtil.intersectLineWithXYPlane(sHelperPoint, sHelperPointAlt, localPoint);

                return super.hitTest(localPoint);
            }
        }

        /** @private */
        override public function setRequiresRedraw():void
        {
            _is2D = _z > -E && _z < E &&
                    _rotationX > -E && _rotationX < E &&
                    _rotationY > -E && _rotationY < E &&
                    _pivotZ > -E && _pivotZ < E;

            super.setRequiresRedraw();
        }

        // helpers

        private function onAddedChild(event:Event):void
        {
            recursivelySetIs3D(event.target as DisplayObject, true);
        }

        private function onRemovedChild(event:Event):void
        {
            recursivelySetIs3D(event.target as DisplayObject, false);
        }

        private function recursivelySetIs3D(object:DisplayObject, value:Boolean):void
        {
            if (object is Sprite3D)
                return;

            if (object is DisplayObjectContainer)
            {
                var container:DisplayObjectContainer = object as DisplayObjectContainer;
                var numChildren:int = container.numChildren;

                for (var i:int=0; i<numChildren; ++i)
                    recursivelySetIs3D(container.getChildAt(i), value);
            }

            object.setIs3D(value);
        }

        private function updateMatrices():void
        {
            var x:Number = this.x;
            var y:Number = this.y;
            var scaleX:Number = this.scaleX;
            var scaleY:Number = this.scaleY;
            var pivotX:Number = this.pivotX;
            var pivotY:Number = this.pivotY;
            var rotationZ:Number = this.rotation;

            _transformationMatrix3D.identity();

            if (scaleX != 1.0 || scaleY != 1.0 || _scaleZ != 1.0)
                _transformationMatrix3D.appendScale(scaleX || E , scaleY || E, _scaleZ || E);
            if (_rotationX != 0.0)
                _transformationMatrix3D.appendRotation(rad2deg(_rotationX), Vector3D.X_AXIS);
            if (_rotationY != 0.0)
                _transformationMatrix3D.appendRotation(rad2deg(_rotationY), Vector3D.Y_AXIS);
            if (rotationZ != 0.0)
                _transformationMatrix3D.appendRotation(rad2deg( rotationZ), Vector3D.Z_AXIS);
            if (x != 0.0 || y != 0.0 || _z != 0.0)
                _transformationMatrix3D.appendTranslation(x, y, _z);
            if (pivotX != 0.0 || pivotY != 0.0 || _pivotZ != 0.0)
                _transformationMatrix3D.prependTranslation(-pivotX, -pivotY, -_pivotZ);

            if (_is2D) MatrixUtil.convertTo2D(_transformationMatrix3D, _transformationMatrix);
            else       _transformationMatrix.identity();
        }

        // properties

        /** The 2D transformation matrix of the object relative to its parent — if it can be
         *  represented in such a matrix (the values of 'z', 'rotationX/Y', and 'pivotZ' are
         *  zero). Otherwise, the identity matrix. CAUTION: not a copy, but the actual object! */
        public override function get transformationMatrix():Matrix
        {
            if (_transformationChanged)
            {
                updateMatrices();
                _transformationChanged = false;
            }

            return _transformationMatrix;
        }

        public override function set transformationMatrix(value:Matrix):void
        {
            super.transformationMatrix = value;
            _rotationX = _rotationY = _pivotZ = _z = 0;
            _transformationChanged = true;
        }

        /**  The 3D transformation matrix of the object relative to its parent.
         *   CAUTION: not a copy, but the actual object! */
        public override function get transformationMatrix3D():Matrix3D
        {
            if (_transformationChanged)
            {
                updateMatrices();
                _transformationChanged = false;
            }

            return _transformationMatrix3D;
        }

        /** @inheritDoc */
        public override function set x(value:Number):void
        {
            super.x = value;
            _transformationChanged = true;
        }

        /** @inheritDoc */
        public override function set y(value:Number):void
        {
            super.y = value;
            _transformationChanged = true;
        }

        /** The z coordinate of the object relative to the local coordinates of the parent.
         *  The z-axis points away from the camera, i.e. positive z-values will move the object further
         *  away from the viewer. */
        public function get z():Number { return _z; }
        public function set z(value:Number):void
        {
            _z = value;
            _transformationChanged = true;
            setRequiresRedraw();
        }

        /** @inheritDoc */
        public override function set pivotX(value:Number):void
        {
            super.pivotX = value;
            _transformationChanged = true;
        }

        /** @inheritDoc */
        public override function set pivotY(value:Number):void
        {
            super.pivotY = value;
            _transformationChanged = true;
        }

        /** The z coordinate of the object's origin in its own coordinate space (default: 0). */
        public function get pivotZ():Number { return _pivotZ; }
        public function set pivotZ(value:Number):void
        {
            _pivotZ = value;
            _transformationChanged = true;
            setRequiresRedraw();
        }

        /** @inheritDoc */
        public override function set scaleX(value:Number):void
        {
            super.scaleX = value;
            _transformationChanged = true;
        }

        /** @inheritDoc */
        public override function set scaleY(value:Number):void
        {
            super.scaleY = value;
            _transformationChanged = true;
        }

        /** The depth scale factor. '1' means no scale, negative values flip the object. */
        public function get scaleZ():Number { return _scaleZ; }
        public function set scaleZ(value:Number):void
        {
            _scaleZ = value;
            _transformationChanged = true;
            setRequiresRedraw();
        }

        /** @private */
        override public function set scale(value:Number):void
        {
            scaleX = scaleY = scaleZ = value;
        }

        /** @private */
        public override function set skewX(value:Number):void
        {
            throw new Error("3D objects do not support skewing");

            // super.skewX = value;
            // _orientationChanged = true;
        }

        /** @private */
        public override function set skewY(value:Number):void
        {
            throw new Error("3D objects do not support skewing");

            // super.skewY = value;
            // _orientationChanged = true;
        }

        /** The rotation of the object about the z axis, in radians.
         *  (In Starling, all angles are measured in radians.) */
        public override function set rotation(value:Number):void
        {
            super.rotation = value;
            _transformationChanged = true;
        }

        /** The rotation of the object about the x axis, in radians.
         *  (In Starling, all angles are measured in radians.) */
        public function get rotationX():Number { return _rotationX; }
        public function set rotationX(value:Number):void
        {
            _rotationX = MathUtil.normalizeAngle(value);
            _transformationChanged = true;
            setRequiresRedraw();
        }

        /** The rotation of the object about the y axis, in radians.
         *  (In Starling, all angles are measured in radians.) */
        public function get rotationY():Number { return _rotationY; }
        public function set rotationY(value:Number):void
        {
            _rotationY = MathUtil.normalizeAngle(value);
            _transformationChanged = true;
            setRequiresRedraw();
        }

        /** The rotation of the object about the z axis, in radians.
         *  (In Starling, all angles are measured in radians.) */
        public function get rotationZ():Number { return rotation; }
        public function set rotationZ(value:Number):void { rotation = value; }

        override public function set texture(value:Texture):void
        {
            _effect.texture = value;
        }

        override public function get texture():Texture
        {
            return _effect.texture;
        }
    }
}
