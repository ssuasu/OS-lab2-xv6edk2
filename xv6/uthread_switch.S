	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */

.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
  movl 4(%esp), %eax
  movl 8(%esp), %edx

  # Save old callee-save registers
  pushl %ebp
  pushl %ebx
  pushl %esi
  pushl %edi

  # Switch stacks
  movl current_thread, %eax
  movl %esp, (%eax)
  movl %edx, %esp

  # Load new callee-save registers
  popl %edi
  popl %esi
  popl %ebx
  popl %ebp
  ret    /* return to ra */
