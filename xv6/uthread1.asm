
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
thread_p  next_thread;
extern void thread_switch(void);

void 
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
   6:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 c0 0d 00 00 	movl   $0xdc0,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 a0 0d 00 00       	mov    0xda0,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 a4 0d 00 00       	mov    %eax,0xda4
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  42:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 a0 0d 00 00       	mov    0xda0,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 a0 0d 00 00       	mov    0xda0,%eax
  6b:	a3 a4 0d 00 00       	mov    %eax,0xda4
  }

  if (next_thread == 0) {
  70:	a1 a4 0d 00 00       	mov    0xda4,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 18 0a 00 00       	push   $0xa18
  81:	6a 02                	push   $0x2
  83:	e8 d8 05 00 00       	call   660 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 54 04 00 00       	call   4e4 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 a0 0d 00 00    	mov    0xda0,%edx
  96:	a1 a4 0d 00 00       	mov    0xda4,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 25                	je     c4 <thread_schedule+0xc4>
    next_thread->state = RUNNING;
  9f:	a1 a4 0d 00 00       	mov    0xda4,%eax
  a4:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ab:	00 00 00 
    current_thread->state = RUNNABLE;
  ae:	a1 a0 0d 00 00       	mov    0xda0,%eax
  b3:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  ba:	00 00 00 
    thread_switch();
  bd:	e8 b1 01 00 00       	call   273 <thread_switch>
  } else
    next_thread = 0;
}
  c2:	eb 0a                	jmp    ce <thread_schedule+0xce>
    next_thread = 0;
  c4:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
  cb:	00 00 00 
}
  ce:	90                   	nop
  cf:	c9                   	leave  
  d0:	c3                   	ret    

000000d1 <thread_init>:

void 
thread_init(void)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	83 ec 18             	sub    $0x18,%esp
  uthread_init((int)thread_schedule);
  d7:	b8 00 00 00 00       	mov    $0x0,%eax
  dc:	83 ec 0c             	sub    $0xc,%esp
  df:	50                   	push   %eax
  e0:	e8 9f 04 00 00       	call   584 <uthread_init>
  e5:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < MAX_THREAD; i++) {
  e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ef:	eb 18                	jmp    109 <thread_init+0x38>
    all_thread[i].state = FREE;
  f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f4:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
  fa:	05 c4 2d 00 00       	add    $0x2dc4,%eax
  ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for (int i = 0; i < MAX_THREAD; i++) {
 105:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 109:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 10d:	7e e2                	jle    f1 <thread_init+0x20>
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
 10f:	c7 05 a0 0d 00 00 c0 	movl   $0xdc0,0xda0
 116:	0d 00 00 
  current_thread->state = RUNNING;
 119:	a1 a0 0d 00 00       	mov    0xda0,%eax
 11e:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 125:	00 00 00 
}
 128:	90                   	nop
 129:	c9                   	leave  
 12a:	c3                   	ret    

0000012b <thread_create>:


void 
thread_create(void (*func)())
{
 12b:	55                   	push   %ebp
 12c:	89 e5                	mov    %esp,%ebp
 12e:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 131:	c7 45 f4 c0 0d 00 00 	movl   $0xdc0,-0xc(%ebp)
 138:	eb 14                	jmp    14e <thread_create+0x23>
    if (t->state == FREE) break;
 13a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 13d:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 143:	85 c0                	test   %eax,%eax
 145:	74 13                	je     15a <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 147:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 14e:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
 153:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 156:	72 e2                	jb     13a <thread_create+0xf>
 158:	eb 01                	jmp    15b <thread_create+0x30>
    if (t->state == FREE) break;
 15a:	90                   	nop
  }
  if (t == all_thread + MAX_THREAD) {
 15b:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
 160:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 163:	75 14                	jne    179 <thread_create+0x4e>
    printf(2, "thread_create: no FREE thread slot available\n");
 165:	83 ec 08             	sub    $0x8,%esp
 168:	68 40 0a 00 00       	push   $0xa40
 16d:	6a 02                	push   $0x2
 16f:	e8 ec 04 00 00       	call   660 <printf>
 174:	83 c4 10             	add    $0x10,%esp
    return;
 177:	eb 45                	jmp    1be <thread_create+0x93>
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 179:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17c:	83 c0 04             	add    $0x4,%eax
 17f:	05 00 20 00 00       	add    $0x2000,%eax
 184:	89 c2                	mov    %eax,%edx
 186:	8b 45 f4             	mov    -0xc(%ebp),%eax
 189:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 18b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18e:	8b 00                	mov    (%eax),%eax
 190:	8d 50 fc             	lea    -0x4(%eax),%edx
 193:	8b 45 f4             	mov    -0xc(%ebp),%eax
 196:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack (스레드가 시작하면 func 함수 실행해야하니까.)
 198:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19b:	8b 00                	mov    (%eax),%eax
 19d:	89 c2                	mov    %eax,%edx
 19f:	8b 45 08             	mov    0x8(%ebp),%eax
 1a2:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 1a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a7:	8b 00                	mov    (%eax),%eax
 1a9:	8d 50 e0             	lea    -0x20(%eax),%edx
 1ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1af:	89 10                	mov    %edx,(%eax)
  //context switching 할 때 레지스터 공간을 32byte 확보
  t->state = RUNNABLE;
 1b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b4:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1bb:	00 00 00 
}
 1be:	c9                   	leave  
 1bf:	c3                   	ret    

000001c0 <mythread>:

static void //그냥 100번 돌면서 출력해주는거
mythread(void)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1c6:	83 ec 08             	sub    $0x8,%esp
 1c9:	68 6e 0a 00 00       	push   $0xa6e
 1ce:	6a 01                	push   $0x1
 1d0:	e8 8b 04 00 00       	call   660 <printf>
 1d5:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1df:	eb 1c                	jmp    1fd <mythread+0x3d>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 1e1:	a1 a0 0d 00 00       	mov    0xda0,%eax
 1e6:	83 ec 04             	sub    $0x4,%esp
 1e9:	50                   	push   %eax
 1ea:	68 81 0a 00 00       	push   $0xa81
 1ef:	6a 01                	push   $0x1
 1f1:	e8 6a 04 00 00       	call   660 <printf>
 1f6:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1fd:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 201:	7e de                	jle    1e1 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 203:	83 ec 08             	sub    $0x8,%esp
 206:	68 91 0a 00 00       	push   $0xa91
 20b:	6a 01                	push   $0x1
 20d:	e8 4e 04 00 00       	call   660 <printf>
 212:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 215:	a1 a0 0d 00 00       	mov    0xda0,%eax
 21a:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 221:	00 00 00 
  thread_schedule();  // 스케줄러로 넘김
 224:	e8 d7 fd ff ff       	call   0 <thread_schedule>
  while (1);  // fallback
 229:	eb fe                	jmp    229 <mythread+0x69>

0000022b <main>:
}


