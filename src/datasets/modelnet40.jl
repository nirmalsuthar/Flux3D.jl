function ModelNet40(;mode="point_cloud")

    if mode == "point_cloud"
        return ModelNet40PCloud
    else
        error("Selected mode: $(mode) is not supported (Currently supported mode are {\"point_cloud\"}).")
    end
end

struct MN40DataPoint <: AbstractDataPoint
    idx::Int
    data::Union{PointCloud}
    ground_truth::UInt8
end

struct ModelNet40PCloud <: AbstractDataset
    root::String 
    path::String #contains the path to dataset
    train::Bool
    transform #TODO Add type-assertion accordingly 
    npoints::Int
    sampling #TODO Add type-assertion accordingly to include two possible option {"top", "uniform"}
    datapaths::Array
    length::Int
    classes_to_idx::Dict{String, UInt8}
    classes::Array{String,1}
end

function MN40_extract(path, npoints)
    pset = Array{Float32}(undef, npoints, 3)
    stream = open(path, "r")
    for i in 1:npoints
        pset[i, :] = map((x->parse(Float32, x)), split(readline(stream, keep=false), ",")[1:3])
    end
    return pset
end

function ModelNet40PCloud(;root::String=default_root, train::Bool=true, npoints::Int=1024, transform=nothing, sampling=nothing)

    cat_file = joinpath(root, "modelnet40_shape_names.txt")
    
    classes = Array{String,1}(undef, 40)
    classes_to_idx = []
    for (i, line) in enumerate(readlines(cat_file))
        classes[1] = line
        push!(classes_to_idx, (line, convert(UInt8,i)))
    end
    classes_to_idx = Dict{String, UInt8}(classes_to_idx)

    _path = dataset("ModelNet40PCloud", root)
    train ? _split="train" : _split="test"
    shapeids = [line for line in readlines(joinpath(_path, "modelnet40_$(_split).txt"))]
    shape_names = [join(split(shapeids[i], "_")[1:end-1], "_") for i in 1:length(shapeids)]
    datapaths = [(shape_names[i], joinpath(_path, shape_names[i], (shapeids[i])*".txt")) for i in 1:length(shapeids)]
    length = length(datapaths)
    ModelNet40PCloud(root, _path, train, transform, npoints, sampling, datapaths, length, classes_to_idx, classes)
end

function Base.getindex(v::ModelNet40PCloud, idx::Int)
    cls = v.classes_to_idx(v.datapaths[idx][1])
    pset, cls = MN40_extract(v.datapaths[idx][2], v.npoints)
    return MN40DataPoint(idx, PointCloud(pset), cls)
end

Base.size(v::ModelNet40PCloud) = (v.length,)
Base.length(v::ModelNet40PCloud) = v.length