module CoreExtensions
  module Float
    module Trigonometry
      def to_rad
        self * (Math::PI / 180)
      end

      def to_deg
        self * (180 / Math::PI)
      end

      def normalize
        (self + 360) % 360
      end
    end
  end
end
