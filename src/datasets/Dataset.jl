module Dataset

import ..Flux3D
import ..Flux3D: PointCloud 

export ModelNet10

include("utils.jl")
include("autodetect.jl")
include("modelnet10.jl")

end # module