int 
main(int argc, char *argv[]) 
{
 22b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 22f:	83 e4 f0             	and    $0xfffffff0,%esp
 232:	ff 71 fc             	push   -0x4(%ecx)
 235:	55                   	push   %ebp
 236:	89 e5                	mov    %esp,%ebp
 238:	51                   	push   %ecx
 239:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 23c:	e8 90 fe ff ff       	call   d1 <thread_init>
  thread_create(mythread);
 241:	83 ec 0c             	sub    $0xc,%esp
 244:	68 c0 01 00 00       	push   $0x1c0
 249:	e8 dd fe ff ff       	call   12b <thread_create>
 24e:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 251:	83 ec 0c             	sub    $0xc,%esp
 254:	68 c0 01 00 00       	push   $0x1c0
 259:	e8 cd fe ff ff       	call   12b <thread_create>
 25e:	83 c4 10             	add    $0x10,%esp
  thread_schedule();  //
 261:	e8 9a fd ff ff       	call   0 <thread_schedule>
  return 0;
 266:	b8 00 00 00 00       	mov    $0x0,%eax
 26b:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 26e:	c9                   	leave  
 26f:	8d 61 fc             	lea    -0x4(%ecx),%esp
 272:	c3                   	ret    

00000273 <thread_switch>:
         */

.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
  movl 4(%esp), %eax
 273:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
 277:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
 27b:	55                   	push   %ebp
  pushl %ebx
 27c:	53                   	push   %ebx
  pushl %esi
 27d:	56                   	push   %esi
  pushl %edi
 27e:	57                   	push   %edi

  # Switch stacks
  movl current_thread, %eax
 27f:	a1 a0 0d 00 00       	mov    0xda0,%eax
  movl %esp, (%eax)
 284:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
 286:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
 288:	5f                   	pop    %edi
  popl %esi
 289:	5e                   	pop    %esi
  popl %ebx
 28a:	5b                   	pop    %ebx
  popl %ebp
 28b:	5d                   	pop    %ebp
  ret    /* return to ra */
 28c:	c3                   	ret    

0000028d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp
 290:	57                   	push   %edi
 291:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 292:	8b 4d 08             	mov    0x8(%ebp),%ecx
 295:	8b 55 10             	mov    0x10(%ebp),%edx
 298:	8b 45 0c             	mov    0xc(%ebp),%eax
 29b:	89 cb                	mov    %ecx,%ebx
 29d:	89 df                	mov    %ebx,%edi
 29f:	89 d1                	mov    %edx,%ecx
 2a1:	fc                   	cld    
 2a2:	f3 aa                	rep stos %al,%es:(%edi)
 2a4:	89 ca                	mov    %ecx,%edx
 2a6:	89 fb                	mov    %edi,%ebx
 2a8:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2ab:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2ae:	90                   	nop
 2af:	5b                   	pop    %ebx
 2b0:	5f                   	pop    %edi
 2b1:	5d                   	pop    %ebp
 2b2:	c3                   	ret    

000002b3 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2b3:	55                   	push   %ebp
 2b4:	89 e5                	mov    %esp,%ebp
 2b6:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2b9:	8b 45 08             	mov    0x8(%ebp),%eax
 2bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2bf:	90                   	nop
 2c0:	8b 55 0c             	mov    0xc(%ebp),%edx
 2c3:	8d 42 01             	lea    0x1(%edx),%eax
 2c6:	89 45 0c             	mov    %eax,0xc(%ebp)
 2c9:	8b 45 08             	mov    0x8(%ebp),%eax
 2cc:	8d 48 01             	lea    0x1(%eax),%ecx
 2cf:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2d2:	0f b6 12             	movzbl (%edx),%edx
 2d5:	88 10                	mov    %dl,(%eax)
 2d7:	0f b6 00             	movzbl (%eax),%eax
 2da:	84 c0                	test   %al,%al
 2dc:	75 e2                	jne    2c0 <strcpy+0xd>
    ;
  return os;
 2de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2e1:	c9                   	leave  
 2e2:	c3                   	ret    

000002e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2e6:	eb 08                	jmp    2f0 <strcmp+0xd>
    p++, q++;
 2e8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2ec:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	0f b6 00             	movzbl (%eax),%eax
 2f6:	84 c0                	test   %al,%al
 2f8:	74 10                	je     30a <strcmp+0x27>
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
 2fd:	0f b6 10             	movzbl (%eax),%edx
 300:	8b 45 0c             	mov    0xc(%ebp),%eax
 303:	0f b6 00             	movzbl (%eax),%eax
 306:	38 c2                	cmp    %al,%dl
 308:	74 de                	je     2e8 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	0f b6 00             	movzbl (%eax),%eax
 310:	0f b6 d0             	movzbl %al,%edx
 313:	8b 45 0c             	mov    0xc(%ebp),%eax
 316:	0f b6 00             	movzbl (%eax),%eax
 319:	0f b6 c8             	movzbl %al,%ecx
 31c:	89 d0                	mov    %edx,%eax
 31e:	29 c8                	sub    %ecx,%eax
}
 320:	5d                   	pop    %ebp
 321:	c3                   	ret    

