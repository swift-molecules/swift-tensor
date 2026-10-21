public import Buffer
import Buffer_Linear
public import Buffer_Linear_Primitive
public import Cardinal
public import Memory
public import Memory_Allocator
import Memory_Allocator_Protocol
public import Storage

extension Tensor {

    public struct Named<Element: ~Copyable, each Axis: Tensor.Axis.`Protocol`>: ~Copyable {

        @usableFromInline
        package var _dims: [Cardinal]

        @usableFromInline
        package var _storage:
            Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>
                .Linear

        @inlinable
        public init(
            storage:
                consuming Buffer<
                    Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
                >.Linear
        ) {
            var dims: [Cardinal] = []
            for axisSize in repeat (each Axis).size {
                precondition(axisSize >= 0)
                dims.append(Cardinal(UInt(axisSize)))
            }
            self._dims = dims
            self._storage = storage
        }
    }
}
