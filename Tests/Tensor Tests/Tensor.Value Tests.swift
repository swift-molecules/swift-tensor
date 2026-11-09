import Buffer
import Buffer_Linear
import Buffer_Linear_Primitive
import Cardinal
import Memory
import Memory_Allocator
import Ordinal
import Storage
import Tagged
import Tensor
import Testing

enum `Tensor.Value Tests` {}

extension `Tensor.Value Tests` {
    @Suite
    struct `Tensor Value Tests` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

extension `Tensor.Value Tests`.`Tensor Value Tests`.Unit {
    @Test
    func `constructs row-major rank-2 tensor from elements`() throws(Tensor.Shape<2>.Error) {
        var dims = InlineArray<2, Cardinal>(repeating: .zero)
        dims[0] = Cardinal(2)
        dims[1] = Cardinal(3)
        let shape = Tensor.Shape<2>(dims)
        let tensor = try Tensor.Value<Int, 2, Tensor.Layout.Order.Row>(
            shape: shape,
            elements: [1, 2, 3, 4, 5, 6]
        )
        #expect(tensor.shape.dims[0] == Cardinal(2))
        #expect(tensor.shape.dims[1] == Cardinal(3))
    }

    @Test
    func `subscript reads correct elements at row-major positions`() throws {
        var dims = InlineArray<2, Cardinal>(repeating: .zero)
        dims[0] = Cardinal(2)
        dims[1] = Cardinal(3)
        let shape = Tensor.Shape<2>(dims)
        let tensor = try Tensor.Value<Int, 2, Tensor.Layout.Order.Row>(
            shape: shape,
            elements: [10, 20, 30, 40, 50, 60]
        )

        for (i, j, expected) in [(0, 0, 10), (0, 2, 30), (1, 0, 40), (1, 2, 60)] {
            var positions = InlineArray<2, Ordinal>(repeating: Ordinal(0))
            positions[0] = Ordinal(UInt(i))
            positions[1] = Ordinal(UInt(j))
            let pos = Tensor.Index.Position<2>(positions)
            let value = try tensor.element(at: pos)
            #expect(value == expected)
        }
    }
}

extension `Tensor.Value Tests`.`Tensor Value Tests`.`Edge Case` {
    @Test
    func `mismatched element count throws elementCountMismatch`() {
        var dims = InlineArray<2, Cardinal>(repeating: .zero)
        dims[0] = Cardinal(2)
        dims[1] = Cardinal(3)
        let shape = Tensor.Shape<2>(dims)

        do throws(Tensor.Shape<2>.Error) {
            _ = try Tensor.Value<Int, 2, Tensor.Layout.Order.Row>(
                shape: shape,
                elements: [1, 2, 3]
            )
            #expect(Bool(false), "Expected throw")
        } catch let error {
            #expect(error == .elementCountMismatch(expected: Cardinal(6), actual: Cardinal(3)))
        }
    }

    @Test
    func `out-of-bounds position throws outOfBounds`() throws(Tensor.Shape<2>.Error) {
        var dims = InlineArray<2, Cardinal>(repeating: .zero)
        dims[0] = Cardinal(2)
        dims[1] = Cardinal(3)
        let shape = Tensor.Shape<2>(dims)
        let tensor = try Tensor.Value<Int, 2, Tensor.Layout.Order.Row>(
            shape: shape,
            elements: [1, 2, 3, 4, 5, 6]
        )

        var positions = InlineArray<2, Ordinal>(repeating: Ordinal(0))
        positions[0] = Ordinal(5)
        positions[1] = Ordinal(0)
        let pos = Tensor.Index.Position<2>(positions)

        do throws(Tensor.Index.Error) {
            _ = try tensor.element(at: pos)
            #expect(Bool(false), "Expected throw")
        } catch let error {
            switch error {
            case .outOfBounds:
                break

            default:
                #expect(Bool(false), "Wrong error variant")
            }
        }
    }
}

extension `Tensor.Value Tests`.`Tensor Value Tests`.Unit {
    @Test
    func `map and reshape read a column-major value through its strides`() throws {
        var storage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>
        >.Linear(
            minimumCapacity: Tagged<Int, Cardinal>(_unchecked: Cardinal(6))
        )
        for element in [1, 2, 3, 4, 5, 6] {
            storage.append(element)
        }
        var dims = InlineArray<2, Cardinal>(repeating: .zero)
        dims[0] = Cardinal(3)
        dims[1] = Cardinal(2)
        let shape = Tensor.Shape<2>(dims)
        let columnMajor = Tensor.Value<Int, 2, Tensor.Layout.Strided>(
            shape: shape,
            strides: Tensor.Strides<2>(columnMajor: shape),
            storage: storage
        )

        let mapped = columnMajor.map { $0 * 10 }
        var flatDims = InlineArray<1, Cardinal>(repeating: .zero)
        flatDims[0] = Cardinal(6)
        let flat = try columnMajor.reshape(to: Tensor.Shape<1>(flatDims))

        let expected = [1, 4, 2, 5, 3, 6]
        for (offset, value) in expected.enumerated() {
            var positions = InlineArray<2, Ordinal>(repeating: Ordinal(0))
            positions[0] = Ordinal(UInt(offset / 2))
            positions[1] = Ordinal(UInt(offset % 2))
            #expect(try mapped.element(at: Tensor.Index.Position<2>(positions)) == value * 10)
            var flatPosition = InlineArray<1, Ordinal>(repeating: Ordinal(0))
            flatPosition[0] = Ordinal(UInt(offset))
            #expect(try flat.element(at: Tensor.Index.Position<1>(flatPosition)) == value)
        }
    }
}