00000322 <strlen>:

uint
strlen(char *s)
{
 322:	55                   	push   %ebp
 323:	89 e5                	mov    %esp,%ebp
 325:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 328:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 32f:	eb 04                	jmp    335 <strlen+0x13>
 331:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 335:	8b 55 fc             	mov    -0x4(%ebp),%edx
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	01 d0                	add    %edx,%eax
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	84 c0                	test   %al,%al
 342:	75 ed                	jne    331 <strlen+0xf>
    ;
  return n;
 344:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 347:	c9                   	leave  
 348:	c3                   	ret    

00000349 <memset>:

void*
memset(void *dst, int c, uint n)
{
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 34c:	8b 45 10             	mov    0x10(%ebp),%eax
 34f:	50                   	push   %eax
 350:	ff 75 0c             	push   0xc(%ebp)
 353:	ff 75 08             	push   0x8(%ebp)
 356:	e8 32 ff ff ff       	call   28d <stosb>
 35b:	83 c4 0c             	add    $0xc,%esp
  return dst;
 35e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 361:	c9                   	leave  
 362:	c3                   	ret    

00000363 <strchr>:

char*
strchr(const char *s, char c)
{
 363:	55                   	push   %ebp
 364:	89 e5                	mov    %esp,%ebp
 366:	83 ec 04             	sub    $0x4,%esp
 369:	8b 45 0c             	mov    0xc(%ebp),%eax
 36c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 36f:	eb 14                	jmp    385 <strchr+0x22>
    if(*s == c)
 371:	8b 45 08             	mov    0x8(%ebp),%eax
 374:	0f b6 00             	movzbl (%eax),%eax
 377:	38 45 fc             	cmp    %al,-0x4(%ebp)
 37a:	75 05                	jne    381 <strchr+0x1e>
      return (char*)s;
 37c:	8b 45 08             	mov    0x8(%ebp),%eax
 37f:	eb 13                	jmp    394 <strchr+0x31>
  for(; *s; s++)
 381:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	0f b6 00             	movzbl (%eax),%eax
 38b:	84 c0                	test   %al,%al
 38d:	75 e2                	jne    371 <strchr+0xe>
  return 0;
 38f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 394:	c9                   	leave  
 395:	c3                   	ret    

00000396 <gets>:

char*
gets(char *buf, int max)
{
 396:	55                   	push   %ebp
 397:	89 e5                	mov    %esp,%ebp
 399:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 39c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3a3:	eb 42                	jmp    3e7 <gets+0x51>
    cc = read(0, &c, 1);
 3a5:	83 ec 04             	sub    $0x4,%esp
 3a8:	6a 01                	push   $0x1
 3aa:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3ad:	50                   	push   %eax
 3ae:	6a 00                	push   $0x0
 3b0:	e8 47 01 00 00       	call   4fc <read>
 3b5:	83 c4 10             	add    $0x10,%esp
 3b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3bf:	7e 33                	jle    3f4 <gets+0x5e>
      break;
    buf[i++] = c;
 3c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c4:	8d 50 01             	lea    0x1(%eax),%edx
 3c7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3ca:	89 c2                	mov    %eax,%edx
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	01 c2                	add    %eax,%edx
 3d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d5:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3d7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3db:	3c 0a                	cmp    $0xa,%al
 3dd:	74 16                	je     3f5 <gets+0x5f>
 3df:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3e3:	3c 0d                	cmp    $0xd,%al
 3e5:	74 0e                	je     3f5 <gets+0x5f>
  for(i=0; i+1 < max; ){
 3e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ea:	83 c0 01             	add    $0x1,%eax
 3ed:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3f0:	7f b3                	jg     3a5 <gets+0xf>
 3f2:	eb 01                	jmp    3f5 <gets+0x5f>
      break;
 3f4:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3f8:	8b 45 08             	mov    0x8(%ebp),%eax
 3fb:	01 d0                	add    %edx,%eax
 3fd:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 400:	8b 45 08             	mov    0x8(%ebp),%eax
}
 403:	c9                   	leave  
 404:	c3                   	ret    

00000405 <stat>:

int
stat(char *n, struct stat *st)
{
 405:	55                   	push   %ebp
 406:	89 e5                	mov    %esp,%ebp
 408:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 40b:	83 ec 08             	sub    $0x8,%esp
 40e:	6a 00                	push   $0x0
 410:	ff 75 08             	push   0x8(%ebp)
 413:	e8 0c 01 00 00       	call   524 <open>
 418:	83 c4 10             	add    $0x10,%esp
 41b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 41e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 422:	79 07                	jns    42b <stat+0x26>
    return -1;
 424:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 429:	eb 25                	jmp    450 <stat+0x4b>
  r = fstat(fd, st);
 42b:	83 ec 08             	sub    $0x8,%esp
 42e:	ff 75 0c             	push   0xc(%ebp)
 431:	ff 75 f4             	push   -0xc(%ebp)
 434:	e8 03 01 00 00       	call   53c <fstat>
 439:	83 c4 10             	add    $0x10,%esp
 43c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 43f:	83 ec 0c             	sub    $0xc,%esp
 442:	ff 75 f4             	push   -0xc(%ebp)
 445:	e8 c2 00 00 00       	call   50c <close>
 44a:	83 c4 10             	add    $0x10,%esp
  return r;
 44d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 450:	c9                   	leave  
 451:	c3                   	ret    

00000452 <atoi>:

int
atoi(const char *s)
{
 452:	55                   	push   %ebp
 453:	89 e5                	mov    %esp,%ebp
 455:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 458:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 45f:	eb 25                	jmp    486 <atoi+0x34>
    n = n*10 + *s++ - '0';
 461:	8b 55 fc             	mov    -0x4(%ebp),%edx
 464:	89 d0                	mov    %edx,%eax
 466:	c1 e0 02             	shl    $0x2,%eax
 469:	01 d0                	add    %edx,%eax
 46b:	01 c0                	add    %eax,%eax
 46d:	89 c1                	mov    %eax,%ecx
 46f:	8b 45 08             	mov    0x8(%ebp),%eax
 472:	8d 50 01             	lea    0x1(%eax),%edx
 475:	89 55 08             	mov    %edx,0x8(%ebp)
 478:	0f b6 00             	movzbl (%eax),%eax
 47b:	0f be c0             	movsbl %al,%eax
 47e:	01 c8                	add    %ecx,%eax
 480:	83 e8 30             	sub    $0x30,%eax
 483:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 486:	8b 45 08             	mov    0x8(%ebp),%eax
 489:	0f b6 00             	movzbl (%eax),%eax
 48c:	3c 2f                	cmp    $0x2f,%al
 48e:	7e 0a                	jle    49a <atoi+0x48>
 490:	8b 45 08             	mov    0x8(%ebp),%eax
 493:	0f b6 00             	movzbl (%eax),%eax
 496:	3c 39                	cmp    $0x39,%al
 498:	7e c7                	jle    461 <atoi+0xf>
  return n;
 49a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 49d:	c9                   	leave  
 49e:	c3                   	ret    

0000049f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 49f:	55                   	push   %ebp
 4a0:	89 e5                	mov    %esp,%ebp
 4a2:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4a5:	8b 45 08             	mov    0x8(%ebp),%eax
 4a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ae:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4b1:	eb 17                	jmp    4ca <memmove+0x2b>
    *dst++ = *src++;
 4b3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4b6:	8d 42 01             	lea    0x1(%edx),%eax
 4b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4bf:	8d 48 01             	lea    0x1(%eax),%ecx
 4c2:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4c5:	0f b6 12             	movzbl (%edx),%edx
 4c8:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4ca:	8b 45 10             	mov    0x10(%ebp),%eax
 4cd:	8d 50 ff             	lea    -0x1(%eax),%edx
 4d0:	89 55 10             	mov    %edx,0x10(%ebp)
 4d3:	85 c0                	test   %eax,%eax
 4d5:	7f dc                	jg     4b3 <memmove+0x14>
  return vdst;
 4d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4da:	c9                   	leave  
 4db:	c3                   	ret    

000004dc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4dc:	b8 01 00 00 00       	mov    $0x1,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <exit>:
SYSCALL(exit)
 4e4:	b8 02 00 00 00       	mov    $0x2,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <wait>:
SYSCALL(wait)
 4ec:	b8 03 00 00 00       	mov    $0x3,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <pipe>:
SYSCALL(pipe)
 4f4:	b8 04 00 00 00       	mov    $0x4,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <read>:
SYSCALL(read)
 4fc:	b8 05 00 00 00       	mov    $0x5,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <write>:
SYSCALL(write)
 504:	b8 10 00 00 00       	mov    $0x10,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <close>:
SYSCALL(close)
 50c:	b8 15 00 00 00       	mov    $0x15,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <kill>:
SYSCALL(kill)
 514:	b8 06 00 00 00       	mov    $0x6,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <exec>:
SYSCALL(exec)
 51c:	b8 07 00 00 00       	mov    $0x7,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <open>:
SYSCALL(open)
 524:	b8 0f 00 00 00       	mov    $0xf,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <mknod>:
SYSCALL(mknod)
 52c:	b8 11 00 00 00       	mov    $0x11,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <unlink>:
SYSCALL(unlink)
 534:	b8 12 00 00 00       	mov    $0x12,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <fstat>:
SYSCALL(fstat)
 53c:	b8 08 00 00 00       	mov    $0x8,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <link>:
SYSCALL(link)
 544:	b8 13 00 00 00       	mov    $0x13,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <mkdir>:
SYSCALL(mkdir)
 54c:	b8 14 00 00 00       	mov    $0x14,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <chdir>:
SYSCALL(chdir)
 554:	b8 09 00 00 00       	mov    $0x9,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <dup>:
SYSCALL(dup)
 55c:	b8 0a 00 00 00       	mov    $0xa,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <getpid>:
SYSCALL(getpid)
 564:	b8 0b 00 00 00       	mov    $0xb,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <sbrk>:
SYSCALL(sbrk)
 56c:	b8 0c 00 00 00       	mov    $0xc,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <sleep>:
SYSCALL(sleep)
 574:	b8 0d 00 00 00       	mov    $0xd,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <uptime>:
SYSCALL(uptime)
 57c:	b8 0e 00 00 00       	mov    $0xe,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <uthread_init>:
SYSCALL(uthread_init)
 584:	b8 16 00 00 00       	mov    $0x16,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 58c:	55                   	push   %ebp
 58d:	89 e5                	mov    %esp,%ebp
 58f:	83 ec 18             	sub    $0x18,%esp
 592:	8b 45 0c             	mov    0xc(%ebp),%eax
 595:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 598:	83 ec 04             	sub    $0x4,%esp
 59b:	6a 01                	push   $0x1
 59d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5a0:	50                   	push   %eax
 5a1:	ff 75 08             	push   0x8(%ebp)
 5a4:	e8 5b ff ff ff       	call   504 <write>
 5a9:	83 c4 10             	add    $0x10,%esp
}
 5ac:	90                   	nop
 5ad:	c9                   	leave  
 5ae:	c3                   	ret    

000005af <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5af:	55                   	push   %ebp
 5b0:	89 e5                	mov    %esp,%ebp
 5b2:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5bc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5c0:	74 17                	je     5d9 <printint+0x2a>
 5c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5c6:	79 11                	jns    5d9 <printint+0x2a>
    neg = 1;
 5c8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d2:	f7 d8                	neg    %eax
 5d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d7:	eb 06                	jmp    5df <printint+0x30>
  } else {
    x = xx;
 5d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 5dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ec:	ba 00 00 00 00       	mov    $0x0,%edx
 5f1:	f7 f1                	div    %ecx
 5f3:	89 d1                	mov    %edx,%ecx
 5f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f8:	8d 50 01             	lea    0x1(%eax),%edx
 5fb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5fe:	0f b6 91 74 0d 00 00 	movzbl 0xd74(%ecx),%edx
 605:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 609:	8b 4d 10             	mov    0x10(%ebp),%ecx
 60c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 60f:	ba 00 00 00 00       	mov    $0x0,%edx
 614:	f7 f1                	div    %ecx
 616:	89 45 ec             	mov    %eax,-0x14(%ebp)
 619:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 61d:	75 c7                	jne    5e6 <printint+0x37>
  if(neg)
 61f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 623:	74 2d                	je     652 <printint+0xa3>
    buf[i++] = '-';
 625:	8b 45 f4             	mov    -0xc(%ebp),%eax
 628:	8d 50 01             	lea    0x1(%eax),%edx
 62b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 62e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 633:	eb 1d                	jmp    652 <printint+0xa3>
    putc(fd, buf[i]);
 635:	8d 55 dc             	lea    -0x24(%ebp),%edx
 638:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63b:	01 d0                	add    %edx,%eax
 63d:	0f b6 00             	movzbl (%eax),%eax
 640:	0f be c0             	movsbl %al,%eax
 643:	83 ec 08             	sub    $0x8,%esp
 646:	50                   	push   %eax
 647:	ff 75 08             	push   0x8(%ebp)
 64a:	e8 3d ff ff ff       	call   58c <putc>
 64f:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 652:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 656:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 65a:	79 d9                	jns    635 <printint+0x86>
}
 65c:	90                   	nop
 65d:	90                   	nop
 65e:	c9                   	leave  
 65f:	c3                   	ret    

00000660 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 660:	55                   	push   %ebp
 661:	89 e5                	mov    %esp,%ebp
 663:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 666:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 66d:	8d 45 0c             	lea    0xc(%ebp),%eax
 670:	83 c0 04             	add    $0x4,%eax
 673:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 676:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 67d:	e9 59 01 00 00       	jmp    7db <printf+0x17b>
    c = fmt[i] & 0xff;
 682:	8b 55 0c             	mov    0xc(%ebp),%edx
 685:	8b 45 f0             	mov    -0x10(%ebp),%eax
 688:	01 d0                	add    %edx,%eax
 68a:	0f b6 00             	movzbl (%eax),%eax
 68d:	0f be c0             	movsbl %al,%eax
 690:	25 ff 00 00 00       	and    $0xff,%eax
 695:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 698:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 69c:	75 2c                	jne    6ca <printf+0x6a>
      if(c == '%'){
 69e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6a2:	75 0c                	jne    6b0 <printf+0x50>
        state = '%';
 6a4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6ab:	e9 27 01 00 00       	jmp    7d7 <printf+0x177>
      } else {
        putc(fd, c);
 6b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b3:	0f be c0             	movsbl %al,%eax
 6b6:	83 ec 08             	sub    $0x8,%esp
 6b9:	50                   	push   %eax
 6ba:	ff 75 08             	push   0x8(%ebp)
 6bd:	e8 ca fe ff ff       	call   58c <putc>
 6c2:	83 c4 10             	add    $0x10,%esp
 6c5:	e9 0d 01 00 00       	jmp    7d7 <printf+0x177>
      }
    } else if(state == '%'){
 6ca:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ce:	0f 85 03 01 00 00    	jne    7d7 <printf+0x177>
      if(c == 'd'){
 6d4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6d8:	75 1e                	jne    6f8 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6dd:	8b 00                	mov    (%eax),%eax
 6df:	6a 01                	push   $0x1
 6e1:	6a 0a                	push   $0xa
 6e3:	50                   	push   %eax
 6e4:	ff 75 08             	push   0x8(%ebp)
 6e7:	e8 c3 fe ff ff       	call   5af <printint>
 6ec:	83 c4 10             	add    $0x10,%esp
        ap++;
 6ef:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f3:	e9 d8 00 00 00       	jmp    7d0 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6f8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6fc:	74 06                	je     704 <printf+0xa4>
 6fe:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 702:	75 1e                	jne    722 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 704:	8b 45 e8             	mov    -0x18(%ebp),%eax
 707:	8b 00                	mov    (%eax),%eax
 709:	6a 00                	push   $0x0
 70b:	6a 10                	push   $0x10
 70d:	50                   	push   %eax
 70e:	ff 75 08             	push   0x8(%ebp)
 711:	e8 99 fe ff ff       	call   5af <printint>
 716:	83 c4 10             	add    $0x10,%esp
        ap++;
 719:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 71d:	e9 ae 00 00 00       	jmp    7d0 <printf+0x170>
      } else if(c == 's'){
 722:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 726:	75 43                	jne    76b <printf+0x10b>
        s = (char*)*ap;
 728:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72b:	8b 00                	mov    (%eax),%eax
 72d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 730:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 734:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 738:	75 25                	jne    75f <printf+0xff>
          s = "(null)";
 73a:	c7 45 f4 a2 0a 00 00 	movl   $0xaa2,-0xc(%ebp)
        while(*s != 0){
 741:	eb 1c                	jmp    75f <printf+0xff>
          putc(fd, *s);
 743:	8b 45 f4             	mov    -0xc(%ebp),%eax
 746:	0f b6 00             	movzbl (%eax),%eax
 749:	0f be c0             	movsbl %al,%eax
 74c:	83 ec 08             	sub    $0x8,%esp
 74f:	50                   	push   %eax
 750:	ff 75 08             	push   0x8(%ebp)
 753:	e8 34 fe ff ff       	call   58c <putc>
 758:	83 c4 10             	add    $0x10,%esp
          s++;
 75b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 75f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 762:	0f b6 00             	movzbl (%eax),%eax
 765:	84 c0                	test   %al,%al
 767:	75 da                	jne    743 <printf+0xe3>
 769:	eb 65                	jmp    7d0 <printf+0x170>
        }
      } else if(c == 'c'){
 76b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 76f:	75 1d                	jne    78e <printf+0x12e>
        putc(fd, *ap);
 771:	8b 45 e8             	mov    -0x18(%ebp),%eax
 774:	8b 00                	mov    (%eax),%eax
 776:	0f be c0             	movsbl %al,%eax
 779:	83 ec 08             	sub    $0x8,%esp
 77c:	50                   	push   %eax
 77d:	ff 75 08             	push   0x8(%ebp)
 780:	e8 07 fe ff ff       	call   58c <putc>
 785:	83 c4 10             	add    $0x10,%esp
        ap++;
 788:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 78c:	eb 42                	jmp    7d0 <printf+0x170>
      } else if(c == '%'){
 78e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 792:	75 17                	jne    7ab <printf+0x14b>
        putc(fd, c);
 794:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 797:	0f be c0             	movsbl %al,%eax
 79a:	83 ec 08             	sub    $0x8,%esp
 79d:	50                   	push   %eax
 79e:	ff 75 08             	push   0x8(%ebp)
 7a1:	e8 e6 fd ff ff       	call   58c <putc>
 7a6:	83 c4 10             	add    $0x10,%esp
 7a9:	eb 25                	jmp    7d0 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7ab:	83 ec 08             	sub    $0x8,%esp
 7ae:	6a 25                	push   $0x25
 7b0:	ff 75 08             	push   0x8(%ebp)
 7b3:	e8 d4 fd ff ff       	call   58c <putc>
 7b8:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7be:	0f be c0             	movsbl %al,%eax
 7c1:	83 ec 08             	sub    $0x8,%esp
 7c4:	50                   	push   %eax
 7c5:	ff 75 08             	push   0x8(%ebp)
 7c8:	e8 bf fd ff ff       	call   58c <putc>
 7cd:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7d0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7d7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7db:	8b 55 0c             	mov    0xc(%ebp),%edx
 7de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e1:	01 d0                	add    %edx,%eax
 7e3:	0f b6 00             	movzbl (%eax),%eax
 7e6:	84 c0                	test   %al,%al
 7e8:	0f 85 94 fe ff ff    	jne    682 <printf+0x22>
    }
  }
}
 7ee:	90                   	nop
 7ef:	90                   	nop
 7f0:	c9                   	leave  
 7f1:	c3                   	ret    

000007f2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f2:	55                   	push   %ebp
 7f3:	89 e5                	mov    %esp,%ebp
 7f5:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f8:	8b 45 08             	mov    0x8(%ebp),%eax
 7fb:	83 e8 08             	sub    $0x8,%eax
 7fe:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 801:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 806:	89 45 fc             	mov    %eax,-0x4(%ebp)
 809:	eb 24                	jmp    82f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80e:	8b 00                	mov    (%eax),%eax
 810:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 813:	72 12                	jb     827 <free+0x35>
 815:	8b 45 f8             	mov    -0x8(%ebp),%eax
 818:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 81b:	77 24                	ja     841 <free+0x4f>
 81d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 825:	72 1a                	jb     841 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 827:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82a:	8b 00                	mov    (%eax),%eax
 82c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 835:	76 d4                	jbe    80b <free+0x19>
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	8b 00                	mov    (%eax),%eax
 83c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 83f:	73 ca                	jae    80b <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 841:	8b 45 f8             	mov    -0x8(%ebp),%eax
 844:	8b 40 04             	mov    0x4(%eax),%eax
 847:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 84e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 851:	01 c2                	add    %eax,%edx
 853:	8b 45 fc             	mov    -0x4(%ebp),%eax
 856:	8b 00                	mov    (%eax),%eax
 858:	39 c2                	cmp    %eax,%edx
 85a:	75 24                	jne    880 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 85c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85f:	8b 50 04             	mov    0x4(%eax),%edx
 862:	8b 45 fc             	mov    -0x4(%ebp),%eax
 865:	8b 00                	mov    (%eax),%eax
 867:	8b 40 04             	mov    0x4(%eax),%eax
 86a:	01 c2                	add    %eax,%edx
 86c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	8b 00                	mov    (%eax),%eax
 877:	8b 10                	mov    (%eax),%edx
 879:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87c:	89 10                	mov    %edx,(%eax)
 87e:	eb 0a                	jmp    88a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 880:	8b 45 fc             	mov    -0x4(%ebp),%eax
 883:	8b 10                	mov    (%eax),%edx
 885:	8b 45 f8             	mov    -0x8(%ebp),%eax
 888:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 88a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88d:	8b 40 04             	mov    0x4(%eax),%eax
 890:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 897:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89a:	01 d0                	add    %edx,%eax
 89c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 89f:	75 20                	jne    8c1 <free+0xcf>
    p->s.size += bp->s.size;
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	8b 50 04             	mov    0x4(%eax),%edx
 8a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8aa:	8b 40 04             	mov    0x4(%eax),%eax
 8ad:	01 c2                	add    %eax,%edx
 8af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b8:	8b 10                	mov    (%eax),%edx
 8ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bd:	89 10                	mov    %edx,(%eax)
 8bf:	eb 08                	jmp    8c9 <free+0xd7>
  } else
    p->s.ptr = bp;
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8c7:	89 10                	mov    %edx,(%eax)
  freep = p;
 8c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cc:	a3 e8 8d 00 00       	mov    %eax,0x8de8
}
 8d1:	90                   	nop
 8d2:	c9                   	leave  
 8d3:	c3                   	ret    

