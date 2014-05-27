SET @test_value := 0;
call exec('SET @test_value := 17');
SELECT @test_value = 17;