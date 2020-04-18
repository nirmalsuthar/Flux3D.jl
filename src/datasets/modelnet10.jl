function ModelNet10(;mode="point_cloud")

    if mode == "point_cloud"
        return ModelNet10PCloud
    else
        error("Selected mode: $(mode) is not supported (Currently supported mode are {\"point_cloud\"}).")
    end

end

const MN10_classes_to_idx = Dict{String, UInt8}([("bathtub",1), ("bed",2), ("chair",3), ("desk",4), ("dresser",5),
    ("monitor",6), ("night_stand",7), ("sofa",8), ("table",9), ("toilet",10)])

const MN10_idx_to_classes = Dict{UInt8, String}([(1,"bathtub"), (2,"bed"), (3,"chair"), (4,"desk"), (5,"dresser"),
    (6,"monitor"), (7,"night_stand"), (8,"sofa"), (9,"table"), (10,"toilet")])

struct MN10DataPoint <: AbstractDataPoint
    idx::Int
    data::Union{PointCloud}
    ground_truth::UInt8
end

struct ModelNet10PCloud <: AbstractDataset
    root::String 
    path::String #contains the path to dataset
    train::Bool
    transform #TODO Add type-assertion accordingly 
    npoints::Int
    sampling #TODO Add type-assertion accordingly to include two possible option {"top", "uniform"}
    datapaths::Array
end

function MN10_extract(datapath, npoints)
    cls = [MN10_classes_to_idx[datapath[1]]]
    pset = Array{Float32}(undef, npoints, 3)
    stream = open(datapath[2], "r")
    for i in 1:npoints
        pset[i, :] = map((x->parse(Float32, x)), split(readline(stream, keep=false), ",")[1:3])
    end
    return (pset,cls)
end

function ModelNet10PCloud(;root::String, train::Bool=true, npoints::Int=1024, transform=nothing, sampling=nothing)
    path = dataset("ModelNet10PCloud", root)
    train ? split="train" : split="test"
    shapeids = [line for line in readlines(joinpath(root, "modelnet10_$(split).txt"))]
    shape_names = [join(split(shapeids[i], "_")[1:end-1], "_") for i in 1:length(shapeids)]
    datapath = [(shape_names[i], joinpath(root, shape_names[i], (shapeids[i])*".txt")) for i in 1:length(shapeids)]
    ModelNet10PCloud(root, path, train, transform, npoints, sampling, datapath)
end

function Base.getindex(v::ModelNet10PCloud, idx::Int)
    pset, cls = MN10_extract(v.datapaths[idx], v.npoints)
    return MN10DataPoint(idx, PointCloud(pset), cls)
end