000008d4 <morecore>:

static Header*
morecore(uint nu)
{
 8d4:	55                   	push   %ebp
 8d5:	89 e5                	mov    %esp,%ebp
 8d7:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8da:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8e1:	77 07                	ja     8ea <morecore+0x16>
    nu = 4096;
 8e3:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8ea:	8b 45 08             	mov    0x8(%ebp),%eax
 8ed:	c1 e0 03             	shl    $0x3,%eax
 8f0:	83 ec 0c             	sub    $0xc,%esp
 8f3:	50                   	push   %eax
 8f4:	e8 73 fc ff ff       	call   56c <sbrk>
 8f9:	83 c4 10             	add    $0x10,%esp
 8fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8ff:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 903:	75 07                	jne    90c <morecore+0x38>
    return 0;
 905:	b8 00 00 00 00       	mov    $0x0,%eax
 90a:	eb 26                	jmp    932 <morecore+0x5e>
  hp = (Header*)p;
 90c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 912:	8b 45 f0             	mov    -0x10(%ebp),%eax
 915:	8b 55 08             	mov    0x8(%ebp),%edx
 918:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 91b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91e:	83 c0 08             	add    $0x8,%eax
 921:	83 ec 0c             	sub    $0xc,%esp
 924:	50                   	push   %eax
 925:	e8 c8 fe ff ff       	call   7f2 <free>
 92a:	83 c4 10             	add    $0x10,%esp
  return freep;
 92d:	a1 e8 8d 00 00       	mov    0x8de8,%eax
}
 932:	c9                   	leave  
 933:	c3                   	ret    

