typedef enum {ADD,SUB,MULL,DIV} op_enum;

class trx;
	// the class of transaction.
	// in uvm it is an uvm_object or uvm_sequence_item
	rand int addr;
	rand int data;
	rand op_enum op_code;

	function void print();
		$display("---------",);
		$display("addr = 0x%0h",addr);
		$display("data = 0x%0h",data);
		$display("opcode = %0s",op_code.name());
		$display("---------",);
	endfunction

endclass

class base_cnstr #(type TYPE = trx);
	TYPE item;

	virtual function string get_name();
		return "base_cnstr";
	endfunction

endclass

class trx_cnstr extends trx;

	rand base_cnstr constraint_queue[$]; // remember it must be rand 

	function void add_cnstr(base_cnstr item);
		constraint_queue.push_back(item);
	endfunction

	function void pre_randomize();
		foreach(constraint_queue[i]) begin
			constraint_queue[i].item = this;
		end
	endfunction

	function void print_all_cnstr();
		foreach(constraint_queue[i]) begin
			$display(constraint_queue[i].get_name());
		end
	endfunction

endclass

// costraints set

class inside_range_cnstr extends base_cnstr;
	constraint c {
		item.addr inside {[32'h1200_0000 : 32'h1500_0000]};
	}

	virtual function string get_name();
		return "inside_range_cnstr";
	endfunction

endclass

class addr_alignment_cnstr extends base_cnstr;
	constraint addr_alignment_cnstr {
		item.addr[1:0] == 0;
	}
	virtual function string get_name();
		return "addr_alignment_cnstr";
	endfunction	
endclass

class addr_alignment_4k_cnstr extends base_cnstr;
	constraint addr_alignment_4k_cnstr {
		item.addr[11:0] == 12'h0;
	}

	virtual function string get_name();
		return "addr_alignment_4k_cnstr";
	endfunction
endclass

class data_cnstr extends base_cnstr;
	constraint data_cnstr {
		item.data inside {[-100 : 100]};
	}

	virtual function string get_name();
		return "data_cnstr";
	endfunction
endclass

class op_only_div_cnstr extends base_cnstr;
	constraint c {
		item.op_code == DIV;
	}

	virtual function string get_name();
		return "op_only_div_cnstr";
	endfunction
endclass

module top();

	initial begin
		trx_cnstr item_h;
		inside_range_cnstr inside_range_cnstr_h;
		addr_alignment_cnstr addr_alignment_cnstr_h;
		addr_alignment_4k_cnstr addr_alignment_4k_cnstr_h;
		data_cnstr data_cnstr_h;
		op_only_div_cnstr op_cnstr_h;

		item_h = new;
		inside_range_cnstr_h = new;
		addr_alignment_cnstr_h = new;
		addr_alignment_4k_cnstr_h = new;
		data_cnstr_h = new;
		op_cnstr_h = new;

		$display("#############################");
		item_h.print_all_cnstr();	
		repeat(5) begin
			item_h.randomize();
			item_h.print();	
		end

		item_h.add_cnstr(inside_range_cnstr_h);
		item_h.add_cnstr(op_cnstr_h);


		$display("#############################");
		item_h.print_all_cnstr();
		repeat(5) begin
			item_h.randomize();
			item_h.print();			
		end


		item_h.constraint_queue.pop_back();
		item_h.add_cnstr(addr_alignment_4k_cnstr_h);
		item_h.add_cnstr(data_cnstr_h);
		$display("#############################");
		item_h.print_all_cnstr();
		repeat(5) begin
			item_h.randomize();
			item_h.print();
		end

	end

endmodule