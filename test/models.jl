@testset "PointCloud Model tests" begin
    x_test = rand(Float32, 256, 3, 1)   #Reduced npoints to speed up tests
    npoints = size(x_test,1)

    @testset "PointNet Model tests" begin
        MODEL = PointNet
        @info "Testing $(MODEL)..."
        for num_classes in [10, 40]
            @testset "PointNet num_classes: $(num_classes)" begin
                model = MODEL(num_classes)

                y_test = model(x_test)

                # Testing Forward Propagation
                @test y_test isa AbstractArray
                @test size(y_test) == (num_classes,1)

                # Testing Backward Propagation
                @test gradtest(x_test -> model(x_test), x_test)
            end
        end
    end

    @testset "DGCNN Model tests" begin
        MODEL = DGCNN
        @info "Testing $(MODEL)..."
        for num_classes in [10, 40]
            @testset "DGCNN num_classes: $(num_classes)" begin
                model = MODEL(num_classes,10,npoints)

                y_test = model(x_test)

                # Testing Forward Propagation
                @test y_test isa AbstractArray
                @test size(y_test) == (num_classes,1)

                # Testing Backward Propagation
                @test gradtest(x_test -> model(x_test), x_test)
            end
        end
    end

end
