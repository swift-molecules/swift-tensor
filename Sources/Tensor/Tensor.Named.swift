public import Buffer_Linear_Primitive
public import Memory_Allocator_Protocol
public import Buffer_Linear
public import Memory_Allocator
public import Storage

public import Cardinal
public import Buffer

public import Memory
public import Storage_Memory

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