00000934 <malloc>:

void*
malloc(uint nbytes)
{
 934:	55                   	push   %ebp
 935:	89 e5                	mov    %esp,%ebp
 937:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 93a:	8b 45 08             	mov    0x8(%ebp),%eax
 93d:	83 c0 07             	add    $0x7,%eax
 940:	c1 e8 03             	shr    $0x3,%eax
 943:	83 c0 01             	add    $0x1,%eax
 946:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 949:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 94e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 951:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 955:	75 23                	jne    97a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 957:	c7 45 f0 e0 8d 00 00 	movl   $0x8de0,-0x10(%ebp)
 95e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 961:	a3 e8 8d 00 00       	mov    %eax,0x8de8
 966:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 96b:	a3 e0 8d 00 00       	mov    %eax,0x8de0
    base.s.size = 0;
 970:	c7 05 e4 8d 00 00 00 	movl   $0x0,0x8de4
 977:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97d:	8b 00                	mov    (%eax),%eax
 97f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 982:	8b 45 f4             	mov    -0xc(%ebp),%eax
 985:	8b 40 04             	mov    0x4(%eax),%eax
 988:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 98b:	77 4d                	ja     9da <malloc+0xa6>
      if(p->s.size == nunits)
 98d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 990:	8b 40 04             	mov    0x4(%eax),%eax
 993:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 996:	75 0c                	jne    9a4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 998:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99b:	8b 10                	mov    (%eax),%edx
 99d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a0:	89 10                	mov    %edx,(%eax)
 9a2:	eb 26                	jmp    9ca <malloc+0x96>
      else {
        p->s.size -= nunits;
 9a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a7:	8b 40 04             	mov    0x4(%eax),%eax
 9aa:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9ad:	89 c2                	mov    %eax,%edx
 9af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b8:	8b 40 04             	mov    0x4(%eax),%eax
 9bb:	c1 e0 03             	shl    $0x3,%eax
 9be:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9c7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cd:	a3 e8 8d 00 00       	mov    %eax,0x8de8
      return (void*)(p + 1);
 9d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d5:	83 c0 08             	add    $0x8,%eax
 9d8:	eb 3b                	jmp    a15 <malloc+0xe1>
    }
    if(p == freep)
 9da:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 9df:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9e2:	75 1e                	jne    a02 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9e4:	83 ec 0c             	sub    $0xc,%esp
 9e7:	ff 75 ec             	push   -0x14(%ebp)
 9ea:	e8 e5 fe ff ff       	call   8d4 <morecore>
 9ef:	83 c4 10             	add    $0x10,%esp
 9f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9f9:	75 07                	jne    a02 <malloc+0xce>
        return 0;
 9fb:	b8 00 00 00 00       	mov    $0x0,%eax
 a00:	eb 13                	jmp    a15 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a05:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0b:	8b 00                	mov    (%eax),%eax
 a0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a10:	e9 6d ff ff ff       	jmp    982 <malloc+0x4e>
  }
}
 a15:	c9                   	leave  
 a16:	c3                   	ret    
