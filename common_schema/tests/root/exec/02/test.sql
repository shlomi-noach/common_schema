SET @test_value0 := 0;
SET @test_value1 := 0;
SET @test_value2 := 0;
call exec('SET @test_value0 := 11; SET @test_value1 := 13; SET @test_value2 := 17; ');
SELECT @test_value0 = 11 AND @test_value1 = 13 AND @test_value2 = 17;