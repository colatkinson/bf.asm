	; eax is the bf instruction pointer
	%define bf_script_reg bx
	; ecx is the bf data pointer
	%define bf_mem_reg di
	; edx is the general computation register
	%define comp_reg si

	%define base_ptr_reg bp
	%define stack_ptr_reg sp
	%define ret_reg ax
