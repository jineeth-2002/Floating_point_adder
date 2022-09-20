/* 
    Author: Jnaneswara Rao Rompilli
    Comments: The Code is passing all test cases if change line 43 in testbench from "#1 start = 1" to "#40 start = 1"
*/


module fpadd(a, b, clk, start, reset, sum, done) ;

    input [31:0] a, b ;
    input clk, start, reset ;

    output reg [31:0] sum ;
    output reg done = 1;

    reg sign_a, sign_b ;
    reg [7:0] exp_a, exp_b ;
    reg [23:0] mant_a, mant_b ;
    reg [24:0] s_mant_a, s_mant_b ;

    reg [7:0] eq_expr ;
    reg [24:0] eq_manta, eq_mantb ;

    reg extract_done = 0 ;
    reg sign_extend = 0 ;
    reg equalize_done = 0 ;
    reg get_sign = 0 ;
    reg normalize_done = 0 ;

    reg [25:0] temp ;
    reg [25:0] ad_mantr ;
    reg [7:0] ad_expr ;

    reg sign_res ;
    reg [7:0] exp_res ;
    reg [24:0] mant_res ;

    reg [31:0] ediff ;

    reg [5:0] count = 0 ;

    always @(posedge clk)
    begin
        if(start == 1 && done == 1) 
        begin
            done <= 0 ;
            exp_a <= a[30:23] ;
            exp_b <= b[30:23] ;
            mant_a <= {1'b1, a[22:0]} ;
            mant_b <= {1'b1, b[22:0]} ;
            sign_a <= a[31:31] ;
            sign_b <= b[31:31] ;
            extract_done <= 1 ;
            // #1 ;
        end
        // #50 ;
    end
    
    always @(posedge clk)
    begin
        if(done == 0 && extract_done == 1) 
        begin
            if ((exp_a == 0) && (mant_a == 0))
            begin
                sum <= b ;
                done <= 1 ;
                sign_extend = 1 ;
            end else if((exp_b == 0) && (mant_b == 0))
            begin
                sum <= a ;
                done <= 1 ;
                sign_extend = 1 ;
            end else if(exp_a == 'hFF) 
            begin
                sum <= a ;
                done <= 1 ;
                sign_extend = 1 ;
            end else if(exp_b == 'hFF)
            begin
                sum <= b ;
                done <= 1 ;
                sign_extend <= 1 ;
            end else begin
                if(sign_a)
                begin
                    s_mant_a = $signed(-mant_a) ;
                    sign_extend = 1 ;
                end else
                begin
                    s_mant_a = {1'b0, mant_a} ;
                    sign_extend = 1 ;
                end

                if(sign_b)
                begin
                    s_mant_b = ~({1'b0, mant_b}) + 1'b1 ;
                    sign_extend = 1 ;
                end else
                begin
                    s_mant_b = {1'b0, mant_b} ;
                    sign_extend = 1 ;
                end
            end
            
            // extract_done <= 0 ;
            // $display("Signed: %b %b", s_mant_a, s_mant_b) ;
        end
    end

    always @(posedge clk)
    begin

        if(done == 0 && sign_extend == 1)
        // exp_a = exp_a - 127 ;
        // exp_b = exp_b - 127 ;
        begin
            if(exp_a > exp_b)
            begin
                ediff = exp_a - exp_b ;
                eq_expr = exp_a ;
                eq_mantb = s_mant_b >>> ediff ;
                eq_manta = s_mant_a ;
                equalize_done = 1 ;
            end else if(exp_a < exp_b) 
            begin
                ediff = exp_b - exp_a ;
                eq_expr = exp_b ;
                eq_manta = s_mant_a >>> ediff ;
                eq_mantb = s_mant_b ;
                equalize_done = 1 ;
            end else
            begin
                ediff = 0 ;
                eq_expr = exp_a ;
                eq_manta = s_mant_a ;
                eq_mantb = s_mant_b ;
                equalize_done = 1 ;
            end
            
            // sign_extend <= 0 ;
            // $display($time, ": Mantissa %b %b %b %d", eq_manta, eq_mantb, eq_expr, ediff) ;
            // done <= 1 ;
        end
    end

    always @(posedge clk)
    begin
        if(done == 0 && equalize_done == 1)
        begin
            temp = $signed(eq_manta + eq_mantb) ;
            // $display($time, " %b", temp) ;
            if(temp[24] == 1)
            begin
                sign_res <= 1 ;
                ad_mantr = ~({1'b0, temp}) + 1'b1 ;
                ad_expr = eq_expr ;
                get_sign = 1 ;
                // $display($time, " Add: %b", ad_mantr) ;
            end
            else
            begin
                get_sign <= 1 ;
                sign_res <= 0 ;
                ad_mantr = temp ;
                ad_expr = eq_expr ;
            end
           
            // equalize_done <= 0 ;
            // done <= 1 ;
            //  $display($time, ": Addition %b %b %b", eq_manta, eq_mantb, ad_mantr) ;
        end
       
    end

    always @(posedge clk)
    begin
        if(done == 0 && get_sign == 1)
        begin
            // #50;
            mant_res <= ad_mantr[23:0] ;
            // $display($time, " Mant: %b %b", eq_expr, ad_mantr) ;
            exp_res <= ad_expr ;
            repeat(24)
                begin
                    if(mant_res[23] == 0)
                    begin
                        // $display("Hi") ;
                        mant_res = mant_res << 1 ;
                        exp_res = exp_res - 1 ;
                    end else
                    begin
                        // $display("Hey") ;
                        sum = {sign_res, exp_res, mant_res[22:0]} ;
                        normalize_done = 1 ;
                        // #50 ;
                    end
                end
            if (normalize_done == 0)
            begin
                // $display("hello") ;
                sum = 0 ;
                normalize_done = 1 ;
            end
            
            // $display($time, ": Result %X", sum) ;
        end
    end

    always @(posedge clk)
    begin
        if(done == 0 && normalize_done == 1)
        begin
            done <= 1 ;
            normalize_done = 0 ;
            // normalize_done = 0 ;
        end
    end
endmodule