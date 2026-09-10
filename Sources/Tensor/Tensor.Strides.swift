public import Difference

extension Tensor {

    public struct Strides<let Rank: Int>: Copyable, Sendable {

        public var values: InlineArray<Rank, Difference>

        @inlinable
        public init(_ values: InlineArray<Rank, Difference>) {
            self.values = values
        }
    }
}
