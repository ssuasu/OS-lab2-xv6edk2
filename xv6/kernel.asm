
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc b0 b0 11 80       	mov    $0x8011b0b0,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 49 38 10 80       	mov    $0x80103849,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 c0 a3 10 80       	push   $0x8010a3c0
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 42 4b 00 00       	call   80104bc0 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 47 11 80 fc 	movl   $0x801146fc,0x8011474c
80100088:	46 11 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 47 11 80 fc 	movl   $0x801146fc,0x80114750
80100092:	46 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 00 11 80 	movl   $0x80110034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 47 11 80    	mov    0x80114750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 c7 a3 10 80       	push   $0x8010a3c7
801000c2:	50                   	push   %eax
801000c3:	e8 9b 49 00 00       	call   80104a63 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 47 11 80       	mov    0x80114750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 47 11 80       	mov    %eax,0x80114750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 46 11 80       	mov    $0x801146fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 00 11 80       	push   $0x80110000
80100101:	e8 dc 4a 00 00       	call   80104be2 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 47 11 80       	mov    0x80114750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 00 11 80       	push   $0x80110000
80100140:	e8 0b 4b 00 00       	call   80104c50 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 48 49 00 00       	call   80104a9f <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 47 11 80       	mov    0x8011474c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 00 11 80       	push   $0x80110000
801001c1:	e8 8a 4a 00 00       	call   80104c50 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 c7 48 00 00       	call   80104a9f <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 ce a3 10 80       	push   $0x8010a3ce
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 f9 26 00 00       	call   8010292b <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 02 49 00 00       	call   80104b51 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 df a3 10 80       	push   $0x8010a3df
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 ae 26 00 00       	call   8010292b <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 b9 48 00 00       	call   80104b51 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 e6 a3 10 80       	push   $0x8010a3e6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 48 48 00 00       	call   80104b03 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 17 49 00 00       	call   80104be2 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 47 11 80    	mov    0x80114750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 47 11 80       	mov    0x80114750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 47 11 80       	mov    %eax,0x80114750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 00 11 80       	push   $0x80110000
80100336:	e8 15 49 00 00       	call   80104c50 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 4a 11 80       	mov    0x80114a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 4a 11 80       	push   $0x80114a00
80100410:	e8 cd 47 00 00       	call   80104be2 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ed a3 10 80       	push   $0x8010a3ed
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec f6 a3 10 80 	movl   $0x8010a3f6,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 4a 11 80       	push   $0x80114a00
8010059e:	e8 ad 46 00 00       	call   80104c50 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 4a 11 80 00 	movl   $0x0,0x80114a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 1b 2a 00 00       	call   80102fde <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 fd a3 10 80       	push   $0x8010a3fd
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 11 a4 10 80       	push   $0x8010a411
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 9f 46 00 00       	call   80104ca2 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 13 a4 10 80       	push   $0x8010a413
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 49 11 80 01 	movl   $0x1,0x801149ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 90 7c 00 00       	call   80108335 <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 3d 7c 00 00       	call   80108335 <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 44 7c 00 00       	call   801083a0 <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 49 11 80       	mov    0x801149ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 14 60 00 00       	call   801067ac <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 07 60 00 00       	call   801067ac <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 fa 5f 00 00       	call   801067ac <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 ea 5f 00 00       	call   801067ac <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 4a 11 80       	push   $0x80114a00
801007eb:	e8 f2 43 00 00       	call   80104be2 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
8010085b:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100889:	a1 e4 49 11 80       	mov    0x801149e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008c7:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 49 11 80    	mov    %edx,0x801149e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 49 11 80    	mov    %dl,-0x7feeb6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100920:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100932:	a3 e4 49 11 80       	mov    %eax,0x801149e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 49 11 80       	push   $0x801149e0
8010093f:	e8 6a 3f 00 00       	call   801048ae <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 4a 11 80       	push   $0x80114a00
80100962:	e8 e9 42 00 00       	call   80104c50 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 f4 3f 00 00       	call   80104969 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 4a 11 80       	push   $0x80114a00
8010099a:	e8 43 42 00 00       	call   80104be2 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 68 35 00 00       	call   80103f14 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 4a 11 80       	push   $0x80114a00
801009bb:	e8 90 42 00 00       	call   80104c50 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 4a 11 80       	push   $0x80114a00
801009e3:	68 e0 49 11 80       	push   $0x801149e0
801009e8:	e8 da 3d 00 00       	call   801047c7 <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801009f6:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 49 11 80    	mov    %edx,0x801149e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 49 11 80       	mov    %eax,0x801149e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 4a 11 80       	push   $0x80114a00
80100a66:	e8 e5 41 00 00       	call   80104c50 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 4a 11 80       	push   $0x80114a00
80100aa2:	e8 3b 41 00 00       	call   80104be2 <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 4a 11 80       	push   $0x80114a00
80100ae4:	e8 67 41 00 00       	call   80104c50 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 49 11 80 00 	movl   $0x0,0x801149ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 17 a4 10 80       	push   $0x8010a417
80100b17:	68 00 4a 11 80       	push   $0x80114a00
80100b1c:	e8 9f 40 00 00       	call   80104bc0 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 4a 11 80 86 	movl   $0x80100a86,0x80114a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 4a 11 80 78 	movl   $0x80100978,0x80114a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 1f a4 10 80 	movl   $0x8010a41f,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 4a 11 80 01 	movl   $0x1,0x80114a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 98 1f 00 00       	call   80102b12 <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 86 33 00 00       	call   80103f14 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 8a 29 00 00       	call   80103520 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 fa 29 00 00       	call   801035ac <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 35 a4 10 80       	push   $0x8010a435
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 92 6b 00 00       	call   801077a8 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 e5 6e 00 00       	call   80107ba1 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 d2 6d 00 00       	call   80107ad4 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 69 28 00 00       	call   801035ac <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 30 6e 00 00       	call   80107ba1 <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 6e 70 00 00       	call   80107e03 <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 d8 42 00 00       	call   801050a6 <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 ab 42 00 00       	call   801050a6 <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 81 71 00 00       	call   80107fa2 <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 e5 70 00 00       	call   80107fa2 <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 6c             	add    $0x6c,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 50 41 00 00       	call   8010505b <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 77 69 00 00       	call   801078c5 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 0e 6e 00 00       	call   80107d6a <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 ce 6d 00 00       	call   80107d6a <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 f4 25 00 00       	call   801035ac <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 41 a4 10 80       	push   $0x8010a441
80100fcd:	68 a0 4a 11 80       	push   $0x80114aa0
80100fd2:	e8 e9 3b 00 00       	call   80104bc0 <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 4a 11 80       	push   $0x80114aa0
80100feb:	e8 f2 3b 00 00       	call   80104be2 <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 4a 11 80 	movl   $0x80114ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 4a 11 80       	push   $0x80114aa0
80101018:	e8 33 3c 00 00       	call   80104c50 <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 54 11 80       	mov    $0x80115434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 4a 11 80       	push   $0x80114aa0
8010103b:	e8 10 3c 00 00       	call   80104c50 <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 4a 11 80       	push   $0x80114aa0
80101058:	e8 85 3b 00 00       	call   80104be2 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 48 a4 10 80       	push   $0x8010a448
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 4a 11 80       	push   $0x80114aa0
8010108e:	e8 bd 3b 00 00       	call   80104c50 <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 4a 11 80       	push   $0x80114aa0
801010a9:	e8 34 3b 00 00       	call   80104be2 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 50 a4 10 80       	push   $0x8010a450
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 4a 11 80       	push   $0x80114aa0
801010e9:	e8 62 3b 00 00       	call   80104c50 <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 4a 11 80       	push   $0x80114aa0
80101137:	e8 14 3b 00 00       	call   80104c50 <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 48 2a 00 00       	call   80103ba3 <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 b3 23 00 00       	call   80103520 <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 2b 24 00 00       	call   801035ac <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 3c 2b 00 00       	call   80103d50 <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 5a a4 10 80       	push   $0x8010a45a
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 81 29 00 00       	call   80103c4e <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 0e 22 00 00       	call   80103520 <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 34 22 00 00       	call   801035ac <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 63 a4 10 80       	push   $0x8010a463
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 73 a4 10 80       	push   $0x8010a473
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 1b 3b 00 00       	call   80104f17 <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 16 3a 00 00       	call   80104e58 <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 09 23 00 00       	call   80103759 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 54 11 80       	mov    0x80115458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 3d 22 00 00       	call   80103759 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 54 11 80       	mov    0x80115440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 54 11 80    	mov    0x80115440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 80 a4 10 80       	push   $0x8010a480
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 54 11 80       	push   $0x80115440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 54 11 80       	mov    0x80115458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 96 a4 10 80       	push   $0x8010a496
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 f5 20 00 00       	call   80103759 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 a9 a4 10 80       	push   $0x8010a4a9
80101690:	68 60 54 11 80       	push   $0x80115460
80101695:	e8 26 35 00 00       	call   80104bc0 <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 54 11 80       	add    $0x80115460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 b0 a4 10 80       	push   $0x8010a4b0
801016c6:	50                   	push   %eax
801016c7:	e8 97 33 00 00       	call   80104a63 <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 54 11 80       	push   $0x80115440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 54 11 80       	mov    0x80115458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 54 11 80    	mov    0x80115454,%edi
801016fa:	8b 35 50 54 11 80    	mov    0x80115450,%esi
80101700:	8b 1d 4c 54 11 80    	mov    0x8011544c,%ebx
80101706:	8b 0d 48 54 11 80    	mov    0x80115448,%ecx
8010170c:	8b 15 44 54 11 80    	mov    0x80115444,%edx
80101712:	a1 40 54 11 80       	mov    0x80115440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 b8 a4 10 80       	push   $0x8010a4b8
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 54 11 80       	mov    0x80115454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 ba 36 00 00       	call   80104e58 <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 a3 1f 00 00       	call   80103759 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 54 11 80    	mov    0x80115448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 0b a5 10 80       	push   $0x8010a50b
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 54 11 80       	mov    0x80115454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 6b 36 00 00       	call   80104f17 <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 9f 1e 00 00       	call   80103759 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 54 11 80       	push   $0x80115460
801018dc:	e8 01 33 00 00       	call   80104be2 <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 54 11 80 	movl   $0x80115494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 54 11 80       	push   $0x80115460
8010192a:	e8 21 33 00 00       	call   80104c50 <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 1d a5 10 80       	push   $0x8010a51d
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 54 11 80       	push   $0x80115460
801019a3:	e8 a8 32 00 00       	call   80104c50 <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 54 11 80       	push   $0x80115460
801019be:	e8 1f 32 00 00       	call   80104be2 <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 54 11 80       	push   $0x80115460
801019dd:	e8 6e 32 00 00       	call   80104c50 <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 2d a5 10 80       	push   $0x8010a52d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 83 30 00 00       	call   80104a9f <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 54 11 80       	mov    0x80115454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 51 34 00 00       	call   80104f17 <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 33 a5 10 80       	push   $0x8010a533
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 39 30 00 00       	call   80104b51 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 42 a5 10 80       	push   $0x8010a542
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 be 2f 00 00       	call   80104b03 <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 3f 2f 00 00       	call   80104a9f <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 54 11 80       	push   $0x80115460
80101b81:	e8 5c 30 00 00       	call   80104be2 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 54 11 80       	push   $0x80115460
80101b9a:	e8 b1 30 00 00       	call   80104c50 <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 1d 2f 00 00       	call   80104b03 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 54 11 80       	push   $0x80115460
80101bf1:	e8 ec 2f 00 00       	call   80104be2 <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 54 11 80       	push   $0x80115460
80101c10:	e8 3b 30 00 00       	call   80104c50 <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 1e 1a 00 00       	call   80103759 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 4a a5 10 80       	push   $0x8010a54a
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 20 2f 00 00       	call   80104f17 <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 d0 2d 00 00       	call   80104f17 <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 04 16 00 00       	call   80103759 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 e6 2d 00 00       	call   80104fad <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 5d a5 10 80       	push   $0x8010a55d
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 6f a5 10 80       	push   $0x8010a56f
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 7e a5 10 80       	push   $0x8010a57e
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 dd 2c 00 00       	call   80105003 <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 8b a5 10 80       	push   $0x8010a58b
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 53 2b 00 00       	call   80104f17 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 3c 2b 00 00       	call   80104f17 <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 ea 1a 00 00       	call   80103f14 <myproc>
8010242a:	8b 40 68             	mov    0x68(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <inb>:
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
80102557:	83 ec 14             	sub    $0x14,%esp
8010255a:	8b 45 08             	mov    0x8(%ebp),%eax
8010255d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102561:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102565:	89 c2                	mov    %eax,%edx
80102567:	ec                   	in     (%dx),%al
80102568:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010256b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010256f:	c9                   	leave  
80102570:	c3                   	ret    

80102571 <insl>:
{
80102571:	55                   	push   %ebp
80102572:	89 e5                	mov    %esp,%ebp
80102574:	57                   	push   %edi
80102575:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102576:	8b 55 08             	mov    0x8(%ebp),%edx
80102579:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010257c:	8b 45 10             	mov    0x10(%ebp),%eax
8010257f:	89 cb                	mov    %ecx,%ebx
80102581:	89 df                	mov    %ebx,%edi
80102583:	89 c1                	mov    %eax,%ecx
80102585:	fc                   	cld    
80102586:	f3 6d                	rep insl (%dx),%es:(%edi)
80102588:	89 c8                	mov    %ecx,%eax
8010258a:	89 fb                	mov    %edi,%ebx
8010258c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010258f:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102592:	90                   	nop
80102593:	5b                   	pop    %ebx
80102594:	5f                   	pop    %edi
80102595:	5d                   	pop    %ebp
80102596:	c3                   	ret    

80102597 <outb>:
{
80102597:	55                   	push   %ebp
80102598:	89 e5                	mov    %esp,%ebp
8010259a:	83 ec 08             	sub    $0x8,%esp
8010259d:	8b 45 08             	mov    0x8(%ebp),%eax
801025a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801025a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025a7:	89 d0                	mov    %edx,%eax
801025a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025b4:	ee                   	out    %al,(%dx)
}
801025b5:	90                   	nop
801025b6:	c9                   	leave  
801025b7:	c3                   	ret    

801025b8 <outsl>:
{
801025b8:	55                   	push   %ebp
801025b9:	89 e5                	mov    %esp,%ebp
801025bb:	56                   	push   %esi
801025bc:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025bd:	8b 55 08             	mov    0x8(%ebp),%edx
801025c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025c3:	8b 45 10             	mov    0x10(%ebp),%eax
801025c6:	89 cb                	mov    %ecx,%ebx
801025c8:	89 de                	mov    %ebx,%esi
801025ca:	89 c1                	mov    %eax,%ecx
801025cc:	fc                   	cld    
801025cd:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025cf:	89 c8                	mov    %ecx,%eax
801025d1:	89 f3                	mov    %esi,%ebx
801025d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025d6:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025d9:	90                   	nop
801025da:	5b                   	pop    %ebx
801025db:	5e                   	pop    %esi
801025dc:	5d                   	pop    %ebp
801025dd:	c3                   	ret    

801025de <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025de:	55                   	push   %ebp
801025df:	89 e5                	mov    %esp,%ebp
801025e1:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025e4:	90                   	nop
801025e5:	68 f7 01 00 00       	push   $0x1f7
801025ea:	e8 65 ff ff ff       	call   80102554 <inb>
801025ef:	83 c4 04             	add    $0x4,%esp
801025f2:	0f b6 c0             	movzbl %al,%eax
801025f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025fb:	25 c0 00 00 00       	and    $0xc0,%eax
80102600:	83 f8 40             	cmp    $0x40,%eax
80102603:	75 e0                	jne    801025e5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102605:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102609:	74 11                	je     8010261c <idewait+0x3e>
8010260b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010260e:	83 e0 21             	and    $0x21,%eax
80102611:	85 c0                	test   %eax,%eax
80102613:	74 07                	je     8010261c <idewait+0x3e>
    return -1;
80102615:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010261a:	eb 05                	jmp    80102621 <idewait+0x43>
  return 0;
8010261c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102621:	c9                   	leave  
80102622:	c3                   	ret    

80102623 <ideinit>:

void
ideinit(void)
{
80102623:	55                   	push   %ebp
80102624:	89 e5                	mov    %esp,%ebp
80102626:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102629:	83 ec 08             	sub    $0x8,%esp
8010262c:	68 93 a5 10 80       	push   $0x8010a593
80102631:	68 c0 70 11 80       	push   $0x801170c0
80102636:	e8 85 25 00 00       	call   80104bc0 <initlock>
8010263b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010263e:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80102643:	83 e8 01             	sub    $0x1,%eax
80102646:	83 ec 08             	sub    $0x8,%esp
80102649:	50                   	push   %eax
8010264a:	6a 0e                	push   $0xe
8010264c:	e8 c1 04 00 00       	call   80102b12 <ioapicenable>
80102651:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102654:	83 ec 0c             	sub    $0xc,%esp
80102657:	6a 00                	push   $0x0
80102659:	e8 80 ff ff ff       	call   801025de <idewait>
8010265e:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102661:	83 ec 08             	sub    $0x8,%esp
80102664:	68 f0 00 00 00       	push   $0xf0
80102669:	68 f6 01 00 00       	push   $0x1f6
8010266e:	e8 24 ff ff ff       	call   80102597 <outb>
80102673:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010267d:	eb 24                	jmp    801026a3 <ideinit+0x80>
    if(inb(0x1f7) != 0){
8010267f:	83 ec 0c             	sub    $0xc,%esp
80102682:	68 f7 01 00 00       	push   $0x1f7
80102687:	e8 c8 fe ff ff       	call   80102554 <inb>
8010268c:	83 c4 10             	add    $0x10,%esp
8010268f:	84 c0                	test   %al,%al
80102691:	74 0c                	je     8010269f <ideinit+0x7c>
      havedisk1 = 1;
80102693:	c7 05 f8 70 11 80 01 	movl   $0x1,0x801170f8
8010269a:	00 00 00 
      break;
8010269d:	eb 0d                	jmp    801026ac <ideinit+0x89>
  for(i=0; i<1000; i++){
8010269f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026a3:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026aa:	7e d3                	jle    8010267f <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026ac:	83 ec 08             	sub    $0x8,%esp
801026af:	68 e0 00 00 00       	push   $0xe0
801026b4:	68 f6 01 00 00       	push   $0x1f6
801026b9:	e8 d9 fe ff ff       	call   80102597 <outb>
801026be:	83 c4 10             	add    $0x10,%esp
}
801026c1:	90                   	nop
801026c2:	c9                   	leave  
801026c3:	c3                   	ret    

801026c4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026c4:	55                   	push   %ebp
801026c5:	89 e5                	mov    %esp,%ebp
801026c7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026ce:	75 0d                	jne    801026dd <idestart+0x19>
    panic("idestart");
801026d0:	83 ec 0c             	sub    $0xc,%esp
801026d3:	68 97 a5 10 80       	push   $0x8010a597
801026d8:	e8 cc de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026dd:	8b 45 08             	mov    0x8(%ebp),%eax
801026e0:	8b 40 08             	mov    0x8(%eax),%eax
801026e3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e8:	76 0d                	jbe    801026f7 <idestart+0x33>
    panic("incorrect blockno");
801026ea:	83 ec 0c             	sub    $0xc,%esp
801026ed:	68 a0 a5 10 80       	push   $0x8010a5a0
801026f2:	e8 b2 de ff ff       	call   801005a9 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026f7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801026fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102701:	8b 50 08             	mov    0x8(%eax),%edx
80102704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102707:	0f af c2             	imul   %edx,%eax
8010270a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010270d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102711:	75 07                	jne    8010271a <idestart+0x56>
80102713:	b8 20 00 00 00       	mov    $0x20,%eax
80102718:	eb 05                	jmp    8010271f <idestart+0x5b>
8010271a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010271f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102722:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102726:	75 07                	jne    8010272f <idestart+0x6b>
80102728:	b8 30 00 00 00       	mov    $0x30,%eax
8010272d:	eb 05                	jmp    80102734 <idestart+0x70>
8010272f:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102734:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102737:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010273b:	7e 0d                	jle    8010274a <idestart+0x86>
8010273d:	83 ec 0c             	sub    $0xc,%esp
80102740:	68 97 a5 10 80       	push   $0x8010a597
80102745:	e8 5f de ff ff       	call   801005a9 <panic>

  idewait(0);
8010274a:	83 ec 0c             	sub    $0xc,%esp
8010274d:	6a 00                	push   $0x0
8010274f:	e8 8a fe ff ff       	call   801025de <idewait>
80102754:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	6a 00                	push   $0x0
8010275c:	68 f6 03 00 00       	push   $0x3f6
80102761:	e8 31 fe ff ff       	call   80102597 <outb>
80102766:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276c:	0f b6 c0             	movzbl %al,%eax
8010276f:	83 ec 08             	sub    $0x8,%esp
80102772:	50                   	push   %eax
80102773:	68 f2 01 00 00       	push   $0x1f2
80102778:	e8 1a fe ff ff       	call   80102597 <outb>
8010277d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102783:	0f b6 c0             	movzbl %al,%eax
80102786:	83 ec 08             	sub    $0x8,%esp
80102789:	50                   	push   %eax
8010278a:	68 f3 01 00 00       	push   $0x1f3
8010278f:	e8 03 fe ff ff       	call   80102597 <outb>
80102794:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010279a:	c1 f8 08             	sar    $0x8,%eax
8010279d:	0f b6 c0             	movzbl %al,%eax
801027a0:	83 ec 08             	sub    $0x8,%esp
801027a3:	50                   	push   %eax
801027a4:	68 f4 01 00 00       	push   $0x1f4
801027a9:	e8 e9 fd ff ff       	call   80102597 <outb>
801027ae:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b4:	c1 f8 10             	sar    $0x10,%eax
801027b7:	0f b6 c0             	movzbl %al,%eax
801027ba:	83 ec 08             	sub    $0x8,%esp
801027bd:	50                   	push   %eax
801027be:	68 f5 01 00 00       	push   $0x1f5
801027c3:	e8 cf fd ff ff       	call   80102597 <outb>
801027c8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027cb:	8b 45 08             	mov    0x8(%ebp),%eax
801027ce:	8b 40 04             	mov    0x4(%eax),%eax
801027d1:	c1 e0 04             	shl    $0x4,%eax
801027d4:	83 e0 10             	and    $0x10,%eax
801027d7:	89 c2                	mov    %eax,%edx
801027d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027dc:	c1 f8 18             	sar    $0x18,%eax
801027df:	83 e0 0f             	and    $0xf,%eax
801027e2:	09 d0                	or     %edx,%eax
801027e4:	83 c8 e0             	or     $0xffffffe0,%eax
801027e7:	0f b6 c0             	movzbl %al,%eax
801027ea:	83 ec 08             	sub    $0x8,%esp
801027ed:	50                   	push   %eax
801027ee:	68 f6 01 00 00       	push   $0x1f6
801027f3:	e8 9f fd ff ff       	call   80102597 <outb>
801027f8:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	8b 00                	mov    (%eax),%eax
80102800:	83 e0 04             	and    $0x4,%eax
80102803:	85 c0                	test   %eax,%eax
80102805:	74 35                	je     8010283c <idestart+0x178>
    outb(0x1f7, write_cmd);
80102807:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010280a:	0f b6 c0             	movzbl %al,%eax
8010280d:	83 ec 08             	sub    $0x8,%esp
80102810:	50                   	push   %eax
80102811:	68 f7 01 00 00       	push   $0x1f7
80102816:	e8 7c fd ff ff       	call   80102597 <outb>
8010281b:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010281e:	8b 45 08             	mov    0x8(%ebp),%eax
80102821:	83 c0 5c             	add    $0x5c,%eax
80102824:	83 ec 04             	sub    $0x4,%esp
80102827:	68 80 00 00 00       	push   $0x80
8010282c:	50                   	push   %eax
8010282d:	68 f0 01 00 00       	push   $0x1f0
80102832:	e8 81 fd ff ff       	call   801025b8 <outsl>
80102837:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010283a:	eb 17                	jmp    80102853 <idestart+0x18f>
    outb(0x1f7, read_cmd);
8010283c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010283f:	0f b6 c0             	movzbl %al,%eax
80102842:	83 ec 08             	sub    $0x8,%esp
80102845:	50                   	push   %eax
80102846:	68 f7 01 00 00       	push   $0x1f7
8010284b:	e8 47 fd ff ff       	call   80102597 <outb>
80102850:	83 c4 10             	add    $0x10,%esp
}
80102853:	90                   	nop
80102854:	c9                   	leave  
80102855:	c3                   	ret    

80102856 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102856:	55                   	push   %ebp
80102857:	89 e5                	mov    %esp,%ebp
80102859:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	68 c0 70 11 80       	push   $0x801170c0
80102864:	e8 79 23 00 00       	call   80104be2 <acquire>
80102869:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010286c:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102871:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102874:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102878:	75 15                	jne    8010288f <ideintr+0x39>
    release(&idelock);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 c0 70 11 80       	push   $0x801170c0
80102882:	e8 c9 23 00 00       	call   80104c50 <release>
80102887:	83 c4 10             	add    $0x10,%esp
    return;
8010288a:	e9 9a 00 00 00       	jmp    80102929 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010288f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102892:	8b 40 58             	mov    0x58(%eax),%eax
80102895:	a3 f4 70 11 80       	mov    %eax,0x801170f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010289a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289d:	8b 00                	mov    (%eax),%eax
8010289f:	83 e0 04             	and    $0x4,%eax
801028a2:	85 c0                	test   %eax,%eax
801028a4:	75 2d                	jne    801028d3 <ideintr+0x7d>
801028a6:	83 ec 0c             	sub    $0xc,%esp
801028a9:	6a 01                	push   $0x1
801028ab:	e8 2e fd ff ff       	call   801025de <idewait>
801028b0:	83 c4 10             	add    $0x10,%esp
801028b3:	85 c0                	test   %eax,%eax
801028b5:	78 1c                	js     801028d3 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ba:	83 c0 5c             	add    $0x5c,%eax
801028bd:	83 ec 04             	sub    $0x4,%esp
801028c0:	68 80 00 00 00       	push   $0x80
801028c5:	50                   	push   %eax
801028c6:	68 f0 01 00 00       	push   $0x1f0
801028cb:	e8 a1 fc ff ff       	call   80102571 <insl>
801028d0:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d6:	8b 00                	mov    (%eax),%eax
801028d8:	83 c8 02             	or     $0x2,%eax
801028db:	89 c2                	mov    %eax,%edx
801028dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e0:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e5:	8b 00                	mov    (%eax),%eax
801028e7:	83 e0 fb             	and    $0xfffffffb,%eax
801028ea:	89 c2                	mov    %eax,%edx
801028ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ef:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028f1:	83 ec 0c             	sub    $0xc,%esp
801028f4:	ff 75 f4             	push   -0xc(%ebp)
801028f7:	e8 b2 1f 00 00       	call   801048ae <wakeup>
801028fc:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801028ff:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102904:	85 c0                	test   %eax,%eax
80102906:	74 11                	je     80102919 <ideintr+0xc3>
    idestart(idequeue);
80102908:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010290d:	83 ec 0c             	sub    $0xc,%esp
80102910:	50                   	push   %eax
80102911:	e8 ae fd ff ff       	call   801026c4 <idestart>
80102916:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102919:	83 ec 0c             	sub    $0xc,%esp
8010291c:	68 c0 70 11 80       	push   $0x801170c0
80102921:	e8 2a 23 00 00       	call   80104c50 <release>
80102926:	83 c4 10             	add    $0x10,%esp
}
80102929:	c9                   	leave  
8010292a:	c3                   	ret    

8010292b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010292b:	55                   	push   %ebp
8010292c:	89 e5                	mov    %esp,%ebp
8010292e:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102931:	8b 15 f8 70 11 80    	mov    0x801170f8,%edx
80102937:	8b 45 08             	mov    0x8(%ebp),%eax
8010293a:	8b 40 04             	mov    0x4(%eax),%eax
8010293d:	83 ec 04             	sub    $0x4,%esp
80102940:	52                   	push   %edx
80102941:	50                   	push   %eax
80102942:	68 b2 a5 10 80       	push   $0x8010a5b2
80102947:	e8 a8 da ff ff       	call   801003f4 <cprintf>
8010294c:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	83 c0 0c             	add    $0xc,%eax
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	50                   	push   %eax
80102959:	e8 f3 21 00 00       	call   80104b51 <holdingsleep>
8010295e:	83 c4 10             	add    $0x10,%esp
80102961:	85 c0                	test   %eax,%eax
80102963:	75 0d                	jne    80102972 <iderw+0x47>
    panic("iderw: buf not locked");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 cc a5 10 80       	push   $0x8010a5cc
8010296d:	e8 37 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	8b 00                	mov    (%eax),%eax
80102977:	83 e0 06             	and    $0x6,%eax
8010297a:	83 f8 02             	cmp    $0x2,%eax
8010297d:	75 0d                	jne    8010298c <iderw+0x61>
    panic("iderw: nothing to do");
8010297f:	83 ec 0c             	sub    $0xc,%esp
80102982:	68 e2 a5 10 80       	push   $0x8010a5e2
80102987:	e8 1d dc ff ff       	call   801005a9 <panic>
  if(b->dev != 0 && !havedisk1)
8010298c:	8b 45 08             	mov    0x8(%ebp),%eax
8010298f:	8b 40 04             	mov    0x4(%eax),%eax
80102992:	85 c0                	test   %eax,%eax
80102994:	74 16                	je     801029ac <iderw+0x81>
80102996:	a1 f8 70 11 80       	mov    0x801170f8,%eax
8010299b:	85 c0                	test   %eax,%eax
8010299d:	75 0d                	jne    801029ac <iderw+0x81>
    panic("iderw: ide disk 1 not present");
8010299f:	83 ec 0c             	sub    $0xc,%esp
801029a2:	68 f7 a5 10 80       	push   $0x8010a5f7
801029a7:	e8 fd db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ac:	83 ec 0c             	sub    $0xc,%esp
801029af:	68 c0 70 11 80       	push   $0x801170c0
801029b4:	e8 29 22 00 00       	call   80104be2 <acquire>
801029b9:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029bc:	8b 45 08             	mov    0x8(%ebp),%eax
801029bf:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029c6:	c7 45 f4 f4 70 11 80 	movl   $0x801170f4,-0xc(%ebp)
801029cd:	eb 0b                	jmp    801029da <iderw+0xaf>
801029cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d2:	8b 00                	mov    (%eax),%eax
801029d4:	83 c0 58             	add    $0x58,%eax
801029d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dd:	8b 00                	mov    (%eax),%eax
801029df:	85 c0                	test   %eax,%eax
801029e1:	75 ec                	jne    801029cf <iderw+0xa4>
    ;
  *pp = b;
801029e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e6:	8b 55 08             	mov    0x8(%ebp),%edx
801029e9:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029eb:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801029f0:	39 45 08             	cmp    %eax,0x8(%ebp)
801029f3:	75 23                	jne    80102a18 <iderw+0xed>
    idestart(b);
801029f5:	83 ec 0c             	sub    $0xc,%esp
801029f8:	ff 75 08             	push   0x8(%ebp)
801029fb:	e8 c4 fc ff ff       	call   801026c4 <idestart>
80102a00:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a03:	eb 13                	jmp    80102a18 <iderw+0xed>
    sleep(b, &idelock);
80102a05:	83 ec 08             	sub    $0x8,%esp
80102a08:	68 c0 70 11 80       	push   $0x801170c0
80102a0d:	ff 75 08             	push   0x8(%ebp)
80102a10:	e8 b2 1d 00 00       	call   801047c7 <sleep>
80102a15:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	8b 00                	mov    (%eax),%eax
80102a1d:	83 e0 06             	and    $0x6,%eax
80102a20:	83 f8 02             	cmp    $0x2,%eax
80102a23:	75 e0                	jne    80102a05 <iderw+0xda>
  }


  release(&idelock);
80102a25:	83 ec 0c             	sub    $0xc,%esp
80102a28:	68 c0 70 11 80       	push   $0x801170c0
80102a2d:	e8 1e 22 00 00       	call   80104c50 <release>
80102a32:	83 c4 10             	add    $0x10,%esp
}
80102a35:	90                   	nop
80102a36:	c9                   	leave  
80102a37:	c3                   	ret    

80102a38 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a3b:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a40:	8b 55 08             	mov    0x8(%ebp),%edx
80102a43:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a45:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a4a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a4d:	5d                   	pop    %ebp
80102a4e:	c3                   	ret    

80102a4f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a4f:	55                   	push   %ebp
80102a50:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a52:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a57:	8b 55 08             	mov    0x8(%ebp),%edx
80102a5a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a5c:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a61:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a64:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a67:	90                   	nop
80102a68:	5d                   	pop    %ebp
80102a69:	c3                   	ret    

80102a6a <ioapicinit>:

void
ioapicinit(void)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a70:	c7 05 fc 70 11 80 00 	movl   $0xfec00000,0x801170fc
80102a77:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a7a:	6a 01                	push   $0x1
80102a7c:	e8 b7 ff ff ff       	call   80102a38 <ioapicread>
80102a81:	83 c4 04             	add    $0x4,%esp
80102a84:	c1 e8 10             	shr    $0x10,%eax
80102a87:	25 ff 00 00 00       	and    $0xff,%eax
80102a8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a8f:	6a 00                	push   $0x0
80102a91:	e8 a2 ff ff ff       	call   80102a38 <ioapicread>
80102a96:	83 c4 04             	add    $0x4,%esp
80102a99:	c1 e8 18             	shr    $0x18,%eax
80102a9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a9f:	0f b6 05 84 9d 11 80 	movzbl 0x80119d84,%eax
80102aa6:	0f b6 c0             	movzbl %al,%eax
80102aa9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102aac:	74 10                	je     80102abe <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aae:	83 ec 0c             	sub    $0xc,%esp
80102ab1:	68 18 a6 10 80       	push   $0x8010a618
80102ab6:	e8 39 d9 ff ff       	call   801003f4 <cprintf>
80102abb:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102abe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ac5:	eb 3f                	jmp    80102b06 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aca:	83 c0 20             	add    $0x20,%eax
80102acd:	0d 00 00 01 00       	or     $0x10000,%eax
80102ad2:	89 c2                	mov    %eax,%edx
80102ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad7:	83 c0 08             	add    $0x8,%eax
80102ada:	01 c0                	add    %eax,%eax
80102adc:	83 ec 08             	sub    $0x8,%esp
80102adf:	52                   	push   %edx
80102ae0:	50                   	push   %eax
80102ae1:	e8 69 ff ff ff       	call   80102a4f <ioapicwrite>
80102ae6:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aec:	83 c0 08             	add    $0x8,%eax
80102aef:	01 c0                	add    %eax,%eax
80102af1:	83 c0 01             	add    $0x1,%eax
80102af4:	83 ec 08             	sub    $0x8,%esp
80102af7:	6a 00                	push   $0x0
80102af9:	50                   	push   %eax
80102afa:	e8 50 ff ff ff       	call   80102a4f <ioapicwrite>
80102aff:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b02:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b09:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b0c:	7e b9                	jle    80102ac7 <ioapicinit+0x5d>
  }
}
80102b0e:	90                   	nop
80102b0f:	90                   	nop
80102b10:	c9                   	leave  
80102b11:	c3                   	ret    

80102b12 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b12:	55                   	push   %ebp
80102b13:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b15:	8b 45 08             	mov    0x8(%ebp),%eax
80102b18:	83 c0 20             	add    $0x20,%eax
80102b1b:	89 c2                	mov    %eax,%edx
80102b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b20:	83 c0 08             	add    $0x8,%eax
80102b23:	01 c0                	add    %eax,%eax
80102b25:	52                   	push   %edx
80102b26:	50                   	push   %eax
80102b27:	e8 23 ff ff ff       	call   80102a4f <ioapicwrite>
80102b2c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b32:	c1 e0 18             	shl    $0x18,%eax
80102b35:	89 c2                	mov    %eax,%edx
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	83 c0 08             	add    $0x8,%eax
80102b3d:	01 c0                	add    %eax,%eax
80102b3f:	83 c0 01             	add    $0x1,%eax
80102b42:	52                   	push   %edx
80102b43:	50                   	push   %eax
80102b44:	e8 06 ff ff ff       	call   80102a4f <ioapicwrite>
80102b49:	83 c4 08             	add    $0x8,%esp
}
80102b4c:	90                   	nop
80102b4d:	c9                   	leave  
80102b4e:	c3                   	ret    

80102b4f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b4f:	55                   	push   %ebp
80102b50:	89 e5                	mov    %esp,%ebp
80102b52:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b55:	83 ec 08             	sub    $0x8,%esp
80102b58:	68 4a a6 10 80       	push   $0x8010a64a
80102b5d:	68 00 71 11 80       	push   $0x80117100
80102b62:	e8 59 20 00 00       	call   80104bc0 <initlock>
80102b67:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b6a:	c7 05 34 71 11 80 00 	movl   $0x0,0x80117134
80102b71:	00 00 00 
  freerange(vstart, vend);
80102b74:	83 ec 08             	sub    $0x8,%esp
80102b77:	ff 75 0c             	push   0xc(%ebp)
80102b7a:	ff 75 08             	push   0x8(%ebp)
80102b7d:	e8 2a 00 00 00       	call   80102bac <freerange>
80102b82:	83 c4 10             	add    $0x10,%esp
}
80102b85:	90                   	nop
80102b86:	c9                   	leave  
80102b87:	c3                   	ret    

80102b88 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b88:	55                   	push   %ebp
80102b89:	89 e5                	mov    %esp,%ebp
80102b8b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b8e:	83 ec 08             	sub    $0x8,%esp
80102b91:	ff 75 0c             	push   0xc(%ebp)
80102b94:	ff 75 08             	push   0x8(%ebp)
80102b97:	e8 10 00 00 00       	call   80102bac <freerange>
80102b9c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b9f:	c7 05 34 71 11 80 01 	movl   $0x1,0x80117134
80102ba6:	00 00 00 
}
80102ba9:	90                   	nop
80102baa:	c9                   	leave  
80102bab:	c3                   	ret    

80102bac <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bac:	55                   	push   %ebp
80102bad:	89 e5                	mov    %esp,%ebp
80102baf:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb5:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc2:	eb 15                	jmp    80102bd9 <freerange+0x2d>
    kfree(p);
80102bc4:	83 ec 0c             	sub    $0xc,%esp
80102bc7:	ff 75 f4             	push   -0xc(%ebp)
80102bca:	e8 1b 00 00 00       	call   80102bea <kfree>
80102bcf:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bdc:	05 00 10 00 00       	add    $0x1000,%eax
80102be1:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102be4:	73 de                	jae    80102bc4 <freerange+0x18>
}
80102be6:	90                   	nop
80102be7:	90                   	nop
80102be8:	c9                   	leave  
80102be9:	c3                   	ret    

80102bea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bea:	55                   	push   %ebp
80102beb:	89 e5                	mov    %esp,%ebp
80102bed:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf3:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bf8:	85 c0                	test   %eax,%eax
80102bfa:	75 18                	jne    80102c14 <kfree+0x2a>
80102bfc:	81 7d 08 00 c0 11 80 	cmpl   $0x8011c000,0x8(%ebp)
80102c03:	72 0f                	jb     80102c14 <kfree+0x2a>
80102c05:	8b 45 08             	mov    0x8(%ebp),%eax
80102c08:	05 00 00 00 80       	add    $0x80000000,%eax
80102c0d:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102c12:	76 0d                	jbe    80102c21 <kfree+0x37>
    panic("kfree");
80102c14:	83 ec 0c             	sub    $0xc,%esp
80102c17:	68 4f a6 10 80       	push   $0x8010a64f
80102c1c:	e8 88 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c21:	83 ec 04             	sub    $0x4,%esp
80102c24:	68 00 10 00 00       	push   $0x1000
80102c29:	6a 01                	push   $0x1
80102c2b:	ff 75 08             	push   0x8(%ebp)
80102c2e:	e8 25 22 00 00       	call   80104e58 <memset>
80102c33:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c36:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c3b:	85 c0                	test   %eax,%eax
80102c3d:	74 10                	je     80102c4f <kfree+0x65>
    acquire(&kmem.lock);
80102c3f:	83 ec 0c             	sub    $0xc,%esp
80102c42:	68 00 71 11 80       	push   $0x80117100
80102c47:	e8 96 1f 00 00       	call   80104be2 <acquire>
80102c4c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c55:	8b 15 38 71 11 80    	mov    0x80117138,%edx
80102c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c63:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102c68:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c6d:	85 c0                	test   %eax,%eax
80102c6f:	74 10                	je     80102c81 <kfree+0x97>
    release(&kmem.lock);
80102c71:	83 ec 0c             	sub    $0xc,%esp
80102c74:	68 00 71 11 80       	push   $0x80117100
80102c79:	e8 d2 1f 00 00       	call   80104c50 <release>
80102c7e:	83 c4 10             	add    $0x10,%esp
}
80102c81:	90                   	nop
80102c82:	c9                   	leave  
80102c83:	c3                   	ret    

80102c84 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c84:	55                   	push   %ebp
80102c85:	89 e5                	mov    %esp,%ebp
80102c87:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c8a:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c8f:	85 c0                	test   %eax,%eax
80102c91:	74 10                	je     80102ca3 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c93:	83 ec 0c             	sub    $0xc,%esp
80102c96:	68 00 71 11 80       	push   $0x80117100
80102c9b:	e8 42 1f 00 00       	call   80104be2 <acquire>
80102ca0:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca3:	a1 38 71 11 80       	mov    0x80117138,%eax
80102ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102caf:	74 0a                	je     80102cbb <kalloc+0x37>
    kmem.freelist = r->next;
80102cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb4:	8b 00                	mov    (%eax),%eax
80102cb6:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102cbb:	a1 34 71 11 80       	mov    0x80117134,%eax
80102cc0:	85 c0                	test   %eax,%eax
80102cc2:	74 10                	je     80102cd4 <kalloc+0x50>
    release(&kmem.lock);
80102cc4:	83 ec 0c             	sub    $0xc,%esp
80102cc7:	68 00 71 11 80       	push   $0x80117100
80102ccc:	e8 7f 1f 00 00       	call   80104c50 <release>
80102cd1:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cd7:	c9                   	leave  
80102cd8:	c3                   	ret    

80102cd9 <inb>:
{
80102cd9:	55                   	push   %ebp
80102cda:	89 e5                	mov    %esp,%ebp
80102cdc:	83 ec 14             	sub    $0x14,%esp
80102cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ce6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cea:	89 c2                	mov    %eax,%edx
80102cec:	ec                   	in     (%dx),%al
80102ced:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cf4:	c9                   	leave  
80102cf5:	c3                   	ret    

80102cf6 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cf6:	55                   	push   %ebp
80102cf7:	89 e5                	mov    %esp,%ebp
80102cf9:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cfc:	6a 64                	push   $0x64
80102cfe:	e8 d6 ff ff ff       	call   80102cd9 <inb>
80102d03:	83 c4 04             	add    $0x4,%esp
80102d06:	0f b6 c0             	movzbl %al,%eax
80102d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d0f:	83 e0 01             	and    $0x1,%eax
80102d12:	85 c0                	test   %eax,%eax
80102d14:	75 0a                	jne    80102d20 <kbdgetc+0x2a>
    return -1;
80102d16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d1b:	e9 23 01 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d20:	6a 60                	push   $0x60
80102d22:	e8 b2 ff ff ff       	call   80102cd9 <inb>
80102d27:	83 c4 04             	add    $0x4,%esp
80102d2a:	0f b6 c0             	movzbl %al,%eax
80102d2d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d30:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d37:	75 17                	jne    80102d50 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d39:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d3e:	83 c8 40             	or     $0x40,%eax
80102d41:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d46:	b8 00 00 00 00       	mov    $0x0,%eax
80102d4b:	e9 f3 00 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d53:	25 80 00 00 00       	and    $0x80,%eax
80102d58:	85 c0                	test   %eax,%eax
80102d5a:	74 45                	je     80102da1 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d5c:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d61:	83 e0 40             	and    $0x40,%eax
80102d64:	85 c0                	test   %eax,%eax
80102d66:	75 08                	jne    80102d70 <kbdgetc+0x7a>
80102d68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d6b:	83 e0 7f             	and    $0x7f,%eax
80102d6e:	eb 03                	jmp    80102d73 <kbdgetc+0x7d>
80102d70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d73:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d79:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102d7e:	0f b6 00             	movzbl (%eax),%eax
80102d81:	83 c8 40             	or     $0x40,%eax
80102d84:	0f b6 c0             	movzbl %al,%eax
80102d87:	f7 d0                	not    %eax
80102d89:	89 c2                	mov    %eax,%edx
80102d8b:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d90:	21 d0                	and    %edx,%eax
80102d92:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d97:	b8 00 00 00 00       	mov    $0x0,%eax
80102d9c:	e9 a2 00 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102da1:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102da6:	83 e0 40             	and    $0x40,%eax
80102da9:	85 c0                	test   %eax,%eax
80102dab:	74 14                	je     80102dc1 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dad:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102db4:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102db9:	83 e0 bf             	and    $0xffffffbf,%eax
80102dbc:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  }

  shift |= shiftcode[data];
80102dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc4:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102dc9:	0f b6 00             	movzbl (%eax),%eax
80102dcc:	0f b6 d0             	movzbl %al,%edx
80102dcf:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dd4:	09 d0                	or     %edx,%eax
80102dd6:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  shift ^= togglecode[data];
80102ddb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dde:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102de3:	0f b6 00             	movzbl (%eax),%eax
80102de6:	0f b6 d0             	movzbl %al,%edx
80102de9:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dee:	31 d0                	xor    %edx,%eax
80102df0:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  c = charcode[shift & (CTL | SHIFT)][data];
80102df5:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dfa:	83 e0 03             	and    $0x3,%eax
80102dfd:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102e04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e07:	01 d0                	add    %edx,%eax
80102e09:	0f b6 00             	movzbl (%eax),%eax
80102e0c:	0f b6 c0             	movzbl %al,%eax
80102e0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e12:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e17:	83 e0 08             	and    $0x8,%eax
80102e1a:	85 c0                	test   %eax,%eax
80102e1c:	74 22                	je     80102e40 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e1e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e22:	76 0c                	jbe    80102e30 <kbdgetc+0x13a>
80102e24:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e28:	77 06                	ja     80102e30 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e2a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e2e:	eb 10                	jmp    80102e40 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e30:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e34:	76 0a                	jbe    80102e40 <kbdgetc+0x14a>
80102e36:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e3a:	77 04                	ja     80102e40 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e3c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e40:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e43:	c9                   	leave  
80102e44:	c3                   	ret    

80102e45 <kbdintr>:

void
kbdintr(void)
{
80102e45:	55                   	push   %ebp
80102e46:	89 e5                	mov    %esp,%ebp
80102e48:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e4b:	83 ec 0c             	sub    $0xc,%esp
80102e4e:	68 f6 2c 10 80       	push   $0x80102cf6
80102e53:	e8 7e d9 ff ff       	call   801007d6 <consoleintr>
80102e58:	83 c4 10             	add    $0x10,%esp
}
80102e5b:	90                   	nop
80102e5c:	c9                   	leave  
80102e5d:	c3                   	ret    

80102e5e <inb>:
{
80102e5e:	55                   	push   %ebp
80102e5f:	89 e5                	mov    %esp,%ebp
80102e61:	83 ec 14             	sub    $0x14,%esp
80102e64:	8b 45 08             	mov    0x8(%ebp),%eax
80102e67:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e6b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e6f:	89 c2                	mov    %eax,%edx
80102e71:	ec                   	in     (%dx),%al
80102e72:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e75:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e79:	c9                   	leave  
80102e7a:	c3                   	ret    

80102e7b <outb>:
{
80102e7b:	55                   	push   %ebp
80102e7c:	89 e5                	mov    %esp,%ebp
80102e7e:	83 ec 08             	sub    $0x8,%esp
80102e81:	8b 45 08             	mov    0x8(%ebp),%eax
80102e84:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e87:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e8b:	89 d0                	mov    %edx,%eax
80102e8d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e90:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e94:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e98:	ee                   	out    %al,(%dx)
}
80102e99:	90                   	nop
80102e9a:	c9                   	leave  
80102e9b:	c3                   	ret    

80102e9c <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e9c:	55                   	push   %ebp
80102e9d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e9f:	8b 15 40 71 11 80    	mov    0x80117140,%edx
80102ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ea8:	c1 e0 02             	shl    $0x2,%eax
80102eab:	01 c2                	add    %eax,%edx
80102ead:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb0:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102eb7:	83 c0 20             	add    $0x20,%eax
80102eba:	8b 00                	mov    (%eax),%eax
}
80102ebc:	90                   	nop
80102ebd:	5d                   	pop    %ebp
80102ebe:	c3                   	ret    

80102ebf <lapicinit>:

void
lapicinit(void)
{
80102ebf:	55                   	push   %ebp
80102ec0:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ec2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ec7:	85 c0                	test   %eax,%eax
80102ec9:	0f 84 0c 01 00 00    	je     80102fdb <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ecf:	68 3f 01 00 00       	push   $0x13f
80102ed4:	6a 3c                	push   $0x3c
80102ed6:	e8 c1 ff ff ff       	call   80102e9c <lapicw>
80102edb:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ede:	6a 0b                	push   $0xb
80102ee0:	68 f8 00 00 00       	push   $0xf8
80102ee5:	e8 b2 ff ff ff       	call   80102e9c <lapicw>
80102eea:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eed:	68 20 00 02 00       	push   $0x20020
80102ef2:	68 c8 00 00 00       	push   $0xc8
80102ef7:	e8 a0 ff ff ff       	call   80102e9c <lapicw>
80102efc:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102eff:	68 80 96 98 00       	push   $0x989680
80102f04:	68 e0 00 00 00       	push   $0xe0
80102f09:	e8 8e ff ff ff       	call   80102e9c <lapicw>
80102f0e:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f11:	68 00 00 01 00       	push   $0x10000
80102f16:	68 d4 00 00 00       	push   $0xd4
80102f1b:	e8 7c ff ff ff       	call   80102e9c <lapicw>
80102f20:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f23:	68 00 00 01 00       	push   $0x10000
80102f28:	68 d8 00 00 00       	push   $0xd8
80102f2d:	e8 6a ff ff ff       	call   80102e9c <lapicw>
80102f32:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f35:	a1 40 71 11 80       	mov    0x80117140,%eax
80102f3a:	83 c0 30             	add    $0x30,%eax
80102f3d:	8b 00                	mov    (%eax),%eax
80102f3f:	c1 e8 10             	shr    $0x10,%eax
80102f42:	25 fc 00 00 00       	and    $0xfc,%eax
80102f47:	85 c0                	test   %eax,%eax
80102f49:	74 12                	je     80102f5d <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f4b:	68 00 00 01 00       	push   $0x10000
80102f50:	68 d0 00 00 00       	push   $0xd0
80102f55:	e8 42 ff ff ff       	call   80102e9c <lapicw>
80102f5a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f5d:	6a 33                	push   $0x33
80102f5f:	68 dc 00 00 00       	push   $0xdc
80102f64:	e8 33 ff ff ff       	call   80102e9c <lapicw>
80102f69:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f6c:	6a 00                	push   $0x0
80102f6e:	68 a0 00 00 00       	push   $0xa0
80102f73:	e8 24 ff ff ff       	call   80102e9c <lapicw>
80102f78:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7b:	6a 00                	push   $0x0
80102f7d:	68 a0 00 00 00       	push   $0xa0
80102f82:	e8 15 ff ff ff       	call   80102e9c <lapicw>
80102f87:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f8a:	6a 00                	push   $0x0
80102f8c:	6a 2c                	push   $0x2c
80102f8e:	e8 09 ff ff ff       	call   80102e9c <lapicw>
80102f93:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f96:	6a 00                	push   $0x0
80102f98:	68 c4 00 00 00       	push   $0xc4
80102f9d:	e8 fa fe ff ff       	call   80102e9c <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa5:	68 00 85 08 00       	push   $0x88500
80102faa:	68 c0 00 00 00       	push   $0xc0
80102faf:	e8 e8 fe ff ff       	call   80102e9c <lapicw>
80102fb4:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb7:	90                   	nop
80102fb8:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fbd:	05 00 03 00 00       	add    $0x300,%eax
80102fc2:	8b 00                	mov    (%eax),%eax
80102fc4:	25 00 10 00 00       	and    $0x1000,%eax
80102fc9:	85 c0                	test   %eax,%eax
80102fcb:	75 eb                	jne    80102fb8 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fcd:	6a 00                	push   $0x0
80102fcf:	6a 20                	push   $0x20
80102fd1:	e8 c6 fe ff ff       	call   80102e9c <lapicw>
80102fd6:	83 c4 08             	add    $0x8,%esp
80102fd9:	eb 01                	jmp    80102fdc <lapicinit+0x11d>
    return;
80102fdb:	90                   	nop
}
80102fdc:	c9                   	leave  
80102fdd:	c3                   	ret    

80102fde <lapicid>:

int
lapicid(void)
{
80102fde:	55                   	push   %ebp
80102fdf:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102fe1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fe6:	85 c0                	test   %eax,%eax
80102fe8:	75 07                	jne    80102ff1 <lapicid+0x13>
    return 0;
80102fea:	b8 00 00 00 00       	mov    $0x0,%eax
80102fef:	eb 0d                	jmp    80102ffe <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102ff1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ff6:	83 c0 20             	add    $0x20,%eax
80102ff9:	8b 00                	mov    (%eax),%eax
80102ffb:	c1 e8 18             	shr    $0x18,%eax
}
80102ffe:	5d                   	pop    %ebp
80102fff:	c3                   	ret    

80103000 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103003:	a1 40 71 11 80       	mov    0x80117140,%eax
80103008:	85 c0                	test   %eax,%eax
8010300a:	74 0c                	je     80103018 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010300c:	6a 00                	push   $0x0
8010300e:	6a 2c                	push   $0x2c
80103010:	e8 87 fe ff ff       	call   80102e9c <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp
}
80103018:	90                   	nop
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
}
8010301e:	90                   	nop
8010301f:	5d                   	pop    %ebp
80103020:	c3                   	ret    

80103021 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103021:	55                   	push   %ebp
80103022:	89 e5                	mov    %esp,%ebp
80103024:	83 ec 14             	sub    $0x14,%esp
80103027:	8b 45 08             	mov    0x8(%ebp),%eax
8010302a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010302d:	6a 0f                	push   $0xf
8010302f:	6a 70                	push   $0x70
80103031:	e8 45 fe ff ff       	call   80102e7b <outb>
80103036:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103039:	6a 0a                	push   $0xa
8010303b:	6a 71                	push   $0x71
8010303d:	e8 39 fe ff ff       	call   80102e7b <outb>
80103042:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103045:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010304c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010304f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103054:	8b 45 0c             	mov    0xc(%ebp),%eax
80103057:	c1 e8 04             	shr    $0x4,%eax
8010305a:	89 c2                	mov    %eax,%edx
8010305c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010305f:	83 c0 02             	add    $0x2,%eax
80103062:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103065:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103069:	c1 e0 18             	shl    $0x18,%eax
8010306c:	50                   	push   %eax
8010306d:	68 c4 00 00 00       	push   $0xc4
80103072:	e8 25 fe ff ff       	call   80102e9c <lapicw>
80103077:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010307a:	68 00 c5 00 00       	push   $0xc500
8010307f:	68 c0 00 00 00       	push   $0xc0
80103084:	e8 13 fe ff ff       	call   80102e9c <lapicw>
80103089:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010308c:	68 c8 00 00 00       	push   $0xc8
80103091:	e8 85 ff ff ff       	call   8010301b <microdelay>
80103096:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103099:	68 00 85 00 00       	push   $0x8500
8010309e:	68 c0 00 00 00       	push   $0xc0
801030a3:	e8 f4 fd ff ff       	call   80102e9c <lapicw>
801030a8:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ab:	6a 64                	push   $0x64
801030ad:	e8 69 ff ff ff       	call   8010301b <microdelay>
801030b2:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030bc:	eb 3d                	jmp    801030fb <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030be:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030c2:	c1 e0 18             	shl    $0x18,%eax
801030c5:	50                   	push   %eax
801030c6:	68 c4 00 00 00       	push   $0xc4
801030cb:	e8 cc fd ff ff       	call   80102e9c <lapicw>
801030d0:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801030d6:	c1 e8 0c             	shr    $0xc,%eax
801030d9:	80 cc 06             	or     $0x6,%ah
801030dc:	50                   	push   %eax
801030dd:	68 c0 00 00 00       	push   $0xc0
801030e2:	e8 b5 fd ff ff       	call   80102e9c <lapicw>
801030e7:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030ea:	68 c8 00 00 00       	push   $0xc8
801030ef:	e8 27 ff ff ff       	call   8010301b <microdelay>
801030f4:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801030f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030fb:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030ff:	7e bd                	jle    801030be <lapicstartap+0x9d>
  }
}
80103101:	90                   	nop
80103102:	90                   	nop
80103103:	c9                   	leave  
80103104:	c3                   	ret    

80103105 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103108:	8b 45 08             	mov    0x8(%ebp),%eax
8010310b:	0f b6 c0             	movzbl %al,%eax
8010310e:	50                   	push   %eax
8010310f:	6a 70                	push   $0x70
80103111:	e8 65 fd ff ff       	call   80102e7b <outb>
80103116:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103119:	68 c8 00 00 00       	push   $0xc8
8010311e:	e8 f8 fe ff ff       	call   8010301b <microdelay>
80103123:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103126:	6a 71                	push   $0x71
80103128:	e8 31 fd ff ff       	call   80102e5e <inb>
8010312d:	83 c4 04             	add    $0x4,%esp
80103130:	0f b6 c0             	movzbl %al,%eax
}
80103133:	c9                   	leave  
80103134:	c3                   	ret    

80103135 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103138:	6a 00                	push   $0x0
8010313a:	e8 c6 ff ff ff       	call   80103105 <cmos_read>
8010313f:	83 c4 04             	add    $0x4,%esp
80103142:	8b 55 08             	mov    0x8(%ebp),%edx
80103145:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103147:	6a 02                	push   $0x2
80103149:	e8 b7 ff ff ff       	call   80103105 <cmos_read>
8010314e:	83 c4 04             	add    $0x4,%esp
80103151:	8b 55 08             	mov    0x8(%ebp),%edx
80103154:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103157:	6a 04                	push   $0x4
80103159:	e8 a7 ff ff ff       	call   80103105 <cmos_read>
8010315e:	83 c4 04             	add    $0x4,%esp
80103161:	8b 55 08             	mov    0x8(%ebp),%edx
80103164:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103167:	6a 07                	push   $0x7
80103169:	e8 97 ff ff ff       	call   80103105 <cmos_read>
8010316e:	83 c4 04             	add    $0x4,%esp
80103171:	8b 55 08             	mov    0x8(%ebp),%edx
80103174:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103177:	6a 08                	push   $0x8
80103179:	e8 87 ff ff ff       	call   80103105 <cmos_read>
8010317e:	83 c4 04             	add    $0x4,%esp
80103181:	8b 55 08             	mov    0x8(%ebp),%edx
80103184:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103187:	6a 09                	push   $0x9
80103189:	e8 77 ff ff ff       	call   80103105 <cmos_read>
8010318e:	83 c4 04             	add    $0x4,%esp
80103191:	8b 55 08             	mov    0x8(%ebp),%edx
80103194:	89 42 14             	mov    %eax,0x14(%edx)
}
80103197:	90                   	nop
80103198:	c9                   	leave  
80103199:	c3                   	ret    

8010319a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010319a:	55                   	push   %ebp
8010319b:	89 e5                	mov    %esp,%ebp
8010319d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031a0:	6a 0b                	push   $0xb
801031a2:	e8 5e ff ff ff       	call   80103105 <cmos_read>
801031a7:	83 c4 04             	add    $0x4,%esp
801031aa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b0:	83 e0 04             	and    $0x4,%eax
801031b3:	85 c0                	test   %eax,%eax
801031b5:	0f 94 c0             	sete   %al
801031b8:	0f b6 c0             	movzbl %al,%eax
801031bb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c1:	50                   	push   %eax
801031c2:	e8 6e ff ff ff       	call   80103135 <fill_rtcdate>
801031c7:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031ca:	6a 0a                	push   $0xa
801031cc:	e8 34 ff ff ff       	call   80103105 <cmos_read>
801031d1:	83 c4 04             	add    $0x4,%esp
801031d4:	25 80 00 00 00       	and    $0x80,%eax
801031d9:	85 c0                	test   %eax,%eax
801031db:	75 27                	jne    80103204 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031dd:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e0:	50                   	push   %eax
801031e1:	e8 4f ff ff ff       	call   80103135 <fill_rtcdate>
801031e6:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031e9:	83 ec 04             	sub    $0x4,%esp
801031ec:	6a 18                	push   $0x18
801031ee:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f1:	50                   	push   %eax
801031f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f5:	50                   	push   %eax
801031f6:	e8 c4 1c 00 00       	call   80104ebf <memcmp>
801031fb:	83 c4 10             	add    $0x10,%esp
801031fe:	85 c0                	test   %eax,%eax
80103200:	74 05                	je     80103207 <cmostime+0x6d>
80103202:	eb ba                	jmp    801031be <cmostime+0x24>
        continue;
80103204:	90                   	nop
    fill_rtcdate(&t1);
80103205:	eb b7                	jmp    801031be <cmostime+0x24>
      break;
80103207:	90                   	nop
  }

  // convert
  if(bcd) {
80103208:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010320c:	0f 84 b4 00 00 00    	je     801032c6 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103212:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103215:	c1 e8 04             	shr    $0x4,%eax
80103218:	89 c2                	mov    %eax,%edx
8010321a:	89 d0                	mov    %edx,%eax
8010321c:	c1 e0 02             	shl    $0x2,%eax
8010321f:	01 d0                	add    %edx,%eax
80103221:	01 c0                	add    %eax,%eax
80103223:	89 c2                	mov    %eax,%edx
80103225:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103228:	83 e0 0f             	and    $0xf,%eax
8010322b:	01 d0                	add    %edx,%eax
8010322d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103230:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103233:	c1 e8 04             	shr    $0x4,%eax
80103236:	89 c2                	mov    %eax,%edx
80103238:	89 d0                	mov    %edx,%eax
8010323a:	c1 e0 02             	shl    $0x2,%eax
8010323d:	01 d0                	add    %edx,%eax
8010323f:	01 c0                	add    %eax,%eax
80103241:	89 c2                	mov    %eax,%edx
80103243:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103246:	83 e0 0f             	and    $0xf,%eax
80103249:	01 d0                	add    %edx,%eax
8010324b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010324e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103251:	c1 e8 04             	shr    $0x4,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	89 d0                	mov    %edx,%eax
80103258:	c1 e0 02             	shl    $0x2,%eax
8010325b:	01 d0                	add    %edx,%eax
8010325d:	01 c0                	add    %eax,%eax
8010325f:	89 c2                	mov    %eax,%edx
80103261:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103264:	83 e0 0f             	and    $0xf,%eax
80103267:	01 d0                	add    %edx,%eax
80103269:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010326c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010326f:	c1 e8 04             	shr    $0x4,%eax
80103272:	89 c2                	mov    %eax,%edx
80103274:	89 d0                	mov    %edx,%eax
80103276:	c1 e0 02             	shl    $0x2,%eax
80103279:	01 d0                	add    %edx,%eax
8010327b:	01 c0                	add    %eax,%eax
8010327d:	89 c2                	mov    %eax,%edx
8010327f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103282:	83 e0 0f             	and    $0xf,%eax
80103285:	01 d0                	add    %edx,%eax
80103287:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010328a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010328d:	c1 e8 04             	shr    $0x4,%eax
80103290:	89 c2                	mov    %eax,%edx
80103292:	89 d0                	mov    %edx,%eax
80103294:	c1 e0 02             	shl    $0x2,%eax
80103297:	01 d0                	add    %edx,%eax
80103299:	01 c0                	add    %eax,%eax
8010329b:	89 c2                	mov    %eax,%edx
8010329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a0:	83 e0 0f             	and    $0xf,%eax
801032a3:	01 d0                	add    %edx,%eax
801032a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ab:	c1 e8 04             	shr    $0x4,%eax
801032ae:	89 c2                	mov    %eax,%edx
801032b0:	89 d0                	mov    %edx,%eax
801032b2:	c1 e0 02             	shl    $0x2,%eax
801032b5:	01 d0                	add    %edx,%eax
801032b7:	01 c0                	add    %eax,%eax
801032b9:	89 c2                	mov    %eax,%edx
801032bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032be:	83 e0 0f             	and    $0xf,%eax
801032c1:	01 d0                	add    %edx,%eax
801032c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032c6:	8b 45 08             	mov    0x8(%ebp),%eax
801032c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032cc:	89 10                	mov    %edx,(%eax)
801032ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032d1:	89 50 04             	mov    %edx,0x4(%eax)
801032d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032d7:	89 50 08             	mov    %edx,0x8(%eax)
801032da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032dd:	89 50 0c             	mov    %edx,0xc(%eax)
801032e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032e3:	89 50 10             	mov    %edx,0x10(%eax)
801032e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032e9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ec:	8b 45 08             	mov    0x8(%ebp),%eax
801032ef:	8b 40 14             	mov    0x14(%eax),%eax
801032f2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032f8:	8b 45 08             	mov    0x8(%ebp),%eax
801032fb:	89 50 14             	mov    %edx,0x14(%eax)
}
801032fe:	90                   	nop
801032ff:	c9                   	leave  
80103300:	c3                   	ret    

80103301 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103301:	55                   	push   %ebp
80103302:	89 e5                	mov    %esp,%ebp
80103304:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103307:	83 ec 08             	sub    $0x8,%esp
8010330a:	68 55 a6 10 80       	push   $0x8010a655
8010330f:	68 60 71 11 80       	push   $0x80117160
80103314:	e8 a7 18 00 00       	call   80104bc0 <initlock>
80103319:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010331c:	83 ec 08             	sub    $0x8,%esp
8010331f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103322:	50                   	push   %eax
80103323:	ff 75 08             	push   0x8(%ebp)
80103326:	e8 a3 e0 ff ff       	call   801013ce <readsb>
8010332b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010332e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103331:	a3 94 71 11 80       	mov    %eax,0x80117194
  log.size = sb.nlog;
80103336:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103339:	a3 98 71 11 80       	mov    %eax,0x80117198
  log.dev = dev;
8010333e:	8b 45 08             	mov    0x8(%ebp),%eax
80103341:	a3 a4 71 11 80       	mov    %eax,0x801171a4
  recover_from_log();
80103346:	e8 b3 01 00 00       	call   801034fe <recover_from_log>
}
8010334b:	90                   	nop
8010334c:	c9                   	leave  
8010334d:	c3                   	ret    

8010334e <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010334e:	55                   	push   %ebp
8010334f:	89 e5                	mov    %esp,%ebp
80103351:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103354:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010335b:	e9 95 00 00 00       	jmp    801033f5 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103360:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103369:	01 d0                	add    %edx,%eax
8010336b:	83 c0 01             	add    $0x1,%eax
8010336e:	89 c2                	mov    %eax,%edx
80103370:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103375:	83 ec 08             	sub    $0x8,%esp
80103378:	52                   	push   %edx
80103379:	50                   	push   %eax
8010337a:	e8 82 ce ff ff       	call   80100201 <bread>
8010337f:	83 c4 10             	add    $0x10,%esp
80103382:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103388:	83 c0 10             	add    $0x10,%eax
8010338b:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
80103392:	89 c2                	mov    %eax,%edx
80103394:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103399:	83 ec 08             	sub    $0x8,%esp
8010339c:	52                   	push   %edx
8010339d:	50                   	push   %eax
8010339e:	e8 5e ce ff ff       	call   80100201 <bread>
801033a3:	83 c4 10             	add    $0x10,%esp
801033a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ac:	8d 50 5c             	lea    0x5c(%eax),%edx
801033af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b2:	83 c0 5c             	add    $0x5c,%eax
801033b5:	83 ec 04             	sub    $0x4,%esp
801033b8:	68 00 02 00 00       	push   $0x200
801033bd:	52                   	push   %edx
801033be:	50                   	push   %eax
801033bf:	e8 53 1b 00 00       	call   80104f17 <memmove>
801033c4:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033c7:	83 ec 0c             	sub    $0xc,%esp
801033ca:	ff 75 ec             	push   -0x14(%ebp)
801033cd:	e8 68 ce ff ff       	call   8010023a <bwrite>
801033d2:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033d5:	83 ec 0c             	sub    $0xc,%esp
801033d8:	ff 75 f0             	push   -0x10(%ebp)
801033db:	e8 a3 ce ff ff       	call   80100283 <brelse>
801033e0:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033e3:	83 ec 0c             	sub    $0xc,%esp
801033e6:	ff 75 ec             	push   -0x14(%ebp)
801033e9:	e8 95 ce ff ff       	call   80100283 <brelse>
801033ee:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033f5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801033fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033fd:	0f 8c 5d ff ff ff    	jl     80103360 <install_trans+0x12>
  }
}
80103403:	90                   	nop
80103404:	90                   	nop
80103405:	c9                   	leave  
80103406:	c3                   	ret    

80103407 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103407:	55                   	push   %ebp
80103408:	89 e5                	mov    %esp,%ebp
8010340a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010340d:	a1 94 71 11 80       	mov    0x80117194,%eax
80103412:	89 c2                	mov    %eax,%edx
80103414:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103419:	83 ec 08             	sub    $0x8,%esp
8010341c:	52                   	push   %edx
8010341d:	50                   	push   %eax
8010341e:	e8 de cd ff ff       	call   80100201 <bread>
80103423:	83 c4 10             	add    $0x10,%esp
80103426:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342c:	83 c0 5c             	add    $0x5c,%eax
8010342f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103432:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103435:	8b 00                	mov    (%eax),%eax
80103437:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  for (i = 0; i < log.lh.n; i++) {
8010343c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103443:	eb 1b                	jmp    80103460 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103445:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010344b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010344f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103452:	83 c2 10             	add    $0x10,%edx
80103455:	89 04 95 6c 71 11 80 	mov    %eax,-0x7fee8e94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010345c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103460:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103465:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103468:	7c db                	jl     80103445 <read_head+0x3e>
  }
  brelse(buf);
8010346a:	83 ec 0c             	sub    $0xc,%esp
8010346d:	ff 75 f0             	push   -0x10(%ebp)
80103470:	e8 0e ce ff ff       	call   80100283 <brelse>
80103475:	83 c4 10             	add    $0x10,%esp
}
80103478:	90                   	nop
80103479:	c9                   	leave  
8010347a:	c3                   	ret    

8010347b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010347b:	55                   	push   %ebp
8010347c:	89 e5                	mov    %esp,%ebp
8010347e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103481:	a1 94 71 11 80       	mov    0x80117194,%eax
80103486:	89 c2                	mov    %eax,%edx
80103488:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010348d:	83 ec 08             	sub    $0x8,%esp
80103490:	52                   	push   %edx
80103491:	50                   	push   %eax
80103492:	e8 6a cd ff ff       	call   80100201 <bread>
80103497:	83 c4 10             	add    $0x10,%esp
8010349a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010349d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a0:	83 c0 5c             	add    $0x5c,%eax
801034a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034a6:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
801034ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034af:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034b8:	eb 1b                	jmp    801034d5 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034bd:	83 c0 10             	add    $0x10,%eax
801034c0:	8b 0c 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%ecx
801034c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034cd:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801034da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034dd:	7c db                	jl     801034ba <write_head+0x3f>
  }
  bwrite(buf);
801034df:	83 ec 0c             	sub    $0xc,%esp
801034e2:	ff 75 f0             	push   -0x10(%ebp)
801034e5:	e8 50 cd ff ff       	call   8010023a <bwrite>
801034ea:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ed:	83 ec 0c             	sub    $0xc,%esp
801034f0:	ff 75 f0             	push   -0x10(%ebp)
801034f3:	e8 8b cd ff ff       	call   80100283 <brelse>
801034f8:	83 c4 10             	add    $0x10,%esp
}
801034fb:	90                   	nop
801034fc:	c9                   	leave  
801034fd:	c3                   	ret    

801034fe <recover_from_log>:

static void
recover_from_log(void)
{
801034fe:	55                   	push   %ebp
801034ff:	89 e5                	mov    %esp,%ebp
80103501:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103504:	e8 fe fe ff ff       	call   80103407 <read_head>
  install_trans(); // if committed, copy from log to disk
80103509:	e8 40 fe ff ff       	call   8010334e <install_trans>
  log.lh.n = 0;
8010350e:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
80103515:	00 00 00 
  write_head(); // clear the log
80103518:	e8 5e ff ff ff       	call   8010347b <write_head>
}
8010351d:	90                   	nop
8010351e:	c9                   	leave  
8010351f:	c3                   	ret    

80103520 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103526:	83 ec 0c             	sub    $0xc,%esp
80103529:	68 60 71 11 80       	push   $0x80117160
8010352e:	e8 af 16 00 00       	call   80104be2 <acquire>
80103533:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103536:	a1 a0 71 11 80       	mov    0x801171a0,%eax
8010353b:	85 c0                	test   %eax,%eax
8010353d:	74 17                	je     80103556 <begin_op+0x36>
      sleep(&log, &log.lock);
8010353f:	83 ec 08             	sub    $0x8,%esp
80103542:	68 60 71 11 80       	push   $0x80117160
80103547:	68 60 71 11 80       	push   $0x80117160
8010354c:	e8 76 12 00 00       	call   801047c7 <sleep>
80103551:	83 c4 10             	add    $0x10,%esp
80103554:	eb e0                	jmp    80103536 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103556:	8b 0d a8 71 11 80    	mov    0x801171a8,%ecx
8010355c:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103561:	8d 50 01             	lea    0x1(%eax),%edx
80103564:	89 d0                	mov    %edx,%eax
80103566:	c1 e0 02             	shl    $0x2,%eax
80103569:	01 d0                	add    %edx,%eax
8010356b:	01 c0                	add    %eax,%eax
8010356d:	01 c8                	add    %ecx,%eax
8010356f:	83 f8 1e             	cmp    $0x1e,%eax
80103572:	7e 17                	jle    8010358b <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103574:	83 ec 08             	sub    $0x8,%esp
80103577:	68 60 71 11 80       	push   $0x80117160
8010357c:	68 60 71 11 80       	push   $0x80117160
80103581:	e8 41 12 00 00       	call   801047c7 <sleep>
80103586:	83 c4 10             	add    $0x10,%esp
80103589:	eb ab                	jmp    80103536 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010358b:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103590:	83 c0 01             	add    $0x1,%eax
80103593:	a3 9c 71 11 80       	mov    %eax,0x8011719c
      release(&log.lock);
80103598:	83 ec 0c             	sub    $0xc,%esp
8010359b:	68 60 71 11 80       	push   $0x80117160
801035a0:	e8 ab 16 00 00       	call   80104c50 <release>
801035a5:	83 c4 10             	add    $0x10,%esp
      break;
801035a8:	90                   	nop
    }
  }
}
801035a9:	90                   	nop
801035aa:	c9                   	leave  
801035ab:	c3                   	ret    

801035ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035ac:	55                   	push   %ebp
801035ad:	89 e5                	mov    %esp,%ebp
801035af:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035b9:	83 ec 0c             	sub    $0xc,%esp
801035bc:	68 60 71 11 80       	push   $0x80117160
801035c1:	e8 1c 16 00 00       	call   80104be2 <acquire>
801035c6:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035c9:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035ce:	83 e8 01             	sub    $0x1,%eax
801035d1:	a3 9c 71 11 80       	mov    %eax,0x8011719c
  if(log.committing)
801035d6:	a1 a0 71 11 80       	mov    0x801171a0,%eax
801035db:	85 c0                	test   %eax,%eax
801035dd:	74 0d                	je     801035ec <end_op+0x40>
    panic("log.committing");
801035df:	83 ec 0c             	sub    $0xc,%esp
801035e2:	68 59 a6 10 80       	push   $0x8010a659
801035e7:	e8 bd cf ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801035ec:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035f1:	85 c0                	test   %eax,%eax
801035f3:	75 13                	jne    80103608 <end_op+0x5c>
    do_commit = 1;
801035f5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035fc:	c7 05 a0 71 11 80 01 	movl   $0x1,0x801171a0
80103603:	00 00 00 
80103606:	eb 10                	jmp    80103618 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103608:	83 ec 0c             	sub    $0xc,%esp
8010360b:	68 60 71 11 80       	push   $0x80117160
80103610:	e8 99 12 00 00       	call   801048ae <wakeup>
80103615:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103618:	83 ec 0c             	sub    $0xc,%esp
8010361b:	68 60 71 11 80       	push   $0x80117160
80103620:	e8 2b 16 00 00       	call   80104c50 <release>
80103625:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103628:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010362c:	74 3f                	je     8010366d <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010362e:	e8 f6 00 00 00       	call   80103729 <commit>
    acquire(&log.lock);
80103633:	83 ec 0c             	sub    $0xc,%esp
80103636:	68 60 71 11 80       	push   $0x80117160
8010363b:	e8 a2 15 00 00       	call   80104be2 <acquire>
80103640:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103643:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364a:	00 00 00 
    wakeup(&log);
8010364d:	83 ec 0c             	sub    $0xc,%esp
80103650:	68 60 71 11 80       	push   $0x80117160
80103655:	e8 54 12 00 00       	call   801048ae <wakeup>
8010365a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	68 60 71 11 80       	push   $0x80117160
80103665:	e8 e6 15 00 00       	call   80104c50 <release>
8010366a:	83 c4 10             	add    $0x10,%esp
  }
}
8010366d:	90                   	nop
8010366e:	c9                   	leave  
8010366f:	c3                   	ret    

80103670 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103670:	55                   	push   %ebp
80103671:	89 e5                	mov    %esp,%ebp
80103673:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367d:	e9 95 00 00 00       	jmp    80103717 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103682:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368b:	01 d0                	add    %edx,%eax
8010368d:	83 c0 01             	add    $0x1,%eax
80103690:	89 c2                	mov    %eax,%edx
80103692:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103697:	83 ec 08             	sub    $0x8,%esp
8010369a:	52                   	push   %edx
8010369b:	50                   	push   %eax
8010369c:	e8 60 cb ff ff       	call   80100201 <bread>
801036a1:	83 c4 10             	add    $0x10,%esp
801036a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036aa:	83 c0 10             	add    $0x10,%eax
801036ad:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801036b4:	89 c2                	mov    %eax,%edx
801036b6:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036bb:	83 ec 08             	sub    $0x8,%esp
801036be:	52                   	push   %edx
801036bf:	50                   	push   %eax
801036c0:	e8 3c cb ff ff       	call   80100201 <bread>
801036c5:	83 c4 10             	add    $0x10,%esp
801036c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ce:	8d 50 5c             	lea    0x5c(%eax),%edx
801036d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d4:	83 c0 5c             	add    $0x5c,%eax
801036d7:	83 ec 04             	sub    $0x4,%esp
801036da:	68 00 02 00 00       	push   $0x200
801036df:	52                   	push   %edx
801036e0:	50                   	push   %eax
801036e1:	e8 31 18 00 00       	call   80104f17 <memmove>
801036e6:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036e9:	83 ec 0c             	sub    $0xc,%esp
801036ec:	ff 75 f0             	push   -0x10(%ebp)
801036ef:	e8 46 cb ff ff       	call   8010023a <bwrite>
801036f4:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801036f7:	83 ec 0c             	sub    $0xc,%esp
801036fa:	ff 75 ec             	push   -0x14(%ebp)
801036fd:	e8 81 cb ff ff       	call   80100283 <brelse>
80103702:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	ff 75 f0             	push   -0x10(%ebp)
8010370b:	e8 73 cb ff ff       	call   80100283 <brelse>
80103710:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103713:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103717:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010371c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010371f:	0f 8c 5d ff ff ff    	jl     80103682 <write_log+0x12>
  }
}
80103725:	90                   	nop
80103726:	90                   	nop
80103727:	c9                   	leave  
80103728:	c3                   	ret    

80103729 <commit>:

static void
commit()
{
80103729:	55                   	push   %ebp
8010372a:	89 e5                	mov    %esp,%ebp
8010372c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010372f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	7e 1e                	jle    80103756 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103738:	e8 33 ff ff ff       	call   80103670 <write_log>
    write_head();    // Write header to disk -- the real commit
8010373d:	e8 39 fd ff ff       	call   8010347b <write_head>
    install_trans(); // Now install writes to home locations
80103742:	e8 07 fc ff ff       	call   8010334e <install_trans>
    log.lh.n = 0;
80103747:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
8010374e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103751:	e8 25 fd ff ff       	call   8010347b <write_head>
  }
}
80103756:	90                   	nop
80103757:	c9                   	leave  
80103758:	c3                   	ret    

80103759 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103759:	55                   	push   %ebp
8010375a:	89 e5                	mov    %esp,%ebp
8010375c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010375f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103764:	83 f8 1d             	cmp    $0x1d,%eax
80103767:	7f 12                	jg     8010377b <log_write+0x22>
80103769:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010376e:	8b 15 98 71 11 80    	mov    0x80117198,%edx
80103774:	83 ea 01             	sub    $0x1,%edx
80103777:	39 d0                	cmp    %edx,%eax
80103779:	7c 0d                	jl     80103788 <log_write+0x2f>
    panic("too big a transaction");
8010377b:	83 ec 0c             	sub    $0xc,%esp
8010377e:	68 68 a6 10 80       	push   $0x8010a668
80103783:	e8 21 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103788:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378d:	85 c0                	test   %eax,%eax
8010378f:	7f 0d                	jg     8010379e <log_write+0x45>
    panic("log_write outside of trans");
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 7e a6 10 80       	push   $0x8010a67e
80103799:	e8 0b ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 71 11 80       	push   $0x80117160
801037a6:	e8 37 14 00 00       	call   80104be2 <acquire>
801037ab:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b5:	eb 1d                	jmp    801037d4 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ba:	83 c0 10             	add    $0x10,%eax
801037bd:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801037c4:	89 c2                	mov    %eax,%edx
801037c6:	8b 45 08             	mov    0x8(%ebp),%eax
801037c9:	8b 40 08             	mov    0x8(%eax),%eax
801037cc:	39 c2                	cmp    %eax,%edx
801037ce:	74 10                	je     801037e0 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d4:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037d9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037dc:	7c d9                	jl     801037b7 <log_write+0x5e>
801037de:	eb 01                	jmp    801037e1 <log_write+0x88>
      break;
801037e0:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037e1:	8b 45 08             	mov    0x8(%ebp),%eax
801037e4:	8b 40 08             	mov    0x8(%eax),%eax
801037e7:	89 c2                	mov    %eax,%edx
801037e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ec:	83 c0 10             	add    $0x10,%eax
801037ef:	89 14 85 6c 71 11 80 	mov    %edx,-0x7fee8e94(,%eax,4)
  if (i == log.lh.n)
801037f6:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037fe:	75 0d                	jne    8010380d <log_write+0xb4>
    log.lh.n++;
80103800:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103805:	83 c0 01             	add    $0x1,%eax
80103808:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  b->flags |= B_DIRTY; // prevent eviction
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 00                	mov    (%eax),%eax
80103812:	83 c8 04             	or     $0x4,%eax
80103815:	89 c2                	mov    %eax,%edx
80103817:	8b 45 08             	mov    0x8(%ebp),%eax
8010381a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010381c:	83 ec 0c             	sub    $0xc,%esp
8010381f:	68 60 71 11 80       	push   $0x80117160
80103824:	e8 27 14 00 00       	call   80104c50 <release>
80103829:	83 c4 10             	add    $0x10,%esp
}
8010382c:	90                   	nop
8010382d:	c9                   	leave  
8010382e:	c3                   	ret    

8010382f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010382f:	55                   	push   %ebp
80103830:	89 e5                	mov    %esp,%ebp
80103832:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103835:	8b 55 08             	mov    0x8(%ebp),%edx
80103838:	8b 45 0c             	mov    0xc(%ebp),%eax
8010383b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010383e:	f0 87 02             	lock xchg %eax,(%edx)
80103841:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103844:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103847:	c9                   	leave  
80103848:	c3                   	ret    

80103849 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103849:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010384d:	83 e4 f0             	and    $0xfffffff0,%esp
80103850:	ff 71 fc             	push   -0x4(%ecx)
80103853:	55                   	push   %ebp
80103854:	89 e5                	mov    %esp,%ebp
80103856:	51                   	push   %ecx
80103857:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
8010385a:	e8 1b 4a 00 00       	call   8010827a <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010385f:	83 ec 08             	sub    $0x8,%esp
80103862:	68 00 00 40 80       	push   $0x80400000
80103867:	68 00 c0 11 80       	push   $0x8011c000
8010386c:	e8 de f2 ff ff       	call   80102b4f <kinit1>
80103871:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103874:	e8 1b 40 00 00       	call   80107894 <kvmalloc>
  mpinit_uefi();
80103879:	e8 c2 47 00 00       	call   80108040 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010387e:	e8 3c f6 ff ff       	call   80102ebf <lapicinit>
  seginit();       // segment descriptors
80103883:	e8 a4 3a 00 00       	call   8010732c <seginit>
  picinit();    // disable pic
80103888:	e8 9d 01 00 00       	call   80103a2a <picinit>
  ioapicinit();    // another interrupt controller
8010388d:	e8 d8 f1 ff ff       	call   80102a6a <ioapicinit>
  consoleinit();   // console hardware
80103892:	e8 68 d2 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
80103897:	e8 29 2e 00 00       	call   801066c5 <uartinit>
  pinit();         // process table
8010389c:	e8 c2 05 00 00       	call   80103e63 <pinit>
  tvinit();        // trap vectors
801038a1:	e8 bb 29 00 00       	call   80106261 <tvinit>
  binit();         // buffer cache
801038a6:	e8 bb c7 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801038ab:	e8 0f d7 ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801038b0:	e8 6e ed ff ff       	call   80102623 <ideinit>
  startothers();   // start other processors
801038b5:	e8 8a 00 00 00       	call   80103944 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038ba:	83 ec 08             	sub    $0x8,%esp
801038bd:	68 00 00 00 a0       	push   $0xa0000000
801038c2:	68 00 00 40 80       	push   $0x80400000
801038c7:	e8 bc f2 ff ff       	call   80102b88 <kinit2>
801038cc:	83 c4 10             	add    $0x10,%esp
  pci_init();
801038cf:	e8 ff 4b 00 00       	call   801084d3 <pci_init>
  arp_scan();
801038d4:	e8 36 59 00 00       	call   8010920f <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038d9:	e8 63 07 00 00       	call   80104041 <userinit>

  mpmain();        // finish this processor's setup
801038de:	e8 1a 00 00 00       	call   801038fd <mpmain>

801038e3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038e3:	55                   	push   %ebp
801038e4:	89 e5                	mov    %esp,%ebp
801038e6:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038e9:	e8 be 3f 00 00       	call   801078ac <switchkvm>
  seginit();
801038ee:	e8 39 3a 00 00       	call   8010732c <seginit>
  lapicinit();
801038f3:	e8 c7 f5 ff ff       	call   80102ebf <lapicinit>
  mpmain();
801038f8:	e8 00 00 00 00       	call   801038fd <mpmain>

801038fd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038fd:	55                   	push   %ebp
801038fe:	89 e5                	mov    %esp,%ebp
80103900:	53                   	push   %ebx
80103901:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103904:	e8 78 05 00 00       	call   80103e81 <cpuid>
80103909:	89 c3                	mov    %eax,%ebx
8010390b:	e8 71 05 00 00       	call   80103e81 <cpuid>
80103910:	83 ec 04             	sub    $0x4,%esp
80103913:	53                   	push   %ebx
80103914:	50                   	push   %eax
80103915:	68 99 a6 10 80       	push   $0x8010a699
8010391a:	e8 d5 ca ff ff       	call   801003f4 <cprintf>
8010391f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103922:	e8 b0 2a 00 00       	call   801063d7 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103927:	e8 70 05 00 00       	call   80103e9c <mycpu>
8010392c:	05 a0 00 00 00       	add    $0xa0,%eax
80103931:	83 ec 08             	sub    $0x8,%esp
80103934:	6a 01                	push   $0x1
80103936:	50                   	push   %eax
80103937:	e8 f3 fe ff ff       	call   8010382f <xchg>
8010393c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010393f:	e8 92 0c 00 00       	call   801045d6 <scheduler>

80103944 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103944:	55                   	push   %ebp
80103945:	89 e5                	mov    %esp,%ebp
80103947:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394a:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103951:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103956:	83 ec 04             	sub    $0x4,%esp
80103959:	50                   	push   %eax
8010395a:	68 18 f5 10 80       	push   $0x8010f518
8010395f:	ff 75 f0             	push   -0x10(%ebp)
80103962:	e8 b0 15 00 00       	call   80104f17 <memmove>
80103967:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396a:	c7 45 f4 c0 9a 11 80 	movl   $0x80119ac0,-0xc(%ebp)
80103971:	eb 79                	jmp    801039ec <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103973:	e8 24 05 00 00       	call   80103e9c <mycpu>
80103978:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397b:	74 67                	je     801039e4 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010397d:	e8 02 f3 ff ff       	call   80102c84 <kalloc>
80103982:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103988:	83 e8 04             	sub    $0x4,%eax
8010398b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010398e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103994:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103999:	83 e8 08             	sub    $0x8,%eax
8010399c:	c7 00 e3 38 10 80    	movl   $0x801038e3,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a2:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801039a7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b0:	83 e8 0c             	sub    $0xc,%eax
801039b3:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c1:	0f b6 00             	movzbl (%eax),%eax
801039c4:	0f b6 c0             	movzbl %al,%eax
801039c7:	83 ec 08             	sub    $0x8,%esp
801039ca:	52                   	push   %edx
801039cb:	50                   	push   %eax
801039cc:	e8 50 f6 ff ff       	call   80103021 <lapicstartap>
801039d1:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d4:	90                   	nop
801039d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039de:	85 c0                	test   %eax,%eax
801039e0:	74 f3                	je     801039d5 <startothers+0x91>
801039e2:	eb 01                	jmp    801039e5 <startothers+0xa1>
      continue;
801039e4:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039e5:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039ec:	a1 80 9d 11 80       	mov    0x80119d80,%eax
801039f1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f7:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
801039fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039ff:	0f 82 6e ff ff ff    	jb     80103973 <startothers+0x2f>
      ;
  }
}
80103a05:	90                   	nop
80103a06:	90                   	nop
80103a07:	c9                   	leave  
80103a08:	c3                   	ret    

80103a09 <outb>:
{
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	83 ec 08             	sub    $0x8,%esp
80103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a15:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a19:	89 d0                	mov    %edx,%eax
80103a1b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a1e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a22:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a26:	ee                   	out    %al,(%dx)
}
80103a27:	90                   	nop
80103a28:	c9                   	leave  
80103a29:	c3                   	ret    

80103a2a <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103a2a:	55                   	push   %ebp
80103a2b:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a2d:	68 ff 00 00 00       	push   $0xff
80103a32:	6a 21                	push   $0x21
80103a34:	e8 d0 ff ff ff       	call   80103a09 <outb>
80103a39:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103a3c:	68 ff 00 00 00       	push   $0xff
80103a41:	68 a1 00 00 00       	push   $0xa1
80103a46:	e8 be ff ff ff       	call   80103a09 <outb>
80103a4b:	83 c4 08             	add    $0x8,%esp
}
80103a4e:	90                   	nop
80103a4f:	c9                   	leave  
80103a50:	c3                   	ret    

80103a51 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103a51:	55                   	push   %ebp
80103a52:	89 e5                	mov    %esp,%ebp
80103a54:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103a57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103a67:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a6a:	8b 10                	mov    (%eax),%edx
80103a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103a71:	e8 67 d5 ff ff       	call   80100fdd <filealloc>
80103a76:	8b 55 08             	mov    0x8(%ebp),%edx
80103a79:	89 02                	mov    %eax,(%edx)
80103a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7e:	8b 00                	mov    (%eax),%eax
80103a80:	85 c0                	test   %eax,%eax
80103a82:	0f 84 c8 00 00 00    	je     80103b50 <pipealloc+0xff>
80103a88:	e8 50 d5 ff ff       	call   80100fdd <filealloc>
80103a8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a90:	89 02                	mov    %eax,(%edx)
80103a92:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a95:	8b 00                	mov    (%eax),%eax
80103a97:	85 c0                	test   %eax,%eax
80103a99:	0f 84 b1 00 00 00    	je     80103b50 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103a9f:	e8 e0 f1 ff ff       	call   80102c84 <kalloc>
80103aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103aab:	0f 84 a2 00 00 00    	je     80103b53 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab4:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103abb:	00 00 00 
  p->writeopen = 1;
80103abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac1:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ac8:	00 00 00 
  p->nwrite = 0;
80103acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ace:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ad5:	00 00 00 
  p->nread = 0;
80103ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adb:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ae2:	00 00 00 
  initlock(&p->lock, "pipe");
80103ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae8:	83 ec 08             	sub    $0x8,%esp
80103aeb:	68 ad a6 10 80       	push   $0x8010a6ad
80103af0:	50                   	push   %eax
80103af1:	e8 ca 10 00 00       	call   80104bc0 <initlock>
80103af6:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103af9:	8b 45 08             	mov    0x8(%ebp),%eax
80103afc:	8b 00                	mov    (%eax),%eax
80103afe:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103b04:	8b 45 08             	mov    0x8(%ebp),%eax
80103b07:	8b 00                	mov    (%eax),%eax
80103b09:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b10:	8b 00                	mov    (%eax),%eax
80103b12:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103b16:	8b 45 08             	mov    0x8(%ebp),%eax
80103b19:	8b 00                	mov    (%eax),%eax
80103b1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b1e:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103b21:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b24:	8b 00                	mov    (%eax),%eax
80103b26:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b2f:	8b 00                	mov    (%eax),%eax
80103b31:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b38:	8b 00                	mov    (%eax),%eax
80103b3a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b41:	8b 00                	mov    (%eax),%eax
80103b43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b46:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103b49:	b8 00 00 00 00       	mov    $0x0,%eax
80103b4e:	eb 51                	jmp    80103ba1 <pipealloc+0x150>
    goto bad;
80103b50:	90                   	nop
80103b51:	eb 01                	jmp    80103b54 <pipealloc+0x103>
    goto bad;
80103b53:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103b54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b58:	74 0e                	je     80103b68 <pipealloc+0x117>
    kfree((char*)p);
80103b5a:	83 ec 0c             	sub    $0xc,%esp
80103b5d:	ff 75 f4             	push   -0xc(%ebp)
80103b60:	e8 85 f0 ff ff       	call   80102bea <kfree>
80103b65:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103b68:	8b 45 08             	mov    0x8(%ebp),%eax
80103b6b:	8b 00                	mov    (%eax),%eax
80103b6d:	85 c0                	test   %eax,%eax
80103b6f:	74 11                	je     80103b82 <pipealloc+0x131>
    fileclose(*f0);
80103b71:	8b 45 08             	mov    0x8(%ebp),%eax
80103b74:	8b 00                	mov    (%eax),%eax
80103b76:	83 ec 0c             	sub    $0xc,%esp
80103b79:	50                   	push   %eax
80103b7a:	e8 1c d5 ff ff       	call   8010109b <fileclose>
80103b7f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103b82:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b85:	8b 00                	mov    (%eax),%eax
80103b87:	85 c0                	test   %eax,%eax
80103b89:	74 11                	je     80103b9c <pipealloc+0x14b>
    fileclose(*f1);
80103b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b8e:	8b 00                	mov    (%eax),%eax
80103b90:	83 ec 0c             	sub    $0xc,%esp
80103b93:	50                   	push   %eax
80103b94:	e8 02 d5 ff ff       	call   8010109b <fileclose>
80103b99:	83 c4 10             	add    $0x10,%esp
  return -1;
80103b9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ba1:	c9                   	leave  
80103ba2:	c3                   	ret    

80103ba3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103ba3:	55                   	push   %ebp
80103ba4:	89 e5                	mov    %esp,%ebp
80103ba6:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bac:	83 ec 0c             	sub    $0xc,%esp
80103baf:	50                   	push   %eax
80103bb0:	e8 2d 10 00 00       	call   80104be2 <acquire>
80103bb5:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103bb8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103bbc:	74 23                	je     80103be1 <pipeclose+0x3e>
    p->writeopen = 0;
80103bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc1:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103bc8:	00 00 00 
    wakeup(&p->nread);
80103bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80103bce:	05 34 02 00 00       	add    $0x234,%eax
80103bd3:	83 ec 0c             	sub    $0xc,%esp
80103bd6:	50                   	push   %eax
80103bd7:	e8 d2 0c 00 00       	call   801048ae <wakeup>
80103bdc:	83 c4 10             	add    $0x10,%esp
80103bdf:	eb 21                	jmp    80103c02 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103be1:	8b 45 08             	mov    0x8(%ebp),%eax
80103be4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103beb:	00 00 00 
    wakeup(&p->nwrite);
80103bee:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf1:	05 38 02 00 00       	add    $0x238,%eax
80103bf6:	83 ec 0c             	sub    $0xc,%esp
80103bf9:	50                   	push   %eax
80103bfa:	e8 af 0c 00 00       	call   801048ae <wakeup>
80103bff:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103c02:	8b 45 08             	mov    0x8(%ebp),%eax
80103c05:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c0b:	85 c0                	test   %eax,%eax
80103c0d:	75 2c                	jne    80103c3b <pipeclose+0x98>
80103c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c12:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103c18:	85 c0                	test   %eax,%eax
80103c1a:	75 1f                	jne    80103c3b <pipeclose+0x98>
    release(&p->lock);
80103c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1f:	83 ec 0c             	sub    $0xc,%esp
80103c22:	50                   	push   %eax
80103c23:	e8 28 10 00 00       	call   80104c50 <release>
80103c28:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103c2b:	83 ec 0c             	sub    $0xc,%esp
80103c2e:	ff 75 08             	push   0x8(%ebp)
80103c31:	e8 b4 ef ff ff       	call   80102bea <kfree>
80103c36:	83 c4 10             	add    $0x10,%esp
80103c39:	eb 10                	jmp    80103c4b <pipeclose+0xa8>
  } else
    release(&p->lock);
80103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3e:	83 ec 0c             	sub    $0xc,%esp
80103c41:	50                   	push   %eax
80103c42:	e8 09 10 00 00       	call   80104c50 <release>
80103c47:	83 c4 10             	add    $0x10,%esp
}
80103c4a:	90                   	nop
80103c4b:	90                   	nop
80103c4c:	c9                   	leave  
80103c4d:	c3                   	ret    

80103c4e <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103c4e:	55                   	push   %ebp
80103c4f:	89 e5                	mov    %esp,%ebp
80103c51:	53                   	push   %ebx
80103c52:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103c55:	8b 45 08             	mov    0x8(%ebp),%eax
80103c58:	83 ec 0c             	sub    $0xc,%esp
80103c5b:	50                   	push   %eax
80103c5c:	e8 81 0f 00 00       	call   80104be2 <acquire>
80103c61:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103c64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c6b:	e9 ad 00 00 00       	jmp    80103d1d <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103c70:	8b 45 08             	mov    0x8(%ebp),%eax
80103c73:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c79:	85 c0                	test   %eax,%eax
80103c7b:	74 0c                	je     80103c89 <pipewrite+0x3b>
80103c7d:	e8 92 02 00 00       	call   80103f14 <myproc>
80103c82:	8b 40 24             	mov    0x24(%eax),%eax
80103c85:	85 c0                	test   %eax,%eax
80103c87:	74 19                	je     80103ca2 <pipewrite+0x54>
        release(&p->lock);
80103c89:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	50                   	push   %eax
80103c90:	e8 bb 0f 00 00       	call   80104c50 <release>
80103c95:	83 c4 10             	add    $0x10,%esp
        return -1;
80103c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c9d:	e9 a9 00 00 00       	jmp    80103d4b <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80103ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca5:	05 34 02 00 00       	add    $0x234,%eax
80103caa:	83 ec 0c             	sub    $0xc,%esp
80103cad:	50                   	push   %eax
80103cae:	e8 fb 0b 00 00       	call   801048ae <wakeup>
80103cb3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103cbc:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc2:	83 ec 08             	sub    $0x8,%esp
80103cc5:	50                   	push   %eax
80103cc6:	52                   	push   %edx
80103cc7:	e8 fb 0a 00 00       	call   801047c7 <sleep>
80103ccc:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd2:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103cdb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ce1:	05 00 02 00 00       	add    $0x200,%eax
80103ce6:	39 c2                	cmp    %eax,%edx
80103ce8:	74 86                	je     80103c70 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ced:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103cfc:	8d 48 01             	lea    0x1(%eax),%ecx
80103cff:	8b 55 08             	mov    0x8(%ebp),%edx
80103d02:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103d08:	25 ff 01 00 00       	and    $0x1ff,%eax
80103d0d:	89 c1                	mov    %eax,%ecx
80103d0f:	0f b6 13             	movzbl (%ebx),%edx
80103d12:	8b 45 08             	mov    0x8(%ebp),%eax
80103d15:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103d19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d20:	3b 45 10             	cmp    0x10(%ebp),%eax
80103d23:	7c aa                	jl     80103ccf <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103d25:	8b 45 08             	mov    0x8(%ebp),%eax
80103d28:	05 34 02 00 00       	add    $0x234,%eax
80103d2d:	83 ec 0c             	sub    $0xc,%esp
80103d30:	50                   	push   %eax
80103d31:	e8 78 0b 00 00       	call   801048ae <wakeup>
80103d36:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d39:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3c:	83 ec 0c             	sub    $0xc,%esp
80103d3f:	50                   	push   %eax
80103d40:	e8 0b 0f 00 00       	call   80104c50 <release>
80103d45:	83 c4 10             	add    $0x10,%esp
  return n;
80103d48:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d4e:	c9                   	leave  
80103d4f:	c3                   	ret    

80103d50 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103d50:	55                   	push   %ebp
80103d51:	89 e5                	mov    %esp,%ebp
80103d53:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103d56:	8b 45 08             	mov    0x8(%ebp),%eax
80103d59:	83 ec 0c             	sub    $0xc,%esp
80103d5c:	50                   	push   %eax
80103d5d:	e8 80 0e 00 00       	call   80104be2 <acquire>
80103d62:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d65:	eb 3e                	jmp    80103da5 <piperead+0x55>
    if(myproc()->killed){
80103d67:	e8 a8 01 00 00       	call   80103f14 <myproc>
80103d6c:	8b 40 24             	mov    0x24(%eax),%eax
80103d6f:	85 c0                	test   %eax,%eax
80103d71:	74 19                	je     80103d8c <piperead+0x3c>
      release(&p->lock);
80103d73:	8b 45 08             	mov    0x8(%ebp),%eax
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	50                   	push   %eax
80103d7a:	e8 d1 0e 00 00       	call   80104c50 <release>
80103d7f:	83 c4 10             	add    $0x10,%esp
      return -1;
80103d82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d87:	e9 be 00 00 00       	jmp    80103e4a <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8f:	8b 55 08             	mov    0x8(%ebp),%edx
80103d92:	81 c2 34 02 00 00    	add    $0x234,%edx
80103d98:	83 ec 08             	sub    $0x8,%esp
80103d9b:	50                   	push   %eax
80103d9c:	52                   	push   %edx
80103d9d:	e8 25 0a 00 00       	call   801047c7 <sleep>
80103da2:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103da5:	8b 45 08             	mov    0x8(%ebp),%eax
80103da8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dae:	8b 45 08             	mov    0x8(%ebp),%eax
80103db1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103db7:	39 c2                	cmp    %eax,%edx
80103db9:	75 0d                	jne    80103dc8 <piperead+0x78>
80103dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbe:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dc4:	85 c0                	test   %eax,%eax
80103dc6:	75 9f                	jne    80103d67 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103dc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dcf:	eb 48                	jmp    80103e19 <piperead+0xc9>
    if(p->nread == p->nwrite)
80103dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dda:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103de3:	39 c2                	cmp    %eax,%edx
80103de5:	74 3c                	je     80103e23 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103de7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dea:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103df0:	8d 48 01             	lea    0x1(%eax),%ecx
80103df3:	8b 55 08             	mov    0x8(%ebp),%edx
80103df6:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103dfc:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e01:	89 c1                	mov    %eax,%ecx
80103e03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e09:	01 c2                	add    %eax,%edx
80103e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0e:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103e13:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103e15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1c:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e1f:	7c b0                	jl     80103dd1 <piperead+0x81>
80103e21:	eb 01                	jmp    80103e24 <piperead+0xd4>
      break;
80103e23:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103e24:	8b 45 08             	mov    0x8(%ebp),%eax
80103e27:	05 38 02 00 00       	add    $0x238,%eax
80103e2c:	83 ec 0c             	sub    $0xc,%esp
80103e2f:	50                   	push   %eax
80103e30:	e8 79 0a 00 00       	call   801048ae <wakeup>
80103e35:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	50                   	push   %eax
80103e3f:	e8 0c 0e 00 00       	call   80104c50 <release>
80103e44:	83 c4 10             	add    $0x10,%esp
  return i;
80103e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103e4a:	c9                   	leave  
80103e4b:	c3                   	ret    

80103e4c <readeflags>:
{
80103e4c:	55                   	push   %ebp
80103e4d:	89 e5                	mov    %esp,%ebp
80103e4f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e52:	9c                   	pushf  
80103e53:	58                   	pop    %eax
80103e54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103e57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103e5a:	c9                   	leave  
80103e5b:	c3                   	ret    

80103e5c <sti>:
{
80103e5c:	55                   	push   %ebp
80103e5d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103e5f:	fb                   	sti    
}
80103e60:	90                   	nop
80103e61:	5d                   	pop    %ebp
80103e62:	c3                   	ret    

80103e63 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103e63:	55                   	push   %ebp
80103e64:	89 e5                	mov    %esp,%ebp
80103e66:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103e69:	83 ec 08             	sub    $0x8,%esp
80103e6c:	68 b4 a6 10 80       	push   $0x8010a6b4
80103e71:	68 40 72 11 80       	push   $0x80117240
80103e76:	e8 45 0d 00 00       	call   80104bc0 <initlock>
80103e7b:	83 c4 10             	add    $0x10,%esp
}
80103e7e:	90                   	nop
80103e7f:	c9                   	leave  
80103e80:	c3                   	ret    

80103e81 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103e81:	55                   	push   %ebp
80103e82:	89 e5                	mov    %esp,%ebp
80103e84:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e87:	e8 10 00 00 00       	call   80103e9c <mycpu>
80103e8c:	2d c0 9a 11 80       	sub    $0x80119ac0,%eax
80103e91:	c1 f8 04             	sar    $0x4,%eax
80103e94:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103e9a:	c9                   	leave  
80103e9b:	c3                   	ret    

80103e9c <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103e9c:	55                   	push   %ebp
80103e9d:	89 e5                	mov    %esp,%ebp
80103e9f:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ea2:	e8 a5 ff ff ff       	call   80103e4c <readeflags>
80103ea7:	25 00 02 00 00       	and    $0x200,%eax
80103eac:	85 c0                	test   %eax,%eax
80103eae:	74 0d                	je     80103ebd <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103eb0:	83 ec 0c             	sub    $0xc,%esp
80103eb3:	68 bc a6 10 80       	push   $0x8010a6bc
80103eb8:	e8 ec c6 ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103ebd:	e8 1c f1 ff ff       	call   80102fde <lapicid>
80103ec2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ec5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ecc:	eb 2d                	jmp    80103efb <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ed7:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80103edc:	0f b6 00             	movzbl (%eax),%eax
80103edf:	0f b6 c0             	movzbl %al,%eax
80103ee2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103ee5:	75 10                	jne    80103ef7 <mycpu+0x5b>
      return &cpus[i];
80103ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eea:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ef0:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80103ef5:	eb 1b                	jmp    80103f12 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103ef7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103efb:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80103f00:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103f03:	7c c9                	jl     80103ece <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103f05:	83 ec 0c             	sub    $0xc,%esp
80103f08:	68 e2 a6 10 80       	push   $0x8010a6e2
80103f0d:	e8 97 c6 ff ff       	call   801005a9 <panic>
}
80103f12:	c9                   	leave  
80103f13:	c3                   	ret    

80103f14 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f14:	55                   	push   %ebp
80103f15:	89 e5                	mov    %esp,%ebp
80103f17:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103f1a:	e8 2e 0e 00 00       	call   80104d4d <pushcli>
  c = mycpu();
80103f1f:	e8 78 ff ff ff       	call   80103e9c <mycpu>
80103f24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f33:	e8 62 0e 00 00       	call   80104d9a <popcli>
  return p;
80103f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f3b:	c9                   	leave  
80103f3c:	c3                   	ret    

80103f3d <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f3d:	55                   	push   %ebp
80103f3e:	89 e5                	mov    %esp,%ebp
80103f40:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f43:	83 ec 0c             	sub    $0xc,%esp
80103f46:	68 40 72 11 80       	push   $0x80117240
80103f4b:	e8 92 0c 00 00       	call   80104be2 <acquire>
80103f50:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f53:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f5a:	eb 0e                	jmp    80103f6a <allocproc+0x2d>
    if(p->state == UNUSED){
80103f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f5f:	8b 40 0c             	mov    0xc(%eax),%eax
80103f62:	85 c0                	test   %eax,%eax
80103f64:	74 27                	je     80103f8d <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f66:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103f6a:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80103f71:	72 e9                	jb     80103f5c <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103f73:	83 ec 0c             	sub    $0xc,%esp
80103f76:	68 40 72 11 80       	push   $0x80117240
80103f7b:	e8 d0 0c 00 00       	call   80104c50 <release>
80103f80:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f83:	b8 00 00 00 00       	mov    $0x0,%eax
80103f88:	e9 b2 00 00 00       	jmp    8010403f <allocproc+0x102>
      goto found;
80103f8d:	90                   	nop

found:
  p->state = EMBRYO;
80103f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f91:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103f98:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103f9d:	8d 50 01             	lea    0x1(%eax),%edx
80103fa0:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fa6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fa9:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103fac:	83 ec 0c             	sub    $0xc,%esp
80103faf:	68 40 72 11 80       	push   $0x80117240
80103fb4:	e8 97 0c 00 00       	call   80104c50 <release>
80103fb9:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103fbc:	e8 c3 ec ff ff       	call   80102c84 <kalloc>
80103fc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fc4:	89 42 08             	mov    %eax,0x8(%edx)
80103fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fca:	8b 40 08             	mov    0x8(%eax),%eax
80103fcd:	85 c0                	test   %eax,%eax
80103fcf:	75 11                	jne    80103fe2 <allocproc+0xa5>
    p->state = UNUSED;
80103fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103fdb:	b8 00 00 00 00       	mov    $0x0,%eax
80103fe0:	eb 5d                	jmp    8010403f <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe5:	8b 40 08             	mov    0x8(%eax),%eax
80103fe8:	05 00 10 00 00       	add    $0x1000,%eax
80103fed:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103ff0:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ffa:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ffd:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104001:	ba 1b 62 10 80       	mov    $0x8010621b,%edx
80104006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104009:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010400b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010400f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104012:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104015:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010401e:	83 ec 04             	sub    $0x4,%esp
80104021:	6a 14                	push   $0x14
80104023:	6a 00                	push   $0x0
80104025:	50                   	push   %eax
80104026:	e8 2d 0e 00 00       	call   80104e58 <memset>
8010402b:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010402e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104031:	8b 40 1c             	mov    0x1c(%eax),%eax
80104034:	ba 81 47 10 80       	mov    $0x80104781,%edx
80104039:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010403c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010403f:	c9                   	leave  
80104040:	c3                   	ret    

80104041 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104041:	55                   	push   %ebp
80104042:	89 e5                	mov    %esp,%ebp
80104044:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104047:	e8 f1 fe ff ff       	call   80103f3d <allocproc>
8010404c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010404f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104052:	a3 74 92 11 80       	mov    %eax,0x80119274
  if((p->pgdir = setupkvm()) == 0){
80104057:	e8 4c 37 00 00       	call   801077a8 <setupkvm>
8010405c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010405f:	89 42 04             	mov    %eax,0x4(%edx)
80104062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104065:	8b 40 04             	mov    0x4(%eax),%eax
80104068:	85 c0                	test   %eax,%eax
8010406a:	75 0d                	jne    80104079 <userinit+0x38>
    panic("userinit: out of memory?");
8010406c:	83 ec 0c             	sub    $0xc,%esp
8010406f:	68 f2 a6 10 80       	push   $0x8010a6f2
80104074:	e8 30 c5 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104079:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010407e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104081:	8b 40 04             	mov    0x4(%eax),%eax
80104084:	83 ec 04             	sub    $0x4,%esp
80104087:	52                   	push   %edx
80104088:	68 ec f4 10 80       	push   $0x8010f4ec
8010408d:	50                   	push   %eax
8010408e:	e8 d1 39 00 00       	call   80107a64 <inituvm>
80104093:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104099:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010409f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a2:	8b 40 18             	mov    0x18(%eax),%eax
801040a5:	83 ec 04             	sub    $0x4,%esp
801040a8:	6a 4c                	push   $0x4c
801040aa:	6a 00                	push   $0x0
801040ac:	50                   	push   %eax
801040ad:	e8 a6 0d 00 00       	call   80104e58 <memset>
801040b2:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801040b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b8:	8b 40 18             	mov    0x18(%eax),%eax
801040bb:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801040c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c4:	8b 40 18             	mov    0x18(%eax),%eax
801040c7:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	8b 50 18             	mov    0x18(%eax),%edx
801040d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d6:	8b 40 18             	mov    0x18(%eax),%eax
801040d9:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040dd:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801040e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e4:	8b 50 18             	mov    0x18(%eax),%edx
801040e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ea:	8b 40 18             	mov    0x18(%eax),%eax
801040ed:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040f1:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801040f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f8:	8b 40 18             	mov    0x18(%eax),%eax
801040fb:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104105:	8b 40 18             	mov    0x18(%eax),%eax
80104108:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010410f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104112:	8b 40 18             	mov    0x18(%eax),%eax
80104115:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411f:	83 c0 6c             	add    $0x6c,%eax
80104122:	83 ec 04             	sub    $0x4,%esp
80104125:	6a 10                	push   $0x10
80104127:	68 0b a7 10 80       	push   $0x8010a70b
8010412c:	50                   	push   %eax
8010412d:	e8 29 0f 00 00       	call   8010505b <safestrcpy>
80104132:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104135:	83 ec 0c             	sub    $0xc,%esp
80104138:	68 14 a7 10 80       	push   $0x8010a714
8010413d:	e8 db e3 ff ff       	call   8010251d <namei>
80104142:	83 c4 10             	add    $0x10,%esp
80104145:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104148:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010414b:	83 ec 0c             	sub    $0xc,%esp
8010414e:	68 40 72 11 80       	push   $0x80117240
80104153:	e8 8a 0a 00 00       	call   80104be2 <acquire>
80104158:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
8010415b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104165:	83 ec 0c             	sub    $0xc,%esp
80104168:	68 40 72 11 80       	push   $0x80117240
8010416d:	e8 de 0a 00 00       	call   80104c50 <release>
80104172:	83 c4 10             	add    $0x10,%esp
}
80104175:	90                   	nop
80104176:	c9                   	leave  
80104177:	c3                   	ret    

80104178 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104178:	55                   	push   %ebp
80104179:	89 e5                	mov    %esp,%ebp
8010417b:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010417e:	e8 91 fd ff ff       	call   80103f14 <myproc>
80104183:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104186:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104189:	8b 00                	mov    (%eax),%eax
8010418b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010418e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104192:	7e 2e                	jle    801041c2 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104194:	8b 55 08             	mov    0x8(%ebp),%edx
80104197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419a:	01 c2                	add    %eax,%edx
8010419c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010419f:	8b 40 04             	mov    0x4(%eax),%eax
801041a2:	83 ec 04             	sub    $0x4,%esp
801041a5:	52                   	push   %edx
801041a6:	ff 75 f4             	push   -0xc(%ebp)
801041a9:	50                   	push   %eax
801041aa:	e8 f2 39 00 00       	call   80107ba1 <allocuvm>
801041af:	83 c4 10             	add    $0x10,%esp
801041b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041b9:	75 3b                	jne    801041f6 <growproc+0x7e>
      return -1;
801041bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c0:	eb 4f                	jmp    80104211 <growproc+0x99>
  } else if(n < 0){
801041c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041c6:	79 2e                	jns    801041f6 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041c8:	8b 55 08             	mov    0x8(%ebp),%edx
801041cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ce:	01 c2                	add    %eax,%edx
801041d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041d3:	8b 40 04             	mov    0x4(%eax),%eax
801041d6:	83 ec 04             	sub    $0x4,%esp
801041d9:	52                   	push   %edx
801041da:	ff 75 f4             	push   -0xc(%ebp)
801041dd:	50                   	push   %eax
801041de:	e8 c3 3a 00 00       	call   80107ca6 <deallocuvm>
801041e3:	83 c4 10             	add    $0x10,%esp
801041e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041ed:	75 07                	jne    801041f6 <growproc+0x7e>
      return -1;
801041ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f4:	eb 1b                	jmp    80104211 <growproc+0x99>
  }
  curproc->sz = sz;
801041f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fc:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801041fe:	83 ec 0c             	sub    $0xc,%esp
80104201:	ff 75 f0             	push   -0x10(%ebp)
80104204:	e8 bc 36 00 00       	call   801078c5 <switchuvm>
80104209:	83 c4 10             	add    $0x10,%esp
  return 0;
8010420c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104211:	c9                   	leave  
80104212:	c3                   	ret    

80104213 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104213:	55                   	push   %ebp
80104214:	89 e5                	mov    %esp,%ebp
80104216:	57                   	push   %edi
80104217:	56                   	push   %esi
80104218:	53                   	push   %ebx
80104219:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010421c:	e8 f3 fc ff ff       	call   80103f14 <myproc>
80104221:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104224:	e8 14 fd ff ff       	call   80103f3d <allocproc>
80104229:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010422c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104230:	75 0a                	jne    8010423c <fork+0x29>
    return -1;
80104232:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104237:	e9 48 01 00 00       	jmp    80104384 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010423c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010423f:	8b 10                	mov    (%eax),%edx
80104241:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104244:	8b 40 04             	mov    0x4(%eax),%eax
80104247:	83 ec 08             	sub    $0x8,%esp
8010424a:	52                   	push   %edx
8010424b:	50                   	push   %eax
8010424c:	e8 f3 3b 00 00       	call   80107e44 <copyuvm>
80104251:	83 c4 10             	add    $0x10,%esp
80104254:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104257:	89 42 04             	mov    %eax,0x4(%edx)
8010425a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010425d:	8b 40 04             	mov    0x4(%eax),%eax
80104260:	85 c0                	test   %eax,%eax
80104262:	75 30                	jne    80104294 <fork+0x81>
    kfree(np->kstack);
80104264:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104267:	8b 40 08             	mov    0x8(%eax),%eax
8010426a:	83 ec 0c             	sub    $0xc,%esp
8010426d:	50                   	push   %eax
8010426e:	e8 77 e9 ff ff       	call   80102bea <kfree>
80104273:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104276:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104279:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104280:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104283:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010428a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428f:	e9 f0 00 00 00       	jmp    80104384 <fork+0x171>
  }
  np->sz = curproc->sz;
80104294:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104297:	8b 10                	mov    (%eax),%edx
80104299:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010429c:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010429e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042a4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801042a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042aa:	8b 48 18             	mov    0x18(%eax),%ecx
801042ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042b0:	8b 40 18             	mov    0x18(%eax),%eax
801042b3:	89 c2                	mov    %eax,%edx
801042b5:	89 cb                	mov    %ecx,%ebx
801042b7:	b8 13 00 00 00       	mov    $0x13,%eax
801042bc:	89 d7                	mov    %edx,%edi
801042be:	89 de                	mov    %ebx,%esi
801042c0:	89 c1                	mov    %eax,%ecx
801042c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801042c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042c7:	8b 40 18             	mov    0x18(%eax),%eax
801042ca:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801042d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801042d8:	eb 3b                	jmp    80104315 <fork+0x102>
    if(curproc->ofile[i])
801042da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042e0:	83 c2 08             	add    $0x8,%edx
801042e3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042e7:	85 c0                	test   %eax,%eax
801042e9:	74 26                	je     80104311 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
801042eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042f1:	83 c2 08             	add    $0x8,%edx
801042f4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042f8:	83 ec 0c             	sub    $0xc,%esp
801042fb:	50                   	push   %eax
801042fc:	e8 49 cd ff ff       	call   8010104a <filedup>
80104301:	83 c4 10             	add    $0x10,%esp
80104304:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104307:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010430a:	83 c1 08             	add    $0x8,%ecx
8010430d:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104311:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104315:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104319:	7e bf                	jle    801042da <fork+0xc7>
  np->cwd = idup(curproc->cwd);
8010431b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010431e:	8b 40 68             	mov    0x68(%eax),%eax
80104321:	83 ec 0c             	sub    $0xc,%esp
80104324:	50                   	push   %eax
80104325:	e8 86 d6 ff ff       	call   801019b0 <idup>
8010432a:	83 c4 10             	add    $0x10,%esp
8010432d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104330:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104333:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104336:	8d 50 6c             	lea    0x6c(%eax),%edx
80104339:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010433c:	83 c0 6c             	add    $0x6c,%eax
8010433f:	83 ec 04             	sub    $0x4,%esp
80104342:	6a 10                	push   $0x10
80104344:	52                   	push   %edx
80104345:	50                   	push   %eax
80104346:	e8 10 0d 00 00       	call   8010505b <safestrcpy>
8010434b:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010434e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104351:	8b 40 10             	mov    0x10(%eax),%eax
80104354:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104357:	83 ec 0c             	sub    $0xc,%esp
8010435a:	68 40 72 11 80       	push   $0x80117240
8010435f:	e8 7e 08 00 00       	call   80104be2 <acquire>
80104364:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104367:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010436a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104371:	83 ec 0c             	sub    $0xc,%esp
80104374:	68 40 72 11 80       	push   $0x80117240
80104379:	e8 d2 08 00 00       	call   80104c50 <release>
8010437e:	83 c4 10             	add    $0x10,%esp

  return pid;
80104381:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104384:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104387:	5b                   	pop    %ebx
80104388:	5e                   	pop    %esi
80104389:	5f                   	pop    %edi
8010438a:	5d                   	pop    %ebp
8010438b:	c3                   	ret    

8010438c <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010438c:	55                   	push   %ebp
8010438d:	89 e5                	mov    %esp,%ebp
8010438f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104392:	e8 7d fb ff ff       	call   80103f14 <myproc>
80104397:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010439a:	a1 74 92 11 80       	mov    0x80119274,%eax
8010439f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801043a2:	75 0d                	jne    801043b1 <exit+0x25>
    panic("init exiting");
801043a4:	83 ec 0c             	sub    $0xc,%esp
801043a7:	68 16 a7 10 80       	push   $0x8010a716
801043ac:	e8 f8 c1 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801043b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801043b8:	eb 3f                	jmp    801043f9 <exit+0x6d>
    if(curproc->ofile[fd]){
801043ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043c0:	83 c2 08             	add    $0x8,%edx
801043c3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043c7:	85 c0                	test   %eax,%eax
801043c9:	74 2a                	je     801043f5 <exit+0x69>
      fileclose(curproc->ofile[fd]);
801043cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043d1:	83 c2 08             	add    $0x8,%edx
801043d4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043d8:	83 ec 0c             	sub    $0xc,%esp
801043db:	50                   	push   %eax
801043dc:	e8 ba cc ff ff       	call   8010109b <fileclose>
801043e1:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801043e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043ea:	83 c2 08             	add    $0x8,%edx
801043ed:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801043f4:	00 
  for(fd = 0; fd < NOFILE; fd++){
801043f5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801043f9:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801043fd:	7e bb                	jle    801043ba <exit+0x2e>
    }
  }

  begin_op();
801043ff:	e8 1c f1 ff ff       	call   80103520 <begin_op>
  iput(curproc->cwd);
80104404:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104407:	8b 40 68             	mov    0x68(%eax),%eax
8010440a:	83 ec 0c             	sub    $0xc,%esp
8010440d:	50                   	push   %eax
8010440e:	e8 38 d7 ff ff       	call   80101b4b <iput>
80104413:	83 c4 10             	add    $0x10,%esp
  end_op();
80104416:	e8 91 f1 ff ff       	call   801035ac <end_op>
  curproc->cwd = 0;
8010441b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010441e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104425:	83 ec 0c             	sub    $0xc,%esp
80104428:	68 40 72 11 80       	push   $0x80117240
8010442d:	e8 b0 07 00 00       	call   80104be2 <acquire>
80104432:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104435:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104438:	8b 40 14             	mov    0x14(%eax),%eax
8010443b:	83 ec 0c             	sub    $0xc,%esp
8010443e:	50                   	push   %eax
8010443f:	e8 2a 04 00 00       	call   8010486e <wakeup1>
80104444:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104447:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
8010444e:	eb 37                	jmp    80104487 <exit+0xfb>
    if(p->parent == curproc){
80104450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104453:	8b 40 14             	mov    0x14(%eax),%eax
80104456:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104459:	75 28                	jne    80104483 <exit+0xf7>
      p->parent = initproc;
8010445b:	8b 15 74 92 11 80    	mov    0x80119274,%edx
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446a:	8b 40 0c             	mov    0xc(%eax),%eax
8010446d:	83 f8 05             	cmp    $0x5,%eax
80104470:	75 11                	jne    80104483 <exit+0xf7>
        wakeup1(initproc);
80104472:	a1 74 92 11 80       	mov    0x80119274,%eax
80104477:	83 ec 0c             	sub    $0xc,%esp
8010447a:	50                   	push   %eax
8010447b:	e8 ee 03 00 00       	call   8010486e <wakeup1>
80104480:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104483:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104487:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
8010448e:	72 c0                	jb     80104450 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104490:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104493:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010449a:	e8 ef 01 00 00       	call   8010468e <sched>
  panic("zombie exit");
8010449f:	83 ec 0c             	sub    $0xc,%esp
801044a2:	68 23 a7 10 80       	push   $0x8010a723
801044a7:	e8 fd c0 ff ff       	call   801005a9 <panic>

801044ac <uthread_init>:
}

int
uthread_init(int address){
801044ac:	55                   	push   %ebp
801044ad:	89 e5                	mov    %esp,%ebp
  return 0; //임시방편
801044af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044b4:	5d                   	pop    %ebp
801044b5:	c3                   	ret    

801044b6 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801044b6:	55                   	push   %ebp
801044b7:	89 e5                	mov    %esp,%ebp
801044b9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801044bc:	e8 53 fa ff ff       	call   80103f14 <myproc>
801044c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801044c4:	83 ec 0c             	sub    $0xc,%esp
801044c7:	68 40 72 11 80       	push   $0x80117240
801044cc:	e8 11 07 00 00       	call   80104be2 <acquire>
801044d1:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801044d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044db:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801044e2:	e9 a1 00 00 00       	jmp    80104588 <wait+0xd2>
      if(p->parent != curproc)
801044e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ea:	8b 40 14             	mov    0x14(%eax),%eax
801044ed:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801044f0:	0f 85 8d 00 00 00    	jne    80104583 <wait+0xcd>
        continue;
      havekids = 1;
801044f6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801044fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104500:	8b 40 0c             	mov    0xc(%eax),%eax
80104503:	83 f8 05             	cmp    $0x5,%eax
80104506:	75 7c                	jne    80104584 <wait+0xce>
        // Found one.
        pid = p->pid;
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	8b 40 10             	mov    0x10(%eax),%eax
8010450e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104514:	8b 40 08             	mov    0x8(%eax),%eax
80104517:	83 ec 0c             	sub    $0xc,%esp
8010451a:	50                   	push   %eax
8010451b:	e8 ca e6 ff ff       	call   80102bea <kfree>
80104520:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104526:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010452d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104530:	8b 40 04             	mov    0x4(%eax),%eax
80104533:	83 ec 0c             	sub    $0xc,%esp
80104536:	50                   	push   %eax
80104537:	e8 2e 38 00 00       	call   80107d6a <freevm>
8010453c:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010453f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104542:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104556:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010455a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104567:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010456e:	83 ec 0c             	sub    $0xc,%esp
80104571:	68 40 72 11 80       	push   $0x80117240
80104576:	e8 d5 06 00 00       	call   80104c50 <release>
8010457b:	83 c4 10             	add    $0x10,%esp
        return pid;
8010457e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104581:	eb 51                	jmp    801045d4 <wait+0x11e>
        continue;
80104583:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104584:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104588:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
8010458f:	0f 82 52 ff ff ff    	jb     801044e7 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104595:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104599:	74 0a                	je     801045a5 <wait+0xef>
8010459b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010459e:	8b 40 24             	mov    0x24(%eax),%eax
801045a1:	85 c0                	test   %eax,%eax
801045a3:	74 17                	je     801045bc <wait+0x106>
      release(&ptable.lock);
801045a5:	83 ec 0c             	sub    $0xc,%esp
801045a8:	68 40 72 11 80       	push   $0x80117240
801045ad:	e8 9e 06 00 00       	call   80104c50 <release>
801045b2:	83 c4 10             	add    $0x10,%esp
      return -1;
801045b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ba:	eb 18                	jmp    801045d4 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801045bc:	83 ec 08             	sub    $0x8,%esp
801045bf:	68 40 72 11 80       	push   $0x80117240
801045c4:	ff 75 ec             	push   -0x14(%ebp)
801045c7:	e8 fb 01 00 00       	call   801047c7 <sleep>
801045cc:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801045cf:	e9 00 ff ff ff       	jmp    801044d4 <wait+0x1e>
  }
}
801045d4:	c9                   	leave  
801045d5:	c3                   	ret    

801045d6 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801045d6:	55                   	push   %ebp
801045d7:	89 e5                	mov    %esp,%ebp
801045d9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801045dc:	e8 bb f8 ff ff       	call   80103e9c <mycpu>
801045e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801045e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045e7:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045ee:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801045f1:	e8 66 f8 ff ff       	call   80103e5c <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801045f6:	83 ec 0c             	sub    $0xc,%esp
801045f9:	68 40 72 11 80       	push   $0x80117240
801045fe:	e8 df 05 00 00       	call   80104be2 <acquire>
80104603:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104606:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
8010460d:	eb 61                	jmp    80104670 <scheduler+0x9a>
      if(p->state != RUNNABLE)
8010460f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104612:	8b 40 0c             	mov    0xc(%eax),%eax
80104615:	83 f8 03             	cmp    $0x3,%eax
80104618:	75 51                	jne    8010466b <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010461a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010461d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104620:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104626:	83 ec 0c             	sub    $0xc,%esp
80104629:	ff 75 f4             	push   -0xc(%ebp)
8010462c:	e8 94 32 00 00       	call   801078c5 <switchuvm>
80104631:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104637:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
8010463e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104641:	8b 40 1c             	mov    0x1c(%eax),%eax
80104644:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104647:	83 c2 04             	add    $0x4,%edx
8010464a:	83 ec 08             	sub    $0x8,%esp
8010464d:	50                   	push   %eax
8010464e:	52                   	push   %edx
8010464f:	e8 79 0a 00 00       	call   801050cd <swtch>
80104654:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104657:	e8 50 32 00 00       	call   801078ac <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010465c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010465f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104666:	00 00 00 
80104669:	eb 01                	jmp    8010466c <scheduler+0x96>
        continue;
8010466b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010466c:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104670:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104677:	72 96                	jb     8010460f <scheduler+0x39>
    }
    release(&ptable.lock);
80104679:	83 ec 0c             	sub    $0xc,%esp
8010467c:	68 40 72 11 80       	push   $0x80117240
80104681:	e8 ca 05 00 00       	call   80104c50 <release>
80104686:	83 c4 10             	add    $0x10,%esp
    sti();
80104689:	e9 63 ff ff ff       	jmp    801045f1 <scheduler+0x1b>

8010468e <sched>:
// Saves and restores intena because intena is a property of this kernel thread, not this CPU. 
// It should be proc->intena and proc->ncli, but that would break in the few places where a lock is held 
// but there's no process.
void
sched(void)
{
8010468e:	55                   	push   %ebp
8010468f:	89 e5                	mov    %esp,%ebp
80104691:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104694:	e8 7b f8 ff ff       	call   80103f14 <myproc>
80104699:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
8010469c:	83 ec 0c             	sub    $0xc,%esp
8010469f:	68 40 72 11 80       	push   $0x80117240
801046a4:	e8 74 06 00 00       	call   80104d1d <holding>
801046a9:	83 c4 10             	add    $0x10,%esp
801046ac:	85 c0                	test   %eax,%eax
801046ae:	75 0d                	jne    801046bd <sched+0x2f>
    panic("sched ptable.lock");
801046b0:	83 ec 0c             	sub    $0xc,%esp
801046b3:	68 2f a7 10 80       	push   $0x8010a72f
801046b8:	e8 ec be ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801046bd:	e8 da f7 ff ff       	call   80103e9c <mycpu>
801046c2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801046c8:	83 f8 01             	cmp    $0x1,%eax
801046cb:	74 0d                	je     801046da <sched+0x4c>
    panic("sched locks");
801046cd:	83 ec 0c             	sub    $0xc,%esp
801046d0:	68 41 a7 10 80       	push   $0x8010a741
801046d5:	e8 cf be ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801046da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046dd:	8b 40 0c             	mov    0xc(%eax),%eax
801046e0:	83 f8 04             	cmp    $0x4,%eax
801046e3:	75 0d                	jne    801046f2 <sched+0x64>
    panic("sched running");
801046e5:	83 ec 0c             	sub    $0xc,%esp
801046e8:	68 4d a7 10 80       	push   $0x8010a74d
801046ed:	e8 b7 be ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801046f2:	e8 55 f7 ff ff       	call   80103e4c <readeflags>
801046f7:	25 00 02 00 00       	and    $0x200,%eax
801046fc:	85 c0                	test   %eax,%eax
801046fe:	74 0d                	je     8010470d <sched+0x7f>
    panic("sched interruptible");
80104700:	83 ec 0c             	sub    $0xc,%esp
80104703:	68 5b a7 10 80       	push   $0x8010a75b
80104708:	e8 9c be ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010470d:	e8 8a f7 ff ff       	call   80103e9c <mycpu>
80104712:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104718:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010471b:	e8 7c f7 ff ff       	call   80103e9c <mycpu>
80104720:	8b 40 04             	mov    0x4(%eax),%eax
80104723:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104726:	83 c2 1c             	add    $0x1c,%edx
80104729:	83 ec 08             	sub    $0x8,%esp
8010472c:	50                   	push   %eax
8010472d:	52                   	push   %edx
8010472e:	e8 9a 09 00 00       	call   801050cd <swtch>
80104733:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104736:	e8 61 f7 ff ff       	call   80103e9c <mycpu>
8010473b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010473e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104744:	90                   	nop
80104745:	c9                   	leave  
80104746:	c3                   	ret    

80104747 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104747:	55                   	push   %ebp
80104748:	89 e5                	mov    %esp,%ebp
8010474a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010474d:	83 ec 0c             	sub    $0xc,%esp
80104750:	68 40 72 11 80       	push   $0x80117240
80104755:	e8 88 04 00 00       	call   80104be2 <acquire>
8010475a:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010475d:	e8 b2 f7 ff ff       	call   80103f14 <myproc>
80104762:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104769:	e8 20 ff ff ff       	call   8010468e <sched>
  release(&ptable.lock);
8010476e:	83 ec 0c             	sub    $0xc,%esp
80104771:	68 40 72 11 80       	push   $0x80117240
80104776:	e8 d5 04 00 00       	call   80104c50 <release>
8010477b:	83 c4 10             	add    $0x10,%esp
}
8010477e:	90                   	nop
8010477f:	c9                   	leave  
80104780:	c3                   	ret    

80104781 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104781:	55                   	push   %ebp
80104782:	89 e5                	mov    %esp,%ebp
80104784:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104787:	83 ec 0c             	sub    $0xc,%esp
8010478a:	68 40 72 11 80       	push   $0x80117240
8010478f:	e8 bc 04 00 00       	call   80104c50 <release>
80104794:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104797:	a1 04 f0 10 80       	mov    0x8010f004,%eax
8010479c:	85 c0                	test   %eax,%eax
8010479e:	74 24                	je     801047c4 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801047a0:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801047a7:	00 00 00 
    iinit(ROOTDEV);
801047aa:	83 ec 0c             	sub    $0xc,%esp
801047ad:	6a 01                	push   $0x1
801047af:	e8 c4 ce ff ff       	call   80101678 <iinit>
801047b4:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801047b7:	83 ec 0c             	sub    $0xc,%esp
801047ba:	6a 01                	push   $0x1
801047bc:	e8 40 eb ff ff       	call   80103301 <initlog>
801047c1:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801047c4:	90                   	nop
801047c5:	c9                   	leave  
801047c6:	c3                   	ret    

801047c7 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801047c7:	55                   	push   %ebp
801047c8:	89 e5                	mov    %esp,%ebp
801047ca:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801047cd:	e8 42 f7 ff ff       	call   80103f14 <myproc>
801047d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801047d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047d9:	75 0d                	jne    801047e8 <sleep+0x21>
    panic("sleep");
801047db:	83 ec 0c             	sub    $0xc,%esp
801047de:	68 6f a7 10 80       	push   $0x8010a76f
801047e3:	e8 c1 bd ff ff       	call   801005a9 <panic>

  if(lk == 0)
801047e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047ec:	75 0d                	jne    801047fb <sleep+0x34>
    panic("sleep without lk");
801047ee:	83 ec 0c             	sub    $0xc,%esp
801047f1:	68 75 a7 10 80       	push   $0x8010a775
801047f6:	e8 ae bd ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801047fb:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104802:	74 1e                	je     80104822 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104804:	83 ec 0c             	sub    $0xc,%esp
80104807:	68 40 72 11 80       	push   $0x80117240
8010480c:	e8 d1 03 00 00       	call   80104be2 <acquire>
80104811:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104814:	83 ec 0c             	sub    $0xc,%esp
80104817:	ff 75 0c             	push   0xc(%ebp)
8010481a:	e8 31 04 00 00       	call   80104c50 <release>
8010481f:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104825:	8b 55 08             	mov    0x8(%ebp),%edx
80104828:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010482b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482e:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104835:	e8 54 fe ff ff       	call   8010468e <sched>

  // Tidy up.
  p->chan = 0;
8010483a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483d:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104844:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
8010484b:	74 1e                	je     8010486b <sleep+0xa4>
    release(&ptable.lock);
8010484d:	83 ec 0c             	sub    $0xc,%esp
80104850:	68 40 72 11 80       	push   $0x80117240
80104855:	e8 f6 03 00 00       	call   80104c50 <release>
8010485a:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010485d:	83 ec 0c             	sub    $0xc,%esp
80104860:	ff 75 0c             	push   0xc(%ebp)
80104863:	e8 7a 03 00 00       	call   80104be2 <acquire>
80104868:	83 c4 10             	add    $0x10,%esp
  }
}
8010486b:	90                   	nop
8010486c:	c9                   	leave  
8010486d:	c3                   	ret    

8010486e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010486e:	55                   	push   %ebp
8010486f:	89 e5                	mov    %esp,%ebp
80104871:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104874:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
8010487b:	eb 24                	jmp    801048a1 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
8010487d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104880:	8b 40 0c             	mov    0xc(%eax),%eax
80104883:	83 f8 02             	cmp    $0x2,%eax
80104886:	75 15                	jne    8010489d <wakeup1+0x2f>
80104888:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010488b:	8b 40 20             	mov    0x20(%eax),%eax
8010488e:	39 45 08             	cmp    %eax,0x8(%ebp)
80104891:	75 0a                	jne    8010489d <wakeup1+0x2f>
      p->state = RUNNABLE;
80104893:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104896:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010489d:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801048a1:	81 7d fc 74 92 11 80 	cmpl   $0x80119274,-0x4(%ebp)
801048a8:	72 d3                	jb     8010487d <wakeup1+0xf>
}
801048aa:	90                   	nop
801048ab:	90                   	nop
801048ac:	c9                   	leave  
801048ad:	c3                   	ret    

801048ae <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048ae:	55                   	push   %ebp
801048af:	89 e5                	mov    %esp,%ebp
801048b1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801048b4:	83 ec 0c             	sub    $0xc,%esp
801048b7:	68 40 72 11 80       	push   $0x80117240
801048bc:	e8 21 03 00 00       	call   80104be2 <acquire>
801048c1:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801048c4:	83 ec 0c             	sub    $0xc,%esp
801048c7:	ff 75 08             	push   0x8(%ebp)
801048ca:	e8 9f ff ff ff       	call   8010486e <wakeup1>
801048cf:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801048d2:	83 ec 0c             	sub    $0xc,%esp
801048d5:	68 40 72 11 80       	push   $0x80117240
801048da:	e8 71 03 00 00       	call   80104c50 <release>
801048df:	83 c4 10             	add    $0x10,%esp
}
801048e2:	90                   	nop
801048e3:	c9                   	leave  
801048e4:	c3                   	ret    

801048e5 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801048e5:	55                   	push   %ebp
801048e6:	89 e5                	mov    %esp,%ebp
801048e8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048eb:	83 ec 0c             	sub    $0xc,%esp
801048ee:	68 40 72 11 80       	push   $0x80117240
801048f3:	e8 ea 02 00 00       	call   80104be2 <acquire>
801048f8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048fb:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104902:	eb 45                	jmp    80104949 <kill+0x64>
    if(p->pid == pid){
80104904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104907:	8b 40 10             	mov    0x10(%eax),%eax
8010490a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010490d:	75 36                	jne    80104945 <kill+0x60>
      p->killed = 1;
8010490f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104912:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491c:	8b 40 0c             	mov    0xc(%eax),%eax
8010491f:	83 f8 02             	cmp    $0x2,%eax
80104922:	75 0a                	jne    8010492e <kill+0x49>
        p->state = RUNNABLE;
80104924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104927:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010492e:	83 ec 0c             	sub    $0xc,%esp
80104931:	68 40 72 11 80       	push   $0x80117240
80104936:	e8 15 03 00 00       	call   80104c50 <release>
8010493b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010493e:	b8 00 00 00 00       	mov    $0x0,%eax
80104943:	eb 22                	jmp    80104967 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104945:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104949:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104950:	72 b2                	jb     80104904 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104952:	83 ec 0c             	sub    $0xc,%esp
80104955:	68 40 72 11 80       	push   $0x80117240
8010495a:	e8 f1 02 00 00       	call   80104c50 <release>
8010495f:	83 c4 10             	add    $0x10,%esp
  return -1;
80104962:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104967:	c9                   	leave  
80104968:	c3                   	ret    

80104969 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104969:	55                   	push   %ebp
8010496a:	89 e5                	mov    %esp,%ebp
8010496c:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010496f:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
80104976:	e9 d7 00 00 00       	jmp    80104a52 <procdump+0xe9>
    if(p->state == UNUSED)
8010497b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010497e:	8b 40 0c             	mov    0xc(%eax),%eax
80104981:	85 c0                	test   %eax,%eax
80104983:	0f 84 c4 00 00 00    	je     80104a4d <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010498c:	8b 40 0c             	mov    0xc(%eax),%eax
8010498f:	83 f8 05             	cmp    $0x5,%eax
80104992:	77 23                	ja     801049b7 <procdump+0x4e>
80104994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104997:	8b 40 0c             	mov    0xc(%eax),%eax
8010499a:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049a1:	85 c0                	test   %eax,%eax
801049a3:	74 12                	je     801049b7 <procdump+0x4e>
      state = states[p->state];
801049a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049a8:	8b 40 0c             	mov    0xc(%eax),%eax
801049ab:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801049b5:	eb 07                	jmp    801049be <procdump+0x55>
    else
      state = "???";
801049b7:	c7 45 ec 86 a7 10 80 	movl   $0x8010a786,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049c1:	8d 50 6c             	lea    0x6c(%eax),%edx
801049c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049c7:	8b 40 10             	mov    0x10(%eax),%eax
801049ca:	52                   	push   %edx
801049cb:	ff 75 ec             	push   -0x14(%ebp)
801049ce:	50                   	push   %eax
801049cf:	68 8a a7 10 80       	push   $0x8010a78a
801049d4:	e8 1b ba ff ff       	call   801003f4 <cprintf>
801049d9:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801049dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049df:	8b 40 0c             	mov    0xc(%eax),%eax
801049e2:	83 f8 02             	cmp    $0x2,%eax
801049e5:	75 54                	jne    80104a3b <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801049e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049ea:	8b 40 1c             	mov    0x1c(%eax),%eax
801049ed:	8b 40 0c             	mov    0xc(%eax),%eax
801049f0:	83 c0 08             	add    $0x8,%eax
801049f3:	89 c2                	mov    %eax,%edx
801049f5:	83 ec 08             	sub    $0x8,%esp
801049f8:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801049fb:	50                   	push   %eax
801049fc:	52                   	push   %edx
801049fd:	e8 a0 02 00 00       	call   80104ca2 <getcallerpcs>
80104a02:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a0c:	eb 1c                	jmp    80104a2a <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a11:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a15:	83 ec 08             	sub    $0x8,%esp
80104a18:	50                   	push   %eax
80104a19:	68 93 a7 10 80       	push   $0x8010a793
80104a1e:	e8 d1 b9 ff ff       	call   801003f4 <cprintf>
80104a23:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a2a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a2e:	7f 0b                	jg     80104a3b <procdump+0xd2>
80104a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a33:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a37:	85 c0                	test   %eax,%eax
80104a39:	75 d3                	jne    80104a0e <procdump+0xa5>
    }
    cprintf("\n");
80104a3b:	83 ec 0c             	sub    $0xc,%esp
80104a3e:	68 97 a7 10 80       	push   $0x8010a797
80104a43:	e8 ac b9 ff ff       	call   801003f4 <cprintf>
80104a48:	83 c4 10             	add    $0x10,%esp
80104a4b:	eb 01                	jmp    80104a4e <procdump+0xe5>
      continue;
80104a4d:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a4e:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104a52:	81 7d f0 74 92 11 80 	cmpl   $0x80119274,-0x10(%ebp)
80104a59:	0f 82 1c ff ff ff    	jb     8010497b <procdump+0x12>
  }
}
80104a5f:	90                   	nop
80104a60:	90                   	nop
80104a61:	c9                   	leave  
80104a62:	c3                   	ret    

80104a63 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a63:	55                   	push   %ebp
80104a64:	89 e5                	mov    %esp,%ebp
80104a66:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a69:	8b 45 08             	mov    0x8(%ebp),%eax
80104a6c:	83 c0 04             	add    $0x4,%eax
80104a6f:	83 ec 08             	sub    $0x8,%esp
80104a72:	68 c3 a7 10 80       	push   $0x8010a7c3
80104a77:	50                   	push   %eax
80104a78:	e8 43 01 00 00       	call   80104bc0 <initlock>
80104a7d:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104a80:	8b 45 08             	mov    0x8(%ebp),%eax
80104a83:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a86:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104a89:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a92:	8b 45 08             	mov    0x8(%ebp),%eax
80104a95:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104a9c:	90                   	nop
80104a9d:	c9                   	leave  
80104a9e:	c3                   	ret    

80104a9f <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104a9f:	55                   	push   %ebp
80104aa0:	89 e5                	mov    %esp,%ebp
80104aa2:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa8:	83 c0 04             	add    $0x4,%eax
80104aab:	83 ec 0c             	sub    $0xc,%esp
80104aae:	50                   	push   %eax
80104aaf:	e8 2e 01 00 00       	call   80104be2 <acquire>
80104ab4:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ab7:	eb 15                	jmp    80104ace <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80104abc:	83 c0 04             	add    $0x4,%eax
80104abf:	83 ec 08             	sub    $0x8,%esp
80104ac2:	50                   	push   %eax
80104ac3:	ff 75 08             	push   0x8(%ebp)
80104ac6:	e8 fc fc ff ff       	call   801047c7 <sleep>
80104acb:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ace:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad1:	8b 00                	mov    (%eax),%eax
80104ad3:	85 c0                	test   %eax,%eax
80104ad5:	75 e2                	jne    80104ab9 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80104ada:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104ae0:	e8 2f f4 ff ff       	call   80103f14 <myproc>
80104ae5:	8b 50 10             	mov    0x10(%eax),%edx
80104ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80104aeb:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104aee:	8b 45 08             	mov    0x8(%ebp),%eax
80104af1:	83 c0 04             	add    $0x4,%eax
80104af4:	83 ec 0c             	sub    $0xc,%esp
80104af7:	50                   	push   %eax
80104af8:	e8 53 01 00 00       	call   80104c50 <release>
80104afd:	83 c4 10             	add    $0x10,%esp
}
80104b00:	90                   	nop
80104b01:	c9                   	leave  
80104b02:	c3                   	ret    

80104b03 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104b03:	55                   	push   %ebp
80104b04:	89 e5                	mov    %esp,%ebp
80104b06:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104b09:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0c:	83 c0 04             	add    $0x4,%eax
80104b0f:	83 ec 0c             	sub    $0xc,%esp
80104b12:	50                   	push   %eax
80104b13:	e8 ca 00 00 00       	call   80104be2 <acquire>
80104b18:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104b24:	8b 45 08             	mov    0x8(%ebp),%eax
80104b27:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104b2e:	83 ec 0c             	sub    $0xc,%esp
80104b31:	ff 75 08             	push   0x8(%ebp)
80104b34:	e8 75 fd ff ff       	call   801048ae <wakeup>
80104b39:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3f:	83 c0 04             	add    $0x4,%eax
80104b42:	83 ec 0c             	sub    $0xc,%esp
80104b45:	50                   	push   %eax
80104b46:	e8 05 01 00 00       	call   80104c50 <release>
80104b4b:	83 c4 10             	add    $0x10,%esp
}
80104b4e:	90                   	nop
80104b4f:	c9                   	leave  
80104b50:	c3                   	ret    

80104b51 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104b51:	55                   	push   %ebp
80104b52:	89 e5                	mov    %esp,%ebp
80104b54:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104b57:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5a:	83 c0 04             	add    $0x4,%eax
80104b5d:	83 ec 0c             	sub    $0xc,%esp
80104b60:	50                   	push   %eax
80104b61:	e8 7c 00 00 00       	call   80104be2 <acquire>
80104b66:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b69:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6c:	8b 00                	mov    (%eax),%eax
80104b6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b71:	8b 45 08             	mov    0x8(%ebp),%eax
80104b74:	83 c0 04             	add    $0x4,%eax
80104b77:	83 ec 0c             	sub    $0xc,%esp
80104b7a:	50                   	push   %eax
80104b7b:	e8 d0 00 00 00       	call   80104c50 <release>
80104b80:	83 c4 10             	add    $0x10,%esp
  return r;
80104b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b86:	c9                   	leave  
80104b87:	c3                   	ret    

80104b88 <readeflags>:
{
80104b88:	55                   	push   %ebp
80104b89:	89 e5                	mov    %esp,%ebp
80104b8b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b8e:	9c                   	pushf  
80104b8f:	58                   	pop    %eax
80104b90:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b93:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b96:	c9                   	leave  
80104b97:	c3                   	ret    

80104b98 <cli>:
{
80104b98:	55                   	push   %ebp
80104b99:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b9b:	fa                   	cli    
}
80104b9c:	90                   	nop
80104b9d:	5d                   	pop    %ebp
80104b9e:	c3                   	ret    

80104b9f <sti>:
{
80104b9f:	55                   	push   %ebp
80104ba0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ba2:	fb                   	sti    
}
80104ba3:	90                   	nop
80104ba4:	5d                   	pop    %ebp
80104ba5:	c3                   	ret    

80104ba6 <xchg>:
{
80104ba6:	55                   	push   %ebp
80104ba7:	89 e5                	mov    %esp,%ebp
80104ba9:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104bac:	8b 55 08             	mov    0x8(%ebp),%edx
80104baf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bb5:	f0 87 02             	lock xchg %eax,(%edx)
80104bb8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104bbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bbe:	c9                   	leave  
80104bbf:	c3                   	ret    

80104bc0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104bc0:	55                   	push   %ebp
80104bc1:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bc9:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80104bcf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104bdf:	90                   	nop
80104be0:	5d                   	pop    %ebp
80104be1:	c3                   	ret    

80104be2 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104be2:	55                   	push   %ebp
80104be3:	89 e5                	mov    %esp,%ebp
80104be5:	53                   	push   %ebx
80104be6:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104be9:	e8 5f 01 00 00       	call   80104d4d <pushcli>
  if(holding(lk)){
80104bee:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf1:	83 ec 0c             	sub    $0xc,%esp
80104bf4:	50                   	push   %eax
80104bf5:	e8 23 01 00 00       	call   80104d1d <holding>
80104bfa:	83 c4 10             	add    $0x10,%esp
80104bfd:	85 c0                	test   %eax,%eax
80104bff:	74 0d                	je     80104c0e <acquire+0x2c>
    panic("acquire");
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	68 ce a7 10 80       	push   $0x8010a7ce
80104c09:	e8 9b b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104c0e:	90                   	nop
80104c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c12:	83 ec 08             	sub    $0x8,%esp
80104c15:	6a 01                	push   $0x1
80104c17:	50                   	push   %eax
80104c18:	e8 89 ff ff ff       	call   80104ba6 <xchg>
80104c1d:	83 c4 10             	add    $0x10,%esp
80104c20:	85 c0                	test   %eax,%eax
80104c22:	75 eb                	jne    80104c0f <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104c24:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104c29:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104c2c:	e8 6b f2 ff ff       	call   80103e9c <mycpu>
80104c31:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104c34:	8b 45 08             	mov    0x8(%ebp),%eax
80104c37:	83 c0 0c             	add    $0xc,%eax
80104c3a:	83 ec 08             	sub    $0x8,%esp
80104c3d:	50                   	push   %eax
80104c3e:	8d 45 08             	lea    0x8(%ebp),%eax
80104c41:	50                   	push   %eax
80104c42:	e8 5b 00 00 00       	call   80104ca2 <getcallerpcs>
80104c47:	83 c4 10             	add    $0x10,%esp
}
80104c4a:	90                   	nop
80104c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c4e:	c9                   	leave  
80104c4f:	c3                   	ret    

80104c50 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c50:	55                   	push   %ebp
80104c51:	89 e5                	mov    %esp,%ebp
80104c53:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c56:	83 ec 0c             	sub    $0xc,%esp
80104c59:	ff 75 08             	push   0x8(%ebp)
80104c5c:	e8 bc 00 00 00       	call   80104d1d <holding>
80104c61:	83 c4 10             	add    $0x10,%esp
80104c64:	85 c0                	test   %eax,%eax
80104c66:	75 0d                	jne    80104c75 <release+0x25>
    panic("release");
80104c68:	83 ec 0c             	sub    $0xc,%esp
80104c6b:	68 d6 a7 10 80       	push   $0x8010a7d6
80104c70:	e8 34 b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c75:	8b 45 08             	mov    0x8(%ebp),%eax
80104c78:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c82:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104c89:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c91:	8b 55 08             	mov    0x8(%ebp),%edx
80104c94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104c9a:	e8 fb 00 00 00       	call   80104d9a <popcli>
}
80104c9f:	90                   	nop
80104ca0:	c9                   	leave  
80104ca1:	c3                   	ret    

80104ca2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104ca2:	55                   	push   %ebp
80104ca3:	89 e5                	mov    %esp,%ebp
80104ca5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104ca8:	8b 45 08             	mov    0x8(%ebp),%eax
80104cab:	83 e8 08             	sub    $0x8,%eax
80104cae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104cb1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104cb8:	eb 38                	jmp    80104cf2 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104cba:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104cbe:	74 53                	je     80104d13 <getcallerpcs+0x71>
80104cc0:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104cc7:	76 4a                	jbe    80104d13 <getcallerpcs+0x71>
80104cc9:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104ccd:	74 44                	je     80104d13 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104ccf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cd2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cdc:	01 c2                	add    %eax,%edx
80104cde:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ce1:	8b 40 04             	mov    0x4(%eax),%eax
80104ce4:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104ce6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ce9:	8b 00                	mov    (%eax),%eax
80104ceb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104cee:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cf2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cf6:	7e c2                	jle    80104cba <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104cf8:	eb 19                	jmp    80104d13 <getcallerpcs+0x71>
    pcs[i] = 0;
80104cfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cfd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d07:	01 d0                	add    %edx,%eax
80104d09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104d0f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104d13:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d17:	7e e1                	jle    80104cfa <getcallerpcs+0x58>
}
80104d19:	90                   	nop
80104d1a:	90                   	nop
80104d1b:	c9                   	leave  
80104d1c:	c3                   	ret    

80104d1d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104d1d:	55                   	push   %ebp
80104d1e:	89 e5                	mov    %esp,%ebp
80104d20:	53                   	push   %ebx
80104d21:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104d24:	8b 45 08             	mov    0x8(%ebp),%eax
80104d27:	8b 00                	mov    (%eax),%eax
80104d29:	85 c0                	test   %eax,%eax
80104d2b:	74 16                	je     80104d43 <holding+0x26>
80104d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d30:	8b 58 08             	mov    0x8(%eax),%ebx
80104d33:	e8 64 f1 ff ff       	call   80103e9c <mycpu>
80104d38:	39 c3                	cmp    %eax,%ebx
80104d3a:	75 07                	jne    80104d43 <holding+0x26>
80104d3c:	b8 01 00 00 00       	mov    $0x1,%eax
80104d41:	eb 05                	jmp    80104d48 <holding+0x2b>
80104d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d4b:	c9                   	leave  
80104d4c:	c3                   	ret    

80104d4d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d4d:	55                   	push   %ebp
80104d4e:	89 e5                	mov    %esp,%ebp
80104d50:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104d53:	e8 30 fe ff ff       	call   80104b88 <readeflags>
80104d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d5b:	e8 38 fe ff ff       	call   80104b98 <cli>
  if(mycpu()->ncli == 0)
80104d60:	e8 37 f1 ff ff       	call   80103e9c <mycpu>
80104d65:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d6b:	85 c0                	test   %eax,%eax
80104d6d:	75 14                	jne    80104d83 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d6f:	e8 28 f1 ff ff       	call   80103e9c <mycpu>
80104d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d77:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d7d:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d83:	e8 14 f1 ff ff       	call   80103e9c <mycpu>
80104d88:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d8e:	83 c2 01             	add    $0x1,%edx
80104d91:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104d97:	90                   	nop
80104d98:	c9                   	leave  
80104d99:	c3                   	ret    

80104d9a <popcli>:

void
popcli(void)
{
80104d9a:	55                   	push   %ebp
80104d9b:	89 e5                	mov    %esp,%ebp
80104d9d:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104da0:	e8 e3 fd ff ff       	call   80104b88 <readeflags>
80104da5:	25 00 02 00 00       	and    $0x200,%eax
80104daa:	85 c0                	test   %eax,%eax
80104dac:	74 0d                	je     80104dbb <popcli+0x21>
    panic("popcli - interruptible");
80104dae:	83 ec 0c             	sub    $0xc,%esp
80104db1:	68 de a7 10 80       	push   $0x8010a7de
80104db6:	e8 ee b7 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104dbb:	e8 dc f0 ff ff       	call   80103e9c <mycpu>
80104dc0:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104dc6:	83 ea 01             	sub    $0x1,%edx
80104dc9:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104dcf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104dd5:	85 c0                	test   %eax,%eax
80104dd7:	79 0d                	jns    80104de6 <popcli+0x4c>
    panic("popcli");
80104dd9:	83 ec 0c             	sub    $0xc,%esp
80104ddc:	68 f5 a7 10 80       	push   $0x8010a7f5
80104de1:	e8 c3 b7 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104de6:	e8 b1 f0 ff ff       	call   80103e9c <mycpu>
80104deb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104df1:	85 c0                	test   %eax,%eax
80104df3:	75 14                	jne    80104e09 <popcli+0x6f>
80104df5:	e8 a2 f0 ff ff       	call   80103e9c <mycpu>
80104dfa:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e00:	85 c0                	test   %eax,%eax
80104e02:	74 05                	je     80104e09 <popcli+0x6f>
    sti();
80104e04:	e8 96 fd ff ff       	call   80104b9f <sti>
}
80104e09:	90                   	nop
80104e0a:	c9                   	leave  
80104e0b:	c3                   	ret    

80104e0c <stosb>:
{
80104e0c:	55                   	push   %ebp
80104e0d:	89 e5                	mov    %esp,%ebp
80104e0f:	57                   	push   %edi
80104e10:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e14:	8b 55 10             	mov    0x10(%ebp),%edx
80104e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e1a:	89 cb                	mov    %ecx,%ebx
80104e1c:	89 df                	mov    %ebx,%edi
80104e1e:	89 d1                	mov    %edx,%ecx
80104e20:	fc                   	cld    
80104e21:	f3 aa                	rep stos %al,%es:(%edi)
80104e23:	89 ca                	mov    %ecx,%edx
80104e25:	89 fb                	mov    %edi,%ebx
80104e27:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e2a:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e2d:	90                   	nop
80104e2e:	5b                   	pop    %ebx
80104e2f:	5f                   	pop    %edi
80104e30:	5d                   	pop    %ebp
80104e31:	c3                   	ret    

80104e32 <stosl>:
{
80104e32:	55                   	push   %ebp
80104e33:	89 e5                	mov    %esp,%ebp
80104e35:	57                   	push   %edi
80104e36:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104e37:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e3a:	8b 55 10             	mov    0x10(%ebp),%edx
80104e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e40:	89 cb                	mov    %ecx,%ebx
80104e42:	89 df                	mov    %ebx,%edi
80104e44:	89 d1                	mov    %edx,%ecx
80104e46:	fc                   	cld    
80104e47:	f3 ab                	rep stos %eax,%es:(%edi)
80104e49:	89 ca                	mov    %ecx,%edx
80104e4b:	89 fb                	mov    %edi,%ebx
80104e4d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e50:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e53:	90                   	nop
80104e54:	5b                   	pop    %ebx
80104e55:	5f                   	pop    %edi
80104e56:	5d                   	pop    %ebp
80104e57:	c3                   	ret    

80104e58 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e58:	55                   	push   %ebp
80104e59:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5e:	83 e0 03             	and    $0x3,%eax
80104e61:	85 c0                	test   %eax,%eax
80104e63:	75 43                	jne    80104ea8 <memset+0x50>
80104e65:	8b 45 10             	mov    0x10(%ebp),%eax
80104e68:	83 e0 03             	and    $0x3,%eax
80104e6b:	85 c0                	test   %eax,%eax
80104e6d:	75 39                	jne    80104ea8 <memset+0x50>
    c &= 0xFF;
80104e6f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e76:	8b 45 10             	mov    0x10(%ebp),%eax
80104e79:	c1 e8 02             	shr    $0x2,%eax
80104e7c:	89 c2                	mov    %eax,%edx
80104e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e81:	c1 e0 18             	shl    $0x18,%eax
80104e84:	89 c1                	mov    %eax,%ecx
80104e86:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e89:	c1 e0 10             	shl    $0x10,%eax
80104e8c:	09 c1                	or     %eax,%ecx
80104e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e91:	c1 e0 08             	shl    $0x8,%eax
80104e94:	09 c8                	or     %ecx,%eax
80104e96:	0b 45 0c             	or     0xc(%ebp),%eax
80104e99:	52                   	push   %edx
80104e9a:	50                   	push   %eax
80104e9b:	ff 75 08             	push   0x8(%ebp)
80104e9e:	e8 8f ff ff ff       	call   80104e32 <stosl>
80104ea3:	83 c4 0c             	add    $0xc,%esp
80104ea6:	eb 12                	jmp    80104eba <memset+0x62>
  } else
    stosb(dst, c, n);
80104ea8:	8b 45 10             	mov    0x10(%ebp),%eax
80104eab:	50                   	push   %eax
80104eac:	ff 75 0c             	push   0xc(%ebp)
80104eaf:	ff 75 08             	push   0x8(%ebp)
80104eb2:	e8 55 ff ff ff       	call   80104e0c <stosb>
80104eb7:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104eba:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ebd:	c9                   	leave  
80104ebe:	c3                   	ret    

80104ebf <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104ebf:	55                   	push   %ebp
80104ec0:	89 e5                	mov    %esp,%ebp
80104ec2:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ece:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104ed1:	eb 30                	jmp    80104f03 <memcmp+0x44>
    if(*s1 != *s2)
80104ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ed6:	0f b6 10             	movzbl (%eax),%edx
80104ed9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104edc:	0f b6 00             	movzbl (%eax),%eax
80104edf:	38 c2                	cmp    %al,%dl
80104ee1:	74 18                	je     80104efb <memcmp+0x3c>
      return *s1 - *s2;
80104ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ee6:	0f b6 00             	movzbl (%eax),%eax
80104ee9:	0f b6 d0             	movzbl %al,%edx
80104eec:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104eef:	0f b6 00             	movzbl (%eax),%eax
80104ef2:	0f b6 c8             	movzbl %al,%ecx
80104ef5:	89 d0                	mov    %edx,%eax
80104ef7:	29 c8                	sub    %ecx,%eax
80104ef9:	eb 1a                	jmp    80104f15 <memcmp+0x56>
    s1++, s2++;
80104efb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104eff:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104f03:	8b 45 10             	mov    0x10(%ebp),%eax
80104f06:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f09:	89 55 10             	mov    %edx,0x10(%ebp)
80104f0c:	85 c0                	test   %eax,%eax
80104f0e:	75 c3                	jne    80104ed3 <memcmp+0x14>
  }

  return 0;
80104f10:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f15:	c9                   	leave  
80104f16:	c3                   	ret    

80104f17 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104f17:	55                   	push   %ebp
80104f18:	89 e5                	mov    %esp,%ebp
80104f1a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f20:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104f23:	8b 45 08             	mov    0x8(%ebp),%eax
80104f26:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104f29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f2c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104f2f:	73 54                	jae    80104f85 <memmove+0x6e>
80104f31:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f34:	8b 45 10             	mov    0x10(%ebp),%eax
80104f37:	01 d0                	add    %edx,%eax
80104f39:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104f3c:	73 47                	jae    80104f85 <memmove+0x6e>
    s += n;
80104f3e:	8b 45 10             	mov    0x10(%ebp),%eax
80104f41:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104f44:	8b 45 10             	mov    0x10(%ebp),%eax
80104f47:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f4a:	eb 13                	jmp    80104f5f <memmove+0x48>
      *--d = *--s;
80104f4c:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f50:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f57:	0f b6 10             	movzbl (%eax),%edx
80104f5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f5d:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f5f:	8b 45 10             	mov    0x10(%ebp),%eax
80104f62:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f65:	89 55 10             	mov    %edx,0x10(%ebp)
80104f68:	85 c0                	test   %eax,%eax
80104f6a:	75 e0                	jne    80104f4c <memmove+0x35>
  if(s < d && s + n > d){
80104f6c:	eb 24                	jmp    80104f92 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f6e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f71:	8d 42 01             	lea    0x1(%edx),%eax
80104f74:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f77:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f7a:	8d 48 01             	lea    0x1(%eax),%ecx
80104f7d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104f80:	0f b6 12             	movzbl (%edx),%edx
80104f83:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f85:	8b 45 10             	mov    0x10(%ebp),%eax
80104f88:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f8b:	89 55 10             	mov    %edx,0x10(%ebp)
80104f8e:	85 c0                	test   %eax,%eax
80104f90:	75 dc                	jne    80104f6e <memmove+0x57>

  return dst;
80104f92:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f95:	c9                   	leave  
80104f96:	c3                   	ret    

80104f97 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f97:	55                   	push   %ebp
80104f98:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f9a:	ff 75 10             	push   0x10(%ebp)
80104f9d:	ff 75 0c             	push   0xc(%ebp)
80104fa0:	ff 75 08             	push   0x8(%ebp)
80104fa3:	e8 6f ff ff ff       	call   80104f17 <memmove>
80104fa8:	83 c4 0c             	add    $0xc,%esp
}
80104fab:	c9                   	leave  
80104fac:	c3                   	ret    

80104fad <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104fad:	55                   	push   %ebp
80104fae:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104fb0:	eb 0c                	jmp    80104fbe <strncmp+0x11>
    n--, p++, q++;
80104fb2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fb6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104fba:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104fbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fc2:	74 1a                	je     80104fde <strncmp+0x31>
80104fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc7:	0f b6 00             	movzbl (%eax),%eax
80104fca:	84 c0                	test   %al,%al
80104fcc:	74 10                	je     80104fde <strncmp+0x31>
80104fce:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd1:	0f b6 10             	movzbl (%eax),%edx
80104fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd7:	0f b6 00             	movzbl (%eax),%eax
80104fda:	38 c2                	cmp    %al,%dl
80104fdc:	74 d4                	je     80104fb2 <strncmp+0x5>
  if(n == 0)
80104fde:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fe2:	75 07                	jne    80104feb <strncmp+0x3e>
    return 0;
80104fe4:	b8 00 00 00 00       	mov    $0x0,%eax
80104fe9:	eb 16                	jmp    80105001 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104feb:	8b 45 08             	mov    0x8(%ebp),%eax
80104fee:	0f b6 00             	movzbl (%eax),%eax
80104ff1:	0f b6 d0             	movzbl %al,%edx
80104ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff7:	0f b6 00             	movzbl (%eax),%eax
80104ffa:	0f b6 c8             	movzbl %al,%ecx
80104ffd:	89 d0                	mov    %edx,%eax
80104fff:	29 c8                	sub    %ecx,%eax
}
80105001:	5d                   	pop    %ebp
80105002:	c3                   	ret    

80105003 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105003:	55                   	push   %ebp
80105004:	89 e5                	mov    %esp,%ebp
80105006:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105009:	8b 45 08             	mov    0x8(%ebp),%eax
8010500c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010500f:	90                   	nop
80105010:	8b 45 10             	mov    0x10(%ebp),%eax
80105013:	8d 50 ff             	lea    -0x1(%eax),%edx
80105016:	89 55 10             	mov    %edx,0x10(%ebp)
80105019:	85 c0                	test   %eax,%eax
8010501b:	7e 2c                	jle    80105049 <strncpy+0x46>
8010501d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105020:	8d 42 01             	lea    0x1(%edx),%eax
80105023:	89 45 0c             	mov    %eax,0xc(%ebp)
80105026:	8b 45 08             	mov    0x8(%ebp),%eax
80105029:	8d 48 01             	lea    0x1(%eax),%ecx
8010502c:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010502f:	0f b6 12             	movzbl (%edx),%edx
80105032:	88 10                	mov    %dl,(%eax)
80105034:	0f b6 00             	movzbl (%eax),%eax
80105037:	84 c0                	test   %al,%al
80105039:	75 d5                	jne    80105010 <strncpy+0xd>
    ;
  while(n-- > 0)
8010503b:	eb 0c                	jmp    80105049 <strncpy+0x46>
    *s++ = 0;
8010503d:	8b 45 08             	mov    0x8(%ebp),%eax
80105040:	8d 50 01             	lea    0x1(%eax),%edx
80105043:	89 55 08             	mov    %edx,0x8(%ebp)
80105046:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105049:	8b 45 10             	mov    0x10(%ebp),%eax
8010504c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010504f:	89 55 10             	mov    %edx,0x10(%ebp)
80105052:	85 c0                	test   %eax,%eax
80105054:	7f e7                	jg     8010503d <strncpy+0x3a>
  return os;
80105056:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105059:	c9                   	leave  
8010505a:	c3                   	ret    

8010505b <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010505b:	55                   	push   %ebp
8010505c:	89 e5                	mov    %esp,%ebp
8010505e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105061:	8b 45 08             	mov    0x8(%ebp),%eax
80105064:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105067:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010506b:	7f 05                	jg     80105072 <safestrcpy+0x17>
    return os;
8010506d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105070:	eb 32                	jmp    801050a4 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105072:	90                   	nop
80105073:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105077:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010507b:	7e 1e                	jle    8010509b <safestrcpy+0x40>
8010507d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105080:	8d 42 01             	lea    0x1(%edx),%eax
80105083:	89 45 0c             	mov    %eax,0xc(%ebp)
80105086:	8b 45 08             	mov    0x8(%ebp),%eax
80105089:	8d 48 01             	lea    0x1(%eax),%ecx
8010508c:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010508f:	0f b6 12             	movzbl (%edx),%edx
80105092:	88 10                	mov    %dl,(%eax)
80105094:	0f b6 00             	movzbl (%eax),%eax
80105097:	84 c0                	test   %al,%al
80105099:	75 d8                	jne    80105073 <safestrcpy+0x18>
    ;
  *s = 0;
8010509b:	8b 45 08             	mov    0x8(%ebp),%eax
8010509e:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801050a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050a4:	c9                   	leave  
801050a5:	c3                   	ret    

801050a6 <strlen>:

int
strlen(const char *s)
{
801050a6:	55                   	push   %ebp
801050a7:	89 e5                	mov    %esp,%ebp
801050a9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801050ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801050b3:	eb 04                	jmp    801050b9 <strlen+0x13>
801050b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050b9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050bc:	8b 45 08             	mov    0x8(%ebp),%eax
801050bf:	01 d0                	add    %edx,%eax
801050c1:	0f b6 00             	movzbl (%eax),%eax
801050c4:	84 c0                	test   %al,%al
801050c6:	75 ed                	jne    801050b5 <strlen+0xf>
    ;
  return n;
801050c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050cb:	c9                   	leave  
801050cc:	c3                   	ret    

801050cd <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801050cd:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801050d1:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801050d5:	55                   	push   %ebp
  pushl %ebx
801050d6:	53                   	push   %ebx
  pushl %esi
801050d7:	56                   	push   %esi
  pushl %edi
801050d8:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801050d9:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801050db:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801050dd:	5f                   	pop    %edi
  popl %esi
801050de:	5e                   	pop    %esi
  popl %ebx
801050df:	5b                   	pop    %ebx
  popl %ebp
801050e0:	5d                   	pop    %ebp
  ret
801050e1:	c3                   	ret    

801050e2 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801050e2:	55                   	push   %ebp
801050e3:	89 e5                	mov    %esp,%ebp
801050e5:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801050e8:	e8 27 ee ff ff       	call   80103f14 <myproc>
801050ed:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801050f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f3:	8b 00                	mov    (%eax),%eax
801050f5:	39 45 08             	cmp    %eax,0x8(%ebp)
801050f8:	73 0f                	jae    80105109 <fetchint+0x27>
801050fa:	8b 45 08             	mov    0x8(%ebp),%eax
801050fd:	8d 50 04             	lea    0x4(%eax),%edx
80105100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105103:	8b 00                	mov    (%eax),%eax
80105105:	39 c2                	cmp    %eax,%edx
80105107:	76 07                	jbe    80105110 <fetchint+0x2e>
    return -1;
80105109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010510e:	eb 0f                	jmp    8010511f <fetchint+0x3d>
  *ip = *(int*)(addr);
80105110:	8b 45 08             	mov    0x8(%ebp),%eax
80105113:	8b 10                	mov    (%eax),%edx
80105115:	8b 45 0c             	mov    0xc(%ebp),%eax
80105118:	89 10                	mov    %edx,(%eax)
  return 0;
8010511a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010511f:	c9                   	leave  
80105120:	c3                   	ret    

80105121 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105121:	55                   	push   %ebp
80105122:	89 e5                	mov    %esp,%ebp
80105124:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105127:	e8 e8 ed ff ff       	call   80103f14 <myproc>
8010512c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010512f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105132:	8b 00                	mov    (%eax),%eax
80105134:	39 45 08             	cmp    %eax,0x8(%ebp)
80105137:	72 07                	jb     80105140 <fetchstr+0x1f>
    return -1;
80105139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010513e:	eb 41                	jmp    80105181 <fetchstr+0x60>
  *pp = (char*)addr;
80105140:	8b 55 08             	mov    0x8(%ebp),%edx
80105143:	8b 45 0c             	mov    0xc(%ebp),%eax
80105146:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010514b:	8b 00                	mov    (%eax),%eax
8010514d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105150:	8b 45 0c             	mov    0xc(%ebp),%eax
80105153:	8b 00                	mov    (%eax),%eax
80105155:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105158:	eb 1a                	jmp    80105174 <fetchstr+0x53>
    if(*s == 0)
8010515a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010515d:	0f b6 00             	movzbl (%eax),%eax
80105160:	84 c0                	test   %al,%al
80105162:	75 0c                	jne    80105170 <fetchstr+0x4f>
      return s - *pp;
80105164:	8b 45 0c             	mov    0xc(%ebp),%eax
80105167:	8b 10                	mov    (%eax),%edx
80105169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516c:	29 d0                	sub    %edx,%eax
8010516e:	eb 11                	jmp    80105181 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105170:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105177:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010517a:	72 de                	jb     8010515a <fetchstr+0x39>
  }
  return -1;
8010517c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105181:	c9                   	leave  
80105182:	c3                   	ret    

80105183 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105183:	55                   	push   %ebp
80105184:	89 e5                	mov    %esp,%ebp
80105186:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105189:	e8 86 ed ff ff       	call   80103f14 <myproc>
8010518e:	8b 40 18             	mov    0x18(%eax),%eax
80105191:	8b 50 44             	mov    0x44(%eax),%edx
80105194:	8b 45 08             	mov    0x8(%ebp),%eax
80105197:	c1 e0 02             	shl    $0x2,%eax
8010519a:	01 d0                	add    %edx,%eax
8010519c:	83 c0 04             	add    $0x4,%eax
8010519f:	83 ec 08             	sub    $0x8,%esp
801051a2:	ff 75 0c             	push   0xc(%ebp)
801051a5:	50                   	push   %eax
801051a6:	e8 37 ff ff ff       	call   801050e2 <fetchint>
801051ab:	83 c4 10             	add    $0x10,%esp
}
801051ae:	c9                   	leave  
801051af:	c3                   	ret    

801051b0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801051b0:	55                   	push   %ebp
801051b1:	89 e5                	mov    %esp,%ebp
801051b3:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801051b6:	e8 59 ed ff ff       	call   80103f14 <myproc>
801051bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801051be:	83 ec 08             	sub    $0x8,%esp
801051c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051c4:	50                   	push   %eax
801051c5:	ff 75 08             	push   0x8(%ebp)
801051c8:	e8 b6 ff ff ff       	call   80105183 <argint>
801051cd:	83 c4 10             	add    $0x10,%esp
801051d0:	85 c0                	test   %eax,%eax
801051d2:	79 07                	jns    801051db <argptr+0x2b>
    return -1;
801051d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051d9:	eb 3b                	jmp    80105216 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801051db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051df:	78 1f                	js     80105200 <argptr+0x50>
801051e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e4:	8b 00                	mov    (%eax),%eax
801051e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051e9:	39 d0                	cmp    %edx,%eax
801051eb:	76 13                	jbe    80105200 <argptr+0x50>
801051ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f0:	89 c2                	mov    %eax,%edx
801051f2:	8b 45 10             	mov    0x10(%ebp),%eax
801051f5:	01 c2                	add    %eax,%edx
801051f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fa:	8b 00                	mov    (%eax),%eax
801051fc:	39 c2                	cmp    %eax,%edx
801051fe:	76 07                	jbe    80105207 <argptr+0x57>
    return -1;
80105200:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105205:	eb 0f                	jmp    80105216 <argptr+0x66>
  *pp = (char*)i;
80105207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010520a:	89 c2                	mov    %eax,%edx
8010520c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010520f:	89 10                	mov    %edx,(%eax)
  return 0;
80105211:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105216:	c9                   	leave  
80105217:	c3                   	ret    

80105218 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105218:	55                   	push   %ebp
80105219:	89 e5                	mov    %esp,%ebp
8010521b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010521e:	83 ec 08             	sub    $0x8,%esp
80105221:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105224:	50                   	push   %eax
80105225:	ff 75 08             	push   0x8(%ebp)
80105228:	e8 56 ff ff ff       	call   80105183 <argint>
8010522d:	83 c4 10             	add    $0x10,%esp
80105230:	85 c0                	test   %eax,%eax
80105232:	79 07                	jns    8010523b <argstr+0x23>
    return -1;
80105234:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105239:	eb 12                	jmp    8010524d <argstr+0x35>
  return fetchstr(addr, pp);
8010523b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010523e:	83 ec 08             	sub    $0x8,%esp
80105241:	ff 75 0c             	push   0xc(%ebp)
80105244:	50                   	push   %eax
80105245:	e8 d7 fe ff ff       	call   80105121 <fetchstr>
8010524a:	83 c4 10             	add    $0x10,%esp
}
8010524d:	c9                   	leave  
8010524e:	c3                   	ret    

8010524f <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010524f:	55                   	push   %ebp
80105250:	89 e5                	mov    %esp,%ebp
80105252:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105255:	e8 ba ec ff ff       	call   80103f14 <myproc>
8010525a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010525d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105260:	8b 40 18             	mov    0x18(%eax),%eax
80105263:	8b 40 1c             	mov    0x1c(%eax),%eax
80105266:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105269:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010526d:	7e 2f                	jle    8010529e <syscall+0x4f>
8010526f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105272:	83 f8 16             	cmp    $0x16,%eax
80105275:	77 27                	ja     8010529e <syscall+0x4f>
80105277:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010527a:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105281:	85 c0                	test   %eax,%eax
80105283:	74 19                	je     8010529e <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105285:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105288:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010528f:	ff d0                	call   *%eax
80105291:	89 c2                	mov    %eax,%edx
80105293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105296:	8b 40 18             	mov    0x18(%eax),%eax
80105299:	89 50 1c             	mov    %edx,0x1c(%eax)
8010529c:	eb 2c                	jmp    801052ca <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010529e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a1:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801052a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a7:	8b 40 10             	mov    0x10(%eax),%eax
801052aa:	ff 75 f0             	push   -0x10(%ebp)
801052ad:	52                   	push   %edx
801052ae:	50                   	push   %eax
801052af:	68 fc a7 10 80       	push   $0x8010a7fc
801052b4:	e8 3b b1 ff ff       	call   801003f4 <cprintf>
801052b9:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801052bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052bf:	8b 40 18             	mov    0x18(%eax),%eax
801052c2:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801052c9:	90                   	nop
801052ca:	90                   	nop
801052cb:	c9                   	leave  
801052cc:	c3                   	ret    

801052cd <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801052cd:	55                   	push   %ebp
801052ce:	89 e5                	mov    %esp,%ebp
801052d0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801052d3:	83 ec 08             	sub    $0x8,%esp
801052d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052d9:	50                   	push   %eax
801052da:	ff 75 08             	push   0x8(%ebp)
801052dd:	e8 a1 fe ff ff       	call   80105183 <argint>
801052e2:	83 c4 10             	add    $0x10,%esp
801052e5:	85 c0                	test   %eax,%eax
801052e7:	79 07                	jns    801052f0 <argfd+0x23>
    return -1;
801052e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ee:	eb 4f                	jmp    8010533f <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801052f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052f3:	85 c0                	test   %eax,%eax
801052f5:	78 20                	js     80105317 <argfd+0x4a>
801052f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052fa:	83 f8 0f             	cmp    $0xf,%eax
801052fd:	7f 18                	jg     80105317 <argfd+0x4a>
801052ff:	e8 10 ec ff ff       	call   80103f14 <myproc>
80105304:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105307:	83 c2 08             	add    $0x8,%edx
8010530a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010530e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105311:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105315:	75 07                	jne    8010531e <argfd+0x51>
    return -1;
80105317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010531c:	eb 21                	jmp    8010533f <argfd+0x72>
  if(pfd)
8010531e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105322:	74 08                	je     8010532c <argfd+0x5f>
    *pfd = fd;
80105324:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105327:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010532c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105330:	74 08                	je     8010533a <argfd+0x6d>
    *pf = f;
80105332:	8b 45 10             	mov    0x10(%ebp),%eax
80105335:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105338:	89 10                	mov    %edx,(%eax)
  return 0;
8010533a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010533f:	c9                   	leave  
80105340:	c3                   	ret    

80105341 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105341:	55                   	push   %ebp
80105342:	89 e5                	mov    %esp,%ebp
80105344:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105347:	e8 c8 eb ff ff       	call   80103f14 <myproc>
8010534c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010534f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105356:	eb 2a                	jmp    80105382 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010535e:	83 c2 08             	add    $0x8,%edx
80105361:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105365:	85 c0                	test   %eax,%eax
80105367:	75 15                	jne    8010537e <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105369:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010536c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010536f:	8d 4a 08             	lea    0x8(%edx),%ecx
80105372:	8b 55 08             	mov    0x8(%ebp),%edx
80105375:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010537c:	eb 0f                	jmp    8010538d <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010537e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105382:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105386:	7e d0                	jle    80105358 <fdalloc+0x17>
    }
  }
  return -1;
80105388:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010538d:	c9                   	leave  
8010538e:	c3                   	ret    

8010538f <sys_dup>:

int
sys_dup(void)
{
8010538f:	55                   	push   %ebp
80105390:	89 e5                	mov    %esp,%ebp
80105392:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105395:	83 ec 04             	sub    $0x4,%esp
80105398:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010539b:	50                   	push   %eax
8010539c:	6a 00                	push   $0x0
8010539e:	6a 00                	push   $0x0
801053a0:	e8 28 ff ff ff       	call   801052cd <argfd>
801053a5:	83 c4 10             	add    $0x10,%esp
801053a8:	85 c0                	test   %eax,%eax
801053aa:	79 07                	jns    801053b3 <sys_dup+0x24>
    return -1;
801053ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b1:	eb 31                	jmp    801053e4 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801053b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053b6:	83 ec 0c             	sub    $0xc,%esp
801053b9:	50                   	push   %eax
801053ba:	e8 82 ff ff ff       	call   80105341 <fdalloc>
801053bf:	83 c4 10             	add    $0x10,%esp
801053c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053c9:	79 07                	jns    801053d2 <sys_dup+0x43>
    return -1;
801053cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d0:	eb 12                	jmp    801053e4 <sys_dup+0x55>
  filedup(f);
801053d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d5:	83 ec 0c             	sub    $0xc,%esp
801053d8:	50                   	push   %eax
801053d9:	e8 6c bc ff ff       	call   8010104a <filedup>
801053de:	83 c4 10             	add    $0x10,%esp
  return fd;
801053e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053e4:	c9                   	leave  
801053e5:	c3                   	ret    

801053e6 <sys_read>:

int
sys_read(void)
{
801053e6:	55                   	push   %ebp
801053e7:	89 e5                	mov    %esp,%ebp
801053e9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053ec:	83 ec 04             	sub    $0x4,%esp
801053ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053f2:	50                   	push   %eax
801053f3:	6a 00                	push   $0x0
801053f5:	6a 00                	push   $0x0
801053f7:	e8 d1 fe ff ff       	call   801052cd <argfd>
801053fc:	83 c4 10             	add    $0x10,%esp
801053ff:	85 c0                	test   %eax,%eax
80105401:	78 2e                	js     80105431 <sys_read+0x4b>
80105403:	83 ec 08             	sub    $0x8,%esp
80105406:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105409:	50                   	push   %eax
8010540a:	6a 02                	push   $0x2
8010540c:	e8 72 fd ff ff       	call   80105183 <argint>
80105411:	83 c4 10             	add    $0x10,%esp
80105414:	85 c0                	test   %eax,%eax
80105416:	78 19                	js     80105431 <sys_read+0x4b>
80105418:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010541b:	83 ec 04             	sub    $0x4,%esp
8010541e:	50                   	push   %eax
8010541f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105422:	50                   	push   %eax
80105423:	6a 01                	push   $0x1
80105425:	e8 86 fd ff ff       	call   801051b0 <argptr>
8010542a:	83 c4 10             	add    $0x10,%esp
8010542d:	85 c0                	test   %eax,%eax
8010542f:	79 07                	jns    80105438 <sys_read+0x52>
    return -1;
80105431:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105436:	eb 17                	jmp    8010544f <sys_read+0x69>
  return fileread(f, p, n);
80105438:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010543b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010543e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105441:	83 ec 04             	sub    $0x4,%esp
80105444:	51                   	push   %ecx
80105445:	52                   	push   %edx
80105446:	50                   	push   %eax
80105447:	e8 8e bd ff ff       	call   801011da <fileread>
8010544c:	83 c4 10             	add    $0x10,%esp
}
8010544f:	c9                   	leave  
80105450:	c3                   	ret    

80105451 <sys_write>:

int
sys_write(void)
{
80105451:	55                   	push   %ebp
80105452:	89 e5                	mov    %esp,%ebp
80105454:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105457:	83 ec 04             	sub    $0x4,%esp
8010545a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010545d:	50                   	push   %eax
8010545e:	6a 00                	push   $0x0
80105460:	6a 00                	push   $0x0
80105462:	e8 66 fe ff ff       	call   801052cd <argfd>
80105467:	83 c4 10             	add    $0x10,%esp
8010546a:	85 c0                	test   %eax,%eax
8010546c:	78 2e                	js     8010549c <sys_write+0x4b>
8010546e:	83 ec 08             	sub    $0x8,%esp
80105471:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105474:	50                   	push   %eax
80105475:	6a 02                	push   $0x2
80105477:	e8 07 fd ff ff       	call   80105183 <argint>
8010547c:	83 c4 10             	add    $0x10,%esp
8010547f:	85 c0                	test   %eax,%eax
80105481:	78 19                	js     8010549c <sys_write+0x4b>
80105483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105486:	83 ec 04             	sub    $0x4,%esp
80105489:	50                   	push   %eax
8010548a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010548d:	50                   	push   %eax
8010548e:	6a 01                	push   $0x1
80105490:	e8 1b fd ff ff       	call   801051b0 <argptr>
80105495:	83 c4 10             	add    $0x10,%esp
80105498:	85 c0                	test   %eax,%eax
8010549a:	79 07                	jns    801054a3 <sys_write+0x52>
    return -1;
8010549c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a1:	eb 17                	jmp    801054ba <sys_write+0x69>
  return filewrite(f, p, n);
801054a3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801054a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801054a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ac:	83 ec 04             	sub    $0x4,%esp
801054af:	51                   	push   %ecx
801054b0:	52                   	push   %edx
801054b1:	50                   	push   %eax
801054b2:	e8 db bd ff ff       	call   80101292 <filewrite>
801054b7:	83 c4 10             	add    $0x10,%esp
}
801054ba:	c9                   	leave  
801054bb:	c3                   	ret    

801054bc <sys_close>:

int
sys_close(void)
{
801054bc:	55                   	push   %ebp
801054bd:	89 e5                	mov    %esp,%ebp
801054bf:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801054c2:	83 ec 04             	sub    $0x4,%esp
801054c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054c8:	50                   	push   %eax
801054c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054cc:	50                   	push   %eax
801054cd:	6a 00                	push   $0x0
801054cf:	e8 f9 fd ff ff       	call   801052cd <argfd>
801054d4:	83 c4 10             	add    $0x10,%esp
801054d7:	85 c0                	test   %eax,%eax
801054d9:	79 07                	jns    801054e2 <sys_close+0x26>
    return -1;
801054db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e0:	eb 27                	jmp    80105509 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801054e2:	e8 2d ea ff ff       	call   80103f14 <myproc>
801054e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054ea:	83 c2 08             	add    $0x8,%edx
801054ed:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054f4:	00 
  fileclose(f);
801054f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f8:	83 ec 0c             	sub    $0xc,%esp
801054fb:	50                   	push   %eax
801054fc:	e8 9a bb ff ff       	call   8010109b <fileclose>
80105501:	83 c4 10             	add    $0x10,%esp
  return 0;
80105504:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105509:	c9                   	leave  
8010550a:	c3                   	ret    

8010550b <sys_fstat>:

int
sys_fstat(void)
{
8010550b:	55                   	push   %ebp
8010550c:	89 e5                	mov    %esp,%ebp
8010550e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105511:	83 ec 04             	sub    $0x4,%esp
80105514:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105517:	50                   	push   %eax
80105518:	6a 00                	push   $0x0
8010551a:	6a 00                	push   $0x0
8010551c:	e8 ac fd ff ff       	call   801052cd <argfd>
80105521:	83 c4 10             	add    $0x10,%esp
80105524:	85 c0                	test   %eax,%eax
80105526:	78 17                	js     8010553f <sys_fstat+0x34>
80105528:	83 ec 04             	sub    $0x4,%esp
8010552b:	6a 14                	push   $0x14
8010552d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105530:	50                   	push   %eax
80105531:	6a 01                	push   $0x1
80105533:	e8 78 fc ff ff       	call   801051b0 <argptr>
80105538:	83 c4 10             	add    $0x10,%esp
8010553b:	85 c0                	test   %eax,%eax
8010553d:	79 07                	jns    80105546 <sys_fstat+0x3b>
    return -1;
8010553f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105544:	eb 13                	jmp    80105559 <sys_fstat+0x4e>
  return filestat(f, st);
80105546:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554c:	83 ec 08             	sub    $0x8,%esp
8010554f:	52                   	push   %edx
80105550:	50                   	push   %eax
80105551:	e8 2d bc ff ff       	call   80101183 <filestat>
80105556:	83 c4 10             	add    $0x10,%esp
}
80105559:	c9                   	leave  
8010555a:	c3                   	ret    

8010555b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010555b:	55                   	push   %ebp
8010555c:	89 e5                	mov    %esp,%ebp
8010555e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105561:	83 ec 08             	sub    $0x8,%esp
80105564:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105567:	50                   	push   %eax
80105568:	6a 00                	push   $0x0
8010556a:	e8 a9 fc ff ff       	call   80105218 <argstr>
8010556f:	83 c4 10             	add    $0x10,%esp
80105572:	85 c0                	test   %eax,%eax
80105574:	78 15                	js     8010558b <sys_link+0x30>
80105576:	83 ec 08             	sub    $0x8,%esp
80105579:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010557c:	50                   	push   %eax
8010557d:	6a 01                	push   $0x1
8010557f:	e8 94 fc ff ff       	call   80105218 <argstr>
80105584:	83 c4 10             	add    $0x10,%esp
80105587:	85 c0                	test   %eax,%eax
80105589:	79 0a                	jns    80105595 <sys_link+0x3a>
    return -1;
8010558b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105590:	e9 68 01 00 00       	jmp    801056fd <sys_link+0x1a2>

  begin_op();
80105595:	e8 86 df ff ff       	call   80103520 <begin_op>
  if((ip = namei(old)) == 0){
8010559a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010559d:	83 ec 0c             	sub    $0xc,%esp
801055a0:	50                   	push   %eax
801055a1:	e8 77 cf ff ff       	call   8010251d <namei>
801055a6:	83 c4 10             	add    $0x10,%esp
801055a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055b0:	75 0f                	jne    801055c1 <sys_link+0x66>
    end_op();
801055b2:	e8 f5 df ff ff       	call   801035ac <end_op>
    return -1;
801055b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055bc:	e9 3c 01 00 00       	jmp    801056fd <sys_link+0x1a2>
  }

  ilock(ip);
801055c1:	83 ec 0c             	sub    $0xc,%esp
801055c4:	ff 75 f4             	push   -0xc(%ebp)
801055c7:	e8 1e c4 ff ff       	call   801019ea <ilock>
801055cc:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801055cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055d6:	66 83 f8 01          	cmp    $0x1,%ax
801055da:	75 1d                	jne    801055f9 <sys_link+0x9e>
    iunlockput(ip);
801055dc:	83 ec 0c             	sub    $0xc,%esp
801055df:	ff 75 f4             	push   -0xc(%ebp)
801055e2:	e8 34 c6 ff ff       	call   80101c1b <iunlockput>
801055e7:	83 c4 10             	add    $0x10,%esp
    end_op();
801055ea:	e8 bd df ff ff       	call   801035ac <end_op>
    return -1;
801055ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f4:	e9 04 01 00 00       	jmp    801056fd <sys_link+0x1a2>
  }

  ip->nlink++;
801055f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fc:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105600:	83 c0 01             	add    $0x1,%eax
80105603:	89 c2                	mov    %eax,%edx
80105605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105608:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010560c:	83 ec 0c             	sub    $0xc,%esp
8010560f:	ff 75 f4             	push   -0xc(%ebp)
80105612:	e8 f6 c1 ff ff       	call   8010180d <iupdate>
80105617:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010561a:	83 ec 0c             	sub    $0xc,%esp
8010561d:	ff 75 f4             	push   -0xc(%ebp)
80105620:	e8 d8 c4 ff ff       	call   80101afd <iunlock>
80105625:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105628:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010562b:	83 ec 08             	sub    $0x8,%esp
8010562e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105631:	52                   	push   %edx
80105632:	50                   	push   %eax
80105633:	e8 01 cf ff ff       	call   80102539 <nameiparent>
80105638:	83 c4 10             	add    $0x10,%esp
8010563b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010563e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105642:	74 71                	je     801056b5 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105644:	83 ec 0c             	sub    $0xc,%esp
80105647:	ff 75 f0             	push   -0x10(%ebp)
8010564a:	e8 9b c3 ff ff       	call   801019ea <ilock>
8010564f:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105652:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105655:	8b 10                	mov    (%eax),%edx
80105657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565a:	8b 00                	mov    (%eax),%eax
8010565c:	39 c2                	cmp    %eax,%edx
8010565e:	75 1d                	jne    8010567d <sys_link+0x122>
80105660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105663:	8b 40 04             	mov    0x4(%eax),%eax
80105666:	83 ec 04             	sub    $0x4,%esp
80105669:	50                   	push   %eax
8010566a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010566d:	50                   	push   %eax
8010566e:	ff 75 f0             	push   -0x10(%ebp)
80105671:	e8 10 cc ff ff       	call   80102286 <dirlink>
80105676:	83 c4 10             	add    $0x10,%esp
80105679:	85 c0                	test   %eax,%eax
8010567b:	79 10                	jns    8010568d <sys_link+0x132>
    iunlockput(dp);
8010567d:	83 ec 0c             	sub    $0xc,%esp
80105680:	ff 75 f0             	push   -0x10(%ebp)
80105683:	e8 93 c5 ff ff       	call   80101c1b <iunlockput>
80105688:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010568b:	eb 29                	jmp    801056b6 <sys_link+0x15b>
  }
  iunlockput(dp);
8010568d:	83 ec 0c             	sub    $0xc,%esp
80105690:	ff 75 f0             	push   -0x10(%ebp)
80105693:	e8 83 c5 ff ff       	call   80101c1b <iunlockput>
80105698:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010569b:	83 ec 0c             	sub    $0xc,%esp
8010569e:	ff 75 f4             	push   -0xc(%ebp)
801056a1:	e8 a5 c4 ff ff       	call   80101b4b <iput>
801056a6:	83 c4 10             	add    $0x10,%esp

  end_op();
801056a9:	e8 fe de ff ff       	call   801035ac <end_op>

  return 0;
801056ae:	b8 00 00 00 00       	mov    $0x0,%eax
801056b3:	eb 48                	jmp    801056fd <sys_link+0x1a2>
    goto bad;
801056b5:	90                   	nop

bad:
  ilock(ip);
801056b6:	83 ec 0c             	sub    $0xc,%esp
801056b9:	ff 75 f4             	push   -0xc(%ebp)
801056bc:	e8 29 c3 ff ff       	call   801019ea <ilock>
801056c1:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801056c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056cb:	83 e8 01             	sub    $0x1,%eax
801056ce:	89 c2                	mov    %eax,%edx
801056d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d3:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056d7:	83 ec 0c             	sub    $0xc,%esp
801056da:	ff 75 f4             	push   -0xc(%ebp)
801056dd:	e8 2b c1 ff ff       	call   8010180d <iupdate>
801056e2:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801056e5:	83 ec 0c             	sub    $0xc,%esp
801056e8:	ff 75 f4             	push   -0xc(%ebp)
801056eb:	e8 2b c5 ff ff       	call   80101c1b <iunlockput>
801056f0:	83 c4 10             	add    $0x10,%esp
  end_op();
801056f3:	e8 b4 de ff ff       	call   801035ac <end_op>
  return -1;
801056f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056fd:	c9                   	leave  
801056fe:	c3                   	ret    

801056ff <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801056ff:	55                   	push   %ebp
80105700:	89 e5                	mov    %esp,%ebp
80105702:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105705:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010570c:	eb 40                	jmp    8010574e <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010570e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105711:	6a 10                	push   $0x10
80105713:	50                   	push   %eax
80105714:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105717:	50                   	push   %eax
80105718:	ff 75 08             	push   0x8(%ebp)
8010571b:	e8 b6 c7 ff ff       	call   80101ed6 <readi>
80105720:	83 c4 10             	add    $0x10,%esp
80105723:	83 f8 10             	cmp    $0x10,%eax
80105726:	74 0d                	je     80105735 <isdirempty+0x36>
      panic("isdirempty: readi");
80105728:	83 ec 0c             	sub    $0xc,%esp
8010572b:	68 18 a8 10 80       	push   $0x8010a818
80105730:	e8 74 ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105735:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105739:	66 85 c0             	test   %ax,%ax
8010573c:	74 07                	je     80105745 <isdirempty+0x46>
      return 0;
8010573e:	b8 00 00 00 00       	mov    $0x0,%eax
80105743:	eb 1b                	jmp    80105760 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105748:	83 c0 10             	add    $0x10,%eax
8010574b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010574e:	8b 45 08             	mov    0x8(%ebp),%eax
80105751:	8b 50 58             	mov    0x58(%eax),%edx
80105754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105757:	39 c2                	cmp    %eax,%edx
80105759:	77 b3                	ja     8010570e <isdirempty+0xf>
  }
  return 1;
8010575b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105760:	c9                   	leave  
80105761:	c3                   	ret    

80105762 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105762:	55                   	push   %ebp
80105763:	89 e5                	mov    %esp,%ebp
80105765:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105768:	83 ec 08             	sub    $0x8,%esp
8010576b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010576e:	50                   	push   %eax
8010576f:	6a 00                	push   $0x0
80105771:	e8 a2 fa ff ff       	call   80105218 <argstr>
80105776:	83 c4 10             	add    $0x10,%esp
80105779:	85 c0                	test   %eax,%eax
8010577b:	79 0a                	jns    80105787 <sys_unlink+0x25>
    return -1;
8010577d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105782:	e9 bf 01 00 00       	jmp    80105946 <sys_unlink+0x1e4>

  begin_op();
80105787:	e8 94 dd ff ff       	call   80103520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010578c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010578f:	83 ec 08             	sub    $0x8,%esp
80105792:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105795:	52                   	push   %edx
80105796:	50                   	push   %eax
80105797:	e8 9d cd ff ff       	call   80102539 <nameiparent>
8010579c:	83 c4 10             	add    $0x10,%esp
8010579f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057a6:	75 0f                	jne    801057b7 <sys_unlink+0x55>
    end_op();
801057a8:	e8 ff dd ff ff       	call   801035ac <end_op>
    return -1;
801057ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b2:	e9 8f 01 00 00       	jmp    80105946 <sys_unlink+0x1e4>
  }

  ilock(dp);
801057b7:	83 ec 0c             	sub    $0xc,%esp
801057ba:	ff 75 f4             	push   -0xc(%ebp)
801057bd:	e8 28 c2 ff ff       	call   801019ea <ilock>
801057c2:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801057c5:	83 ec 08             	sub    $0x8,%esp
801057c8:	68 2a a8 10 80       	push   $0x8010a82a
801057cd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057d0:	50                   	push   %eax
801057d1:	e8 db c9 ff ff       	call   801021b1 <namecmp>
801057d6:	83 c4 10             	add    $0x10,%esp
801057d9:	85 c0                	test   %eax,%eax
801057db:	0f 84 49 01 00 00    	je     8010592a <sys_unlink+0x1c8>
801057e1:	83 ec 08             	sub    $0x8,%esp
801057e4:	68 2c a8 10 80       	push   $0x8010a82c
801057e9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057ec:	50                   	push   %eax
801057ed:	e8 bf c9 ff ff       	call   801021b1 <namecmp>
801057f2:	83 c4 10             	add    $0x10,%esp
801057f5:	85 c0                	test   %eax,%eax
801057f7:	0f 84 2d 01 00 00    	je     8010592a <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801057fd:	83 ec 04             	sub    $0x4,%esp
80105800:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105803:	50                   	push   %eax
80105804:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105807:	50                   	push   %eax
80105808:	ff 75 f4             	push   -0xc(%ebp)
8010580b:	e8 bc c9 ff ff       	call   801021cc <dirlookup>
80105810:	83 c4 10             	add    $0x10,%esp
80105813:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105816:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010581a:	0f 84 0d 01 00 00    	je     8010592d <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105820:	83 ec 0c             	sub    $0xc,%esp
80105823:	ff 75 f0             	push   -0x10(%ebp)
80105826:	e8 bf c1 ff ff       	call   801019ea <ilock>
8010582b:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010582e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105831:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105835:	66 85 c0             	test   %ax,%ax
80105838:	7f 0d                	jg     80105847 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010583a:	83 ec 0c             	sub    $0xc,%esp
8010583d:	68 2f a8 10 80       	push   $0x8010a82f
80105842:	e8 62 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105847:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010584e:	66 83 f8 01          	cmp    $0x1,%ax
80105852:	75 25                	jne    80105879 <sys_unlink+0x117>
80105854:	83 ec 0c             	sub    $0xc,%esp
80105857:	ff 75 f0             	push   -0x10(%ebp)
8010585a:	e8 a0 fe ff ff       	call   801056ff <isdirempty>
8010585f:	83 c4 10             	add    $0x10,%esp
80105862:	85 c0                	test   %eax,%eax
80105864:	75 13                	jne    80105879 <sys_unlink+0x117>
    iunlockput(ip);
80105866:	83 ec 0c             	sub    $0xc,%esp
80105869:	ff 75 f0             	push   -0x10(%ebp)
8010586c:	e8 aa c3 ff ff       	call   80101c1b <iunlockput>
80105871:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105874:	e9 b5 00 00 00       	jmp    8010592e <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105879:	83 ec 04             	sub    $0x4,%esp
8010587c:	6a 10                	push   $0x10
8010587e:	6a 00                	push   $0x0
80105880:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105883:	50                   	push   %eax
80105884:	e8 cf f5 ff ff       	call   80104e58 <memset>
80105889:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010588c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010588f:	6a 10                	push   $0x10
80105891:	50                   	push   %eax
80105892:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105895:	50                   	push   %eax
80105896:	ff 75 f4             	push   -0xc(%ebp)
80105899:	e8 8d c7 ff ff       	call   8010202b <writei>
8010589e:	83 c4 10             	add    $0x10,%esp
801058a1:	83 f8 10             	cmp    $0x10,%eax
801058a4:	74 0d                	je     801058b3 <sys_unlink+0x151>
    panic("unlink: writei");
801058a6:	83 ec 0c             	sub    $0xc,%esp
801058a9:	68 41 a8 10 80       	push   $0x8010a841
801058ae:	e8 f6 ac ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058ba:	66 83 f8 01          	cmp    $0x1,%ax
801058be:	75 21                	jne    801058e1 <sys_unlink+0x17f>
    dp->nlink--;
801058c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058c7:	83 e8 01             	sub    $0x1,%eax
801058ca:	89 c2                	mov    %eax,%edx
801058cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058cf:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801058d3:	83 ec 0c             	sub    $0xc,%esp
801058d6:	ff 75 f4             	push   -0xc(%ebp)
801058d9:	e8 2f bf ff ff       	call   8010180d <iupdate>
801058de:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801058e1:	83 ec 0c             	sub    $0xc,%esp
801058e4:	ff 75 f4             	push   -0xc(%ebp)
801058e7:	e8 2f c3 ff ff       	call   80101c1b <iunlockput>
801058ec:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801058ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058f6:	83 e8 01             	sub    $0x1,%eax
801058f9:	89 c2                	mov    %eax,%edx
801058fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fe:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105902:	83 ec 0c             	sub    $0xc,%esp
80105905:	ff 75 f0             	push   -0x10(%ebp)
80105908:	e8 00 bf ff ff       	call   8010180d <iupdate>
8010590d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105910:	83 ec 0c             	sub    $0xc,%esp
80105913:	ff 75 f0             	push   -0x10(%ebp)
80105916:	e8 00 c3 ff ff       	call   80101c1b <iunlockput>
8010591b:	83 c4 10             	add    $0x10,%esp

  end_op();
8010591e:	e8 89 dc ff ff       	call   801035ac <end_op>

  return 0;
80105923:	b8 00 00 00 00       	mov    $0x0,%eax
80105928:	eb 1c                	jmp    80105946 <sys_unlink+0x1e4>
    goto bad;
8010592a:	90                   	nop
8010592b:	eb 01                	jmp    8010592e <sys_unlink+0x1cc>
    goto bad;
8010592d:	90                   	nop

bad:
  iunlockput(dp);
8010592e:	83 ec 0c             	sub    $0xc,%esp
80105931:	ff 75 f4             	push   -0xc(%ebp)
80105934:	e8 e2 c2 ff ff       	call   80101c1b <iunlockput>
80105939:	83 c4 10             	add    $0x10,%esp
  end_op();
8010593c:	e8 6b dc ff ff       	call   801035ac <end_op>
  return -1;
80105941:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105946:	c9                   	leave  
80105947:	c3                   	ret    

80105948 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105948:	55                   	push   %ebp
80105949:	89 e5                	mov    %esp,%ebp
8010594b:	83 ec 38             	sub    $0x38,%esp
8010594e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105951:	8b 55 10             	mov    0x10(%ebp),%edx
80105954:	8b 45 14             	mov    0x14(%ebp),%eax
80105957:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010595b:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010595f:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105963:	83 ec 08             	sub    $0x8,%esp
80105966:	8d 45 de             	lea    -0x22(%ebp),%eax
80105969:	50                   	push   %eax
8010596a:	ff 75 08             	push   0x8(%ebp)
8010596d:	e8 c7 cb ff ff       	call   80102539 <nameiparent>
80105972:	83 c4 10             	add    $0x10,%esp
80105975:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105978:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010597c:	75 0a                	jne    80105988 <create+0x40>
    return 0;
8010597e:	b8 00 00 00 00       	mov    $0x0,%eax
80105983:	e9 90 01 00 00       	jmp    80105b18 <create+0x1d0>
  ilock(dp);
80105988:	83 ec 0c             	sub    $0xc,%esp
8010598b:	ff 75 f4             	push   -0xc(%ebp)
8010598e:	e8 57 c0 ff ff       	call   801019ea <ilock>
80105993:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105996:	83 ec 04             	sub    $0x4,%esp
80105999:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010599c:	50                   	push   %eax
8010599d:	8d 45 de             	lea    -0x22(%ebp),%eax
801059a0:	50                   	push   %eax
801059a1:	ff 75 f4             	push   -0xc(%ebp)
801059a4:	e8 23 c8 ff ff       	call   801021cc <dirlookup>
801059a9:	83 c4 10             	add    $0x10,%esp
801059ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059b3:	74 50                	je     80105a05 <create+0xbd>
    iunlockput(dp);
801059b5:	83 ec 0c             	sub    $0xc,%esp
801059b8:	ff 75 f4             	push   -0xc(%ebp)
801059bb:	e8 5b c2 ff ff       	call   80101c1b <iunlockput>
801059c0:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801059c3:	83 ec 0c             	sub    $0xc,%esp
801059c6:	ff 75 f0             	push   -0x10(%ebp)
801059c9:	e8 1c c0 ff ff       	call   801019ea <ilock>
801059ce:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801059d1:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801059d6:	75 15                	jne    801059ed <create+0xa5>
801059d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059db:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059df:	66 83 f8 02          	cmp    $0x2,%ax
801059e3:	75 08                	jne    801059ed <create+0xa5>
      return ip;
801059e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e8:	e9 2b 01 00 00       	jmp    80105b18 <create+0x1d0>
    iunlockput(ip);
801059ed:	83 ec 0c             	sub    $0xc,%esp
801059f0:	ff 75 f0             	push   -0x10(%ebp)
801059f3:	e8 23 c2 ff ff       	call   80101c1b <iunlockput>
801059f8:	83 c4 10             	add    $0x10,%esp
    return 0;
801059fb:	b8 00 00 00 00       	mov    $0x0,%eax
80105a00:	e9 13 01 00 00       	jmp    80105b18 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105a05:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0c:	8b 00                	mov    (%eax),%eax
80105a0e:	83 ec 08             	sub    $0x8,%esp
80105a11:	52                   	push   %edx
80105a12:	50                   	push   %eax
80105a13:	e8 1e bd ff ff       	call   80101736 <ialloc>
80105a18:	83 c4 10             	add    $0x10,%esp
80105a1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a22:	75 0d                	jne    80105a31 <create+0xe9>
    panic("create: ialloc");
80105a24:	83 ec 0c             	sub    $0xc,%esp
80105a27:	68 50 a8 10 80       	push   $0x8010a850
80105a2c:	e8 78 ab ff ff       	call   801005a9 <panic>

  ilock(ip);
80105a31:	83 ec 0c             	sub    $0xc,%esp
80105a34:	ff 75 f0             	push   -0x10(%ebp)
80105a37:	e8 ae bf ff ff       	call   801019ea <ilock>
80105a3c:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a42:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a46:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4d:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a51:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a58:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a5e:	83 ec 0c             	sub    $0xc,%esp
80105a61:	ff 75 f0             	push   -0x10(%ebp)
80105a64:	e8 a4 bd ff ff       	call   8010180d <iupdate>
80105a69:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a6c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a71:	75 6a                	jne    80105add <create+0x195>
    dp->nlink++;  // for ".."
80105a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a76:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a7a:	83 c0 01             	add    $0x1,%eax
80105a7d:	89 c2                	mov    %eax,%edx
80105a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a82:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a86:	83 ec 0c             	sub    $0xc,%esp
80105a89:	ff 75 f4             	push   -0xc(%ebp)
80105a8c:	e8 7c bd ff ff       	call   8010180d <iupdate>
80105a91:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a97:	8b 40 04             	mov    0x4(%eax),%eax
80105a9a:	83 ec 04             	sub    $0x4,%esp
80105a9d:	50                   	push   %eax
80105a9e:	68 2a a8 10 80       	push   $0x8010a82a
80105aa3:	ff 75 f0             	push   -0x10(%ebp)
80105aa6:	e8 db c7 ff ff       	call   80102286 <dirlink>
80105aab:	83 c4 10             	add    $0x10,%esp
80105aae:	85 c0                	test   %eax,%eax
80105ab0:	78 1e                	js     80105ad0 <create+0x188>
80105ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab5:	8b 40 04             	mov    0x4(%eax),%eax
80105ab8:	83 ec 04             	sub    $0x4,%esp
80105abb:	50                   	push   %eax
80105abc:	68 2c a8 10 80       	push   $0x8010a82c
80105ac1:	ff 75 f0             	push   -0x10(%ebp)
80105ac4:	e8 bd c7 ff ff       	call   80102286 <dirlink>
80105ac9:	83 c4 10             	add    $0x10,%esp
80105acc:	85 c0                	test   %eax,%eax
80105ace:	79 0d                	jns    80105add <create+0x195>
      panic("create dots");
80105ad0:	83 ec 0c             	sub    $0xc,%esp
80105ad3:	68 5f a8 10 80       	push   $0x8010a85f
80105ad8:	e8 cc aa ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105add:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae0:	8b 40 04             	mov    0x4(%eax),%eax
80105ae3:	83 ec 04             	sub    $0x4,%esp
80105ae6:	50                   	push   %eax
80105ae7:	8d 45 de             	lea    -0x22(%ebp),%eax
80105aea:	50                   	push   %eax
80105aeb:	ff 75 f4             	push   -0xc(%ebp)
80105aee:	e8 93 c7 ff ff       	call   80102286 <dirlink>
80105af3:	83 c4 10             	add    $0x10,%esp
80105af6:	85 c0                	test   %eax,%eax
80105af8:	79 0d                	jns    80105b07 <create+0x1bf>
    panic("create: dirlink");
80105afa:	83 ec 0c             	sub    $0xc,%esp
80105afd:	68 6b a8 10 80       	push   $0x8010a86b
80105b02:	e8 a2 aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105b07:	83 ec 0c             	sub    $0xc,%esp
80105b0a:	ff 75 f4             	push   -0xc(%ebp)
80105b0d:	e8 09 c1 ff ff       	call   80101c1b <iunlockput>
80105b12:	83 c4 10             	add    $0x10,%esp

  return ip;
80105b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105b18:	c9                   	leave  
80105b19:	c3                   	ret    

80105b1a <sys_open>:

int
sys_open(void)
{
80105b1a:	55                   	push   %ebp
80105b1b:	89 e5                	mov    %esp,%ebp
80105b1d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105b20:	83 ec 08             	sub    $0x8,%esp
80105b23:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b26:	50                   	push   %eax
80105b27:	6a 00                	push   $0x0
80105b29:	e8 ea f6 ff ff       	call   80105218 <argstr>
80105b2e:	83 c4 10             	add    $0x10,%esp
80105b31:	85 c0                	test   %eax,%eax
80105b33:	78 15                	js     80105b4a <sys_open+0x30>
80105b35:	83 ec 08             	sub    $0x8,%esp
80105b38:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b3b:	50                   	push   %eax
80105b3c:	6a 01                	push   $0x1
80105b3e:	e8 40 f6 ff ff       	call   80105183 <argint>
80105b43:	83 c4 10             	add    $0x10,%esp
80105b46:	85 c0                	test   %eax,%eax
80105b48:	79 0a                	jns    80105b54 <sys_open+0x3a>
    return -1;
80105b4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4f:	e9 61 01 00 00       	jmp    80105cb5 <sys_open+0x19b>

  begin_op();
80105b54:	e8 c7 d9 ff ff       	call   80103520 <begin_op>

  if(omode & O_CREATE){
80105b59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b5c:	25 00 02 00 00       	and    $0x200,%eax
80105b61:	85 c0                	test   %eax,%eax
80105b63:	74 2a                	je     80105b8f <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b65:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b68:	6a 00                	push   $0x0
80105b6a:	6a 00                	push   $0x0
80105b6c:	6a 02                	push   $0x2
80105b6e:	50                   	push   %eax
80105b6f:	e8 d4 fd ff ff       	call   80105948 <create>
80105b74:	83 c4 10             	add    $0x10,%esp
80105b77:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b7e:	75 75                	jne    80105bf5 <sys_open+0xdb>
      end_op();
80105b80:	e8 27 da ff ff       	call   801035ac <end_op>
      return -1;
80105b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8a:	e9 26 01 00 00       	jmp    80105cb5 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b92:	83 ec 0c             	sub    $0xc,%esp
80105b95:	50                   	push   %eax
80105b96:	e8 82 c9 ff ff       	call   8010251d <namei>
80105b9b:	83 c4 10             	add    $0x10,%esp
80105b9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ba5:	75 0f                	jne    80105bb6 <sys_open+0x9c>
      end_op();
80105ba7:	e8 00 da ff ff       	call   801035ac <end_op>
      return -1;
80105bac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb1:	e9 ff 00 00 00       	jmp    80105cb5 <sys_open+0x19b>
    }
    ilock(ip);
80105bb6:	83 ec 0c             	sub    $0xc,%esp
80105bb9:	ff 75 f4             	push   -0xc(%ebp)
80105bbc:	e8 29 be ff ff       	call   801019ea <ilock>
80105bc1:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bcb:	66 83 f8 01          	cmp    $0x1,%ax
80105bcf:	75 24                	jne    80105bf5 <sys_open+0xdb>
80105bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bd4:	85 c0                	test   %eax,%eax
80105bd6:	74 1d                	je     80105bf5 <sys_open+0xdb>
      iunlockput(ip);
80105bd8:	83 ec 0c             	sub    $0xc,%esp
80105bdb:	ff 75 f4             	push   -0xc(%ebp)
80105bde:	e8 38 c0 ff ff       	call   80101c1b <iunlockput>
80105be3:	83 c4 10             	add    $0x10,%esp
      end_op();
80105be6:	e8 c1 d9 ff ff       	call   801035ac <end_op>
      return -1;
80105beb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf0:	e9 c0 00 00 00       	jmp    80105cb5 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105bf5:	e8 e3 b3 ff ff       	call   80100fdd <filealloc>
80105bfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bfd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c01:	74 17                	je     80105c1a <sys_open+0x100>
80105c03:	83 ec 0c             	sub    $0xc,%esp
80105c06:	ff 75 f0             	push   -0x10(%ebp)
80105c09:	e8 33 f7 ff ff       	call   80105341 <fdalloc>
80105c0e:	83 c4 10             	add    $0x10,%esp
80105c11:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105c14:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c18:	79 2e                	jns    80105c48 <sys_open+0x12e>
    if(f)
80105c1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c1e:	74 0e                	je     80105c2e <sys_open+0x114>
      fileclose(f);
80105c20:	83 ec 0c             	sub    $0xc,%esp
80105c23:	ff 75 f0             	push   -0x10(%ebp)
80105c26:	e8 70 b4 ff ff       	call   8010109b <fileclose>
80105c2b:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105c2e:	83 ec 0c             	sub    $0xc,%esp
80105c31:	ff 75 f4             	push   -0xc(%ebp)
80105c34:	e8 e2 bf ff ff       	call   80101c1b <iunlockput>
80105c39:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c3c:	e8 6b d9 ff ff       	call   801035ac <end_op>
    return -1;
80105c41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c46:	eb 6d                	jmp    80105cb5 <sys_open+0x19b>
  }
  iunlock(ip);
80105c48:	83 ec 0c             	sub    $0xc,%esp
80105c4b:	ff 75 f4             	push   -0xc(%ebp)
80105c4e:	e8 aa be ff ff       	call   80101afd <iunlock>
80105c53:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c56:	e8 51 d9 ff ff       	call   801035ac <end_op>

  f->type = FD_INODE;
80105c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c6a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c70:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c7a:	83 e0 01             	and    $0x1,%eax
80105c7d:	85 c0                	test   %eax,%eax
80105c7f:	0f 94 c0             	sete   %al
80105c82:	89 c2                	mov    %eax,%edx
80105c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c87:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c8d:	83 e0 01             	and    $0x1,%eax
80105c90:	85 c0                	test   %eax,%eax
80105c92:	75 0a                	jne    80105c9e <sys_open+0x184>
80105c94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c97:	83 e0 02             	and    $0x2,%eax
80105c9a:	85 c0                	test   %eax,%eax
80105c9c:	74 07                	je     80105ca5 <sys_open+0x18b>
80105c9e:	b8 01 00 00 00       	mov    $0x1,%eax
80105ca3:	eb 05                	jmp    80105caa <sys_open+0x190>
80105ca5:	b8 00 00 00 00       	mov    $0x0,%eax
80105caa:	89 c2                	mov    %eax,%edx
80105cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105caf:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105cb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105cb5:	c9                   	leave  
80105cb6:	c3                   	ret    

80105cb7 <sys_mkdir>:

int
sys_mkdir(void)
{
80105cb7:	55                   	push   %ebp
80105cb8:	89 e5                	mov    %esp,%ebp
80105cba:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105cbd:	e8 5e d8 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105cc2:	83 ec 08             	sub    $0x8,%esp
80105cc5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cc8:	50                   	push   %eax
80105cc9:	6a 00                	push   $0x0
80105ccb:	e8 48 f5 ff ff       	call   80105218 <argstr>
80105cd0:	83 c4 10             	add    $0x10,%esp
80105cd3:	85 c0                	test   %eax,%eax
80105cd5:	78 1b                	js     80105cf2 <sys_mkdir+0x3b>
80105cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cda:	6a 00                	push   $0x0
80105cdc:	6a 00                	push   $0x0
80105cde:	6a 01                	push   $0x1
80105ce0:	50                   	push   %eax
80105ce1:	e8 62 fc ff ff       	call   80105948 <create>
80105ce6:	83 c4 10             	add    $0x10,%esp
80105ce9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cf0:	75 0c                	jne    80105cfe <sys_mkdir+0x47>
    end_op();
80105cf2:	e8 b5 d8 ff ff       	call   801035ac <end_op>
    return -1;
80105cf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cfc:	eb 18                	jmp    80105d16 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105cfe:	83 ec 0c             	sub    $0xc,%esp
80105d01:	ff 75 f4             	push   -0xc(%ebp)
80105d04:	e8 12 bf ff ff       	call   80101c1b <iunlockput>
80105d09:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d0c:	e8 9b d8 ff ff       	call   801035ac <end_op>
  return 0;
80105d11:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d16:	c9                   	leave  
80105d17:	c3                   	ret    

80105d18 <sys_mknod>:

int
sys_mknod(void)
{
80105d18:	55                   	push   %ebp
80105d19:	89 e5                	mov    %esp,%ebp
80105d1b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105d1e:	e8 fd d7 ff ff       	call   80103520 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105d23:	83 ec 08             	sub    $0x8,%esp
80105d26:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d29:	50                   	push   %eax
80105d2a:	6a 00                	push   $0x0
80105d2c:	e8 e7 f4 ff ff       	call   80105218 <argstr>
80105d31:	83 c4 10             	add    $0x10,%esp
80105d34:	85 c0                	test   %eax,%eax
80105d36:	78 4f                	js     80105d87 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105d38:	83 ec 08             	sub    $0x8,%esp
80105d3b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d3e:	50                   	push   %eax
80105d3f:	6a 01                	push   $0x1
80105d41:	e8 3d f4 ff ff       	call   80105183 <argint>
80105d46:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d49:	85 c0                	test   %eax,%eax
80105d4b:	78 3a                	js     80105d87 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105d4d:	83 ec 08             	sub    $0x8,%esp
80105d50:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d53:	50                   	push   %eax
80105d54:	6a 02                	push   $0x2
80105d56:	e8 28 f4 ff ff       	call   80105183 <argint>
80105d5b:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d5e:	85 c0                	test   %eax,%eax
80105d60:	78 25                	js     80105d87 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d62:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d65:	0f bf c8             	movswl %ax,%ecx
80105d68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d6b:	0f bf d0             	movswl %ax,%edx
80105d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d71:	51                   	push   %ecx
80105d72:	52                   	push   %edx
80105d73:	6a 03                	push   $0x3
80105d75:	50                   	push   %eax
80105d76:	e8 cd fb ff ff       	call   80105948 <create>
80105d7b:	83 c4 10             	add    $0x10,%esp
80105d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105d81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d85:	75 0c                	jne    80105d93 <sys_mknod+0x7b>
    end_op();
80105d87:	e8 20 d8 ff ff       	call   801035ac <end_op>
    return -1;
80105d8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d91:	eb 18                	jmp    80105dab <sys_mknod+0x93>
  }
  iunlockput(ip);
80105d93:	83 ec 0c             	sub    $0xc,%esp
80105d96:	ff 75 f4             	push   -0xc(%ebp)
80105d99:	e8 7d be ff ff       	call   80101c1b <iunlockput>
80105d9e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105da1:	e8 06 d8 ff ff       	call   801035ac <end_op>
  return 0;
80105da6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dab:	c9                   	leave  
80105dac:	c3                   	ret    

80105dad <sys_chdir>:

int
sys_chdir(void)
{
80105dad:	55                   	push   %ebp
80105dae:	89 e5                	mov    %esp,%ebp
80105db0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105db3:	e8 5c e1 ff ff       	call   80103f14 <myproc>
80105db8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105dbb:	e8 60 d7 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105dc0:	83 ec 08             	sub    $0x8,%esp
80105dc3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dc6:	50                   	push   %eax
80105dc7:	6a 00                	push   $0x0
80105dc9:	e8 4a f4 ff ff       	call   80105218 <argstr>
80105dce:	83 c4 10             	add    $0x10,%esp
80105dd1:	85 c0                	test   %eax,%eax
80105dd3:	78 18                	js     80105ded <sys_chdir+0x40>
80105dd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105dd8:	83 ec 0c             	sub    $0xc,%esp
80105ddb:	50                   	push   %eax
80105ddc:	e8 3c c7 ff ff       	call   8010251d <namei>
80105de1:	83 c4 10             	add    $0x10,%esp
80105de4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105de7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105deb:	75 0c                	jne    80105df9 <sys_chdir+0x4c>
    end_op();
80105ded:	e8 ba d7 ff ff       	call   801035ac <end_op>
    return -1;
80105df2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df7:	eb 68                	jmp    80105e61 <sys_chdir+0xb4>
  }
  ilock(ip);
80105df9:	83 ec 0c             	sub    $0xc,%esp
80105dfc:	ff 75 f0             	push   -0x10(%ebp)
80105dff:	e8 e6 bb ff ff       	call   801019ea <ilock>
80105e04:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e0e:	66 83 f8 01          	cmp    $0x1,%ax
80105e12:	74 1a                	je     80105e2e <sys_chdir+0x81>
    iunlockput(ip);
80105e14:	83 ec 0c             	sub    $0xc,%esp
80105e17:	ff 75 f0             	push   -0x10(%ebp)
80105e1a:	e8 fc bd ff ff       	call   80101c1b <iunlockput>
80105e1f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e22:	e8 85 d7 ff ff       	call   801035ac <end_op>
    return -1;
80105e27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2c:	eb 33                	jmp    80105e61 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105e2e:	83 ec 0c             	sub    $0xc,%esp
80105e31:	ff 75 f0             	push   -0x10(%ebp)
80105e34:	e8 c4 bc ff ff       	call   80101afd <iunlock>
80105e39:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3f:	8b 40 68             	mov    0x68(%eax),%eax
80105e42:	83 ec 0c             	sub    $0xc,%esp
80105e45:	50                   	push   %eax
80105e46:	e8 00 bd ff ff       	call   80101b4b <iput>
80105e4b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e4e:	e8 59 d7 ff ff       	call   801035ac <end_op>
  curproc->cwd = ip;
80105e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e56:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e59:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e61:	c9                   	leave  
80105e62:	c3                   	ret    

80105e63 <sys_exec>:

int
sys_exec(void)
{
80105e63:	55                   	push   %ebp
80105e64:	89 e5                	mov    %esp,%ebp
80105e66:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e6c:	83 ec 08             	sub    $0x8,%esp
80105e6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e72:	50                   	push   %eax
80105e73:	6a 00                	push   $0x0
80105e75:	e8 9e f3 ff ff       	call   80105218 <argstr>
80105e7a:	83 c4 10             	add    $0x10,%esp
80105e7d:	85 c0                	test   %eax,%eax
80105e7f:	78 18                	js     80105e99 <sys_exec+0x36>
80105e81:	83 ec 08             	sub    $0x8,%esp
80105e84:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e8a:	50                   	push   %eax
80105e8b:	6a 01                	push   $0x1
80105e8d:	e8 f1 f2 ff ff       	call   80105183 <argint>
80105e92:	83 c4 10             	add    $0x10,%esp
80105e95:	85 c0                	test   %eax,%eax
80105e97:	79 0a                	jns    80105ea3 <sys_exec+0x40>
    return -1;
80105e99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e9e:	e9 c6 00 00 00       	jmp    80105f69 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105ea3:	83 ec 04             	sub    $0x4,%esp
80105ea6:	68 80 00 00 00       	push   $0x80
80105eab:	6a 00                	push   $0x0
80105ead:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105eb3:	50                   	push   %eax
80105eb4:	e8 9f ef ff ff       	call   80104e58 <memset>
80105eb9:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105ebc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec6:	83 f8 1f             	cmp    $0x1f,%eax
80105ec9:	76 0a                	jbe    80105ed5 <sys_exec+0x72>
      return -1;
80105ecb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed0:	e9 94 00 00 00       	jmp    80105f69 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed8:	c1 e0 02             	shl    $0x2,%eax
80105edb:	89 c2                	mov    %eax,%edx
80105edd:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105ee3:	01 c2                	add    %eax,%edx
80105ee5:	83 ec 08             	sub    $0x8,%esp
80105ee8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105eee:	50                   	push   %eax
80105eef:	52                   	push   %edx
80105ef0:	e8 ed f1 ff ff       	call   801050e2 <fetchint>
80105ef5:	83 c4 10             	add    $0x10,%esp
80105ef8:	85 c0                	test   %eax,%eax
80105efa:	79 07                	jns    80105f03 <sys_exec+0xa0>
      return -1;
80105efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f01:	eb 66                	jmp    80105f69 <sys_exec+0x106>
    if(uarg == 0){
80105f03:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f09:	85 c0                	test   %eax,%eax
80105f0b:	75 27                	jne    80105f34 <sys_exec+0xd1>
      argv[i] = 0;
80105f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f10:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105f17:	00 00 00 00 
      break;
80105f1b:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1f:	83 ec 08             	sub    $0x8,%esp
80105f22:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f28:	52                   	push   %edx
80105f29:	50                   	push   %eax
80105f2a:	e8 51 ac ff ff       	call   80100b80 <exec>
80105f2f:	83 c4 10             	add    $0x10,%esp
80105f32:	eb 35                	jmp    80105f69 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105f34:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3d:	c1 e0 02             	shl    $0x2,%eax
80105f40:	01 c2                	add    %eax,%edx
80105f42:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f48:	83 ec 08             	sub    $0x8,%esp
80105f4b:	52                   	push   %edx
80105f4c:	50                   	push   %eax
80105f4d:	e8 cf f1 ff ff       	call   80105121 <fetchstr>
80105f52:	83 c4 10             	add    $0x10,%esp
80105f55:	85 c0                	test   %eax,%eax
80105f57:	79 07                	jns    80105f60 <sys_exec+0xfd>
      return -1;
80105f59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f5e:	eb 09                	jmp    80105f69 <sys_exec+0x106>
  for(i=0;; i++){
80105f60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f64:	e9 5a ff ff ff       	jmp    80105ec3 <sys_exec+0x60>
}
80105f69:	c9                   	leave  
80105f6a:	c3                   	ret    

80105f6b <sys_pipe>:

int
sys_pipe(void)
{
80105f6b:	55                   	push   %ebp
80105f6c:	89 e5                	mov    %esp,%ebp
80105f6e:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f71:	83 ec 04             	sub    $0x4,%esp
80105f74:	6a 08                	push   $0x8
80105f76:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f79:	50                   	push   %eax
80105f7a:	6a 00                	push   $0x0
80105f7c:	e8 2f f2 ff ff       	call   801051b0 <argptr>
80105f81:	83 c4 10             	add    $0x10,%esp
80105f84:	85 c0                	test   %eax,%eax
80105f86:	79 0a                	jns    80105f92 <sys_pipe+0x27>
    return -1;
80105f88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f8d:	e9 ae 00 00 00       	jmp    80106040 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105f92:	83 ec 08             	sub    $0x8,%esp
80105f95:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f98:	50                   	push   %eax
80105f99:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f9c:	50                   	push   %eax
80105f9d:	e8 af da ff ff       	call   80103a51 <pipealloc>
80105fa2:	83 c4 10             	add    $0x10,%esp
80105fa5:	85 c0                	test   %eax,%eax
80105fa7:	79 0a                	jns    80105fb3 <sys_pipe+0x48>
    return -1;
80105fa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fae:	e9 8d 00 00 00       	jmp    80106040 <sys_pipe+0xd5>
  fd0 = -1;
80105fb3:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105fba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fbd:	83 ec 0c             	sub    $0xc,%esp
80105fc0:	50                   	push   %eax
80105fc1:	e8 7b f3 ff ff       	call   80105341 <fdalloc>
80105fc6:	83 c4 10             	add    $0x10,%esp
80105fc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd0:	78 18                	js     80105fea <sys_pipe+0x7f>
80105fd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fd5:	83 ec 0c             	sub    $0xc,%esp
80105fd8:	50                   	push   %eax
80105fd9:	e8 63 f3 ff ff       	call   80105341 <fdalloc>
80105fde:	83 c4 10             	add    $0x10,%esp
80105fe1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fe4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fe8:	79 3e                	jns    80106028 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105fea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fee:	78 13                	js     80106003 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105ff0:	e8 1f df ff ff       	call   80103f14 <myproc>
80105ff5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ff8:	83 c2 08             	add    $0x8,%edx
80105ffb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106002:	00 
    fileclose(rf);
80106003:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106006:	83 ec 0c             	sub    $0xc,%esp
80106009:	50                   	push   %eax
8010600a:	e8 8c b0 ff ff       	call   8010109b <fileclose>
8010600f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106012:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106015:	83 ec 0c             	sub    $0xc,%esp
80106018:	50                   	push   %eax
80106019:	e8 7d b0 ff ff       	call   8010109b <fileclose>
8010601e:	83 c4 10             	add    $0x10,%esp
    return -1;
80106021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106026:	eb 18                	jmp    80106040 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010602b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010602e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106030:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106033:	8d 50 04             	lea    0x4(%eax),%edx
80106036:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106039:	89 02                	mov    %eax,(%edx)
  return 0;
8010603b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106040:	c9                   	leave  
80106041:	c3                   	ret    

80106042 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106042:	55                   	push   %ebp
80106043:	89 e5                	mov    %esp,%ebp
80106045:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106048:	e8 c6 e1 ff ff       	call   80104213 <fork>
}
8010604d:	c9                   	leave  
8010604e:	c3                   	ret    

8010604f <sys_exit>:

int
sys_exit(void)
{
8010604f:	55                   	push   %ebp
80106050:	89 e5                	mov    %esp,%ebp
80106052:	83 ec 08             	sub    $0x8,%esp
  exit();
80106055:	e8 32 e3 ff ff       	call   8010438c <exit>
  return 0;  // not reached
8010605a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010605f:	c9                   	leave  
80106060:	c3                   	ret    

80106061 <sys_wait>:

int
sys_wait(void)
{
80106061:	55                   	push   %ebp
80106062:	89 e5                	mov    %esp,%ebp
80106064:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106067:	e8 4a e4 ff ff       	call   801044b6 <wait>
}
8010606c:	c9                   	leave  
8010606d:	c3                   	ret    

8010606e <sys_uthread_init>:
  uthread_init(addr);

  return 0;
}*/

int sys_uthread_init(void) {
8010606e:	55                   	push   %ebp
8010606f:	89 e5                	mov    %esp,%ebp
80106071:	53                   	push   %ebx
80106072:	83 ec 14             	sub    $0x14,%esp
  int addr;
  if (argint(0, &addr) < 0)
80106075:	83 ec 08             	sub    $0x8,%esp
80106078:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010607b:	50                   	push   %eax
8010607c:	6a 00                	push   $0x0
8010607e:	e8 00 f1 ff ff       	call   80105183 <argint>
80106083:	83 c4 10             	add    $0x10,%esp
80106086:	85 c0                	test   %eax,%eax
80106088:	79 07                	jns    80106091 <sys_uthread_init+0x23>
    return -1;
8010608a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010608f:	eb 12                	jmp    801060a3 <sys_uthread_init+0x35>
  myproc()->scheduler = addr;  // 저장함 ✅
80106091:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80106094:	e8 7b de ff ff       	call   80103f14 <myproc>
80106099:	89 da                	mov    %ebx,%edx
8010609b:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
8010609e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801060a6:	c9                   	leave  
801060a7:	c3                   	ret    

801060a8 <sys_kill>:


int
sys_kill(void)
{
801060a8:	55                   	push   %ebp
801060a9:	89 e5                	mov    %esp,%ebp
801060ab:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801060ae:	83 ec 08             	sub    $0x8,%esp
801060b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060b4:	50                   	push   %eax
801060b5:	6a 00                	push   $0x0
801060b7:	e8 c7 f0 ff ff       	call   80105183 <argint>
801060bc:	83 c4 10             	add    $0x10,%esp
801060bf:	85 c0                	test   %eax,%eax
801060c1:	79 07                	jns    801060ca <sys_kill+0x22>
    return -1;
801060c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c8:	eb 0f                	jmp    801060d9 <sys_kill+0x31>
  return kill(pid);
801060ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060cd:	83 ec 0c             	sub    $0xc,%esp
801060d0:	50                   	push   %eax
801060d1:	e8 0f e8 ff ff       	call   801048e5 <kill>
801060d6:	83 c4 10             	add    $0x10,%esp
}
801060d9:	c9                   	leave  
801060da:	c3                   	ret    

801060db <sys_getpid>:

int
sys_getpid(void)
{
801060db:	55                   	push   %ebp
801060dc:	89 e5                	mov    %esp,%ebp
801060de:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801060e1:	e8 2e de ff ff       	call   80103f14 <myproc>
801060e6:	8b 40 10             	mov    0x10(%eax),%eax
}
801060e9:	c9                   	leave  
801060ea:	c3                   	ret    

801060eb <sys_sbrk>:

int
sys_sbrk(void)
{
801060eb:	55                   	push   %ebp
801060ec:	89 e5                	mov    %esp,%ebp
801060ee:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801060f1:	83 ec 08             	sub    $0x8,%esp
801060f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060f7:	50                   	push   %eax
801060f8:	6a 00                	push   $0x0
801060fa:	e8 84 f0 ff ff       	call   80105183 <argint>
801060ff:	83 c4 10             	add    $0x10,%esp
80106102:	85 c0                	test   %eax,%eax
80106104:	79 07                	jns    8010610d <sys_sbrk+0x22>
    return -1;
80106106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610b:	eb 27                	jmp    80106134 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010610d:	e8 02 de ff ff       	call   80103f14 <myproc>
80106112:	8b 00                	mov    (%eax),%eax
80106114:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106117:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611a:	83 ec 0c             	sub    $0xc,%esp
8010611d:	50                   	push   %eax
8010611e:	e8 55 e0 ff ff       	call   80104178 <growproc>
80106123:	83 c4 10             	add    $0x10,%esp
80106126:	85 c0                	test   %eax,%eax
80106128:	79 07                	jns    80106131 <sys_sbrk+0x46>
    return -1;
8010612a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612f:	eb 03                	jmp    80106134 <sys_sbrk+0x49>
  return addr;
80106131:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106134:	c9                   	leave  
80106135:	c3                   	ret    

80106136 <sys_sleep>:

int
sys_sleep(void)
{
80106136:	55                   	push   %ebp
80106137:	89 e5                	mov    %esp,%ebp
80106139:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010613c:	83 ec 08             	sub    $0x8,%esp
8010613f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106142:	50                   	push   %eax
80106143:	6a 00                	push   $0x0
80106145:	e8 39 f0 ff ff       	call   80105183 <argint>
8010614a:	83 c4 10             	add    $0x10,%esp
8010614d:	85 c0                	test   %eax,%eax
8010614f:	79 07                	jns    80106158 <sys_sleep+0x22>
    return -1;
80106151:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106156:	eb 76                	jmp    801061ce <sys_sleep+0x98>
  acquire(&tickslock);
80106158:	83 ec 0c             	sub    $0xc,%esp
8010615b:	68 80 9a 11 80       	push   $0x80119a80
80106160:	e8 7d ea ff ff       	call   80104be2 <acquire>
80106165:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106168:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
8010616d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106170:	eb 38                	jmp    801061aa <sys_sleep+0x74>
    if(myproc()->killed){
80106172:	e8 9d dd ff ff       	call   80103f14 <myproc>
80106177:	8b 40 24             	mov    0x24(%eax),%eax
8010617a:	85 c0                	test   %eax,%eax
8010617c:	74 17                	je     80106195 <sys_sleep+0x5f>
      release(&tickslock);
8010617e:	83 ec 0c             	sub    $0xc,%esp
80106181:	68 80 9a 11 80       	push   $0x80119a80
80106186:	e8 c5 ea ff ff       	call   80104c50 <release>
8010618b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010618e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106193:	eb 39                	jmp    801061ce <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106195:	83 ec 08             	sub    $0x8,%esp
80106198:	68 80 9a 11 80       	push   $0x80119a80
8010619d:	68 b4 9a 11 80       	push   $0x80119ab4
801061a2:	e8 20 e6 ff ff       	call   801047c7 <sleep>
801061a7:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801061aa:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
801061af:	2b 45 f4             	sub    -0xc(%ebp),%eax
801061b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061b5:	39 d0                	cmp    %edx,%eax
801061b7:	72 b9                	jb     80106172 <sys_sleep+0x3c>
  }
  release(&tickslock);
801061b9:	83 ec 0c             	sub    $0xc,%esp
801061bc:	68 80 9a 11 80       	push   $0x80119a80
801061c1:	e8 8a ea ff ff       	call   80104c50 <release>
801061c6:	83 c4 10             	add    $0x10,%esp
  return 0;
801061c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061ce:	c9                   	leave  
801061cf:	c3                   	ret    

801061d0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801061d0:	55                   	push   %ebp
801061d1:	89 e5                	mov    %esp,%ebp
801061d3:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801061d6:	83 ec 0c             	sub    $0xc,%esp
801061d9:	68 80 9a 11 80       	push   $0x80119a80
801061de:	e8 ff e9 ff ff       	call   80104be2 <acquire>
801061e3:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061e6:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
801061eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061ee:	83 ec 0c             	sub    $0xc,%esp
801061f1:	68 80 9a 11 80       	push   $0x80119a80
801061f6:	e8 55 ea ff ff       	call   80104c50 <release>
801061fb:	83 c4 10             	add    $0x10,%esp
  return xticks;
801061fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106201:	c9                   	leave  
80106202:	c3                   	ret    

80106203 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106203:	1e                   	push   %ds
  pushl %es
80106204:	06                   	push   %es
  pushl %fs
80106205:	0f a0                	push   %fs
  pushl %gs
80106207:	0f a8                	push   %gs
  pushal
80106209:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010620a:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010620e:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106210:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106212:	54                   	push   %esp
  call trap
80106213:	e8 d7 01 00 00       	call   801063ef <trap>
  addl $4, %esp
80106218:	83 c4 04             	add    $0x4,%esp

8010621b <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010621b:	61                   	popa   
  popl %gs
8010621c:	0f a9                	pop    %gs
  popl %fs
8010621e:	0f a1                	pop    %fs
  popl %es
80106220:	07                   	pop    %es
  popl %ds
80106221:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106222:	83 c4 08             	add    $0x8,%esp
  iret
80106225:	cf                   	iret   

80106226 <lidt>:
{
80106226:	55                   	push   %ebp
80106227:	89 e5                	mov    %esp,%ebp
80106229:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010622c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010622f:	83 e8 01             	sub    $0x1,%eax
80106232:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106236:	8b 45 08             	mov    0x8(%ebp),%eax
80106239:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010623d:	8b 45 08             	mov    0x8(%ebp),%eax
80106240:	c1 e8 10             	shr    $0x10,%eax
80106243:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106247:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010624a:	0f 01 18             	lidtl  (%eax)
}
8010624d:	90                   	nop
8010624e:	c9                   	leave  
8010624f:	c3                   	ret    

80106250 <rcr2>:

static inline uint
rcr2(void)
{
80106250:	55                   	push   %ebp
80106251:	89 e5                	mov    %esp,%ebp
80106253:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106256:	0f 20 d0             	mov    %cr2,%eax
80106259:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010625c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010625f:	c9                   	leave  
80106260:	c3                   	ret    

80106261 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106261:	55                   	push   %ebp
80106262:	89 e5                	mov    %esp,%ebp
80106264:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106267:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010626e:	e9 c3 00 00 00       	jmp    80106336 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106276:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
8010627d:	89 c2                	mov    %eax,%edx
8010627f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106282:	66 89 14 c5 80 92 11 	mov    %dx,-0x7fee6d80(,%eax,8)
80106289:	80 
8010628a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010628d:	66 c7 04 c5 82 92 11 	movw   $0x8,-0x7fee6d7e(,%eax,8)
80106294:	80 08 00 
80106297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629a:	0f b6 14 c5 84 92 11 	movzbl -0x7fee6d7c(,%eax,8),%edx
801062a1:	80 
801062a2:	83 e2 e0             	and    $0xffffffe0,%edx
801062a5:	88 14 c5 84 92 11 80 	mov    %dl,-0x7fee6d7c(,%eax,8)
801062ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062af:	0f b6 14 c5 84 92 11 	movzbl -0x7fee6d7c(,%eax,8),%edx
801062b6:	80 
801062b7:	83 e2 1f             	and    $0x1f,%edx
801062ba:	88 14 c5 84 92 11 80 	mov    %dl,-0x7fee6d7c(,%eax,8)
801062c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c4:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
801062cb:	80 
801062cc:	83 e2 f0             	and    $0xfffffff0,%edx
801062cf:	83 ca 0e             	or     $0xe,%edx
801062d2:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
801062d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062dc:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
801062e3:	80 
801062e4:	83 e2 ef             	and    $0xffffffef,%edx
801062e7:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
801062ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f1:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
801062f8:	80 
801062f9:	83 e2 9f             	and    $0xffffff9f,%edx
801062fc:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
80106303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106306:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
8010630d:	80 
8010630e:	83 ca 80             	or     $0xffffff80,%edx
80106311:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
80106318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631b:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80106322:	c1 e8 10             	shr    $0x10,%eax
80106325:	89 c2                	mov    %eax,%edx
80106327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632a:	66 89 14 c5 86 92 11 	mov    %dx,-0x7fee6d7a(,%eax,8)
80106331:	80 
  for(i = 0; i < 256; i++)
80106332:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106336:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010633d:	0f 8e 30 ff ff ff    	jle    80106273 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106343:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106348:	66 a3 80 94 11 80    	mov    %ax,0x80119480
8010634e:	66 c7 05 82 94 11 80 	movw   $0x8,0x80119482
80106355:	08 00 
80106357:	0f b6 05 84 94 11 80 	movzbl 0x80119484,%eax
8010635e:	83 e0 e0             	and    $0xffffffe0,%eax
80106361:	a2 84 94 11 80       	mov    %al,0x80119484
80106366:	0f b6 05 84 94 11 80 	movzbl 0x80119484,%eax
8010636d:	83 e0 1f             	and    $0x1f,%eax
80106370:	a2 84 94 11 80       	mov    %al,0x80119484
80106375:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
8010637c:	83 c8 0f             	or     $0xf,%eax
8010637f:	a2 85 94 11 80       	mov    %al,0x80119485
80106384:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
8010638b:	83 e0 ef             	and    $0xffffffef,%eax
8010638e:	a2 85 94 11 80       	mov    %al,0x80119485
80106393:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
8010639a:	83 c8 60             	or     $0x60,%eax
8010639d:	a2 85 94 11 80       	mov    %al,0x80119485
801063a2:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
801063a9:	83 c8 80             	or     $0xffffff80,%eax
801063ac:	a2 85 94 11 80       	mov    %al,0x80119485
801063b1:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
801063b6:	c1 e8 10             	shr    $0x10,%eax
801063b9:	66 a3 86 94 11 80    	mov    %ax,0x80119486

  initlock(&tickslock, "time");
801063bf:	83 ec 08             	sub    $0x8,%esp
801063c2:	68 7c a8 10 80       	push   $0x8010a87c
801063c7:	68 80 9a 11 80       	push   $0x80119a80
801063cc:	e8 ef e7 ff ff       	call   80104bc0 <initlock>
801063d1:	83 c4 10             	add    $0x10,%esp
}
801063d4:	90                   	nop
801063d5:	c9                   	leave  
801063d6:	c3                   	ret    

801063d7 <idtinit>:

void
idtinit(void)
{
801063d7:	55                   	push   %ebp
801063d8:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801063da:	68 00 08 00 00       	push   $0x800
801063df:	68 80 92 11 80       	push   $0x80119280
801063e4:	e8 3d fe ff ff       	call   80106226 <lidt>
801063e9:	83 c4 08             	add    $0x8,%esp
}
801063ec:	90                   	nop
801063ed:	c9                   	leave  
801063ee:	c3                   	ret    

801063ef <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801063ef:	55                   	push   %ebp
801063f0:	89 e5                	mov    %esp,%ebp
801063f2:	57                   	push   %edi
801063f3:	56                   	push   %esi
801063f4:	53                   	push   %ebx
801063f5:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801063f8:	8b 45 08             	mov    0x8(%ebp),%eax
801063fb:	8b 40 30             	mov    0x30(%eax),%eax
801063fe:	83 f8 40             	cmp    $0x40,%eax
80106401:	75 3b                	jne    8010643e <trap+0x4f>
    if(myproc()->killed)
80106403:	e8 0c db ff ff       	call   80103f14 <myproc>
80106408:	8b 40 24             	mov    0x24(%eax),%eax
8010640b:	85 c0                	test   %eax,%eax
8010640d:	74 05                	je     80106414 <trap+0x25>
      exit();
8010640f:	e8 78 df ff ff       	call   8010438c <exit>
    myproc()->tf = tf;
80106414:	e8 fb da ff ff       	call   80103f14 <myproc>
80106419:	8b 55 08             	mov    0x8(%ebp),%edx
8010641c:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010641f:	e8 2b ee ff ff       	call   8010524f <syscall>
    if(myproc()->killed)
80106424:	e8 eb da ff ff       	call   80103f14 <myproc>
80106429:	8b 40 24             	mov    0x24(%eax),%eax
8010642c:	85 c0                	test   %eax,%eax
8010642e:	0f 84 4a 02 00 00    	je     8010667e <trap+0x28f>
      exit();
80106434:	e8 53 df ff ff       	call   8010438c <exit>
    return;
80106439:	e9 40 02 00 00       	jmp    8010667e <trap+0x28f>
  }

  switch(tf->trapno){
8010643e:	8b 45 08             	mov    0x8(%ebp),%eax
80106441:	8b 40 30             	mov    0x30(%eax),%eax
80106444:	83 e8 20             	sub    $0x20,%eax
80106447:	83 f8 1f             	cmp    $0x1f,%eax
8010644a:	0f 87 f6 00 00 00    	ja     80106546 <trap+0x157>
80106450:	8b 04 85 24 a9 10 80 	mov    -0x7fef56dc(,%eax,4),%eax
80106457:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106459:	e8 23 da ff ff       	call   80103e81 <cpuid>
8010645e:	85 c0                	test   %eax,%eax
80106460:	75 3d                	jne    8010649f <trap+0xb0>
      acquire(&tickslock);
80106462:	83 ec 0c             	sub    $0xc,%esp
80106465:	68 80 9a 11 80       	push   $0x80119a80
8010646a:	e8 73 e7 ff ff       	call   80104be2 <acquire>
8010646f:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106472:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
80106477:	83 c0 01             	add    $0x1,%eax
8010647a:	a3 b4 9a 11 80       	mov    %eax,0x80119ab4
      wakeup(&ticks);
8010647f:	83 ec 0c             	sub    $0xc,%esp
80106482:	68 b4 9a 11 80       	push   $0x80119ab4
80106487:	e8 22 e4 ff ff       	call   801048ae <wakeup>
8010648c:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010648f:	83 ec 0c             	sub    $0xc,%esp
80106492:	68 80 9a 11 80       	push   $0x80119a80
80106497:	e8 b4 e7 ff ff       	call   80104c50 <release>
8010649c:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010649f:	e8 5c cb ff ff       	call   80103000 <lapiceoi>
    //Add new code here
    /*인터럽트 처리 끝낸 후?? 스위칭...만? 맞나?*/ 
    // 유저 스케줄러 주소로 eip 세팅 ==다음 유저 공간으로 돌아갈 때 scheduler()부터 실행하라!
    if (myproc() && myproc()->scheduler) {
801064a4:	e8 6b da ff ff       	call   80103f14 <myproc>
801064a9:	85 c0                	test   %eax,%eax
801064ab:	0f 84 4c 01 00 00    	je     801065fd <trap+0x20e>
801064b1:	e8 5e da ff ff       	call   80103f14 <myproc>
801064b6:	8b 40 7c             	mov    0x7c(%eax),%eax
801064b9:	85 c0                	test   %eax,%eax
801064bb:	0f 84 3c 01 00 00    	je     801065fd <trap+0x20e>
      myproc()->tf->eip = myproc()->scheduler;
801064c1:	e8 4e da ff ff       	call   80103f14 <myproc>
801064c6:	89 c3                	mov    %eax,%ebx
801064c8:	e8 47 da ff ff       	call   80103f14 <myproc>
801064cd:	8b 40 18             	mov    0x18(%eax),%eax
801064d0:	8b 53 7c             	mov    0x7c(%ebx),%edx
801064d3:	89 50 38             	mov    %edx,0x38(%eax)
    }
    break;
801064d6:	e9 22 01 00 00       	jmp    801065fd <trap+0x20e>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801064db:	e8 76 c3 ff ff       	call   80102856 <ideintr>
    lapiceoi();
801064e0:	e8 1b cb ff ff       	call   80103000 <lapiceoi>
    break;
801064e5:	e9 14 01 00 00       	jmp    801065fe <trap+0x20f>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801064ea:	e8 56 c9 ff ff       	call   80102e45 <kbdintr>
    lapiceoi();
801064ef:	e8 0c cb ff ff       	call   80103000 <lapiceoi>
    break;
801064f4:	e9 05 01 00 00       	jmp    801065fe <trap+0x20f>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801064f9:	e8 56 03 00 00       	call   80106854 <uartintr>
    lapiceoi();
801064fe:	e8 fd ca ff ff       	call   80103000 <lapiceoi>
    break;
80106503:	e9 f6 00 00 00       	jmp    801065fe <trap+0x20f>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106508:	e8 7e 2b 00 00       	call   8010908b <i8254_intr>
    lapiceoi();
8010650d:	e8 ee ca ff ff       	call   80103000 <lapiceoi>
    break;
80106512:	e9 e7 00 00 00       	jmp    801065fe <trap+0x20f>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106517:	8b 45 08             	mov    0x8(%ebp),%eax
8010651a:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010651d:	8b 45 08             	mov    0x8(%ebp),%eax
80106520:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106524:	0f b7 d8             	movzwl %ax,%ebx
80106527:	e8 55 d9 ff ff       	call   80103e81 <cpuid>
8010652c:	56                   	push   %esi
8010652d:	53                   	push   %ebx
8010652e:	50                   	push   %eax
8010652f:	68 84 a8 10 80       	push   $0x8010a884
80106534:	e8 bb 9e ff ff       	call   801003f4 <cprintf>
80106539:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010653c:	e8 bf ca ff ff       	call   80103000 <lapiceoi>
    break;
80106541:	e9 b8 00 00 00       	jmp    801065fe <trap+0x20f>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106546:	e8 c9 d9 ff ff       	call   80103f14 <myproc>
8010654b:	85 c0                	test   %eax,%eax
8010654d:	74 11                	je     80106560 <trap+0x171>
8010654f:	8b 45 08             	mov    0x8(%ebp),%eax
80106552:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106556:	0f b7 c0             	movzwl %ax,%eax
80106559:	83 e0 03             	and    $0x3,%eax
8010655c:	85 c0                	test   %eax,%eax
8010655e:	75 39                	jne    80106599 <trap+0x1aa>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106560:	e8 eb fc ff ff       	call   80106250 <rcr2>
80106565:	89 c3                	mov    %eax,%ebx
80106567:	8b 45 08             	mov    0x8(%ebp),%eax
8010656a:	8b 70 38             	mov    0x38(%eax),%esi
8010656d:	e8 0f d9 ff ff       	call   80103e81 <cpuid>
80106572:	8b 55 08             	mov    0x8(%ebp),%edx
80106575:	8b 52 30             	mov    0x30(%edx),%edx
80106578:	83 ec 0c             	sub    $0xc,%esp
8010657b:	53                   	push   %ebx
8010657c:	56                   	push   %esi
8010657d:	50                   	push   %eax
8010657e:	52                   	push   %edx
8010657f:	68 a8 a8 10 80       	push   $0x8010a8a8
80106584:	e8 6b 9e ff ff       	call   801003f4 <cprintf>
80106589:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010658c:	83 ec 0c             	sub    $0xc,%esp
8010658f:	68 da a8 10 80       	push   $0x8010a8da
80106594:	e8 10 a0 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106599:	e8 b2 fc ff ff       	call   80106250 <rcr2>
8010659e:	89 c6                	mov    %eax,%esi
801065a0:	8b 45 08             	mov    0x8(%ebp),%eax
801065a3:	8b 40 38             	mov    0x38(%eax),%eax
801065a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801065a9:	e8 d3 d8 ff ff       	call   80103e81 <cpuid>
801065ae:	89 c3                	mov    %eax,%ebx
801065b0:	8b 45 08             	mov    0x8(%ebp),%eax
801065b3:	8b 48 34             	mov    0x34(%eax),%ecx
801065b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801065b9:	8b 45 08             	mov    0x8(%ebp),%eax
801065bc:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801065bf:	e8 50 d9 ff ff       	call   80103f14 <myproc>
801065c4:	8d 50 6c             	lea    0x6c(%eax),%edx
801065c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
801065ca:	e8 45 d9 ff ff       	call   80103f14 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065cf:	8b 40 10             	mov    0x10(%eax),%eax
801065d2:	56                   	push   %esi
801065d3:	ff 75 e4             	push   -0x1c(%ebp)
801065d6:	53                   	push   %ebx
801065d7:	ff 75 e0             	push   -0x20(%ebp)
801065da:	57                   	push   %edi
801065db:	ff 75 dc             	push   -0x24(%ebp)
801065de:	50                   	push   %eax
801065df:	68 e0 a8 10 80       	push   $0x8010a8e0
801065e4:	e8 0b 9e ff ff       	call   801003f4 <cprintf>
801065e9:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801065ec:	e8 23 d9 ff ff       	call   80103f14 <myproc>
801065f1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801065f8:	eb 04                	jmp    801065fe <trap+0x20f>
    break;
801065fa:	90                   	nop
801065fb:	eb 01                	jmp    801065fe <trap+0x20f>
    break;
801065fd:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801065fe:	e8 11 d9 ff ff       	call   80103f14 <myproc>
80106603:	85 c0                	test   %eax,%eax
80106605:	74 23                	je     8010662a <trap+0x23b>
80106607:	e8 08 d9 ff ff       	call   80103f14 <myproc>
8010660c:	8b 40 24             	mov    0x24(%eax),%eax
8010660f:	85 c0                	test   %eax,%eax
80106611:	74 17                	je     8010662a <trap+0x23b>
80106613:	8b 45 08             	mov    0x8(%ebp),%eax
80106616:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010661a:	0f b7 c0             	movzwl %ax,%eax
8010661d:	83 e0 03             	and    $0x3,%eax
80106620:	83 f8 03             	cmp    $0x3,%eax
80106623:	75 05                	jne    8010662a <trap+0x23b>
    exit();
80106625:	e8 62 dd ff ff       	call   8010438c <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010662a:	e8 e5 d8 ff ff       	call   80103f14 <myproc>
8010662f:	85 c0                	test   %eax,%eax
80106631:	74 1d                	je     80106650 <trap+0x261>
80106633:	e8 dc d8 ff ff       	call   80103f14 <myproc>
80106638:	8b 40 0c             	mov    0xc(%eax),%eax
8010663b:	83 f8 04             	cmp    $0x4,%eax
8010663e:	75 10                	jne    80106650 <trap+0x261>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106640:	8b 45 08             	mov    0x8(%ebp),%eax
80106643:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106646:	83 f8 20             	cmp    $0x20,%eax
80106649:	75 05                	jne    80106650 <trap+0x261>
    yield();
8010664b:	e8 f7 e0 ff ff       	call   80104747 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106650:	e8 bf d8 ff ff       	call   80103f14 <myproc>
80106655:	85 c0                	test   %eax,%eax
80106657:	74 26                	je     8010667f <trap+0x290>
80106659:	e8 b6 d8 ff ff       	call   80103f14 <myproc>
8010665e:	8b 40 24             	mov    0x24(%eax),%eax
80106661:	85 c0                	test   %eax,%eax
80106663:	74 1a                	je     8010667f <trap+0x290>
80106665:	8b 45 08             	mov    0x8(%ebp),%eax
80106668:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010666c:	0f b7 c0             	movzwl %ax,%eax
8010666f:	83 e0 03             	and    $0x3,%eax
80106672:	83 f8 03             	cmp    $0x3,%eax
80106675:	75 08                	jne    8010667f <trap+0x290>
    exit();
80106677:	e8 10 dd ff ff       	call   8010438c <exit>
8010667c:	eb 01                	jmp    8010667f <trap+0x290>
    return;
8010667e:	90                   	nop
}
8010667f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106682:	5b                   	pop    %ebx
80106683:	5e                   	pop    %esi
80106684:	5f                   	pop    %edi
80106685:	5d                   	pop    %ebp
80106686:	c3                   	ret    

80106687 <inb>:
{
80106687:	55                   	push   %ebp
80106688:	89 e5                	mov    %esp,%ebp
8010668a:	83 ec 14             	sub    $0x14,%esp
8010668d:	8b 45 08             	mov    0x8(%ebp),%eax
80106690:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106694:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106698:	89 c2                	mov    %eax,%edx
8010669a:	ec                   	in     (%dx),%al
8010669b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010669e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066a2:	c9                   	leave  
801066a3:	c3                   	ret    

801066a4 <outb>:
{
801066a4:	55                   	push   %ebp
801066a5:	89 e5                	mov    %esp,%ebp
801066a7:	83 ec 08             	sub    $0x8,%esp
801066aa:	8b 45 08             	mov    0x8(%ebp),%eax
801066ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801066b0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801066b4:	89 d0                	mov    %edx,%eax
801066b6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066b9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066bd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066c1:	ee                   	out    %al,(%dx)
}
801066c2:	90                   	nop
801066c3:	c9                   	leave  
801066c4:	c3                   	ret    

801066c5 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801066c5:	55                   	push   %ebp
801066c6:	89 e5                	mov    %esp,%ebp
801066c8:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801066cb:	6a 00                	push   $0x0
801066cd:	68 fa 03 00 00       	push   $0x3fa
801066d2:	e8 cd ff ff ff       	call   801066a4 <outb>
801066d7:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801066da:	68 80 00 00 00       	push   $0x80
801066df:	68 fb 03 00 00       	push   $0x3fb
801066e4:	e8 bb ff ff ff       	call   801066a4 <outb>
801066e9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801066ec:	6a 0c                	push   $0xc
801066ee:	68 f8 03 00 00       	push   $0x3f8
801066f3:	e8 ac ff ff ff       	call   801066a4 <outb>
801066f8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801066fb:	6a 00                	push   $0x0
801066fd:	68 f9 03 00 00       	push   $0x3f9
80106702:	e8 9d ff ff ff       	call   801066a4 <outb>
80106707:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010670a:	6a 03                	push   $0x3
8010670c:	68 fb 03 00 00       	push   $0x3fb
80106711:	e8 8e ff ff ff       	call   801066a4 <outb>
80106716:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106719:	6a 00                	push   $0x0
8010671b:	68 fc 03 00 00       	push   $0x3fc
80106720:	e8 7f ff ff ff       	call   801066a4 <outb>
80106725:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106728:	6a 01                	push   $0x1
8010672a:	68 f9 03 00 00       	push   $0x3f9
8010672f:	e8 70 ff ff ff       	call   801066a4 <outb>
80106734:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106737:	68 fd 03 00 00       	push   $0x3fd
8010673c:	e8 46 ff ff ff       	call   80106687 <inb>
80106741:	83 c4 04             	add    $0x4,%esp
80106744:	3c ff                	cmp    $0xff,%al
80106746:	74 61                	je     801067a9 <uartinit+0xe4>
    return;
  uart = 1;
80106748:	c7 05 b8 9a 11 80 01 	movl   $0x1,0x80119ab8
8010674f:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106752:	68 fa 03 00 00       	push   $0x3fa
80106757:	e8 2b ff ff ff       	call   80106687 <inb>
8010675c:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010675f:	68 f8 03 00 00       	push   $0x3f8
80106764:	e8 1e ff ff ff       	call   80106687 <inb>
80106769:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010676c:	83 ec 08             	sub    $0x8,%esp
8010676f:	6a 00                	push   $0x0
80106771:	6a 04                	push   $0x4
80106773:	e8 9a c3 ff ff       	call   80102b12 <ioapicenable>
80106778:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010677b:	c7 45 f4 a4 a9 10 80 	movl   $0x8010a9a4,-0xc(%ebp)
80106782:	eb 19                	jmp    8010679d <uartinit+0xd8>
    uartputc(*p);
80106784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106787:	0f b6 00             	movzbl (%eax),%eax
8010678a:	0f be c0             	movsbl %al,%eax
8010678d:	83 ec 0c             	sub    $0xc,%esp
80106790:	50                   	push   %eax
80106791:	e8 16 00 00 00       	call   801067ac <uartputc>
80106796:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106799:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010679d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a0:	0f b6 00             	movzbl (%eax),%eax
801067a3:	84 c0                	test   %al,%al
801067a5:	75 dd                	jne    80106784 <uartinit+0xbf>
801067a7:	eb 01                	jmp    801067aa <uartinit+0xe5>
    return;
801067a9:	90                   	nop
}
801067aa:	c9                   	leave  
801067ab:	c3                   	ret    

801067ac <uartputc>:

void
uartputc(int c)
{
801067ac:	55                   	push   %ebp
801067ad:	89 e5                	mov    %esp,%ebp
801067af:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801067b2:	a1 b8 9a 11 80       	mov    0x80119ab8,%eax
801067b7:	85 c0                	test   %eax,%eax
801067b9:	74 53                	je     8010680e <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067c2:	eb 11                	jmp    801067d5 <uartputc+0x29>
    microdelay(10);
801067c4:	83 ec 0c             	sub    $0xc,%esp
801067c7:	6a 0a                	push   $0xa
801067c9:	e8 4d c8 ff ff       	call   8010301b <microdelay>
801067ce:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067d5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801067d9:	7f 1a                	jg     801067f5 <uartputc+0x49>
801067db:	83 ec 0c             	sub    $0xc,%esp
801067de:	68 fd 03 00 00       	push   $0x3fd
801067e3:	e8 9f fe ff ff       	call   80106687 <inb>
801067e8:	83 c4 10             	add    $0x10,%esp
801067eb:	0f b6 c0             	movzbl %al,%eax
801067ee:	83 e0 20             	and    $0x20,%eax
801067f1:	85 c0                	test   %eax,%eax
801067f3:	74 cf                	je     801067c4 <uartputc+0x18>
  outb(COM1+0, c);
801067f5:	8b 45 08             	mov    0x8(%ebp),%eax
801067f8:	0f b6 c0             	movzbl %al,%eax
801067fb:	83 ec 08             	sub    $0x8,%esp
801067fe:	50                   	push   %eax
801067ff:	68 f8 03 00 00       	push   $0x3f8
80106804:	e8 9b fe ff ff       	call   801066a4 <outb>
80106809:	83 c4 10             	add    $0x10,%esp
8010680c:	eb 01                	jmp    8010680f <uartputc+0x63>
    return;
8010680e:	90                   	nop
}
8010680f:	c9                   	leave  
80106810:	c3                   	ret    

80106811 <uartgetc>:

static int
uartgetc(void)
{
80106811:	55                   	push   %ebp
80106812:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106814:	a1 b8 9a 11 80       	mov    0x80119ab8,%eax
80106819:	85 c0                	test   %eax,%eax
8010681b:	75 07                	jne    80106824 <uartgetc+0x13>
    return -1;
8010681d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106822:	eb 2e                	jmp    80106852 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106824:	68 fd 03 00 00       	push   $0x3fd
80106829:	e8 59 fe ff ff       	call   80106687 <inb>
8010682e:	83 c4 04             	add    $0x4,%esp
80106831:	0f b6 c0             	movzbl %al,%eax
80106834:	83 e0 01             	and    $0x1,%eax
80106837:	85 c0                	test   %eax,%eax
80106839:	75 07                	jne    80106842 <uartgetc+0x31>
    return -1;
8010683b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106840:	eb 10                	jmp    80106852 <uartgetc+0x41>
  return inb(COM1+0);
80106842:	68 f8 03 00 00       	push   $0x3f8
80106847:	e8 3b fe ff ff       	call   80106687 <inb>
8010684c:	83 c4 04             	add    $0x4,%esp
8010684f:	0f b6 c0             	movzbl %al,%eax
}
80106852:	c9                   	leave  
80106853:	c3                   	ret    

80106854 <uartintr>:

void
uartintr(void)
{
80106854:	55                   	push   %ebp
80106855:	89 e5                	mov    %esp,%ebp
80106857:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010685a:	83 ec 0c             	sub    $0xc,%esp
8010685d:	68 11 68 10 80       	push   $0x80106811
80106862:	e8 6f 9f ff ff       	call   801007d6 <consoleintr>
80106867:	83 c4 10             	add    $0x10,%esp
}
8010686a:	90                   	nop
8010686b:	c9                   	leave  
8010686c:	c3                   	ret    

8010686d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $0
8010686f:	6a 00                	push   $0x0
  jmp alltraps
80106871:	e9 8d f9 ff ff       	jmp    80106203 <alltraps>

80106876 <vector1>:
.globl vector1
vector1:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $1
80106878:	6a 01                	push   $0x1
  jmp alltraps
8010687a:	e9 84 f9 ff ff       	jmp    80106203 <alltraps>

8010687f <vector2>:
.globl vector2
vector2:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $2
80106881:	6a 02                	push   $0x2
  jmp alltraps
80106883:	e9 7b f9 ff ff       	jmp    80106203 <alltraps>

80106888 <vector3>:
.globl vector3
vector3:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $3
8010688a:	6a 03                	push   $0x3
  jmp alltraps
8010688c:	e9 72 f9 ff ff       	jmp    80106203 <alltraps>

80106891 <vector4>:
.globl vector4
vector4:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $4
80106893:	6a 04                	push   $0x4
  jmp alltraps
80106895:	e9 69 f9 ff ff       	jmp    80106203 <alltraps>

8010689a <vector5>:
.globl vector5
vector5:
  pushl $0
8010689a:	6a 00                	push   $0x0
  pushl $5
8010689c:	6a 05                	push   $0x5
  jmp alltraps
8010689e:	e9 60 f9 ff ff       	jmp    80106203 <alltraps>

801068a3 <vector6>:
.globl vector6
vector6:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $6
801068a5:	6a 06                	push   $0x6
  jmp alltraps
801068a7:	e9 57 f9 ff ff       	jmp    80106203 <alltraps>

801068ac <vector7>:
.globl vector7
vector7:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $7
801068ae:	6a 07                	push   $0x7
  jmp alltraps
801068b0:	e9 4e f9 ff ff       	jmp    80106203 <alltraps>

801068b5 <vector8>:
.globl vector8
vector8:
  pushl $8
801068b5:	6a 08                	push   $0x8
  jmp alltraps
801068b7:	e9 47 f9 ff ff       	jmp    80106203 <alltraps>

801068bc <vector9>:
.globl vector9
vector9:
  pushl $0
801068bc:	6a 00                	push   $0x0
  pushl $9
801068be:	6a 09                	push   $0x9
  jmp alltraps
801068c0:	e9 3e f9 ff ff       	jmp    80106203 <alltraps>

801068c5 <vector10>:
.globl vector10
vector10:
  pushl $10
801068c5:	6a 0a                	push   $0xa
  jmp alltraps
801068c7:	e9 37 f9 ff ff       	jmp    80106203 <alltraps>

801068cc <vector11>:
.globl vector11
vector11:
  pushl $11
801068cc:	6a 0b                	push   $0xb
  jmp alltraps
801068ce:	e9 30 f9 ff ff       	jmp    80106203 <alltraps>

801068d3 <vector12>:
.globl vector12
vector12:
  pushl $12
801068d3:	6a 0c                	push   $0xc
  jmp alltraps
801068d5:	e9 29 f9 ff ff       	jmp    80106203 <alltraps>

801068da <vector13>:
.globl vector13
vector13:
  pushl $13
801068da:	6a 0d                	push   $0xd
  jmp alltraps
801068dc:	e9 22 f9 ff ff       	jmp    80106203 <alltraps>

801068e1 <vector14>:
.globl vector14
vector14:
  pushl $14
801068e1:	6a 0e                	push   $0xe
  jmp alltraps
801068e3:	e9 1b f9 ff ff       	jmp    80106203 <alltraps>

801068e8 <vector15>:
.globl vector15
vector15:
  pushl $0
801068e8:	6a 00                	push   $0x0
  pushl $15
801068ea:	6a 0f                	push   $0xf
  jmp alltraps
801068ec:	e9 12 f9 ff ff       	jmp    80106203 <alltraps>

801068f1 <vector16>:
.globl vector16
vector16:
  pushl $0
801068f1:	6a 00                	push   $0x0
  pushl $16
801068f3:	6a 10                	push   $0x10
  jmp alltraps
801068f5:	e9 09 f9 ff ff       	jmp    80106203 <alltraps>

801068fa <vector17>:
.globl vector17
vector17:
  pushl $17
801068fa:	6a 11                	push   $0x11
  jmp alltraps
801068fc:	e9 02 f9 ff ff       	jmp    80106203 <alltraps>

80106901 <vector18>:
.globl vector18
vector18:
  pushl $0
80106901:	6a 00                	push   $0x0
  pushl $18
80106903:	6a 12                	push   $0x12
  jmp alltraps
80106905:	e9 f9 f8 ff ff       	jmp    80106203 <alltraps>

8010690a <vector19>:
.globl vector19
vector19:
  pushl $0
8010690a:	6a 00                	push   $0x0
  pushl $19
8010690c:	6a 13                	push   $0x13
  jmp alltraps
8010690e:	e9 f0 f8 ff ff       	jmp    80106203 <alltraps>

80106913 <vector20>:
.globl vector20
vector20:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $20
80106915:	6a 14                	push   $0x14
  jmp alltraps
80106917:	e9 e7 f8 ff ff       	jmp    80106203 <alltraps>

8010691c <vector21>:
.globl vector21
vector21:
  pushl $0
8010691c:	6a 00                	push   $0x0
  pushl $21
8010691e:	6a 15                	push   $0x15
  jmp alltraps
80106920:	e9 de f8 ff ff       	jmp    80106203 <alltraps>

80106925 <vector22>:
.globl vector22
vector22:
  pushl $0
80106925:	6a 00                	push   $0x0
  pushl $22
80106927:	6a 16                	push   $0x16
  jmp alltraps
80106929:	e9 d5 f8 ff ff       	jmp    80106203 <alltraps>

8010692e <vector23>:
.globl vector23
vector23:
  pushl $0
8010692e:	6a 00                	push   $0x0
  pushl $23
80106930:	6a 17                	push   $0x17
  jmp alltraps
80106932:	e9 cc f8 ff ff       	jmp    80106203 <alltraps>

80106937 <vector24>:
.globl vector24
vector24:
  pushl $0
80106937:	6a 00                	push   $0x0
  pushl $24
80106939:	6a 18                	push   $0x18
  jmp alltraps
8010693b:	e9 c3 f8 ff ff       	jmp    80106203 <alltraps>

80106940 <vector25>:
.globl vector25
vector25:
  pushl $0
80106940:	6a 00                	push   $0x0
  pushl $25
80106942:	6a 19                	push   $0x19
  jmp alltraps
80106944:	e9 ba f8 ff ff       	jmp    80106203 <alltraps>

80106949 <vector26>:
.globl vector26
vector26:
  pushl $0
80106949:	6a 00                	push   $0x0
  pushl $26
8010694b:	6a 1a                	push   $0x1a
  jmp alltraps
8010694d:	e9 b1 f8 ff ff       	jmp    80106203 <alltraps>

80106952 <vector27>:
.globl vector27
vector27:
  pushl $0
80106952:	6a 00                	push   $0x0
  pushl $27
80106954:	6a 1b                	push   $0x1b
  jmp alltraps
80106956:	e9 a8 f8 ff ff       	jmp    80106203 <alltraps>

8010695b <vector28>:
.globl vector28
vector28:
  pushl $0
8010695b:	6a 00                	push   $0x0
  pushl $28
8010695d:	6a 1c                	push   $0x1c
  jmp alltraps
8010695f:	e9 9f f8 ff ff       	jmp    80106203 <alltraps>

80106964 <vector29>:
.globl vector29
vector29:
  pushl $0
80106964:	6a 00                	push   $0x0
  pushl $29
80106966:	6a 1d                	push   $0x1d
  jmp alltraps
80106968:	e9 96 f8 ff ff       	jmp    80106203 <alltraps>

8010696d <vector30>:
.globl vector30
vector30:
  pushl $0
8010696d:	6a 00                	push   $0x0
  pushl $30
8010696f:	6a 1e                	push   $0x1e
  jmp alltraps
80106971:	e9 8d f8 ff ff       	jmp    80106203 <alltraps>

80106976 <vector31>:
.globl vector31
vector31:
  pushl $0
80106976:	6a 00                	push   $0x0
  pushl $31
80106978:	6a 1f                	push   $0x1f
  jmp alltraps
8010697a:	e9 84 f8 ff ff       	jmp    80106203 <alltraps>

8010697f <vector32>:
.globl vector32
vector32:
  pushl $0
8010697f:	6a 00                	push   $0x0
  pushl $32
80106981:	6a 20                	push   $0x20
  jmp alltraps
80106983:	e9 7b f8 ff ff       	jmp    80106203 <alltraps>

80106988 <vector33>:
.globl vector33
vector33:
  pushl $0
80106988:	6a 00                	push   $0x0
  pushl $33
8010698a:	6a 21                	push   $0x21
  jmp alltraps
8010698c:	e9 72 f8 ff ff       	jmp    80106203 <alltraps>

80106991 <vector34>:
.globl vector34
vector34:
  pushl $0
80106991:	6a 00                	push   $0x0
  pushl $34
80106993:	6a 22                	push   $0x22
  jmp alltraps
80106995:	e9 69 f8 ff ff       	jmp    80106203 <alltraps>

8010699a <vector35>:
.globl vector35
vector35:
  pushl $0
8010699a:	6a 00                	push   $0x0
  pushl $35
8010699c:	6a 23                	push   $0x23
  jmp alltraps
8010699e:	e9 60 f8 ff ff       	jmp    80106203 <alltraps>

801069a3 <vector36>:
.globl vector36
vector36:
  pushl $0
801069a3:	6a 00                	push   $0x0
  pushl $36
801069a5:	6a 24                	push   $0x24
  jmp alltraps
801069a7:	e9 57 f8 ff ff       	jmp    80106203 <alltraps>

801069ac <vector37>:
.globl vector37
vector37:
  pushl $0
801069ac:	6a 00                	push   $0x0
  pushl $37
801069ae:	6a 25                	push   $0x25
  jmp alltraps
801069b0:	e9 4e f8 ff ff       	jmp    80106203 <alltraps>

801069b5 <vector38>:
.globl vector38
vector38:
  pushl $0
801069b5:	6a 00                	push   $0x0
  pushl $38
801069b7:	6a 26                	push   $0x26
  jmp alltraps
801069b9:	e9 45 f8 ff ff       	jmp    80106203 <alltraps>

801069be <vector39>:
.globl vector39
vector39:
  pushl $0
801069be:	6a 00                	push   $0x0
  pushl $39
801069c0:	6a 27                	push   $0x27
  jmp alltraps
801069c2:	e9 3c f8 ff ff       	jmp    80106203 <alltraps>

801069c7 <vector40>:
.globl vector40
vector40:
  pushl $0
801069c7:	6a 00                	push   $0x0
  pushl $40
801069c9:	6a 28                	push   $0x28
  jmp alltraps
801069cb:	e9 33 f8 ff ff       	jmp    80106203 <alltraps>

801069d0 <vector41>:
.globl vector41
vector41:
  pushl $0
801069d0:	6a 00                	push   $0x0
  pushl $41
801069d2:	6a 29                	push   $0x29
  jmp alltraps
801069d4:	e9 2a f8 ff ff       	jmp    80106203 <alltraps>

801069d9 <vector42>:
.globl vector42
vector42:
  pushl $0
801069d9:	6a 00                	push   $0x0
  pushl $42
801069db:	6a 2a                	push   $0x2a
  jmp alltraps
801069dd:	e9 21 f8 ff ff       	jmp    80106203 <alltraps>

801069e2 <vector43>:
.globl vector43
vector43:
  pushl $0
801069e2:	6a 00                	push   $0x0
  pushl $43
801069e4:	6a 2b                	push   $0x2b
  jmp alltraps
801069e6:	e9 18 f8 ff ff       	jmp    80106203 <alltraps>

801069eb <vector44>:
.globl vector44
vector44:
  pushl $0
801069eb:	6a 00                	push   $0x0
  pushl $44
801069ed:	6a 2c                	push   $0x2c
  jmp alltraps
801069ef:	e9 0f f8 ff ff       	jmp    80106203 <alltraps>

801069f4 <vector45>:
.globl vector45
vector45:
  pushl $0
801069f4:	6a 00                	push   $0x0
  pushl $45
801069f6:	6a 2d                	push   $0x2d
  jmp alltraps
801069f8:	e9 06 f8 ff ff       	jmp    80106203 <alltraps>

801069fd <vector46>:
.globl vector46
vector46:
  pushl $0
801069fd:	6a 00                	push   $0x0
  pushl $46
801069ff:	6a 2e                	push   $0x2e
  jmp alltraps
80106a01:	e9 fd f7 ff ff       	jmp    80106203 <alltraps>

80106a06 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a06:	6a 00                	push   $0x0
  pushl $47
80106a08:	6a 2f                	push   $0x2f
  jmp alltraps
80106a0a:	e9 f4 f7 ff ff       	jmp    80106203 <alltraps>

80106a0f <vector48>:
.globl vector48
vector48:
  pushl $0
80106a0f:	6a 00                	push   $0x0
  pushl $48
80106a11:	6a 30                	push   $0x30
  jmp alltraps
80106a13:	e9 eb f7 ff ff       	jmp    80106203 <alltraps>

80106a18 <vector49>:
.globl vector49
vector49:
  pushl $0
80106a18:	6a 00                	push   $0x0
  pushl $49
80106a1a:	6a 31                	push   $0x31
  jmp alltraps
80106a1c:	e9 e2 f7 ff ff       	jmp    80106203 <alltraps>

80106a21 <vector50>:
.globl vector50
vector50:
  pushl $0
80106a21:	6a 00                	push   $0x0
  pushl $50
80106a23:	6a 32                	push   $0x32
  jmp alltraps
80106a25:	e9 d9 f7 ff ff       	jmp    80106203 <alltraps>

80106a2a <vector51>:
.globl vector51
vector51:
  pushl $0
80106a2a:	6a 00                	push   $0x0
  pushl $51
80106a2c:	6a 33                	push   $0x33
  jmp alltraps
80106a2e:	e9 d0 f7 ff ff       	jmp    80106203 <alltraps>

80106a33 <vector52>:
.globl vector52
vector52:
  pushl $0
80106a33:	6a 00                	push   $0x0
  pushl $52
80106a35:	6a 34                	push   $0x34
  jmp alltraps
80106a37:	e9 c7 f7 ff ff       	jmp    80106203 <alltraps>

80106a3c <vector53>:
.globl vector53
vector53:
  pushl $0
80106a3c:	6a 00                	push   $0x0
  pushl $53
80106a3e:	6a 35                	push   $0x35
  jmp alltraps
80106a40:	e9 be f7 ff ff       	jmp    80106203 <alltraps>

80106a45 <vector54>:
.globl vector54
vector54:
  pushl $0
80106a45:	6a 00                	push   $0x0
  pushl $54
80106a47:	6a 36                	push   $0x36
  jmp alltraps
80106a49:	e9 b5 f7 ff ff       	jmp    80106203 <alltraps>

80106a4e <vector55>:
.globl vector55
vector55:
  pushl $0
80106a4e:	6a 00                	push   $0x0
  pushl $55
80106a50:	6a 37                	push   $0x37
  jmp alltraps
80106a52:	e9 ac f7 ff ff       	jmp    80106203 <alltraps>

80106a57 <vector56>:
.globl vector56
vector56:
  pushl $0
80106a57:	6a 00                	push   $0x0
  pushl $56
80106a59:	6a 38                	push   $0x38
  jmp alltraps
80106a5b:	e9 a3 f7 ff ff       	jmp    80106203 <alltraps>

80106a60 <vector57>:
.globl vector57
vector57:
  pushl $0
80106a60:	6a 00                	push   $0x0
  pushl $57
80106a62:	6a 39                	push   $0x39
  jmp alltraps
80106a64:	e9 9a f7 ff ff       	jmp    80106203 <alltraps>

80106a69 <vector58>:
.globl vector58
vector58:
  pushl $0
80106a69:	6a 00                	push   $0x0
  pushl $58
80106a6b:	6a 3a                	push   $0x3a
  jmp alltraps
80106a6d:	e9 91 f7 ff ff       	jmp    80106203 <alltraps>

80106a72 <vector59>:
.globl vector59
vector59:
  pushl $0
80106a72:	6a 00                	push   $0x0
  pushl $59
80106a74:	6a 3b                	push   $0x3b
  jmp alltraps
80106a76:	e9 88 f7 ff ff       	jmp    80106203 <alltraps>

80106a7b <vector60>:
.globl vector60
vector60:
  pushl $0
80106a7b:	6a 00                	push   $0x0
  pushl $60
80106a7d:	6a 3c                	push   $0x3c
  jmp alltraps
80106a7f:	e9 7f f7 ff ff       	jmp    80106203 <alltraps>

80106a84 <vector61>:
.globl vector61
vector61:
  pushl $0
80106a84:	6a 00                	push   $0x0
  pushl $61
80106a86:	6a 3d                	push   $0x3d
  jmp alltraps
80106a88:	e9 76 f7 ff ff       	jmp    80106203 <alltraps>

80106a8d <vector62>:
.globl vector62
vector62:
  pushl $0
80106a8d:	6a 00                	push   $0x0
  pushl $62
80106a8f:	6a 3e                	push   $0x3e
  jmp alltraps
80106a91:	e9 6d f7 ff ff       	jmp    80106203 <alltraps>

80106a96 <vector63>:
.globl vector63
vector63:
  pushl $0
80106a96:	6a 00                	push   $0x0
  pushl $63
80106a98:	6a 3f                	push   $0x3f
  jmp alltraps
80106a9a:	e9 64 f7 ff ff       	jmp    80106203 <alltraps>

80106a9f <vector64>:
.globl vector64
vector64:
  pushl $0
80106a9f:	6a 00                	push   $0x0
  pushl $64
80106aa1:	6a 40                	push   $0x40
  jmp alltraps
80106aa3:	e9 5b f7 ff ff       	jmp    80106203 <alltraps>

80106aa8 <vector65>:
.globl vector65
vector65:
  pushl $0
80106aa8:	6a 00                	push   $0x0
  pushl $65
80106aaa:	6a 41                	push   $0x41
  jmp alltraps
80106aac:	e9 52 f7 ff ff       	jmp    80106203 <alltraps>

80106ab1 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ab1:	6a 00                	push   $0x0
  pushl $66
80106ab3:	6a 42                	push   $0x42
  jmp alltraps
80106ab5:	e9 49 f7 ff ff       	jmp    80106203 <alltraps>

80106aba <vector67>:
.globl vector67
vector67:
  pushl $0
80106aba:	6a 00                	push   $0x0
  pushl $67
80106abc:	6a 43                	push   $0x43
  jmp alltraps
80106abe:	e9 40 f7 ff ff       	jmp    80106203 <alltraps>

80106ac3 <vector68>:
.globl vector68
vector68:
  pushl $0
80106ac3:	6a 00                	push   $0x0
  pushl $68
80106ac5:	6a 44                	push   $0x44
  jmp alltraps
80106ac7:	e9 37 f7 ff ff       	jmp    80106203 <alltraps>

80106acc <vector69>:
.globl vector69
vector69:
  pushl $0
80106acc:	6a 00                	push   $0x0
  pushl $69
80106ace:	6a 45                	push   $0x45
  jmp alltraps
80106ad0:	e9 2e f7 ff ff       	jmp    80106203 <alltraps>

80106ad5 <vector70>:
.globl vector70
vector70:
  pushl $0
80106ad5:	6a 00                	push   $0x0
  pushl $70
80106ad7:	6a 46                	push   $0x46
  jmp alltraps
80106ad9:	e9 25 f7 ff ff       	jmp    80106203 <alltraps>

80106ade <vector71>:
.globl vector71
vector71:
  pushl $0
80106ade:	6a 00                	push   $0x0
  pushl $71
80106ae0:	6a 47                	push   $0x47
  jmp alltraps
80106ae2:	e9 1c f7 ff ff       	jmp    80106203 <alltraps>

80106ae7 <vector72>:
.globl vector72
vector72:
  pushl $0
80106ae7:	6a 00                	push   $0x0
  pushl $72
80106ae9:	6a 48                	push   $0x48
  jmp alltraps
80106aeb:	e9 13 f7 ff ff       	jmp    80106203 <alltraps>

80106af0 <vector73>:
.globl vector73
vector73:
  pushl $0
80106af0:	6a 00                	push   $0x0
  pushl $73
80106af2:	6a 49                	push   $0x49
  jmp alltraps
80106af4:	e9 0a f7 ff ff       	jmp    80106203 <alltraps>

80106af9 <vector74>:
.globl vector74
vector74:
  pushl $0
80106af9:	6a 00                	push   $0x0
  pushl $74
80106afb:	6a 4a                	push   $0x4a
  jmp alltraps
80106afd:	e9 01 f7 ff ff       	jmp    80106203 <alltraps>

80106b02 <vector75>:
.globl vector75
vector75:
  pushl $0
80106b02:	6a 00                	push   $0x0
  pushl $75
80106b04:	6a 4b                	push   $0x4b
  jmp alltraps
80106b06:	e9 f8 f6 ff ff       	jmp    80106203 <alltraps>

80106b0b <vector76>:
.globl vector76
vector76:
  pushl $0
80106b0b:	6a 00                	push   $0x0
  pushl $76
80106b0d:	6a 4c                	push   $0x4c
  jmp alltraps
80106b0f:	e9 ef f6 ff ff       	jmp    80106203 <alltraps>

80106b14 <vector77>:
.globl vector77
vector77:
  pushl $0
80106b14:	6a 00                	push   $0x0
  pushl $77
80106b16:	6a 4d                	push   $0x4d
  jmp alltraps
80106b18:	e9 e6 f6 ff ff       	jmp    80106203 <alltraps>

80106b1d <vector78>:
.globl vector78
vector78:
  pushl $0
80106b1d:	6a 00                	push   $0x0
  pushl $78
80106b1f:	6a 4e                	push   $0x4e
  jmp alltraps
80106b21:	e9 dd f6 ff ff       	jmp    80106203 <alltraps>

80106b26 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b26:	6a 00                	push   $0x0
  pushl $79
80106b28:	6a 4f                	push   $0x4f
  jmp alltraps
80106b2a:	e9 d4 f6 ff ff       	jmp    80106203 <alltraps>

80106b2f <vector80>:
.globl vector80
vector80:
  pushl $0
80106b2f:	6a 00                	push   $0x0
  pushl $80
80106b31:	6a 50                	push   $0x50
  jmp alltraps
80106b33:	e9 cb f6 ff ff       	jmp    80106203 <alltraps>

80106b38 <vector81>:
.globl vector81
vector81:
  pushl $0
80106b38:	6a 00                	push   $0x0
  pushl $81
80106b3a:	6a 51                	push   $0x51
  jmp alltraps
80106b3c:	e9 c2 f6 ff ff       	jmp    80106203 <alltraps>

80106b41 <vector82>:
.globl vector82
vector82:
  pushl $0
80106b41:	6a 00                	push   $0x0
  pushl $82
80106b43:	6a 52                	push   $0x52
  jmp alltraps
80106b45:	e9 b9 f6 ff ff       	jmp    80106203 <alltraps>

80106b4a <vector83>:
.globl vector83
vector83:
  pushl $0
80106b4a:	6a 00                	push   $0x0
  pushl $83
80106b4c:	6a 53                	push   $0x53
  jmp alltraps
80106b4e:	e9 b0 f6 ff ff       	jmp    80106203 <alltraps>

80106b53 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b53:	6a 00                	push   $0x0
  pushl $84
80106b55:	6a 54                	push   $0x54
  jmp alltraps
80106b57:	e9 a7 f6 ff ff       	jmp    80106203 <alltraps>

80106b5c <vector85>:
.globl vector85
vector85:
  pushl $0
80106b5c:	6a 00                	push   $0x0
  pushl $85
80106b5e:	6a 55                	push   $0x55
  jmp alltraps
80106b60:	e9 9e f6 ff ff       	jmp    80106203 <alltraps>

80106b65 <vector86>:
.globl vector86
vector86:
  pushl $0
80106b65:	6a 00                	push   $0x0
  pushl $86
80106b67:	6a 56                	push   $0x56
  jmp alltraps
80106b69:	e9 95 f6 ff ff       	jmp    80106203 <alltraps>

80106b6e <vector87>:
.globl vector87
vector87:
  pushl $0
80106b6e:	6a 00                	push   $0x0
  pushl $87
80106b70:	6a 57                	push   $0x57
  jmp alltraps
80106b72:	e9 8c f6 ff ff       	jmp    80106203 <alltraps>

80106b77 <vector88>:
.globl vector88
vector88:
  pushl $0
80106b77:	6a 00                	push   $0x0
  pushl $88
80106b79:	6a 58                	push   $0x58
  jmp alltraps
80106b7b:	e9 83 f6 ff ff       	jmp    80106203 <alltraps>

80106b80 <vector89>:
.globl vector89
vector89:
  pushl $0
80106b80:	6a 00                	push   $0x0
  pushl $89
80106b82:	6a 59                	push   $0x59
  jmp alltraps
80106b84:	e9 7a f6 ff ff       	jmp    80106203 <alltraps>

80106b89 <vector90>:
.globl vector90
vector90:
  pushl $0
80106b89:	6a 00                	push   $0x0
  pushl $90
80106b8b:	6a 5a                	push   $0x5a
  jmp alltraps
80106b8d:	e9 71 f6 ff ff       	jmp    80106203 <alltraps>

80106b92 <vector91>:
.globl vector91
vector91:
  pushl $0
80106b92:	6a 00                	push   $0x0
  pushl $91
80106b94:	6a 5b                	push   $0x5b
  jmp alltraps
80106b96:	e9 68 f6 ff ff       	jmp    80106203 <alltraps>

80106b9b <vector92>:
.globl vector92
vector92:
  pushl $0
80106b9b:	6a 00                	push   $0x0
  pushl $92
80106b9d:	6a 5c                	push   $0x5c
  jmp alltraps
80106b9f:	e9 5f f6 ff ff       	jmp    80106203 <alltraps>

80106ba4 <vector93>:
.globl vector93
vector93:
  pushl $0
80106ba4:	6a 00                	push   $0x0
  pushl $93
80106ba6:	6a 5d                	push   $0x5d
  jmp alltraps
80106ba8:	e9 56 f6 ff ff       	jmp    80106203 <alltraps>

80106bad <vector94>:
.globl vector94
vector94:
  pushl $0
80106bad:	6a 00                	push   $0x0
  pushl $94
80106baf:	6a 5e                	push   $0x5e
  jmp alltraps
80106bb1:	e9 4d f6 ff ff       	jmp    80106203 <alltraps>

80106bb6 <vector95>:
.globl vector95
vector95:
  pushl $0
80106bb6:	6a 00                	push   $0x0
  pushl $95
80106bb8:	6a 5f                	push   $0x5f
  jmp alltraps
80106bba:	e9 44 f6 ff ff       	jmp    80106203 <alltraps>

80106bbf <vector96>:
.globl vector96
vector96:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $96
80106bc1:	6a 60                	push   $0x60
  jmp alltraps
80106bc3:	e9 3b f6 ff ff       	jmp    80106203 <alltraps>

80106bc8 <vector97>:
.globl vector97
vector97:
  pushl $0
80106bc8:	6a 00                	push   $0x0
  pushl $97
80106bca:	6a 61                	push   $0x61
  jmp alltraps
80106bcc:	e9 32 f6 ff ff       	jmp    80106203 <alltraps>

80106bd1 <vector98>:
.globl vector98
vector98:
  pushl $0
80106bd1:	6a 00                	push   $0x0
  pushl $98
80106bd3:	6a 62                	push   $0x62
  jmp alltraps
80106bd5:	e9 29 f6 ff ff       	jmp    80106203 <alltraps>

80106bda <vector99>:
.globl vector99
vector99:
  pushl $0
80106bda:	6a 00                	push   $0x0
  pushl $99
80106bdc:	6a 63                	push   $0x63
  jmp alltraps
80106bde:	e9 20 f6 ff ff       	jmp    80106203 <alltraps>

80106be3 <vector100>:
.globl vector100
vector100:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $100
80106be5:	6a 64                	push   $0x64
  jmp alltraps
80106be7:	e9 17 f6 ff ff       	jmp    80106203 <alltraps>

80106bec <vector101>:
.globl vector101
vector101:
  pushl $0
80106bec:	6a 00                	push   $0x0
  pushl $101
80106bee:	6a 65                	push   $0x65
  jmp alltraps
80106bf0:	e9 0e f6 ff ff       	jmp    80106203 <alltraps>

80106bf5 <vector102>:
.globl vector102
vector102:
  pushl $0
80106bf5:	6a 00                	push   $0x0
  pushl $102
80106bf7:	6a 66                	push   $0x66
  jmp alltraps
80106bf9:	e9 05 f6 ff ff       	jmp    80106203 <alltraps>

80106bfe <vector103>:
.globl vector103
vector103:
  pushl $0
80106bfe:	6a 00                	push   $0x0
  pushl $103
80106c00:	6a 67                	push   $0x67
  jmp alltraps
80106c02:	e9 fc f5 ff ff       	jmp    80106203 <alltraps>

80106c07 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $104
80106c09:	6a 68                	push   $0x68
  jmp alltraps
80106c0b:	e9 f3 f5 ff ff       	jmp    80106203 <alltraps>

80106c10 <vector105>:
.globl vector105
vector105:
  pushl $0
80106c10:	6a 00                	push   $0x0
  pushl $105
80106c12:	6a 69                	push   $0x69
  jmp alltraps
80106c14:	e9 ea f5 ff ff       	jmp    80106203 <alltraps>

80106c19 <vector106>:
.globl vector106
vector106:
  pushl $0
80106c19:	6a 00                	push   $0x0
  pushl $106
80106c1b:	6a 6a                	push   $0x6a
  jmp alltraps
80106c1d:	e9 e1 f5 ff ff       	jmp    80106203 <alltraps>

80106c22 <vector107>:
.globl vector107
vector107:
  pushl $0
80106c22:	6a 00                	push   $0x0
  pushl $107
80106c24:	6a 6b                	push   $0x6b
  jmp alltraps
80106c26:	e9 d8 f5 ff ff       	jmp    80106203 <alltraps>

80106c2b <vector108>:
.globl vector108
vector108:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $108
80106c2d:	6a 6c                	push   $0x6c
  jmp alltraps
80106c2f:	e9 cf f5 ff ff       	jmp    80106203 <alltraps>

80106c34 <vector109>:
.globl vector109
vector109:
  pushl $0
80106c34:	6a 00                	push   $0x0
  pushl $109
80106c36:	6a 6d                	push   $0x6d
  jmp alltraps
80106c38:	e9 c6 f5 ff ff       	jmp    80106203 <alltraps>

80106c3d <vector110>:
.globl vector110
vector110:
  pushl $0
80106c3d:	6a 00                	push   $0x0
  pushl $110
80106c3f:	6a 6e                	push   $0x6e
  jmp alltraps
80106c41:	e9 bd f5 ff ff       	jmp    80106203 <alltraps>

80106c46 <vector111>:
.globl vector111
vector111:
  pushl $0
80106c46:	6a 00                	push   $0x0
  pushl $111
80106c48:	6a 6f                	push   $0x6f
  jmp alltraps
80106c4a:	e9 b4 f5 ff ff       	jmp    80106203 <alltraps>

80106c4f <vector112>:
.globl vector112
vector112:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $112
80106c51:	6a 70                	push   $0x70
  jmp alltraps
80106c53:	e9 ab f5 ff ff       	jmp    80106203 <alltraps>

80106c58 <vector113>:
.globl vector113
vector113:
  pushl $0
80106c58:	6a 00                	push   $0x0
  pushl $113
80106c5a:	6a 71                	push   $0x71
  jmp alltraps
80106c5c:	e9 a2 f5 ff ff       	jmp    80106203 <alltraps>

80106c61 <vector114>:
.globl vector114
vector114:
  pushl $0
80106c61:	6a 00                	push   $0x0
  pushl $114
80106c63:	6a 72                	push   $0x72
  jmp alltraps
80106c65:	e9 99 f5 ff ff       	jmp    80106203 <alltraps>

80106c6a <vector115>:
.globl vector115
vector115:
  pushl $0
80106c6a:	6a 00                	push   $0x0
  pushl $115
80106c6c:	6a 73                	push   $0x73
  jmp alltraps
80106c6e:	e9 90 f5 ff ff       	jmp    80106203 <alltraps>

80106c73 <vector116>:
.globl vector116
vector116:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $116
80106c75:	6a 74                	push   $0x74
  jmp alltraps
80106c77:	e9 87 f5 ff ff       	jmp    80106203 <alltraps>

80106c7c <vector117>:
.globl vector117
vector117:
  pushl $0
80106c7c:	6a 00                	push   $0x0
  pushl $117
80106c7e:	6a 75                	push   $0x75
  jmp alltraps
80106c80:	e9 7e f5 ff ff       	jmp    80106203 <alltraps>

80106c85 <vector118>:
.globl vector118
vector118:
  pushl $0
80106c85:	6a 00                	push   $0x0
  pushl $118
80106c87:	6a 76                	push   $0x76
  jmp alltraps
80106c89:	e9 75 f5 ff ff       	jmp    80106203 <alltraps>

80106c8e <vector119>:
.globl vector119
vector119:
  pushl $0
80106c8e:	6a 00                	push   $0x0
  pushl $119
80106c90:	6a 77                	push   $0x77
  jmp alltraps
80106c92:	e9 6c f5 ff ff       	jmp    80106203 <alltraps>

80106c97 <vector120>:
.globl vector120
vector120:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $120
80106c99:	6a 78                	push   $0x78
  jmp alltraps
80106c9b:	e9 63 f5 ff ff       	jmp    80106203 <alltraps>

80106ca0 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ca0:	6a 00                	push   $0x0
  pushl $121
80106ca2:	6a 79                	push   $0x79
  jmp alltraps
80106ca4:	e9 5a f5 ff ff       	jmp    80106203 <alltraps>

80106ca9 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ca9:	6a 00                	push   $0x0
  pushl $122
80106cab:	6a 7a                	push   $0x7a
  jmp alltraps
80106cad:	e9 51 f5 ff ff       	jmp    80106203 <alltraps>

80106cb2 <vector123>:
.globl vector123
vector123:
  pushl $0
80106cb2:	6a 00                	push   $0x0
  pushl $123
80106cb4:	6a 7b                	push   $0x7b
  jmp alltraps
80106cb6:	e9 48 f5 ff ff       	jmp    80106203 <alltraps>

80106cbb <vector124>:
.globl vector124
vector124:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $124
80106cbd:	6a 7c                	push   $0x7c
  jmp alltraps
80106cbf:	e9 3f f5 ff ff       	jmp    80106203 <alltraps>

80106cc4 <vector125>:
.globl vector125
vector125:
  pushl $0
80106cc4:	6a 00                	push   $0x0
  pushl $125
80106cc6:	6a 7d                	push   $0x7d
  jmp alltraps
80106cc8:	e9 36 f5 ff ff       	jmp    80106203 <alltraps>

80106ccd <vector126>:
.globl vector126
vector126:
  pushl $0
80106ccd:	6a 00                	push   $0x0
  pushl $126
80106ccf:	6a 7e                	push   $0x7e
  jmp alltraps
80106cd1:	e9 2d f5 ff ff       	jmp    80106203 <alltraps>

80106cd6 <vector127>:
.globl vector127
vector127:
  pushl $0
80106cd6:	6a 00                	push   $0x0
  pushl $127
80106cd8:	6a 7f                	push   $0x7f
  jmp alltraps
80106cda:	e9 24 f5 ff ff       	jmp    80106203 <alltraps>

80106cdf <vector128>:
.globl vector128
vector128:
  pushl $0
80106cdf:	6a 00                	push   $0x0
  pushl $128
80106ce1:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106ce6:	e9 18 f5 ff ff       	jmp    80106203 <alltraps>

80106ceb <vector129>:
.globl vector129
vector129:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $129
80106ced:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106cf2:	e9 0c f5 ff ff       	jmp    80106203 <alltraps>

80106cf7 <vector130>:
.globl vector130
vector130:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $130
80106cf9:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106cfe:	e9 00 f5 ff ff       	jmp    80106203 <alltraps>

80106d03 <vector131>:
.globl vector131
vector131:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $131
80106d05:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d0a:	e9 f4 f4 ff ff       	jmp    80106203 <alltraps>

80106d0f <vector132>:
.globl vector132
vector132:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $132
80106d11:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d16:	e9 e8 f4 ff ff       	jmp    80106203 <alltraps>

80106d1b <vector133>:
.globl vector133
vector133:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $133
80106d1d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d22:	e9 dc f4 ff ff       	jmp    80106203 <alltraps>

80106d27 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $134
80106d29:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d2e:	e9 d0 f4 ff ff       	jmp    80106203 <alltraps>

80106d33 <vector135>:
.globl vector135
vector135:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $135
80106d35:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d3a:	e9 c4 f4 ff ff       	jmp    80106203 <alltraps>

80106d3f <vector136>:
.globl vector136
vector136:
  pushl $0
80106d3f:	6a 00                	push   $0x0
  pushl $136
80106d41:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d46:	e9 b8 f4 ff ff       	jmp    80106203 <alltraps>

80106d4b <vector137>:
.globl vector137
vector137:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $137
80106d4d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d52:	e9 ac f4 ff ff       	jmp    80106203 <alltraps>

80106d57 <vector138>:
.globl vector138
vector138:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $138
80106d59:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d5e:	e9 a0 f4 ff ff       	jmp    80106203 <alltraps>

80106d63 <vector139>:
.globl vector139
vector139:
  pushl $0
80106d63:	6a 00                	push   $0x0
  pushl $139
80106d65:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d6a:	e9 94 f4 ff ff       	jmp    80106203 <alltraps>

80106d6f <vector140>:
.globl vector140
vector140:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $140
80106d71:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106d76:	e9 88 f4 ff ff       	jmp    80106203 <alltraps>

80106d7b <vector141>:
.globl vector141
vector141:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $141
80106d7d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106d82:	e9 7c f4 ff ff       	jmp    80106203 <alltraps>

80106d87 <vector142>:
.globl vector142
vector142:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $142
80106d89:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106d8e:	e9 70 f4 ff ff       	jmp    80106203 <alltraps>

80106d93 <vector143>:
.globl vector143
vector143:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $143
80106d95:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106d9a:	e9 64 f4 ff ff       	jmp    80106203 <alltraps>

80106d9f <vector144>:
.globl vector144
vector144:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $144
80106da1:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106da6:	e9 58 f4 ff ff       	jmp    80106203 <alltraps>

80106dab <vector145>:
.globl vector145
vector145:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $145
80106dad:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106db2:	e9 4c f4 ff ff       	jmp    80106203 <alltraps>

80106db7 <vector146>:
.globl vector146
vector146:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $146
80106db9:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106dbe:	e9 40 f4 ff ff       	jmp    80106203 <alltraps>

80106dc3 <vector147>:
.globl vector147
vector147:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $147
80106dc5:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106dca:	e9 34 f4 ff ff       	jmp    80106203 <alltraps>

80106dcf <vector148>:
.globl vector148
vector148:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $148
80106dd1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106dd6:	e9 28 f4 ff ff       	jmp    80106203 <alltraps>

80106ddb <vector149>:
.globl vector149
vector149:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $149
80106ddd:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106de2:	e9 1c f4 ff ff       	jmp    80106203 <alltraps>

80106de7 <vector150>:
.globl vector150
vector150:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $150
80106de9:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106dee:	e9 10 f4 ff ff       	jmp    80106203 <alltraps>

80106df3 <vector151>:
.globl vector151
vector151:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $151
80106df5:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106dfa:	e9 04 f4 ff ff       	jmp    80106203 <alltraps>

80106dff <vector152>:
.globl vector152
vector152:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $152
80106e01:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e06:	e9 f8 f3 ff ff       	jmp    80106203 <alltraps>

80106e0b <vector153>:
.globl vector153
vector153:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $153
80106e0d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e12:	e9 ec f3 ff ff       	jmp    80106203 <alltraps>

80106e17 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $154
80106e19:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e1e:	e9 e0 f3 ff ff       	jmp    80106203 <alltraps>

80106e23 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $155
80106e25:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e2a:	e9 d4 f3 ff ff       	jmp    80106203 <alltraps>

80106e2f <vector156>:
.globl vector156
vector156:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $156
80106e31:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e36:	e9 c8 f3 ff ff       	jmp    80106203 <alltraps>

80106e3b <vector157>:
.globl vector157
vector157:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $157
80106e3d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e42:	e9 bc f3 ff ff       	jmp    80106203 <alltraps>

80106e47 <vector158>:
.globl vector158
vector158:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $158
80106e49:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e4e:	e9 b0 f3 ff ff       	jmp    80106203 <alltraps>

80106e53 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $159
80106e55:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e5a:	e9 a4 f3 ff ff       	jmp    80106203 <alltraps>

80106e5f <vector160>:
.globl vector160
vector160:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $160
80106e61:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e66:	e9 98 f3 ff ff       	jmp    80106203 <alltraps>

80106e6b <vector161>:
.globl vector161
vector161:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $161
80106e6d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106e72:	e9 8c f3 ff ff       	jmp    80106203 <alltraps>

80106e77 <vector162>:
.globl vector162
vector162:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $162
80106e79:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106e7e:	e9 80 f3 ff ff       	jmp    80106203 <alltraps>

80106e83 <vector163>:
.globl vector163
vector163:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $163
80106e85:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106e8a:	e9 74 f3 ff ff       	jmp    80106203 <alltraps>

80106e8f <vector164>:
.globl vector164
vector164:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $164
80106e91:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106e96:	e9 68 f3 ff ff       	jmp    80106203 <alltraps>

80106e9b <vector165>:
.globl vector165
vector165:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $165
80106e9d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ea2:	e9 5c f3 ff ff       	jmp    80106203 <alltraps>

80106ea7 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ea7:	6a 00                	push   $0x0
  pushl $166
80106ea9:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106eae:	e9 50 f3 ff ff       	jmp    80106203 <alltraps>

80106eb3 <vector167>:
.globl vector167
vector167:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $167
80106eb5:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106eba:	e9 44 f3 ff ff       	jmp    80106203 <alltraps>

80106ebf <vector168>:
.globl vector168
vector168:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $168
80106ec1:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ec6:	e9 38 f3 ff ff       	jmp    80106203 <alltraps>

80106ecb <vector169>:
.globl vector169
vector169:
  pushl $0
80106ecb:	6a 00                	push   $0x0
  pushl $169
80106ecd:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106ed2:	e9 2c f3 ff ff       	jmp    80106203 <alltraps>

80106ed7 <vector170>:
.globl vector170
vector170:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $170
80106ed9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106ede:	e9 20 f3 ff ff       	jmp    80106203 <alltraps>

80106ee3 <vector171>:
.globl vector171
vector171:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $171
80106ee5:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106eea:	e9 14 f3 ff ff       	jmp    80106203 <alltraps>

80106eef <vector172>:
.globl vector172
vector172:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $172
80106ef1:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106ef6:	e9 08 f3 ff ff       	jmp    80106203 <alltraps>

80106efb <vector173>:
.globl vector173
vector173:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $173
80106efd:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f02:	e9 fc f2 ff ff       	jmp    80106203 <alltraps>

80106f07 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $174
80106f09:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f0e:	e9 f0 f2 ff ff       	jmp    80106203 <alltraps>

80106f13 <vector175>:
.globl vector175
vector175:
  pushl $0
80106f13:	6a 00                	push   $0x0
  pushl $175
80106f15:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f1a:	e9 e4 f2 ff ff       	jmp    80106203 <alltraps>

80106f1f <vector176>:
.globl vector176
vector176:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $176
80106f21:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f26:	e9 d8 f2 ff ff       	jmp    80106203 <alltraps>

80106f2b <vector177>:
.globl vector177
vector177:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $177
80106f2d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f32:	e9 cc f2 ff ff       	jmp    80106203 <alltraps>

80106f37 <vector178>:
.globl vector178
vector178:
  pushl $0
80106f37:	6a 00                	push   $0x0
  pushl $178
80106f39:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f3e:	e9 c0 f2 ff ff       	jmp    80106203 <alltraps>

80106f43 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $179
80106f45:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f4a:	e9 b4 f2 ff ff       	jmp    80106203 <alltraps>

80106f4f <vector180>:
.globl vector180
vector180:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $180
80106f51:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f56:	e9 a8 f2 ff ff       	jmp    80106203 <alltraps>

80106f5b <vector181>:
.globl vector181
vector181:
  pushl $0
80106f5b:	6a 00                	push   $0x0
  pushl $181
80106f5d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f62:	e9 9c f2 ff ff       	jmp    80106203 <alltraps>

80106f67 <vector182>:
.globl vector182
vector182:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $182
80106f69:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106f6e:	e9 90 f2 ff ff       	jmp    80106203 <alltraps>

80106f73 <vector183>:
.globl vector183
vector183:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $183
80106f75:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106f7a:	e9 84 f2 ff ff       	jmp    80106203 <alltraps>

80106f7f <vector184>:
.globl vector184
vector184:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $184
80106f81:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106f86:	e9 78 f2 ff ff       	jmp    80106203 <alltraps>

80106f8b <vector185>:
.globl vector185
vector185:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $185
80106f8d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106f92:	e9 6c f2 ff ff       	jmp    80106203 <alltraps>

80106f97 <vector186>:
.globl vector186
vector186:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $186
80106f99:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106f9e:	e9 60 f2 ff ff       	jmp    80106203 <alltraps>

80106fa3 <vector187>:
.globl vector187
vector187:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $187
80106fa5:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106faa:	e9 54 f2 ff ff       	jmp    80106203 <alltraps>

80106faf <vector188>:
.globl vector188
vector188:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $188
80106fb1:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106fb6:	e9 48 f2 ff ff       	jmp    80106203 <alltraps>

80106fbb <vector189>:
.globl vector189
vector189:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $189
80106fbd:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106fc2:	e9 3c f2 ff ff       	jmp    80106203 <alltraps>

80106fc7 <vector190>:
.globl vector190
vector190:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $190
80106fc9:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106fce:	e9 30 f2 ff ff       	jmp    80106203 <alltraps>

80106fd3 <vector191>:
.globl vector191
vector191:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $191
80106fd5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106fda:	e9 24 f2 ff ff       	jmp    80106203 <alltraps>

80106fdf <vector192>:
.globl vector192
vector192:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $192
80106fe1:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106fe6:	e9 18 f2 ff ff       	jmp    80106203 <alltraps>

80106feb <vector193>:
.globl vector193
vector193:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $193
80106fed:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106ff2:	e9 0c f2 ff ff       	jmp    80106203 <alltraps>

80106ff7 <vector194>:
.globl vector194
vector194:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $194
80106ff9:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106ffe:	e9 00 f2 ff ff       	jmp    80106203 <alltraps>

80107003 <vector195>:
.globl vector195
vector195:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $195
80107005:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010700a:	e9 f4 f1 ff ff       	jmp    80106203 <alltraps>

8010700f <vector196>:
.globl vector196
vector196:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $196
80107011:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107016:	e9 e8 f1 ff ff       	jmp    80106203 <alltraps>

8010701b <vector197>:
.globl vector197
vector197:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $197
8010701d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107022:	e9 dc f1 ff ff       	jmp    80106203 <alltraps>

80107027 <vector198>:
.globl vector198
vector198:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $198
80107029:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010702e:	e9 d0 f1 ff ff       	jmp    80106203 <alltraps>

80107033 <vector199>:
.globl vector199
vector199:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $199
80107035:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010703a:	e9 c4 f1 ff ff       	jmp    80106203 <alltraps>

8010703f <vector200>:
.globl vector200
vector200:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $200
80107041:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107046:	e9 b8 f1 ff ff       	jmp    80106203 <alltraps>

8010704b <vector201>:
.globl vector201
vector201:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $201
8010704d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107052:	e9 ac f1 ff ff       	jmp    80106203 <alltraps>

80107057 <vector202>:
.globl vector202
vector202:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $202
80107059:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010705e:	e9 a0 f1 ff ff       	jmp    80106203 <alltraps>

80107063 <vector203>:
.globl vector203
vector203:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $203
80107065:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010706a:	e9 94 f1 ff ff       	jmp    80106203 <alltraps>

8010706f <vector204>:
.globl vector204
vector204:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $204
80107071:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107076:	e9 88 f1 ff ff       	jmp    80106203 <alltraps>

8010707b <vector205>:
.globl vector205
vector205:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $205
8010707d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107082:	e9 7c f1 ff ff       	jmp    80106203 <alltraps>

80107087 <vector206>:
.globl vector206
vector206:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $206
80107089:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010708e:	e9 70 f1 ff ff       	jmp    80106203 <alltraps>

80107093 <vector207>:
.globl vector207
vector207:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $207
80107095:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010709a:	e9 64 f1 ff ff       	jmp    80106203 <alltraps>

8010709f <vector208>:
.globl vector208
vector208:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $208
801070a1:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070a6:	e9 58 f1 ff ff       	jmp    80106203 <alltraps>

801070ab <vector209>:
.globl vector209
vector209:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $209
801070ad:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801070b2:	e9 4c f1 ff ff       	jmp    80106203 <alltraps>

801070b7 <vector210>:
.globl vector210
vector210:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $210
801070b9:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070be:	e9 40 f1 ff ff       	jmp    80106203 <alltraps>

801070c3 <vector211>:
.globl vector211
vector211:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $211
801070c5:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801070ca:	e9 34 f1 ff ff       	jmp    80106203 <alltraps>

801070cf <vector212>:
.globl vector212
vector212:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $212
801070d1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801070d6:	e9 28 f1 ff ff       	jmp    80106203 <alltraps>

801070db <vector213>:
.globl vector213
vector213:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $213
801070dd:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801070e2:	e9 1c f1 ff ff       	jmp    80106203 <alltraps>

801070e7 <vector214>:
.globl vector214
vector214:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $214
801070e9:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801070ee:	e9 10 f1 ff ff       	jmp    80106203 <alltraps>

801070f3 <vector215>:
.globl vector215
vector215:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $215
801070f5:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801070fa:	e9 04 f1 ff ff       	jmp    80106203 <alltraps>

801070ff <vector216>:
.globl vector216
vector216:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $216
80107101:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107106:	e9 f8 f0 ff ff       	jmp    80106203 <alltraps>

8010710b <vector217>:
.globl vector217
vector217:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $217
8010710d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107112:	e9 ec f0 ff ff       	jmp    80106203 <alltraps>

80107117 <vector218>:
.globl vector218
vector218:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $218
80107119:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010711e:	e9 e0 f0 ff ff       	jmp    80106203 <alltraps>

80107123 <vector219>:
.globl vector219
vector219:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $219
80107125:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010712a:	e9 d4 f0 ff ff       	jmp    80106203 <alltraps>

8010712f <vector220>:
.globl vector220
vector220:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $220
80107131:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107136:	e9 c8 f0 ff ff       	jmp    80106203 <alltraps>

8010713b <vector221>:
.globl vector221
vector221:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $221
8010713d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107142:	e9 bc f0 ff ff       	jmp    80106203 <alltraps>

80107147 <vector222>:
.globl vector222
vector222:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $222
80107149:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010714e:	e9 b0 f0 ff ff       	jmp    80106203 <alltraps>

80107153 <vector223>:
.globl vector223
vector223:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $223
80107155:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010715a:	e9 a4 f0 ff ff       	jmp    80106203 <alltraps>

8010715f <vector224>:
.globl vector224
vector224:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $224
80107161:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107166:	e9 98 f0 ff ff       	jmp    80106203 <alltraps>

8010716b <vector225>:
.globl vector225
vector225:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $225
8010716d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107172:	e9 8c f0 ff ff       	jmp    80106203 <alltraps>

80107177 <vector226>:
.globl vector226
vector226:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $226
80107179:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010717e:	e9 80 f0 ff ff       	jmp    80106203 <alltraps>

80107183 <vector227>:
.globl vector227
vector227:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $227
80107185:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010718a:	e9 74 f0 ff ff       	jmp    80106203 <alltraps>

8010718f <vector228>:
.globl vector228
vector228:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $228
80107191:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107196:	e9 68 f0 ff ff       	jmp    80106203 <alltraps>

8010719b <vector229>:
.globl vector229
vector229:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $229
8010719d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071a2:	e9 5c f0 ff ff       	jmp    80106203 <alltraps>

801071a7 <vector230>:
.globl vector230
vector230:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $230
801071a9:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801071ae:	e9 50 f0 ff ff       	jmp    80106203 <alltraps>

801071b3 <vector231>:
.globl vector231
vector231:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $231
801071b5:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801071ba:	e9 44 f0 ff ff       	jmp    80106203 <alltraps>

801071bf <vector232>:
.globl vector232
vector232:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $232
801071c1:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801071c6:	e9 38 f0 ff ff       	jmp    80106203 <alltraps>

801071cb <vector233>:
.globl vector233
vector233:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $233
801071cd:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801071d2:	e9 2c f0 ff ff       	jmp    80106203 <alltraps>

801071d7 <vector234>:
.globl vector234
vector234:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $234
801071d9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801071de:	e9 20 f0 ff ff       	jmp    80106203 <alltraps>

801071e3 <vector235>:
.globl vector235
vector235:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $235
801071e5:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801071ea:	e9 14 f0 ff ff       	jmp    80106203 <alltraps>

801071ef <vector236>:
.globl vector236
vector236:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $236
801071f1:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801071f6:	e9 08 f0 ff ff       	jmp    80106203 <alltraps>

801071fb <vector237>:
.globl vector237
vector237:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $237
801071fd:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107202:	e9 fc ef ff ff       	jmp    80106203 <alltraps>

80107207 <vector238>:
.globl vector238
vector238:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $238
80107209:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010720e:	e9 f0 ef ff ff       	jmp    80106203 <alltraps>

80107213 <vector239>:
.globl vector239
vector239:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $239
80107215:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010721a:	e9 e4 ef ff ff       	jmp    80106203 <alltraps>

8010721f <vector240>:
.globl vector240
vector240:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $240
80107221:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107226:	e9 d8 ef ff ff       	jmp    80106203 <alltraps>

8010722b <vector241>:
.globl vector241
vector241:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $241
8010722d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107232:	e9 cc ef ff ff       	jmp    80106203 <alltraps>

80107237 <vector242>:
.globl vector242
vector242:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $242
80107239:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010723e:	e9 c0 ef ff ff       	jmp    80106203 <alltraps>

80107243 <vector243>:
.globl vector243
vector243:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $243
80107245:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010724a:	e9 b4 ef ff ff       	jmp    80106203 <alltraps>

8010724f <vector244>:
.globl vector244
vector244:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $244
80107251:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107256:	e9 a8 ef ff ff       	jmp    80106203 <alltraps>

8010725b <vector245>:
.globl vector245
vector245:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $245
8010725d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107262:	e9 9c ef ff ff       	jmp    80106203 <alltraps>

80107267 <vector246>:
.globl vector246
vector246:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $246
80107269:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010726e:	e9 90 ef ff ff       	jmp    80106203 <alltraps>

80107273 <vector247>:
.globl vector247
vector247:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $247
80107275:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010727a:	e9 84 ef ff ff       	jmp    80106203 <alltraps>

8010727f <vector248>:
.globl vector248
vector248:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $248
80107281:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107286:	e9 78 ef ff ff       	jmp    80106203 <alltraps>

8010728b <vector249>:
.globl vector249
vector249:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $249
8010728d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107292:	e9 6c ef ff ff       	jmp    80106203 <alltraps>

80107297 <vector250>:
.globl vector250
vector250:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $250
80107299:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010729e:	e9 60 ef ff ff       	jmp    80106203 <alltraps>

801072a3 <vector251>:
.globl vector251
vector251:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $251
801072a5:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801072aa:	e9 54 ef ff ff       	jmp    80106203 <alltraps>

801072af <vector252>:
.globl vector252
vector252:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $252
801072b1:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801072b6:	e9 48 ef ff ff       	jmp    80106203 <alltraps>

801072bb <vector253>:
.globl vector253
vector253:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $253
801072bd:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801072c2:	e9 3c ef ff ff       	jmp    80106203 <alltraps>

801072c7 <vector254>:
.globl vector254
vector254:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $254
801072c9:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801072ce:	e9 30 ef ff ff       	jmp    80106203 <alltraps>

801072d3 <vector255>:
.globl vector255
vector255:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $255
801072d5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801072da:	e9 24 ef ff ff       	jmp    80106203 <alltraps>

801072df <lgdt>:
{
801072df:	55                   	push   %ebp
801072e0:	89 e5                	mov    %esp,%ebp
801072e2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801072e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801072e8:	83 e8 01             	sub    $0x1,%eax
801072eb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801072ef:	8b 45 08             	mov    0x8(%ebp),%eax
801072f2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801072f6:	8b 45 08             	mov    0x8(%ebp),%eax
801072f9:	c1 e8 10             	shr    $0x10,%eax
801072fc:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107300:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107303:	0f 01 10             	lgdtl  (%eax)
}
80107306:	90                   	nop
80107307:	c9                   	leave  
80107308:	c3                   	ret    

80107309 <ltr>:
{
80107309:	55                   	push   %ebp
8010730a:	89 e5                	mov    %esp,%ebp
8010730c:	83 ec 04             	sub    $0x4,%esp
8010730f:	8b 45 08             	mov    0x8(%ebp),%eax
80107312:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107316:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010731a:	0f 00 d8             	ltr    %ax
}
8010731d:	90                   	nop
8010731e:	c9                   	leave  
8010731f:	c3                   	ret    

80107320 <lcr3>:

static inline void
lcr3(uint val)
{
80107320:	55                   	push   %ebp
80107321:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107323:	8b 45 08             	mov    0x8(%ebp),%eax
80107326:	0f 22 d8             	mov    %eax,%cr3
}
80107329:	90                   	nop
8010732a:	5d                   	pop    %ebp
8010732b:	c3                   	ret    

8010732c <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010732c:	55                   	push   %ebp
8010732d:	89 e5                	mov    %esp,%ebp
8010732f:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107332:	e8 4a cb ff ff       	call   80103e81 <cpuid>
80107337:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010733d:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80107342:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107348:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010734e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107351:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735a:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010735e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107361:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107365:	83 e2 f0             	and    $0xfffffff0,%edx
80107368:	83 ca 0a             	or     $0xa,%edx
8010736b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010736e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107371:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107375:	83 ca 10             	or     $0x10,%edx
80107378:	88 50 7d             	mov    %dl,0x7d(%eax)
8010737b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107382:	83 e2 9f             	and    $0xffffff9f,%edx
80107385:	88 50 7d             	mov    %dl,0x7d(%eax)
80107388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010738f:	83 ca 80             	or     $0xffffff80,%edx
80107392:	88 50 7d             	mov    %dl,0x7d(%eax)
80107395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107398:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010739c:	83 ca 0f             	or     $0xf,%edx
8010739f:	88 50 7e             	mov    %dl,0x7e(%eax)
801073a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073a9:	83 e2 ef             	and    $0xffffffef,%edx
801073ac:	88 50 7e             	mov    %dl,0x7e(%eax)
801073af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073b6:	83 e2 df             	and    $0xffffffdf,%edx
801073b9:	88 50 7e             	mov    %dl,0x7e(%eax)
801073bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073c3:	83 ca 40             	or     $0x40,%edx
801073c6:	88 50 7e             	mov    %dl,0x7e(%eax)
801073c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073d0:	83 ca 80             	or     $0xffffff80,%edx
801073d3:	88 50 7e             	mov    %dl,0x7e(%eax)
801073d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801073dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801073e7:	ff ff 
801073e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ec:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801073f3:	00 00 
801073f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f8:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801073ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107402:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107409:	83 e2 f0             	and    $0xfffffff0,%edx
8010740c:	83 ca 02             	or     $0x2,%edx
8010740f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107418:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010741f:	83 ca 10             	or     $0x10,%edx
80107422:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107432:	83 e2 9f             	and    $0xffffff9f,%edx
80107435:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010743b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107445:	83 ca 80             	or     $0xffffff80,%edx
80107448:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010744e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107451:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107458:	83 ca 0f             	or     $0xf,%edx
8010745b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107464:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010746b:	83 e2 ef             	and    $0xffffffef,%edx
8010746e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107477:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010747e:	83 e2 df             	and    $0xffffffdf,%edx
80107481:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107491:	83 ca 40             	or     $0x40,%edx
80107494:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010749a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074a4:	83 ca 80             	or     $0xffffff80,%edx
801074a7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b0:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801074b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ba:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801074c1:	ff ff 
801074c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c6:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801074cd:	00 00 
801074cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d2:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801074d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074dc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074e3:	83 e2 f0             	and    $0xfffffff0,%edx
801074e6:	83 ca 0a             	or     $0xa,%edx
801074e9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801074ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074f9:	83 ca 10             	or     $0x10,%edx
801074fc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107505:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010750c:	83 ca 60             	or     $0x60,%edx
8010750f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107518:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010751f:	83 ca 80             	or     $0xffffff80,%edx
80107522:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107532:	83 ca 0f             	or     $0xf,%edx
80107535:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010753b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107545:	83 e2 ef             	and    $0xffffffef,%edx
80107548:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010754e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107551:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107558:	83 e2 df             	and    $0xffffffdf,%edx
8010755b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107564:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010756b:	83 ca 40             	or     $0x40,%edx
8010756e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107577:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010757e:	83 ca 80             	or     $0xffffff80,%edx
80107581:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758a:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107594:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010759b:	ff ff 
8010759d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a0:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801075a7:	00 00 
801075a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ac:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801075b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075bd:	83 e2 f0             	and    $0xfffffff0,%edx
801075c0:	83 ca 02             	or     $0x2,%edx
801075c3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075d3:	83 ca 10             	or     $0x10,%edx
801075d6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075df:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075e6:	83 ca 60             	or     $0x60,%edx
801075e9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075f9:	83 ca 80             	or     $0xffffff80,%edx
801075fc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107605:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010760c:	83 ca 0f             	or     $0xf,%edx
8010760f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107618:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010761f:	83 e2 ef             	and    $0xffffffef,%edx
80107622:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107632:	83 e2 df             	and    $0xffffffdf,%edx
80107635:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010763b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107645:	83 ca 40             	or     $0x40,%edx
80107648:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010764e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107651:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107658:	83 ca 80             	or     $0xffffff80,%edx
8010765b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107664:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010766b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766e:	83 c0 70             	add    $0x70,%eax
80107671:	83 ec 08             	sub    $0x8,%esp
80107674:	6a 30                	push   $0x30
80107676:	50                   	push   %eax
80107677:	e8 63 fc ff ff       	call   801072df <lgdt>
8010767c:	83 c4 10             	add    $0x10,%esp
}
8010767f:	90                   	nop
80107680:	c9                   	leave  
80107681:	c3                   	ret    

80107682 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107682:	55                   	push   %ebp
80107683:	89 e5                	mov    %esp,%ebp
80107685:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107688:	8b 45 0c             	mov    0xc(%ebp),%eax
8010768b:	c1 e8 16             	shr    $0x16,%eax
8010768e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107695:	8b 45 08             	mov    0x8(%ebp),%eax
80107698:	01 d0                	add    %edx,%eax
8010769a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010769d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076a0:	8b 00                	mov    (%eax),%eax
801076a2:	83 e0 01             	and    $0x1,%eax
801076a5:	85 c0                	test   %eax,%eax
801076a7:	74 14                	je     801076bd <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801076a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076ac:	8b 00                	mov    (%eax),%eax
801076ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076b3:	05 00 00 00 80       	add    $0x80000000,%eax
801076b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076bb:	eb 42                	jmp    801076ff <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801076bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801076c1:	74 0e                	je     801076d1 <walkpgdir+0x4f>
801076c3:	e8 bc b5 ff ff       	call   80102c84 <kalloc>
801076c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801076cf:	75 07                	jne    801076d8 <walkpgdir+0x56>
      return 0;
801076d1:	b8 00 00 00 00       	mov    $0x0,%eax
801076d6:	eb 3e                	jmp    80107716 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801076d8:	83 ec 04             	sub    $0x4,%esp
801076db:	68 00 10 00 00       	push   $0x1000
801076e0:	6a 00                	push   $0x0
801076e2:	ff 75 f4             	push   -0xc(%ebp)
801076e5:	e8 6e d7 ff ff       	call   80104e58 <memset>
801076ea:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801076ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f0:	05 00 00 00 80       	add    $0x80000000,%eax
801076f5:	83 c8 07             	or     $0x7,%eax
801076f8:	89 c2                	mov    %eax,%edx
801076fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076fd:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801076ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80107702:	c1 e8 0c             	shr    $0xc,%eax
80107705:	25 ff 03 00 00       	and    $0x3ff,%eax
8010770a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107714:	01 d0                	add    %edx,%eax
}
80107716:	c9                   	leave  
80107717:	c3                   	ret    

80107718 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107718:	55                   	push   %ebp
80107719:	89 e5                	mov    %esp,%ebp
8010771b:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010771e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107721:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107726:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107729:	8b 55 0c             	mov    0xc(%ebp),%edx
8010772c:	8b 45 10             	mov    0x10(%ebp),%eax
8010772f:	01 d0                	add    %edx,%eax
80107731:	83 e8 01             	sub    $0x1,%eax
80107734:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107739:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010773c:	83 ec 04             	sub    $0x4,%esp
8010773f:	6a 01                	push   $0x1
80107741:	ff 75 f4             	push   -0xc(%ebp)
80107744:	ff 75 08             	push   0x8(%ebp)
80107747:	e8 36 ff ff ff       	call   80107682 <walkpgdir>
8010774c:	83 c4 10             	add    $0x10,%esp
8010774f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107752:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107756:	75 07                	jne    8010775f <mappages+0x47>
      return -1;
80107758:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010775d:	eb 47                	jmp    801077a6 <mappages+0x8e>
    if(*pte & PTE_P)
8010775f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107762:	8b 00                	mov    (%eax),%eax
80107764:	83 e0 01             	and    $0x1,%eax
80107767:	85 c0                	test   %eax,%eax
80107769:	74 0d                	je     80107778 <mappages+0x60>
      panic("remap");
8010776b:	83 ec 0c             	sub    $0xc,%esp
8010776e:	68 ac a9 10 80       	push   $0x8010a9ac
80107773:	e8 31 8e ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107778:	8b 45 18             	mov    0x18(%ebp),%eax
8010777b:	0b 45 14             	or     0x14(%ebp),%eax
8010777e:	83 c8 01             	or     $0x1,%eax
80107781:	89 c2                	mov    %eax,%edx
80107783:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107786:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010778e:	74 10                	je     801077a0 <mappages+0x88>
      break;
    a += PGSIZE;
80107790:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107797:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010779e:	eb 9c                	jmp    8010773c <mappages+0x24>
      break;
801077a0:	90                   	nop
  }
  return 0;
801077a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077a6:	c9                   	leave  
801077a7:	c3                   	ret    

801077a8 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801077a8:	55                   	push   %ebp
801077a9:	89 e5                	mov    %esp,%ebp
801077ab:	53                   	push   %ebx
801077ac:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801077af:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801077b6:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
801077bc:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801077c1:	29 d0                	sub    %edx,%eax
801077c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801077c6:	a1 88 9d 11 80       	mov    0x80119d88,%eax
801077cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077ce:	8b 15 88 9d 11 80    	mov    0x80119d88,%edx
801077d4:	a1 90 9d 11 80       	mov    0x80119d90,%eax
801077d9:	01 d0                	add    %edx,%eax
801077db:	89 45 e8             	mov    %eax,-0x18(%ebp)
801077de:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801077e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e8:	83 c0 30             	add    $0x30,%eax
801077eb:	8b 55 e0             	mov    -0x20(%ebp),%edx
801077ee:	89 10                	mov    %edx,(%eax)
801077f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801077f3:	89 50 04             	mov    %edx,0x4(%eax)
801077f6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801077f9:	89 50 08             	mov    %edx,0x8(%eax)
801077fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801077ff:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107802:	e8 7d b4 ff ff       	call   80102c84 <kalloc>
80107807:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010780a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010780e:	75 07                	jne    80107817 <setupkvm+0x6f>
    return 0;
80107810:	b8 00 00 00 00       	mov    $0x0,%eax
80107815:	eb 78                	jmp    8010788f <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107817:	83 ec 04             	sub    $0x4,%esp
8010781a:	68 00 10 00 00       	push   $0x1000
8010781f:	6a 00                	push   $0x0
80107821:	ff 75 f0             	push   -0x10(%ebp)
80107824:	e8 2f d6 ff ff       	call   80104e58 <memset>
80107829:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010782c:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107833:	eb 4e                	jmp    80107883 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107838:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010783b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783e:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107844:	8b 58 08             	mov    0x8(%eax),%ebx
80107847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784a:	8b 40 04             	mov    0x4(%eax),%eax
8010784d:	29 c3                	sub    %eax,%ebx
8010784f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107852:	8b 00                	mov    (%eax),%eax
80107854:	83 ec 0c             	sub    $0xc,%esp
80107857:	51                   	push   %ecx
80107858:	52                   	push   %edx
80107859:	53                   	push   %ebx
8010785a:	50                   	push   %eax
8010785b:	ff 75 f0             	push   -0x10(%ebp)
8010785e:	e8 b5 fe ff ff       	call   80107718 <mappages>
80107863:	83 c4 20             	add    $0x20,%esp
80107866:	85 c0                	test   %eax,%eax
80107868:	79 15                	jns    8010787f <setupkvm+0xd7>
      freevm(pgdir);
8010786a:	83 ec 0c             	sub    $0xc,%esp
8010786d:	ff 75 f0             	push   -0x10(%ebp)
80107870:	e8 f5 04 00 00       	call   80107d6a <freevm>
80107875:	83 c4 10             	add    $0x10,%esp
      return 0;
80107878:	b8 00 00 00 00       	mov    $0x0,%eax
8010787d:	eb 10                	jmp    8010788f <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010787f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107883:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
8010788a:	72 a9                	jb     80107835 <setupkvm+0x8d>
    }
  return pgdir;
8010788c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010788f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107892:	c9                   	leave  
80107893:	c3                   	ret    

80107894 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107894:	55                   	push   %ebp
80107895:	89 e5                	mov    %esp,%ebp
80107897:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010789a:	e8 09 ff ff ff       	call   801077a8 <setupkvm>
8010789f:	a3 bc 9a 11 80       	mov    %eax,0x80119abc
  switchkvm();
801078a4:	e8 03 00 00 00       	call   801078ac <switchkvm>
}
801078a9:	90                   	nop
801078aa:	c9                   	leave  
801078ab:	c3                   	ret    

801078ac <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078ac:	55                   	push   %ebp
801078ad:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078af:	a1 bc 9a 11 80       	mov    0x80119abc,%eax
801078b4:	05 00 00 00 80       	add    $0x80000000,%eax
801078b9:	50                   	push   %eax
801078ba:	e8 61 fa ff ff       	call   80107320 <lcr3>
801078bf:	83 c4 04             	add    $0x4,%esp
}
801078c2:	90                   	nop
801078c3:	c9                   	leave  
801078c4:	c3                   	ret    

801078c5 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801078c5:	55                   	push   %ebp
801078c6:	89 e5                	mov    %esp,%ebp
801078c8:	56                   	push   %esi
801078c9:	53                   	push   %ebx
801078ca:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801078cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801078d1:	75 0d                	jne    801078e0 <switchuvm+0x1b>
    panic("switchuvm: no process");
801078d3:	83 ec 0c             	sub    $0xc,%esp
801078d6:	68 b2 a9 10 80       	push   $0x8010a9b2
801078db:	e8 c9 8c ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
801078e0:	8b 45 08             	mov    0x8(%ebp),%eax
801078e3:	8b 40 08             	mov    0x8(%eax),%eax
801078e6:	85 c0                	test   %eax,%eax
801078e8:	75 0d                	jne    801078f7 <switchuvm+0x32>
    panic("switchuvm: no kstack");
801078ea:	83 ec 0c             	sub    $0xc,%esp
801078ed:	68 c8 a9 10 80       	push   $0x8010a9c8
801078f2:	e8 b2 8c ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
801078f7:	8b 45 08             	mov    0x8(%ebp),%eax
801078fa:	8b 40 04             	mov    0x4(%eax),%eax
801078fd:	85 c0                	test   %eax,%eax
801078ff:	75 0d                	jne    8010790e <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107901:	83 ec 0c             	sub    $0xc,%esp
80107904:	68 dd a9 10 80       	push   $0x8010a9dd
80107909:	e8 9b 8c ff ff       	call   801005a9 <panic>

  pushcli();
8010790e:	e8 3a d4 ff ff       	call   80104d4d <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107913:	e8 84 c5 ff ff       	call   80103e9c <mycpu>
80107918:	89 c3                	mov    %eax,%ebx
8010791a:	e8 7d c5 ff ff       	call   80103e9c <mycpu>
8010791f:	83 c0 08             	add    $0x8,%eax
80107922:	89 c6                	mov    %eax,%esi
80107924:	e8 73 c5 ff ff       	call   80103e9c <mycpu>
80107929:	83 c0 08             	add    $0x8,%eax
8010792c:	c1 e8 10             	shr    $0x10,%eax
8010792f:	88 45 f7             	mov    %al,-0x9(%ebp)
80107932:	e8 65 c5 ff ff       	call   80103e9c <mycpu>
80107937:	83 c0 08             	add    $0x8,%eax
8010793a:	c1 e8 18             	shr    $0x18,%eax
8010793d:	89 c2                	mov    %eax,%edx
8010793f:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107946:	67 00 
80107948:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010794f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107953:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107959:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107960:	83 e0 f0             	and    $0xfffffff0,%eax
80107963:	83 c8 09             	or     $0x9,%eax
80107966:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010796c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107973:	83 c8 10             	or     $0x10,%eax
80107976:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010797c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107983:	83 e0 9f             	and    $0xffffff9f,%eax
80107986:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010798c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107993:	83 c8 80             	or     $0xffffff80,%eax
80107996:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010799c:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079a3:	83 e0 f0             	and    $0xfffffff0,%eax
801079a6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079ac:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079b3:	83 e0 ef             	and    $0xffffffef,%eax
801079b6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079bc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079c3:	83 e0 df             	and    $0xffffffdf,%eax
801079c6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079cc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079d3:	83 c8 40             	or     $0x40,%eax
801079d6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079dc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079e3:	83 e0 7f             	and    $0x7f,%eax
801079e6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079ec:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801079f2:	e8 a5 c4 ff ff       	call   80103e9c <mycpu>
801079f7:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801079fe:	83 e2 ef             	and    $0xffffffef,%edx
80107a01:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a07:	e8 90 c4 ff ff       	call   80103e9c <mycpu>
80107a0c:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a12:	8b 45 08             	mov    0x8(%ebp),%eax
80107a15:	8b 40 08             	mov    0x8(%eax),%eax
80107a18:	89 c3                	mov    %eax,%ebx
80107a1a:	e8 7d c4 ff ff       	call   80103e9c <mycpu>
80107a1f:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a25:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a28:	e8 6f c4 ff ff       	call   80103e9c <mycpu>
80107a2d:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a33:	83 ec 0c             	sub    $0xc,%esp
80107a36:	6a 28                	push   $0x28
80107a38:	e8 cc f8 ff ff       	call   80107309 <ltr>
80107a3d:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a40:	8b 45 08             	mov    0x8(%ebp),%eax
80107a43:	8b 40 04             	mov    0x4(%eax),%eax
80107a46:	05 00 00 00 80       	add    $0x80000000,%eax
80107a4b:	83 ec 0c             	sub    $0xc,%esp
80107a4e:	50                   	push   %eax
80107a4f:	e8 cc f8 ff ff       	call   80107320 <lcr3>
80107a54:	83 c4 10             	add    $0x10,%esp
  popcli();
80107a57:	e8 3e d3 ff ff       	call   80104d9a <popcli>
}
80107a5c:	90                   	nop
80107a5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107a60:	5b                   	pop    %ebx
80107a61:	5e                   	pop    %esi
80107a62:	5d                   	pop    %ebp
80107a63:	c3                   	ret    

80107a64 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107a64:	55                   	push   %ebp
80107a65:	89 e5                	mov    %esp,%ebp
80107a67:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107a6a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107a71:	76 0d                	jbe    80107a80 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107a73:	83 ec 0c             	sub    $0xc,%esp
80107a76:	68 f1 a9 10 80       	push   $0x8010a9f1
80107a7b:	e8 29 8b ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107a80:	e8 ff b1 ff ff       	call   80102c84 <kalloc>
80107a85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107a88:	83 ec 04             	sub    $0x4,%esp
80107a8b:	68 00 10 00 00       	push   $0x1000
80107a90:	6a 00                	push   $0x0
80107a92:	ff 75 f4             	push   -0xc(%ebp)
80107a95:	e8 be d3 ff ff       	call   80104e58 <memset>
80107a9a:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa0:	05 00 00 00 80       	add    $0x80000000,%eax
80107aa5:	83 ec 0c             	sub    $0xc,%esp
80107aa8:	6a 06                	push   $0x6
80107aaa:	50                   	push   %eax
80107aab:	68 00 10 00 00       	push   $0x1000
80107ab0:	6a 00                	push   $0x0
80107ab2:	ff 75 08             	push   0x8(%ebp)
80107ab5:	e8 5e fc ff ff       	call   80107718 <mappages>
80107aba:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107abd:	83 ec 04             	sub    $0x4,%esp
80107ac0:	ff 75 10             	push   0x10(%ebp)
80107ac3:	ff 75 0c             	push   0xc(%ebp)
80107ac6:	ff 75 f4             	push   -0xc(%ebp)
80107ac9:	e8 49 d4 ff ff       	call   80104f17 <memmove>
80107ace:	83 c4 10             	add    $0x10,%esp
}
80107ad1:	90                   	nop
80107ad2:	c9                   	leave  
80107ad3:	c3                   	ret    

80107ad4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107ad4:	55                   	push   %ebp
80107ad5:	89 e5                	mov    %esp,%ebp
80107ad7:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107ada:	8b 45 0c             	mov    0xc(%ebp),%eax
80107add:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ae2:	85 c0                	test   %eax,%eax
80107ae4:	74 0d                	je     80107af3 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107ae6:	83 ec 0c             	sub    $0xc,%esp
80107ae9:	68 0c aa 10 80       	push   $0x8010aa0c
80107aee:	e8 b6 8a ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107af3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107afa:	e9 8f 00 00 00       	jmp    80107b8e <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107aff:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b05:	01 d0                	add    %edx,%eax
80107b07:	83 ec 04             	sub    $0x4,%esp
80107b0a:	6a 00                	push   $0x0
80107b0c:	50                   	push   %eax
80107b0d:	ff 75 08             	push   0x8(%ebp)
80107b10:	e8 6d fb ff ff       	call   80107682 <walkpgdir>
80107b15:	83 c4 10             	add    $0x10,%esp
80107b18:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b1f:	75 0d                	jne    80107b2e <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107b21:	83 ec 0c             	sub    $0xc,%esp
80107b24:	68 2f aa 10 80       	push   $0x8010aa2f
80107b29:	e8 7b 8a ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107b2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b31:	8b 00                	mov    (%eax),%eax
80107b33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b38:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b3b:	8b 45 18             	mov    0x18(%ebp),%eax
80107b3e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b41:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b46:	77 0b                	ja     80107b53 <loaduvm+0x7f>
      n = sz - i;
80107b48:	8b 45 18             	mov    0x18(%ebp),%eax
80107b4b:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b51:	eb 07                	jmp    80107b5a <loaduvm+0x86>
    else
      n = PGSIZE;
80107b53:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107b5a:	8b 55 14             	mov    0x14(%ebp),%edx
80107b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b60:	01 d0                	add    %edx,%eax
80107b62:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107b65:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107b6b:	ff 75 f0             	push   -0x10(%ebp)
80107b6e:	50                   	push   %eax
80107b6f:	52                   	push   %edx
80107b70:	ff 75 10             	push   0x10(%ebp)
80107b73:	e8 5e a3 ff ff       	call   80101ed6 <readi>
80107b78:	83 c4 10             	add    $0x10,%esp
80107b7b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107b7e:	74 07                	je     80107b87 <loaduvm+0xb3>
      return -1;
80107b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b85:	eb 18                	jmp    80107b9f <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107b87:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b91:	3b 45 18             	cmp    0x18(%ebp),%eax
80107b94:	0f 82 65 ff ff ff    	jb     80107aff <loaduvm+0x2b>
  }
  return 0;
80107b9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b9f:	c9                   	leave  
80107ba0:	c3                   	ret    

80107ba1 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ba1:	55                   	push   %ebp
80107ba2:	89 e5                	mov    %esp,%ebp
80107ba4:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107ba7:	8b 45 10             	mov    0x10(%ebp),%eax
80107baa:	85 c0                	test   %eax,%eax
80107bac:	79 0a                	jns    80107bb8 <allocuvm+0x17>
    return 0;
80107bae:	b8 00 00 00 00       	mov    $0x0,%eax
80107bb3:	e9 ec 00 00 00       	jmp    80107ca4 <allocuvm+0x103>
  if(newsz < oldsz)
80107bb8:	8b 45 10             	mov    0x10(%ebp),%eax
80107bbb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107bbe:	73 08                	jae    80107bc8 <allocuvm+0x27>
    return oldsz;
80107bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bc3:	e9 dc 00 00 00       	jmp    80107ca4 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bcb:	05 ff 0f 00 00       	add    $0xfff,%eax
80107bd0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107bd8:	e9 b8 00 00 00       	jmp    80107c95 <allocuvm+0xf4>
    mem = kalloc();
80107bdd:	e8 a2 b0 ff ff       	call   80102c84 <kalloc>
80107be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107be5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107be9:	75 2e                	jne    80107c19 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107beb:	83 ec 0c             	sub    $0xc,%esp
80107bee:	68 4d aa 10 80       	push   $0x8010aa4d
80107bf3:	e8 fc 87 ff ff       	call   801003f4 <cprintf>
80107bf8:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107bfb:	83 ec 04             	sub    $0x4,%esp
80107bfe:	ff 75 0c             	push   0xc(%ebp)
80107c01:	ff 75 10             	push   0x10(%ebp)
80107c04:	ff 75 08             	push   0x8(%ebp)
80107c07:	e8 9a 00 00 00       	call   80107ca6 <deallocuvm>
80107c0c:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80107c14:	e9 8b 00 00 00       	jmp    80107ca4 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107c19:	83 ec 04             	sub    $0x4,%esp
80107c1c:	68 00 10 00 00       	push   $0x1000
80107c21:	6a 00                	push   $0x0
80107c23:	ff 75 f0             	push   -0x10(%ebp)
80107c26:	e8 2d d2 ff ff       	call   80104e58 <memset>
80107c2b:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107c2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c31:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3a:	83 ec 0c             	sub    $0xc,%esp
80107c3d:	6a 06                	push   $0x6
80107c3f:	52                   	push   %edx
80107c40:	68 00 10 00 00       	push   $0x1000
80107c45:	50                   	push   %eax
80107c46:	ff 75 08             	push   0x8(%ebp)
80107c49:	e8 ca fa ff ff       	call   80107718 <mappages>
80107c4e:	83 c4 20             	add    $0x20,%esp
80107c51:	85 c0                	test   %eax,%eax
80107c53:	79 39                	jns    80107c8e <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107c55:	83 ec 0c             	sub    $0xc,%esp
80107c58:	68 65 aa 10 80       	push   $0x8010aa65
80107c5d:	e8 92 87 ff ff       	call   801003f4 <cprintf>
80107c62:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c65:	83 ec 04             	sub    $0x4,%esp
80107c68:	ff 75 0c             	push   0xc(%ebp)
80107c6b:	ff 75 10             	push   0x10(%ebp)
80107c6e:	ff 75 08             	push   0x8(%ebp)
80107c71:	e8 30 00 00 00       	call   80107ca6 <deallocuvm>
80107c76:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107c79:	83 ec 0c             	sub    $0xc,%esp
80107c7c:	ff 75 f0             	push   -0x10(%ebp)
80107c7f:	e8 66 af ff ff       	call   80102bea <kfree>
80107c84:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c87:	b8 00 00 00 00       	mov    $0x0,%eax
80107c8c:	eb 16                	jmp    80107ca4 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107c8e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c98:	3b 45 10             	cmp    0x10(%ebp),%eax
80107c9b:	0f 82 3c ff ff ff    	jb     80107bdd <allocuvm+0x3c>
    }
  }
  return newsz;
80107ca1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ca4:	c9                   	leave  
80107ca5:	c3                   	ret    

80107ca6 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ca6:	55                   	push   %ebp
80107ca7:	89 e5                	mov    %esp,%ebp
80107ca9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107cac:	8b 45 10             	mov    0x10(%ebp),%eax
80107caf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107cb2:	72 08                	jb     80107cbc <deallocuvm+0x16>
    return oldsz;
80107cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cb7:	e9 ac 00 00 00       	jmp    80107d68 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107cbc:	8b 45 10             	mov    0x10(%ebp),%eax
80107cbf:	05 ff 0f 00 00       	add    $0xfff,%eax
80107cc4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107ccc:	e9 88 00 00 00       	jmp    80107d59 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd4:	83 ec 04             	sub    $0x4,%esp
80107cd7:	6a 00                	push   $0x0
80107cd9:	50                   	push   %eax
80107cda:	ff 75 08             	push   0x8(%ebp)
80107cdd:	e8 a0 f9 ff ff       	call   80107682 <walkpgdir>
80107ce2:	83 c4 10             	add    $0x10,%esp
80107ce5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107ce8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cec:	75 16                	jne    80107d04 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf1:	c1 e8 16             	shr    $0x16,%eax
80107cf4:	83 c0 01             	add    $0x1,%eax
80107cf7:	c1 e0 16             	shl    $0x16,%eax
80107cfa:	2d 00 10 00 00       	sub    $0x1000,%eax
80107cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d02:	eb 4e                	jmp    80107d52 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d07:	8b 00                	mov    (%eax),%eax
80107d09:	83 e0 01             	and    $0x1,%eax
80107d0c:	85 c0                	test   %eax,%eax
80107d0e:	74 42                	je     80107d52 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107d10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d13:	8b 00                	mov    (%eax),%eax
80107d15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d21:	75 0d                	jne    80107d30 <deallocuvm+0x8a>
        panic("kfree");
80107d23:	83 ec 0c             	sub    $0xc,%esp
80107d26:	68 81 aa 10 80       	push   $0x8010aa81
80107d2b:	e8 79 88 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107d30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d33:	05 00 00 00 80       	add    $0x80000000,%eax
80107d38:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107d3b:	83 ec 0c             	sub    $0xc,%esp
80107d3e:	ff 75 e8             	push   -0x18(%ebp)
80107d41:	e8 a4 ae ff ff       	call   80102bea <kfree>
80107d46:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107d52:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d5f:	0f 82 6c ff ff ff    	jb     80107cd1 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107d65:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d68:	c9                   	leave  
80107d69:	c3                   	ret    

80107d6a <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107d6a:	55                   	push   %ebp
80107d6b:	89 e5                	mov    %esp,%ebp
80107d6d:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107d70:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d74:	75 0d                	jne    80107d83 <freevm+0x19>
    panic("freevm: no pgdir");
80107d76:	83 ec 0c             	sub    $0xc,%esp
80107d79:	68 87 aa 10 80       	push   $0x8010aa87
80107d7e:	e8 26 88 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107d83:	83 ec 04             	sub    $0x4,%esp
80107d86:	6a 00                	push   $0x0
80107d88:	68 00 00 00 80       	push   $0x80000000
80107d8d:	ff 75 08             	push   0x8(%ebp)
80107d90:	e8 11 ff ff ff       	call   80107ca6 <deallocuvm>
80107d95:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107d98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d9f:	eb 48                	jmp    80107de9 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dab:	8b 45 08             	mov    0x8(%ebp),%eax
80107dae:	01 d0                	add    %edx,%eax
80107db0:	8b 00                	mov    (%eax),%eax
80107db2:	83 e0 01             	and    $0x1,%eax
80107db5:	85 c0                	test   %eax,%eax
80107db7:	74 2c                	je     80107de5 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc6:	01 d0                	add    %edx,%eax
80107dc8:	8b 00                	mov    (%eax),%eax
80107dca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dcf:	05 00 00 00 80       	add    $0x80000000,%eax
80107dd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107dd7:	83 ec 0c             	sub    $0xc,%esp
80107dda:	ff 75 f0             	push   -0x10(%ebp)
80107ddd:	e8 08 ae ff ff       	call   80102bea <kfree>
80107de2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107de5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107de9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107df0:	76 af                	jbe    80107da1 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107df2:	83 ec 0c             	sub    $0xc,%esp
80107df5:	ff 75 08             	push   0x8(%ebp)
80107df8:	e8 ed ad ff ff       	call   80102bea <kfree>
80107dfd:	83 c4 10             	add    $0x10,%esp
}
80107e00:	90                   	nop
80107e01:	c9                   	leave  
80107e02:	c3                   	ret    

80107e03 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e03:	55                   	push   %ebp
80107e04:	89 e5                	mov    %esp,%ebp
80107e06:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e09:	83 ec 04             	sub    $0x4,%esp
80107e0c:	6a 00                	push   $0x0
80107e0e:	ff 75 0c             	push   0xc(%ebp)
80107e11:	ff 75 08             	push   0x8(%ebp)
80107e14:	e8 69 f8 ff ff       	call   80107682 <walkpgdir>
80107e19:	83 c4 10             	add    $0x10,%esp
80107e1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e23:	75 0d                	jne    80107e32 <clearpteu+0x2f>
    panic("clearpteu");
80107e25:	83 ec 0c             	sub    $0xc,%esp
80107e28:	68 98 aa 10 80       	push   $0x8010aa98
80107e2d:	e8 77 87 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e35:	8b 00                	mov    (%eax),%eax
80107e37:	83 e0 fb             	and    $0xfffffffb,%eax
80107e3a:	89 c2                	mov    %eax,%edx
80107e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3f:	89 10                	mov    %edx,(%eax)
}
80107e41:	90                   	nop
80107e42:	c9                   	leave  
80107e43:	c3                   	ret    

80107e44 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e44:	55                   	push   %ebp
80107e45:	89 e5                	mov    %esp,%ebp
80107e47:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107e4a:	e8 59 f9 ff ff       	call   801077a8 <setupkvm>
80107e4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e56:	75 0a                	jne    80107e62 <copyuvm+0x1e>
    return 0;
80107e58:	b8 00 00 00 00       	mov    $0x0,%eax
80107e5d:	e9 eb 00 00 00       	jmp    80107f4d <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107e62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e69:	e9 b7 00 00 00       	jmp    80107f25 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e71:	83 ec 04             	sub    $0x4,%esp
80107e74:	6a 00                	push   $0x0
80107e76:	50                   	push   %eax
80107e77:	ff 75 08             	push   0x8(%ebp)
80107e7a:	e8 03 f8 ff ff       	call   80107682 <walkpgdir>
80107e7f:	83 c4 10             	add    $0x10,%esp
80107e82:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e89:	75 0d                	jne    80107e98 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107e8b:	83 ec 0c             	sub    $0xc,%esp
80107e8e:	68 a2 aa 10 80       	push   $0x8010aaa2
80107e93:	e8 11 87 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107e98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e9b:	8b 00                	mov    (%eax),%eax
80107e9d:	83 e0 01             	and    $0x1,%eax
80107ea0:	85 c0                	test   %eax,%eax
80107ea2:	75 0d                	jne    80107eb1 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107ea4:	83 ec 0c             	sub    $0xc,%esp
80107ea7:	68 bc aa 10 80       	push   $0x8010aabc
80107eac:	e8 f8 86 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107eb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eb4:	8b 00                	mov    (%eax),%eax
80107eb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ebb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec1:	8b 00                	mov    (%eax),%eax
80107ec3:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ec8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107ecb:	e8 b4 ad ff ff       	call   80102c84 <kalloc>
80107ed0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ed3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107ed7:	74 5d                	je     80107f36 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107ed9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107edc:	05 00 00 00 80       	add    $0x80000000,%eax
80107ee1:	83 ec 04             	sub    $0x4,%esp
80107ee4:	68 00 10 00 00       	push   $0x1000
80107ee9:	50                   	push   %eax
80107eea:	ff 75 e0             	push   -0x20(%ebp)
80107eed:	e8 25 d0 ff ff       	call   80104f17 <memmove>
80107ef2:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107ef5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107ef8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107efb:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f04:	83 ec 0c             	sub    $0xc,%esp
80107f07:	52                   	push   %edx
80107f08:	51                   	push   %ecx
80107f09:	68 00 10 00 00       	push   $0x1000
80107f0e:	50                   	push   %eax
80107f0f:	ff 75 f0             	push   -0x10(%ebp)
80107f12:	e8 01 f8 ff ff       	call   80107718 <mappages>
80107f17:	83 c4 20             	add    $0x20,%esp
80107f1a:	85 c0                	test   %eax,%eax
80107f1c:	78 1b                	js     80107f39 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107f1e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f28:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f2b:	0f 82 3d ff ff ff    	jb     80107e6e <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f34:	eb 17                	jmp    80107f4d <copyuvm+0x109>
      goto bad;
80107f36:	90                   	nop
80107f37:	eb 01                	jmp    80107f3a <copyuvm+0xf6>
      goto bad;
80107f39:	90                   	nop

bad:
  freevm(d);
80107f3a:	83 ec 0c             	sub    $0xc,%esp
80107f3d:	ff 75 f0             	push   -0x10(%ebp)
80107f40:	e8 25 fe ff ff       	call   80107d6a <freevm>
80107f45:	83 c4 10             	add    $0x10,%esp
  return 0;
80107f48:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f4d:	c9                   	leave  
80107f4e:	c3                   	ret    

80107f4f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107f4f:	55                   	push   %ebp
80107f50:	89 e5                	mov    %esp,%ebp
80107f52:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f55:	83 ec 04             	sub    $0x4,%esp
80107f58:	6a 00                	push   $0x0
80107f5a:	ff 75 0c             	push   0xc(%ebp)
80107f5d:	ff 75 08             	push   0x8(%ebp)
80107f60:	e8 1d f7 ff ff       	call   80107682 <walkpgdir>
80107f65:	83 c4 10             	add    $0x10,%esp
80107f68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6e:	8b 00                	mov    (%eax),%eax
80107f70:	83 e0 01             	and    $0x1,%eax
80107f73:	85 c0                	test   %eax,%eax
80107f75:	75 07                	jne    80107f7e <uva2ka+0x2f>
    return 0;
80107f77:	b8 00 00 00 00       	mov    $0x0,%eax
80107f7c:	eb 22                	jmp    80107fa0 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f81:	8b 00                	mov    (%eax),%eax
80107f83:	83 e0 04             	and    $0x4,%eax
80107f86:	85 c0                	test   %eax,%eax
80107f88:	75 07                	jne    80107f91 <uva2ka+0x42>
    return 0;
80107f8a:	b8 00 00 00 00       	mov    $0x0,%eax
80107f8f:	eb 0f                	jmp    80107fa0 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f94:	8b 00                	mov    (%eax),%eax
80107f96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f9b:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107fa0:	c9                   	leave  
80107fa1:	c3                   	ret    

80107fa2 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107fa2:	55                   	push   %ebp
80107fa3:	89 e5                	mov    %esp,%ebp
80107fa5:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107fa8:	8b 45 10             	mov    0x10(%ebp),%eax
80107fab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107fae:	eb 7f                	jmp    8010802f <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fb3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107fbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fbe:	83 ec 08             	sub    $0x8,%esp
80107fc1:	50                   	push   %eax
80107fc2:	ff 75 08             	push   0x8(%ebp)
80107fc5:	e8 85 ff ff ff       	call   80107f4f <uva2ka>
80107fca:	83 c4 10             	add    $0x10,%esp
80107fcd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107fd0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107fd4:	75 07                	jne    80107fdd <copyout+0x3b>
      return -1;
80107fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fdb:	eb 61                	jmp    8010803e <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107fdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fe0:	2b 45 0c             	sub    0xc(%ebp),%eax
80107fe3:	05 00 10 00 00       	add    $0x1000,%eax
80107fe8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107feb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fee:	3b 45 14             	cmp    0x14(%ebp),%eax
80107ff1:	76 06                	jbe    80107ff9 <copyout+0x57>
      n = len;
80107ff3:	8b 45 14             	mov    0x14(%ebp),%eax
80107ff6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ffc:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107fff:	89 c2                	mov    %eax,%edx
80108001:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108004:	01 d0                	add    %edx,%eax
80108006:	83 ec 04             	sub    $0x4,%esp
80108009:	ff 75 f0             	push   -0x10(%ebp)
8010800c:	ff 75 f4             	push   -0xc(%ebp)
8010800f:	50                   	push   %eax
80108010:	e8 02 cf ff ff       	call   80104f17 <memmove>
80108015:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108018:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010801b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010801e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108021:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108024:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108027:	05 00 10 00 00       	add    $0x1000,%eax
8010802c:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010802f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108033:	0f 85 77 ff ff ff    	jne    80107fb0 <copyout+0xe>
  }
  return 0;
80108039:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010803e:	c9                   	leave  
8010803f:	c3                   	ret    

80108040 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108040:	55                   	push   %ebp
80108041:	89 e5                	mov    %esp,%ebp
80108043:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108046:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
8010804d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108050:	8b 40 08             	mov    0x8(%eax),%eax
80108053:	05 00 00 00 80       	add    $0x80000000,%eax
80108058:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010805b:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108065:	8b 40 24             	mov    0x24(%eax),%eax
80108068:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
8010806d:	c7 05 80 9d 11 80 00 	movl   $0x0,0x80119d80
80108074:	00 00 00 

  while(i<madt->len){
80108077:	90                   	nop
80108078:	e9 bd 00 00 00       	jmp    8010813a <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
8010807d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108080:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108083:	01 d0                	add    %edx,%eax
80108085:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108088:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010808b:	0f b6 00             	movzbl (%eax),%eax
8010808e:	0f b6 c0             	movzbl %al,%eax
80108091:	83 f8 05             	cmp    $0x5,%eax
80108094:	0f 87 a0 00 00 00    	ja     8010813a <mpinit_uefi+0xfa>
8010809a:	8b 04 85 d8 aa 10 80 	mov    -0x7fef5528(,%eax,4),%eax
801080a1:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801080a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801080a9:	a1 80 9d 11 80       	mov    0x80119d80,%eax
801080ae:	83 f8 03             	cmp    $0x3,%eax
801080b1:	7f 28                	jg     801080db <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801080b3:	8b 15 80 9d 11 80    	mov    0x80119d80,%edx
801080b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080bc:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801080c0:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
801080c6:	81 c2 c0 9a 11 80    	add    $0x80119ac0,%edx
801080cc:	88 02                	mov    %al,(%edx)
          ncpu++;
801080ce:	a1 80 9d 11 80       	mov    0x80119d80,%eax
801080d3:	83 c0 01             	add    $0x1,%eax
801080d6:	a3 80 9d 11 80       	mov    %eax,0x80119d80
        }
        i += lapic_entry->record_len;
801080db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080de:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801080e2:	0f b6 c0             	movzbl %al,%eax
801080e5:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801080e8:	eb 50                	jmp    8010813a <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801080ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801080f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801080f3:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801080f7:	a2 84 9d 11 80       	mov    %al,0x80119d84
        i += ioapic->record_len;
801080fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801080ff:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108103:	0f b6 c0             	movzbl %al,%eax
80108106:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108109:	eb 2f                	jmp    8010813a <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010810b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010810e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108111:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108114:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108118:	0f b6 c0             	movzbl %al,%eax
8010811b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010811e:	eb 1a                	jmp    8010813a <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108120:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108123:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108126:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108129:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010812d:	0f b6 c0             	movzbl %al,%eax
80108130:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108133:	eb 05                	jmp    8010813a <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80108135:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108139:	90                   	nop
  while(i<madt->len){
8010813a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813d:	8b 40 04             	mov    0x4(%eax),%eax
80108140:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108143:	0f 82 34 ff ff ff    	jb     8010807d <mpinit_uefi+0x3d>
    }
  }

}
80108149:	90                   	nop
8010814a:	90                   	nop
8010814b:	c9                   	leave  
8010814c:	c3                   	ret    

8010814d <inb>:
{
8010814d:	55                   	push   %ebp
8010814e:	89 e5                	mov    %esp,%ebp
80108150:	83 ec 14             	sub    $0x14,%esp
80108153:	8b 45 08             	mov    0x8(%ebp),%eax
80108156:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010815a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010815e:	89 c2                	mov    %eax,%edx
80108160:	ec                   	in     (%dx),%al
80108161:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108164:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108168:	c9                   	leave  
80108169:	c3                   	ret    

8010816a <outb>:
{
8010816a:	55                   	push   %ebp
8010816b:	89 e5                	mov    %esp,%ebp
8010816d:	83 ec 08             	sub    $0x8,%esp
80108170:	8b 45 08             	mov    0x8(%ebp),%eax
80108173:	8b 55 0c             	mov    0xc(%ebp),%edx
80108176:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010817a:	89 d0                	mov    %edx,%eax
8010817c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010817f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108183:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108187:	ee                   	out    %al,(%dx)
}
80108188:	90                   	nop
80108189:	c9                   	leave  
8010818a:	c3                   	ret    

8010818b <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010818b:	55                   	push   %ebp
8010818c:	89 e5                	mov    %esp,%ebp
8010818e:	83 ec 28             	sub    $0x28,%esp
80108191:	8b 45 08             	mov    0x8(%ebp),%eax
80108194:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108197:	6a 00                	push   $0x0
80108199:	68 fa 03 00 00       	push   $0x3fa
8010819e:	e8 c7 ff ff ff       	call   8010816a <outb>
801081a3:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801081a6:	68 80 00 00 00       	push   $0x80
801081ab:	68 fb 03 00 00       	push   $0x3fb
801081b0:	e8 b5 ff ff ff       	call   8010816a <outb>
801081b5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801081b8:	6a 0c                	push   $0xc
801081ba:	68 f8 03 00 00       	push   $0x3f8
801081bf:	e8 a6 ff ff ff       	call   8010816a <outb>
801081c4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801081c7:	6a 00                	push   $0x0
801081c9:	68 f9 03 00 00       	push   $0x3f9
801081ce:	e8 97 ff ff ff       	call   8010816a <outb>
801081d3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801081d6:	6a 03                	push   $0x3
801081d8:	68 fb 03 00 00       	push   $0x3fb
801081dd:	e8 88 ff ff ff       	call   8010816a <outb>
801081e2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801081e5:	6a 00                	push   $0x0
801081e7:	68 fc 03 00 00       	push   $0x3fc
801081ec:	e8 79 ff ff ff       	call   8010816a <outb>
801081f1:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801081f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081fb:	eb 11                	jmp    8010820e <uart_debug+0x83>
801081fd:	83 ec 0c             	sub    $0xc,%esp
80108200:	6a 0a                	push   $0xa
80108202:	e8 14 ae ff ff       	call   8010301b <microdelay>
80108207:	83 c4 10             	add    $0x10,%esp
8010820a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010820e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108212:	7f 1a                	jg     8010822e <uart_debug+0xa3>
80108214:	83 ec 0c             	sub    $0xc,%esp
80108217:	68 fd 03 00 00       	push   $0x3fd
8010821c:	e8 2c ff ff ff       	call   8010814d <inb>
80108221:	83 c4 10             	add    $0x10,%esp
80108224:	0f b6 c0             	movzbl %al,%eax
80108227:	83 e0 20             	and    $0x20,%eax
8010822a:	85 c0                	test   %eax,%eax
8010822c:	74 cf                	je     801081fd <uart_debug+0x72>
  outb(COM1+0, p);
8010822e:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108232:	0f b6 c0             	movzbl %al,%eax
80108235:	83 ec 08             	sub    $0x8,%esp
80108238:	50                   	push   %eax
80108239:	68 f8 03 00 00       	push   $0x3f8
8010823e:	e8 27 ff ff ff       	call   8010816a <outb>
80108243:	83 c4 10             	add    $0x10,%esp
}
80108246:	90                   	nop
80108247:	c9                   	leave  
80108248:	c3                   	ret    

80108249 <uart_debugs>:

void uart_debugs(char *p){
80108249:	55                   	push   %ebp
8010824a:	89 e5                	mov    %esp,%ebp
8010824c:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010824f:	eb 1b                	jmp    8010826c <uart_debugs+0x23>
    uart_debug(*p++);
80108251:	8b 45 08             	mov    0x8(%ebp),%eax
80108254:	8d 50 01             	lea    0x1(%eax),%edx
80108257:	89 55 08             	mov    %edx,0x8(%ebp)
8010825a:	0f b6 00             	movzbl (%eax),%eax
8010825d:	0f be c0             	movsbl %al,%eax
80108260:	83 ec 0c             	sub    $0xc,%esp
80108263:	50                   	push   %eax
80108264:	e8 22 ff ff ff       	call   8010818b <uart_debug>
80108269:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010826c:	8b 45 08             	mov    0x8(%ebp),%eax
8010826f:	0f b6 00             	movzbl (%eax),%eax
80108272:	84 c0                	test   %al,%al
80108274:	75 db                	jne    80108251 <uart_debugs+0x8>
  }
}
80108276:	90                   	nop
80108277:	90                   	nop
80108278:	c9                   	leave  
80108279:	c3                   	ret    

8010827a <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010827a:	55                   	push   %ebp
8010827b:	89 e5                	mov    %esp,%ebp
8010827d:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108280:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108287:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010828a:	8b 50 14             	mov    0x14(%eax),%edx
8010828d:	8b 40 10             	mov    0x10(%eax),%eax
80108290:	a3 88 9d 11 80       	mov    %eax,0x80119d88
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108295:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108298:	8b 50 1c             	mov    0x1c(%eax),%edx
8010829b:	8b 40 18             	mov    0x18(%eax),%eax
8010829e:	a3 90 9d 11 80       	mov    %eax,0x80119d90
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801082a3:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
801082a9:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801082ae:	29 d0                	sub    %edx,%eax
801082b0:	a3 8c 9d 11 80       	mov    %eax,0x80119d8c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801082b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082b8:	8b 50 24             	mov    0x24(%eax),%edx
801082bb:	8b 40 20             	mov    0x20(%eax),%eax
801082be:	a3 94 9d 11 80       	mov    %eax,0x80119d94
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801082c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082c6:	8b 50 2c             	mov    0x2c(%eax),%edx
801082c9:	8b 40 28             	mov    0x28(%eax),%eax
801082cc:	a3 98 9d 11 80       	mov    %eax,0x80119d98
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801082d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082d4:	8b 50 34             	mov    0x34(%eax),%edx
801082d7:	8b 40 30             	mov    0x30(%eax),%eax
801082da:	a3 9c 9d 11 80       	mov    %eax,0x80119d9c
}
801082df:	90                   	nop
801082e0:	c9                   	leave  
801082e1:	c3                   	ret    

801082e2 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801082e2:	55                   	push   %ebp
801082e3:	89 e5                	mov    %esp,%ebp
801082e5:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801082e8:	8b 15 9c 9d 11 80    	mov    0x80119d9c,%edx
801082ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801082f1:	0f af d0             	imul   %eax,%edx
801082f4:	8b 45 08             	mov    0x8(%ebp),%eax
801082f7:	01 d0                	add    %edx,%eax
801082f9:	c1 e0 02             	shl    $0x2,%eax
801082fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801082ff:	8b 15 8c 9d 11 80    	mov    0x80119d8c,%edx
80108305:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108308:	01 d0                	add    %edx,%eax
8010830a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
8010830d:	8b 45 10             	mov    0x10(%ebp),%eax
80108310:	0f b6 10             	movzbl (%eax),%edx
80108313:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108316:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108318:	8b 45 10             	mov    0x10(%ebp),%eax
8010831b:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010831f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108322:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108325:	8b 45 10             	mov    0x10(%ebp),%eax
80108328:	0f b6 50 02          	movzbl 0x2(%eax),%edx
8010832c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010832f:	88 50 02             	mov    %dl,0x2(%eax)
}
80108332:	90                   	nop
80108333:	c9                   	leave  
80108334:	c3                   	ret    

80108335 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108335:	55                   	push   %ebp
80108336:	89 e5                	mov    %esp,%ebp
80108338:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
8010833b:	8b 15 9c 9d 11 80    	mov    0x80119d9c,%edx
80108341:	8b 45 08             	mov    0x8(%ebp),%eax
80108344:	0f af c2             	imul   %edx,%eax
80108347:	c1 e0 02             	shl    $0x2,%eax
8010834a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
8010834d:	a1 90 9d 11 80       	mov    0x80119d90,%eax
80108352:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108355:	29 d0                	sub    %edx,%eax
80108357:	8b 0d 8c 9d 11 80    	mov    0x80119d8c,%ecx
8010835d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108360:	01 ca                	add    %ecx,%edx
80108362:	89 d1                	mov    %edx,%ecx
80108364:	8b 15 8c 9d 11 80    	mov    0x80119d8c,%edx
8010836a:	83 ec 04             	sub    $0x4,%esp
8010836d:	50                   	push   %eax
8010836e:	51                   	push   %ecx
8010836f:	52                   	push   %edx
80108370:	e8 a2 cb ff ff       	call   80104f17 <memmove>
80108375:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837b:	8b 0d 8c 9d 11 80    	mov    0x80119d8c,%ecx
80108381:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
80108387:	01 ca                	add    %ecx,%edx
80108389:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010838c:	29 ca                	sub    %ecx,%edx
8010838e:	83 ec 04             	sub    $0x4,%esp
80108391:	50                   	push   %eax
80108392:	6a 00                	push   $0x0
80108394:	52                   	push   %edx
80108395:	e8 be ca ff ff       	call   80104e58 <memset>
8010839a:	83 c4 10             	add    $0x10,%esp
}
8010839d:	90                   	nop
8010839e:	c9                   	leave  
8010839f:	c3                   	ret    

801083a0 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801083a0:	55                   	push   %ebp
801083a1:	89 e5                	mov    %esp,%ebp
801083a3:	53                   	push   %ebx
801083a4:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801083a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083ae:	e9 b1 00 00 00       	jmp    80108464 <font_render+0xc4>
    for(int j=14;j>-1;j--){
801083b3:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801083ba:	e9 97 00 00 00       	jmp    80108456 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801083bf:	8b 45 10             	mov    0x10(%ebp),%eax
801083c2:	83 e8 20             	sub    $0x20,%eax
801083c5:	6b d0 1e             	imul   $0x1e,%eax,%edx
801083c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cb:	01 d0                	add    %edx,%eax
801083cd:	0f b7 84 00 00 ab 10 	movzwl -0x7fef5500(%eax,%eax,1),%eax
801083d4:	80 
801083d5:	0f b7 d0             	movzwl %ax,%edx
801083d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083db:	bb 01 00 00 00       	mov    $0x1,%ebx
801083e0:	89 c1                	mov    %eax,%ecx
801083e2:	d3 e3                	shl    %cl,%ebx
801083e4:	89 d8                	mov    %ebx,%eax
801083e6:	21 d0                	and    %edx,%eax
801083e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801083eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ee:	ba 01 00 00 00       	mov    $0x1,%edx
801083f3:	89 c1                	mov    %eax,%ecx
801083f5:	d3 e2                	shl    %cl,%edx
801083f7:	89 d0                	mov    %edx,%eax
801083f9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801083fc:	75 2b                	jne    80108429 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801083fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80108401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108404:	01 c2                	add    %eax,%edx
80108406:	b8 0e 00 00 00       	mov    $0xe,%eax
8010840b:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010840e:	89 c1                	mov    %eax,%ecx
80108410:	8b 45 08             	mov    0x8(%ebp),%eax
80108413:	01 c8                	add    %ecx,%eax
80108415:	83 ec 04             	sub    $0x4,%esp
80108418:	68 e0 f4 10 80       	push   $0x8010f4e0
8010841d:	52                   	push   %edx
8010841e:	50                   	push   %eax
8010841f:	e8 be fe ff ff       	call   801082e2 <graphic_draw_pixel>
80108424:	83 c4 10             	add    $0x10,%esp
80108427:	eb 29                	jmp    80108452 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108429:	8b 55 0c             	mov    0xc(%ebp),%edx
8010842c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842f:	01 c2                	add    %eax,%edx
80108431:	b8 0e 00 00 00       	mov    $0xe,%eax
80108436:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108439:	89 c1                	mov    %eax,%ecx
8010843b:	8b 45 08             	mov    0x8(%ebp),%eax
8010843e:	01 c8                	add    %ecx,%eax
80108440:	83 ec 04             	sub    $0x4,%esp
80108443:	68 a0 9d 11 80       	push   $0x80119da0
80108448:	52                   	push   %edx
80108449:	50                   	push   %eax
8010844a:	e8 93 fe ff ff       	call   801082e2 <graphic_draw_pixel>
8010844f:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108452:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108456:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010845a:	0f 89 5f ff ff ff    	jns    801083bf <font_render+0x1f>
  for(int i=0;i<30;i++){
80108460:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108464:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108468:	0f 8e 45 ff ff ff    	jle    801083b3 <font_render+0x13>
      }
    }
  }
}
8010846e:	90                   	nop
8010846f:	90                   	nop
80108470:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108473:	c9                   	leave  
80108474:	c3                   	ret    

80108475 <font_render_string>:

void font_render_string(char *string,int row){
80108475:	55                   	push   %ebp
80108476:	89 e5                	mov    %esp,%ebp
80108478:	53                   	push   %ebx
80108479:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010847c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108483:	eb 33                	jmp    801084b8 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108485:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108488:	8b 45 08             	mov    0x8(%ebp),%eax
8010848b:	01 d0                	add    %edx,%eax
8010848d:	0f b6 00             	movzbl (%eax),%eax
80108490:	0f be c8             	movsbl %al,%ecx
80108493:	8b 45 0c             	mov    0xc(%ebp),%eax
80108496:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108499:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010849c:	89 d8                	mov    %ebx,%eax
8010849e:	c1 e0 04             	shl    $0x4,%eax
801084a1:	29 d8                	sub    %ebx,%eax
801084a3:	83 c0 02             	add    $0x2,%eax
801084a6:	83 ec 04             	sub    $0x4,%esp
801084a9:	51                   	push   %ecx
801084aa:	52                   	push   %edx
801084ab:	50                   	push   %eax
801084ac:	e8 ef fe ff ff       	call   801083a0 <font_render>
801084b1:	83 c4 10             	add    $0x10,%esp
    i++;
801084b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801084b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084bb:	8b 45 08             	mov    0x8(%ebp),%eax
801084be:	01 d0                	add    %edx,%eax
801084c0:	0f b6 00             	movzbl (%eax),%eax
801084c3:	84 c0                	test   %al,%al
801084c5:	74 06                	je     801084cd <font_render_string+0x58>
801084c7:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801084cb:	7e b8                	jle    80108485 <font_render_string+0x10>
  }
}
801084cd:	90                   	nop
801084ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084d1:	c9                   	leave  
801084d2:	c3                   	ret    

801084d3 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801084d3:	55                   	push   %ebp
801084d4:	89 e5                	mov    %esp,%ebp
801084d6:	53                   	push   %ebx
801084d7:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801084da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084e1:	eb 6b                	jmp    8010854e <pci_init+0x7b>
    for(int j=0;j<32;j++){
801084e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801084ea:	eb 58                	jmp    80108544 <pci_init+0x71>
      for(int k=0;k<8;k++){
801084ec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801084f3:	eb 45                	jmp    8010853a <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801084f5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801084f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801084fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fe:	83 ec 0c             	sub    $0xc,%esp
80108501:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108504:	53                   	push   %ebx
80108505:	6a 00                	push   $0x0
80108507:	51                   	push   %ecx
80108508:	52                   	push   %edx
80108509:	50                   	push   %eax
8010850a:	e8 b0 00 00 00       	call   801085bf <pci_access_config>
8010850f:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108512:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108515:	0f b7 c0             	movzwl %ax,%eax
80108518:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010851d:	74 17                	je     80108536 <pci_init+0x63>
        pci_init_device(i,j,k);
8010851f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108522:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108528:	83 ec 04             	sub    $0x4,%esp
8010852b:	51                   	push   %ecx
8010852c:	52                   	push   %edx
8010852d:	50                   	push   %eax
8010852e:	e8 37 01 00 00       	call   8010866a <pci_init_device>
80108533:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108536:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010853a:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010853e:	7e b5                	jle    801084f5 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108540:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108544:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108548:	7e a2                	jle    801084ec <pci_init+0x19>
  for(int i=0;i<256;i++){
8010854a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010854e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108555:	7e 8c                	jle    801084e3 <pci_init+0x10>
      }
      }
    }
  }
}
80108557:	90                   	nop
80108558:	90                   	nop
80108559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010855c:	c9                   	leave  
8010855d:	c3                   	ret    

8010855e <pci_write_config>:

void pci_write_config(uint config){
8010855e:	55                   	push   %ebp
8010855f:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108561:	8b 45 08             	mov    0x8(%ebp),%eax
80108564:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108569:	89 c0                	mov    %eax,%eax
8010856b:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010856c:	90                   	nop
8010856d:	5d                   	pop    %ebp
8010856e:	c3                   	ret    

8010856f <pci_write_data>:

void pci_write_data(uint config){
8010856f:	55                   	push   %ebp
80108570:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108572:	8b 45 08             	mov    0x8(%ebp),%eax
80108575:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010857a:	89 c0                	mov    %eax,%eax
8010857c:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010857d:	90                   	nop
8010857e:	5d                   	pop    %ebp
8010857f:	c3                   	ret    

80108580 <pci_read_config>:
uint pci_read_config(){
80108580:	55                   	push   %ebp
80108581:	89 e5                	mov    %esp,%ebp
80108583:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108586:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010858b:	ed                   	in     (%dx),%eax
8010858c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
8010858f:	83 ec 0c             	sub    $0xc,%esp
80108592:	68 c8 00 00 00       	push   $0xc8
80108597:	e8 7f aa ff ff       	call   8010301b <microdelay>
8010859c:	83 c4 10             	add    $0x10,%esp
  return data;
8010859f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801085a2:	c9                   	leave  
801085a3:	c3                   	ret    

801085a4 <pci_test>:


void pci_test(){
801085a4:	55                   	push   %ebp
801085a5:	89 e5                	mov    %esp,%ebp
801085a7:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801085aa:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801085b1:	ff 75 fc             	push   -0x4(%ebp)
801085b4:	e8 a5 ff ff ff       	call   8010855e <pci_write_config>
801085b9:	83 c4 04             	add    $0x4,%esp
}
801085bc:	90                   	nop
801085bd:	c9                   	leave  
801085be:	c3                   	ret    

801085bf <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801085bf:	55                   	push   %ebp
801085c0:	89 e5                	mov    %esp,%ebp
801085c2:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801085c5:	8b 45 08             	mov    0x8(%ebp),%eax
801085c8:	c1 e0 10             	shl    $0x10,%eax
801085cb:	25 00 00 ff 00       	and    $0xff0000,%eax
801085d0:	89 c2                	mov    %eax,%edx
801085d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801085d5:	c1 e0 0b             	shl    $0xb,%eax
801085d8:	0f b7 c0             	movzwl %ax,%eax
801085db:	09 c2                	or     %eax,%edx
801085dd:	8b 45 10             	mov    0x10(%ebp),%eax
801085e0:	c1 e0 08             	shl    $0x8,%eax
801085e3:	25 00 07 00 00       	and    $0x700,%eax
801085e8:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801085ea:	8b 45 14             	mov    0x14(%ebp),%eax
801085ed:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801085f2:	09 d0                	or     %edx,%eax
801085f4:	0d 00 00 00 80       	or     $0x80000000,%eax
801085f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801085fc:	ff 75 f4             	push   -0xc(%ebp)
801085ff:	e8 5a ff ff ff       	call   8010855e <pci_write_config>
80108604:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108607:	e8 74 ff ff ff       	call   80108580 <pci_read_config>
8010860c:	8b 55 18             	mov    0x18(%ebp),%edx
8010860f:	89 02                	mov    %eax,(%edx)
}
80108611:	90                   	nop
80108612:	c9                   	leave  
80108613:	c3                   	ret    

80108614 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108614:	55                   	push   %ebp
80108615:	89 e5                	mov    %esp,%ebp
80108617:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010861a:	8b 45 08             	mov    0x8(%ebp),%eax
8010861d:	c1 e0 10             	shl    $0x10,%eax
80108620:	25 00 00 ff 00       	and    $0xff0000,%eax
80108625:	89 c2                	mov    %eax,%edx
80108627:	8b 45 0c             	mov    0xc(%ebp),%eax
8010862a:	c1 e0 0b             	shl    $0xb,%eax
8010862d:	0f b7 c0             	movzwl %ax,%eax
80108630:	09 c2                	or     %eax,%edx
80108632:	8b 45 10             	mov    0x10(%ebp),%eax
80108635:	c1 e0 08             	shl    $0x8,%eax
80108638:	25 00 07 00 00       	and    $0x700,%eax
8010863d:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010863f:	8b 45 14             	mov    0x14(%ebp),%eax
80108642:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108647:	09 d0                	or     %edx,%eax
80108649:	0d 00 00 00 80       	or     $0x80000000,%eax
8010864e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108651:	ff 75 fc             	push   -0x4(%ebp)
80108654:	e8 05 ff ff ff       	call   8010855e <pci_write_config>
80108659:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010865c:	ff 75 18             	push   0x18(%ebp)
8010865f:	e8 0b ff ff ff       	call   8010856f <pci_write_data>
80108664:	83 c4 04             	add    $0x4,%esp
}
80108667:	90                   	nop
80108668:	c9                   	leave  
80108669:	c3                   	ret    

8010866a <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010866a:	55                   	push   %ebp
8010866b:	89 e5                	mov    %esp,%ebp
8010866d:	53                   	push   %ebx
8010866e:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108671:	8b 45 08             	mov    0x8(%ebp),%eax
80108674:	a2 a4 9d 11 80       	mov    %al,0x80119da4
  dev.device_num = device_num;
80108679:	8b 45 0c             	mov    0xc(%ebp),%eax
8010867c:	a2 a5 9d 11 80       	mov    %al,0x80119da5
  dev.function_num = function_num;
80108681:	8b 45 10             	mov    0x10(%ebp),%eax
80108684:	a2 a6 9d 11 80       	mov    %al,0x80119da6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108689:	ff 75 10             	push   0x10(%ebp)
8010868c:	ff 75 0c             	push   0xc(%ebp)
8010868f:	ff 75 08             	push   0x8(%ebp)
80108692:	68 44 c1 10 80       	push   $0x8010c144
80108697:	e8 58 7d ff ff       	call   801003f4 <cprintf>
8010869c:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
8010869f:	83 ec 0c             	sub    $0xc,%esp
801086a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086a5:	50                   	push   %eax
801086a6:	6a 00                	push   $0x0
801086a8:	ff 75 10             	push   0x10(%ebp)
801086ab:	ff 75 0c             	push   0xc(%ebp)
801086ae:	ff 75 08             	push   0x8(%ebp)
801086b1:	e8 09 ff ff ff       	call   801085bf <pci_access_config>
801086b6:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801086b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086bc:	c1 e8 10             	shr    $0x10,%eax
801086bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801086c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086c5:	25 ff ff 00 00       	and    $0xffff,%eax
801086ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801086cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d0:	a3 a8 9d 11 80       	mov    %eax,0x80119da8
  dev.vendor_id = vendor_id;
801086d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d8:	a3 ac 9d 11 80       	mov    %eax,0x80119dac
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801086dd:	83 ec 04             	sub    $0x4,%esp
801086e0:	ff 75 f0             	push   -0x10(%ebp)
801086e3:	ff 75 f4             	push   -0xc(%ebp)
801086e6:	68 78 c1 10 80       	push   $0x8010c178
801086eb:	e8 04 7d ff ff       	call   801003f4 <cprintf>
801086f0:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801086f3:	83 ec 0c             	sub    $0xc,%esp
801086f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086f9:	50                   	push   %eax
801086fa:	6a 08                	push   $0x8
801086fc:	ff 75 10             	push   0x10(%ebp)
801086ff:	ff 75 0c             	push   0xc(%ebp)
80108702:	ff 75 08             	push   0x8(%ebp)
80108705:	e8 b5 fe ff ff       	call   801085bf <pci_access_config>
8010870a:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010870d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108710:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108713:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108716:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108719:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010871c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010871f:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108722:	0f b6 c0             	movzbl %al,%eax
80108725:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108728:	c1 eb 18             	shr    $0x18,%ebx
8010872b:	83 ec 0c             	sub    $0xc,%esp
8010872e:	51                   	push   %ecx
8010872f:	52                   	push   %edx
80108730:	50                   	push   %eax
80108731:	53                   	push   %ebx
80108732:	68 9c c1 10 80       	push   $0x8010c19c
80108737:	e8 b8 7c ff ff       	call   801003f4 <cprintf>
8010873c:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010873f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108742:	c1 e8 18             	shr    $0x18,%eax
80108745:	a2 b0 9d 11 80       	mov    %al,0x80119db0
  dev.sub_class = (data>>16)&0xFF;
8010874a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010874d:	c1 e8 10             	shr    $0x10,%eax
80108750:	a2 b1 9d 11 80       	mov    %al,0x80119db1
  dev.interface = (data>>8)&0xFF;
80108755:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108758:	c1 e8 08             	shr    $0x8,%eax
8010875b:	a2 b2 9d 11 80       	mov    %al,0x80119db2
  dev.revision_id = data&0xFF;
80108760:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108763:	a2 b3 9d 11 80       	mov    %al,0x80119db3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108768:	83 ec 0c             	sub    $0xc,%esp
8010876b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010876e:	50                   	push   %eax
8010876f:	6a 10                	push   $0x10
80108771:	ff 75 10             	push   0x10(%ebp)
80108774:	ff 75 0c             	push   0xc(%ebp)
80108777:	ff 75 08             	push   0x8(%ebp)
8010877a:	e8 40 fe ff ff       	call   801085bf <pci_access_config>
8010877f:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108782:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108785:	a3 b4 9d 11 80       	mov    %eax,0x80119db4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010878a:	83 ec 0c             	sub    $0xc,%esp
8010878d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108790:	50                   	push   %eax
80108791:	6a 14                	push   $0x14
80108793:	ff 75 10             	push   0x10(%ebp)
80108796:	ff 75 0c             	push   0xc(%ebp)
80108799:	ff 75 08             	push   0x8(%ebp)
8010879c:	e8 1e fe ff ff       	call   801085bf <pci_access_config>
801087a1:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801087a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087a7:	a3 b8 9d 11 80       	mov    %eax,0x80119db8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801087ac:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801087b3:	75 5a                	jne    8010880f <pci_init_device+0x1a5>
801087b5:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801087bc:	75 51                	jne    8010880f <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801087be:	83 ec 0c             	sub    $0xc,%esp
801087c1:	68 e1 c1 10 80       	push   $0x8010c1e1
801087c6:	e8 29 7c ff ff       	call   801003f4 <cprintf>
801087cb:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801087ce:	83 ec 0c             	sub    $0xc,%esp
801087d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087d4:	50                   	push   %eax
801087d5:	68 f0 00 00 00       	push   $0xf0
801087da:	ff 75 10             	push   0x10(%ebp)
801087dd:	ff 75 0c             	push   0xc(%ebp)
801087e0:	ff 75 08             	push   0x8(%ebp)
801087e3:	e8 d7 fd ff ff       	call   801085bf <pci_access_config>
801087e8:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801087eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ee:	83 ec 08             	sub    $0x8,%esp
801087f1:	50                   	push   %eax
801087f2:	68 fb c1 10 80       	push   $0x8010c1fb
801087f7:	e8 f8 7b ff ff       	call   801003f4 <cprintf>
801087fc:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801087ff:	83 ec 0c             	sub    $0xc,%esp
80108802:	68 a4 9d 11 80       	push   $0x80119da4
80108807:	e8 09 00 00 00       	call   80108815 <i8254_init>
8010880c:	83 c4 10             	add    $0x10,%esp
  }
}
8010880f:	90                   	nop
80108810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108813:	c9                   	leave  
80108814:	c3                   	ret    

80108815 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108815:	55                   	push   %ebp
80108816:	89 e5                	mov    %esp,%ebp
80108818:	53                   	push   %ebx
80108819:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010881c:	8b 45 08             	mov    0x8(%ebp),%eax
8010881f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108823:	0f b6 c8             	movzbl %al,%ecx
80108826:	8b 45 08             	mov    0x8(%ebp),%eax
80108829:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010882d:	0f b6 d0             	movzbl %al,%edx
80108830:	8b 45 08             	mov    0x8(%ebp),%eax
80108833:	0f b6 00             	movzbl (%eax),%eax
80108836:	0f b6 c0             	movzbl %al,%eax
80108839:	83 ec 0c             	sub    $0xc,%esp
8010883c:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010883f:	53                   	push   %ebx
80108840:	6a 04                	push   $0x4
80108842:	51                   	push   %ecx
80108843:	52                   	push   %edx
80108844:	50                   	push   %eax
80108845:	e8 75 fd ff ff       	call   801085bf <pci_access_config>
8010884a:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010884d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108850:	83 c8 04             	or     $0x4,%eax
80108853:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108856:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108859:	8b 45 08             	mov    0x8(%ebp),%eax
8010885c:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108860:	0f b6 c8             	movzbl %al,%ecx
80108863:	8b 45 08             	mov    0x8(%ebp),%eax
80108866:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010886a:	0f b6 d0             	movzbl %al,%edx
8010886d:	8b 45 08             	mov    0x8(%ebp),%eax
80108870:	0f b6 00             	movzbl (%eax),%eax
80108873:	0f b6 c0             	movzbl %al,%eax
80108876:	83 ec 0c             	sub    $0xc,%esp
80108879:	53                   	push   %ebx
8010887a:	6a 04                	push   $0x4
8010887c:	51                   	push   %ecx
8010887d:	52                   	push   %edx
8010887e:	50                   	push   %eax
8010887f:	e8 90 fd ff ff       	call   80108614 <pci_write_config_register>
80108884:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108887:	8b 45 08             	mov    0x8(%ebp),%eax
8010888a:	8b 40 10             	mov    0x10(%eax),%eax
8010888d:	05 00 00 00 40       	add    $0x40000000,%eax
80108892:	a3 bc 9d 11 80       	mov    %eax,0x80119dbc
  uint *ctrl = (uint *)base_addr;
80108897:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
8010889c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010889f:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
801088a4:	05 d8 00 00 00       	add    $0xd8,%eax
801088a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801088ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088af:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801088b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b8:	8b 00                	mov    (%eax),%eax
801088ba:	0d 00 00 00 04       	or     $0x4000000,%eax
801088bf:	89 c2                	mov    %eax,%edx
801088c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c4:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801088c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088c9:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801088cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d2:	8b 00                	mov    (%eax),%eax
801088d4:	83 c8 40             	or     $0x40,%eax
801088d7:	89 c2                	mov    %eax,%edx
801088d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088dc:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801088de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e1:	8b 10                	mov    (%eax),%edx
801088e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e6:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801088e8:	83 ec 0c             	sub    $0xc,%esp
801088eb:	68 10 c2 10 80       	push   $0x8010c210
801088f0:	e8 ff 7a ff ff       	call   801003f4 <cprintf>
801088f5:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801088f8:	e8 87 a3 ff ff       	call   80102c84 <kalloc>
801088fd:	a3 c8 9d 11 80       	mov    %eax,0x80119dc8
  *intr_addr = 0;
80108902:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
80108907:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
8010890d:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
80108912:	83 ec 08             	sub    $0x8,%esp
80108915:	50                   	push   %eax
80108916:	68 32 c2 10 80       	push   $0x8010c232
8010891b:	e8 d4 7a ff ff       	call   801003f4 <cprintf>
80108920:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108923:	e8 50 00 00 00       	call   80108978 <i8254_init_recv>
  i8254_init_send();
80108928:	e8 69 03 00 00       	call   80108c96 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010892d:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108934:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108937:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010893e:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108941:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108948:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010894b:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108952:	0f b6 c0             	movzbl %al,%eax
80108955:	83 ec 0c             	sub    $0xc,%esp
80108958:	53                   	push   %ebx
80108959:	51                   	push   %ecx
8010895a:	52                   	push   %edx
8010895b:	50                   	push   %eax
8010895c:	68 40 c2 10 80       	push   $0x8010c240
80108961:	e8 8e 7a ff ff       	call   801003f4 <cprintf>
80108966:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010896c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108972:	90                   	nop
80108973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108976:	c9                   	leave  
80108977:	c3                   	ret    

80108978 <i8254_init_recv>:

void i8254_init_recv(){
80108978:	55                   	push   %ebp
80108979:	89 e5                	mov    %esp,%ebp
8010897b:	57                   	push   %edi
8010897c:	56                   	push   %esi
8010897d:	53                   	push   %ebx
8010897e:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108981:	83 ec 0c             	sub    $0xc,%esp
80108984:	6a 00                	push   $0x0
80108986:	e8 e8 04 00 00       	call   80108e73 <i8254_read_eeprom>
8010898b:	83 c4 10             	add    $0x10,%esp
8010898e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108991:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108994:	a2 c0 9d 11 80       	mov    %al,0x80119dc0
  mac_addr[1] = data_l>>8;
80108999:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010899c:	c1 e8 08             	shr    $0x8,%eax
8010899f:	a2 c1 9d 11 80       	mov    %al,0x80119dc1
  uint data_m = i8254_read_eeprom(0x1);
801089a4:	83 ec 0c             	sub    $0xc,%esp
801089a7:	6a 01                	push   $0x1
801089a9:	e8 c5 04 00 00       	call   80108e73 <i8254_read_eeprom>
801089ae:	83 c4 10             	add    $0x10,%esp
801089b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801089b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089b7:	a2 c2 9d 11 80       	mov    %al,0x80119dc2
  mac_addr[3] = data_m>>8;
801089bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089bf:	c1 e8 08             	shr    $0x8,%eax
801089c2:	a2 c3 9d 11 80       	mov    %al,0x80119dc3
  uint data_h = i8254_read_eeprom(0x2);
801089c7:	83 ec 0c             	sub    $0xc,%esp
801089ca:	6a 02                	push   $0x2
801089cc:	e8 a2 04 00 00       	call   80108e73 <i8254_read_eeprom>
801089d1:	83 c4 10             	add    $0x10,%esp
801089d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801089d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089da:	a2 c4 9d 11 80       	mov    %al,0x80119dc4
  mac_addr[5] = data_h>>8;
801089df:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089e2:	c1 e8 08             	shr    $0x8,%eax
801089e5:	a2 c5 9d 11 80       	mov    %al,0x80119dc5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801089ea:	0f b6 05 c5 9d 11 80 	movzbl 0x80119dc5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089f1:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801089f4:	0f b6 05 c4 9d 11 80 	movzbl 0x80119dc4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089fb:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801089fe:	0f b6 05 c3 9d 11 80 	movzbl 0x80119dc3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a05:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108a08:	0f b6 05 c2 9d 11 80 	movzbl 0x80119dc2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a0f:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108a12:	0f b6 05 c1 9d 11 80 	movzbl 0x80119dc1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a19:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108a1c:	0f b6 05 c0 9d 11 80 	movzbl 0x80119dc0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a23:	0f b6 c0             	movzbl %al,%eax
80108a26:	83 ec 04             	sub    $0x4,%esp
80108a29:	57                   	push   %edi
80108a2a:	56                   	push   %esi
80108a2b:	53                   	push   %ebx
80108a2c:	51                   	push   %ecx
80108a2d:	52                   	push   %edx
80108a2e:	50                   	push   %eax
80108a2f:	68 58 c2 10 80       	push   $0x8010c258
80108a34:	e8 bb 79 ff ff       	call   801003f4 <cprintf>
80108a39:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108a3c:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108a41:	05 00 54 00 00       	add    $0x5400,%eax
80108a46:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108a49:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108a4e:	05 04 54 00 00       	add    $0x5404,%eax
80108a53:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108a56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a59:	c1 e0 10             	shl    $0x10,%eax
80108a5c:	0b 45 d8             	or     -0x28(%ebp),%eax
80108a5f:	89 c2                	mov    %eax,%edx
80108a61:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108a64:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108a66:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a69:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a6e:	89 c2                	mov    %eax,%edx
80108a70:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a73:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108a75:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108a7a:	05 00 52 00 00       	add    $0x5200,%eax
80108a7f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108a82:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108a89:	eb 19                	jmp    80108aa4 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a95:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108a98:	01 d0                	add    %edx,%eax
80108a9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108aa0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108aa4:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108aa8:	7e e1                	jle    80108a8b <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108aaa:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108aaf:	05 d0 00 00 00       	add    $0xd0,%eax
80108ab4:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ab7:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108aba:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108ac0:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ac5:	05 c8 00 00 00       	add    $0xc8,%eax
80108aca:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108acd:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108ad0:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108ad6:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108adb:	05 28 28 00 00       	add    $0x2828,%eax
80108ae0:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108ae3:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108ae6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108aec:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108af1:	05 00 01 00 00       	add    $0x100,%eax
80108af6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108af9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108afc:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108b02:	e8 7d a1 ff ff       	call   80102c84 <kalloc>
80108b07:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b0a:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b0f:	05 00 28 00 00       	add    $0x2800,%eax
80108b14:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108b17:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b1c:	05 04 28 00 00       	add    $0x2804,%eax
80108b21:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108b24:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b29:	05 08 28 00 00       	add    $0x2808,%eax
80108b2e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b31:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b36:	05 10 28 00 00       	add    $0x2810,%eax
80108b3b:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b3e:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b43:	05 18 28 00 00       	add    $0x2818,%eax
80108b48:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108b4b:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b4e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b54:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108b57:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108b59:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108b5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108b62:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108b65:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108b6b:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108b6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108b74:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108b77:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108b7d:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b80:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108b83:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108b8a:	eb 73                	jmp    80108bff <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108b8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b8f:	c1 e0 04             	shl    $0x4,%eax
80108b92:	89 c2                	mov    %eax,%edx
80108b94:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b97:	01 d0                	add    %edx,%eax
80108b99:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108ba0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ba3:	c1 e0 04             	shl    $0x4,%eax
80108ba6:	89 c2                	mov    %eax,%edx
80108ba8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bab:	01 d0                	add    %edx,%eax
80108bad:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108bb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bb6:	c1 e0 04             	shl    $0x4,%eax
80108bb9:	89 c2                	mov    %eax,%edx
80108bbb:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bbe:	01 d0                	add    %edx,%eax
80108bc0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108bc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bc9:	c1 e0 04             	shl    $0x4,%eax
80108bcc:	89 c2                	mov    %eax,%edx
80108bce:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bd1:	01 d0                	add    %edx,%eax
80108bd3:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108bd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bda:	c1 e0 04             	shl    $0x4,%eax
80108bdd:	89 c2                	mov    %eax,%edx
80108bdf:	8b 45 98             	mov    -0x68(%ebp),%eax
80108be2:	01 d0                	add    %edx,%eax
80108be4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108be8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108beb:	c1 e0 04             	shl    $0x4,%eax
80108bee:	89 c2                	mov    %eax,%edx
80108bf0:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bf3:	01 d0                	add    %edx,%eax
80108bf5:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108bfb:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108bff:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108c06:	7e 84                	jle    80108b8c <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c08:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108c0f:	eb 57                	jmp    80108c68 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108c11:	e8 6e a0 ff ff       	call   80102c84 <kalloc>
80108c16:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108c19:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108c1d:	75 12                	jne    80108c31 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108c1f:	83 ec 0c             	sub    $0xc,%esp
80108c22:	68 78 c2 10 80       	push   $0x8010c278
80108c27:	e8 c8 77 ff ff       	call   801003f4 <cprintf>
80108c2c:	83 c4 10             	add    $0x10,%esp
      break;
80108c2f:	eb 3d                	jmp    80108c6e <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108c31:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c34:	c1 e0 04             	shl    $0x4,%eax
80108c37:	89 c2                	mov    %eax,%edx
80108c39:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c3c:	01 d0                	add    %edx,%eax
80108c3e:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c41:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c47:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108c49:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c4c:	83 c0 01             	add    $0x1,%eax
80108c4f:	c1 e0 04             	shl    $0x4,%eax
80108c52:	89 c2                	mov    %eax,%edx
80108c54:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c57:	01 d0                	add    %edx,%eax
80108c59:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c5c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108c62:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c64:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108c68:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108c6c:	7e a3                	jle    80108c11 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108c6e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c71:	8b 00                	mov    (%eax),%eax
80108c73:	83 c8 02             	or     $0x2,%eax
80108c76:	89 c2                	mov    %eax,%edx
80108c78:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c7b:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108c7d:	83 ec 0c             	sub    $0xc,%esp
80108c80:	68 98 c2 10 80       	push   $0x8010c298
80108c85:	e8 6a 77 ff ff       	call   801003f4 <cprintf>
80108c8a:	83 c4 10             	add    $0x10,%esp
}
80108c8d:	90                   	nop
80108c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108c91:	5b                   	pop    %ebx
80108c92:	5e                   	pop    %esi
80108c93:	5f                   	pop    %edi
80108c94:	5d                   	pop    %ebp
80108c95:	c3                   	ret    

80108c96 <i8254_init_send>:

void i8254_init_send(){
80108c96:	55                   	push   %ebp
80108c97:	89 e5                	mov    %esp,%ebp
80108c99:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108c9c:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ca1:	05 28 38 00 00       	add    $0x3828,%eax
80108ca6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108ca9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cac:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108cb2:	e8 cd 9f ff ff       	call   80102c84 <kalloc>
80108cb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108cba:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108cbf:	05 00 38 00 00       	add    $0x3800,%eax
80108cc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108cc7:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ccc:	05 04 38 00 00       	add    $0x3804,%eax
80108cd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108cd4:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108cd9:	05 08 38 00 00       	add    $0x3808,%eax
80108cde:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ce4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108cea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ced:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108cef:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cf2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108cf8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cfb:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d01:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d06:	05 10 38 00 00       	add    $0x3810,%eax
80108d0b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d0e:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d13:	05 18 38 00 00       	add    $0x3818,%eax
80108d18:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108d1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d1e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108d24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d27:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108d2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d30:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108d33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d3a:	e9 82 00 00 00       	jmp    80108dc1 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d42:	c1 e0 04             	shl    $0x4,%eax
80108d45:	89 c2                	mov    %eax,%edx
80108d47:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d4a:	01 d0                	add    %edx,%eax
80108d4c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d56:	c1 e0 04             	shl    $0x4,%eax
80108d59:	89 c2                	mov    %eax,%edx
80108d5b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d5e:	01 d0                	add    %edx,%eax
80108d60:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d69:	c1 e0 04             	shl    $0x4,%eax
80108d6c:	89 c2                	mov    %eax,%edx
80108d6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d71:	01 d0                	add    %edx,%eax
80108d73:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d7a:	c1 e0 04             	shl    $0x4,%eax
80108d7d:	89 c2                	mov    %eax,%edx
80108d7f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d82:	01 d0                	add    %edx,%eax
80108d84:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d8b:	c1 e0 04             	shl    $0x4,%eax
80108d8e:	89 c2                	mov    %eax,%edx
80108d90:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d93:	01 d0                	add    %edx,%eax
80108d95:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d9c:	c1 e0 04             	shl    $0x4,%eax
80108d9f:	89 c2                	mov    %eax,%edx
80108da1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108da4:	01 d0                	add    %edx,%eax
80108da6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dad:	c1 e0 04             	shl    $0x4,%eax
80108db0:	89 c2                	mov    %eax,%edx
80108db2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108db5:	01 d0                	add    %edx,%eax
80108db7:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108dbd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108dc1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108dc8:	0f 8e 71 ff ff ff    	jle    80108d3f <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108dce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108dd5:	eb 57                	jmp    80108e2e <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108dd7:	e8 a8 9e ff ff       	call   80102c84 <kalloc>
80108ddc:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108ddf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108de3:	75 12                	jne    80108df7 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108de5:	83 ec 0c             	sub    $0xc,%esp
80108de8:	68 78 c2 10 80       	push   $0x8010c278
80108ded:	e8 02 76 ff ff       	call   801003f4 <cprintf>
80108df2:	83 c4 10             	add    $0x10,%esp
      break;
80108df5:	eb 3d                	jmp    80108e34 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dfa:	c1 e0 04             	shl    $0x4,%eax
80108dfd:	89 c2                	mov    %eax,%edx
80108dff:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e02:	01 d0                	add    %edx,%eax
80108e04:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e07:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e0d:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e12:	83 c0 01             	add    $0x1,%eax
80108e15:	c1 e0 04             	shl    $0x4,%eax
80108e18:	89 c2                	mov    %eax,%edx
80108e1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e1d:	01 d0                	add    %edx,%eax
80108e1f:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e22:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e28:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e2a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e2e:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108e32:	7e a3                	jle    80108dd7 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108e34:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108e39:	05 00 04 00 00       	add    $0x400,%eax
80108e3e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108e41:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108e44:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108e4a:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108e4f:	05 10 04 00 00       	add    $0x410,%eax
80108e54:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108e57:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108e5a:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108e60:	83 ec 0c             	sub    $0xc,%esp
80108e63:	68 b8 c2 10 80       	push   $0x8010c2b8
80108e68:	e8 87 75 ff ff       	call   801003f4 <cprintf>
80108e6d:	83 c4 10             	add    $0x10,%esp

}
80108e70:	90                   	nop
80108e71:	c9                   	leave  
80108e72:	c3                   	ret    

80108e73 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108e73:	55                   	push   %ebp
80108e74:	89 e5                	mov    %esp,%ebp
80108e76:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108e79:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108e7e:	83 c0 14             	add    $0x14,%eax
80108e81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108e84:	8b 45 08             	mov    0x8(%ebp),%eax
80108e87:	c1 e0 08             	shl    $0x8,%eax
80108e8a:	0f b7 c0             	movzwl %ax,%eax
80108e8d:	83 c8 01             	or     $0x1,%eax
80108e90:	89 c2                	mov    %eax,%edx
80108e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e95:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108e97:	83 ec 0c             	sub    $0xc,%esp
80108e9a:	68 d8 c2 10 80       	push   $0x8010c2d8
80108e9f:	e8 50 75 ff ff       	call   801003f4 <cprintf>
80108ea4:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eaa:	8b 00                	mov    (%eax),%eax
80108eac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb2:	83 e0 10             	and    $0x10,%eax
80108eb5:	85 c0                	test   %eax,%eax
80108eb7:	75 02                	jne    80108ebb <i8254_read_eeprom+0x48>
  while(1){
80108eb9:	eb dc                	jmp    80108e97 <i8254_read_eeprom+0x24>
      break;
80108ebb:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ebf:	8b 00                	mov    (%eax),%eax
80108ec1:	c1 e8 10             	shr    $0x10,%eax
}
80108ec4:	c9                   	leave  
80108ec5:	c3                   	ret    

80108ec6 <i8254_recv>:
void i8254_recv(){
80108ec6:	55                   	push   %ebp
80108ec7:	89 e5                	mov    %esp,%ebp
80108ec9:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108ecc:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ed1:	05 10 28 00 00       	add    $0x2810,%eax
80108ed6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108ed9:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ede:	05 18 28 00 00       	add    $0x2818,%eax
80108ee3:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ee6:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108eeb:	05 00 28 00 00       	add    $0x2800,%eax
80108ef0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ef6:	8b 00                	mov    (%eax),%eax
80108ef8:	05 00 00 00 80       	add    $0x80000000,%eax
80108efd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f03:	8b 10                	mov    (%eax),%edx
80108f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f08:	8b 08                	mov    (%eax),%ecx
80108f0a:	89 d0                	mov    %edx,%eax
80108f0c:	29 c8                	sub    %ecx,%eax
80108f0e:	25 ff 00 00 00       	and    $0xff,%eax
80108f13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108f16:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f1a:	7e 37                	jle    80108f53 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f1f:	8b 00                	mov    (%eax),%eax
80108f21:	c1 e0 04             	shl    $0x4,%eax
80108f24:	89 c2                	mov    %eax,%edx
80108f26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f29:	01 d0                	add    %edx,%eax
80108f2b:	8b 00                	mov    (%eax),%eax
80108f2d:	05 00 00 00 80       	add    $0x80000000,%eax
80108f32:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f38:	8b 00                	mov    (%eax),%eax
80108f3a:	83 c0 01             	add    $0x1,%eax
80108f3d:	0f b6 d0             	movzbl %al,%edx
80108f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f43:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108f45:	83 ec 0c             	sub    $0xc,%esp
80108f48:	ff 75 e0             	push   -0x20(%ebp)
80108f4b:	e8 15 09 00 00       	call   80109865 <eth_proc>
80108f50:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f56:	8b 10                	mov    (%eax),%edx
80108f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f5b:	8b 00                	mov    (%eax),%eax
80108f5d:	39 c2                	cmp    %eax,%edx
80108f5f:	75 9f                	jne    80108f00 <i8254_recv+0x3a>
      (*rdt)--;
80108f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f64:	8b 00                	mov    (%eax),%eax
80108f66:	8d 50 ff             	lea    -0x1(%eax),%edx
80108f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f6c:	89 10                	mov    %edx,(%eax)
  while(1){
80108f6e:	eb 90                	jmp    80108f00 <i8254_recv+0x3a>

80108f70 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108f70:	55                   	push   %ebp
80108f71:	89 e5                	mov    %esp,%ebp
80108f73:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f76:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f7b:	05 10 38 00 00       	add    $0x3810,%eax
80108f80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f83:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f88:	05 18 38 00 00       	add    $0x3818,%eax
80108f8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108f90:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f95:	05 00 38 00 00       	add    $0x3800,%eax
80108f9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fa0:	8b 00                	mov    (%eax),%eax
80108fa2:	05 00 00 00 80       	add    $0x80000000,%eax
80108fa7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fad:	8b 10                	mov    (%eax),%edx
80108faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb2:	8b 08                	mov    (%eax),%ecx
80108fb4:	89 d0                	mov    %edx,%eax
80108fb6:	29 c8                	sub    %ecx,%eax
80108fb8:	0f b6 d0             	movzbl %al,%edx
80108fbb:	b8 00 01 00 00       	mov    $0x100,%eax
80108fc0:	29 d0                	sub    %edx,%eax
80108fc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc8:	8b 00                	mov    (%eax),%eax
80108fca:	25 ff 00 00 00       	and    $0xff,%eax
80108fcf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108fd2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108fd6:	0f 8e a8 00 00 00    	jle    80109084 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80108fdf:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108fe2:	89 d1                	mov    %edx,%ecx
80108fe4:	c1 e1 04             	shl    $0x4,%ecx
80108fe7:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108fea:	01 ca                	add    %ecx,%edx
80108fec:	8b 12                	mov    (%edx),%edx
80108fee:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108ff4:	83 ec 04             	sub    $0x4,%esp
80108ff7:	ff 75 0c             	push   0xc(%ebp)
80108ffa:	50                   	push   %eax
80108ffb:	52                   	push   %edx
80108ffc:	e8 16 bf ff ff       	call   80104f17 <memmove>
80109001:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109004:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109007:	c1 e0 04             	shl    $0x4,%eax
8010900a:	89 c2                	mov    %eax,%edx
8010900c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010900f:	01 d0                	add    %edx,%eax
80109011:	8b 55 0c             	mov    0xc(%ebp),%edx
80109014:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109018:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010901b:	c1 e0 04             	shl    $0x4,%eax
8010901e:	89 c2                	mov    %eax,%edx
80109020:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109023:	01 d0                	add    %edx,%eax
80109025:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109029:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010902c:	c1 e0 04             	shl    $0x4,%eax
8010902f:	89 c2                	mov    %eax,%edx
80109031:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109034:	01 d0                	add    %edx,%eax
80109036:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010903a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010903d:	c1 e0 04             	shl    $0x4,%eax
80109040:	89 c2                	mov    %eax,%edx
80109042:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109045:	01 d0                	add    %edx,%eax
80109047:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010904b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010904e:	c1 e0 04             	shl    $0x4,%eax
80109051:	89 c2                	mov    %eax,%edx
80109053:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109056:	01 d0                	add    %edx,%eax
80109058:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
8010905e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109061:	c1 e0 04             	shl    $0x4,%eax
80109064:	89 c2                	mov    %eax,%edx
80109066:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109069:	01 d0                	add    %edx,%eax
8010906b:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
8010906f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109072:	8b 00                	mov    (%eax),%eax
80109074:	83 c0 01             	add    $0x1,%eax
80109077:	0f b6 d0             	movzbl %al,%edx
8010907a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010907d:	89 10                	mov    %edx,(%eax)
    return len;
8010907f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109082:	eb 05                	jmp    80109089 <i8254_send+0x119>
  }else{
    return -1;
80109084:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109089:	c9                   	leave  
8010908a:	c3                   	ret    

8010908b <i8254_intr>:

void i8254_intr(){
8010908b:	55                   	push   %ebp
8010908c:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
8010908e:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
80109093:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109099:	90                   	nop
8010909a:	5d                   	pop    %ebp
8010909b:	c3                   	ret    

8010909c <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
8010909c:	55                   	push   %ebp
8010909d:	89 e5                	mov    %esp,%ebp
8010909f:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801090a2:	8b 45 08             	mov    0x8(%ebp),%eax
801090a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801090a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ab:	0f b7 00             	movzwl (%eax),%eax
801090ae:	66 3d 00 01          	cmp    $0x100,%ax
801090b2:	74 0a                	je     801090be <arp_proc+0x22>
801090b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090b9:	e9 4f 01 00 00       	jmp    8010920d <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801090be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c1:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801090c5:	66 83 f8 08          	cmp    $0x8,%ax
801090c9:	74 0a                	je     801090d5 <arp_proc+0x39>
801090cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090d0:	e9 38 01 00 00       	jmp    8010920d <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
801090d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801090dc:	3c 06                	cmp    $0x6,%al
801090de:	74 0a                	je     801090ea <arp_proc+0x4e>
801090e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090e5:	e9 23 01 00 00       	jmp    8010920d <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801090ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ed:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801090f1:	3c 04                	cmp    $0x4,%al
801090f3:	74 0a                	je     801090ff <arp_proc+0x63>
801090f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090fa:	e9 0e 01 00 00       	jmp    8010920d <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801090ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109102:	83 c0 18             	add    $0x18,%eax
80109105:	83 ec 04             	sub    $0x4,%esp
80109108:	6a 04                	push   $0x4
8010910a:	50                   	push   %eax
8010910b:	68 e4 f4 10 80       	push   $0x8010f4e4
80109110:	e8 aa bd ff ff       	call   80104ebf <memcmp>
80109115:	83 c4 10             	add    $0x10,%esp
80109118:	85 c0                	test   %eax,%eax
8010911a:	74 27                	je     80109143 <arp_proc+0xa7>
8010911c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010911f:	83 c0 0e             	add    $0xe,%eax
80109122:	83 ec 04             	sub    $0x4,%esp
80109125:	6a 04                	push   $0x4
80109127:	50                   	push   %eax
80109128:	68 e4 f4 10 80       	push   $0x8010f4e4
8010912d:	e8 8d bd ff ff       	call   80104ebf <memcmp>
80109132:	83 c4 10             	add    $0x10,%esp
80109135:	85 c0                	test   %eax,%eax
80109137:	74 0a                	je     80109143 <arp_proc+0xa7>
80109139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010913e:	e9 ca 00 00 00       	jmp    8010920d <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109146:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010914a:	66 3d 00 01          	cmp    $0x100,%ax
8010914e:	75 69                	jne    801091b9 <arp_proc+0x11d>
80109150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109153:	83 c0 18             	add    $0x18,%eax
80109156:	83 ec 04             	sub    $0x4,%esp
80109159:	6a 04                	push   $0x4
8010915b:	50                   	push   %eax
8010915c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109161:	e8 59 bd ff ff       	call   80104ebf <memcmp>
80109166:	83 c4 10             	add    $0x10,%esp
80109169:	85 c0                	test   %eax,%eax
8010916b:	75 4c                	jne    801091b9 <arp_proc+0x11d>
    uint send = (uint)kalloc();
8010916d:	e8 12 9b ff ff       	call   80102c84 <kalloc>
80109172:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109175:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
8010917c:	83 ec 04             	sub    $0x4,%esp
8010917f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109182:	50                   	push   %eax
80109183:	ff 75 f0             	push   -0x10(%ebp)
80109186:	ff 75 f4             	push   -0xc(%ebp)
80109189:	e8 1f 04 00 00       	call   801095ad <arp_reply_pkt_create>
8010918e:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109191:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109194:	83 ec 08             	sub    $0x8,%esp
80109197:	50                   	push   %eax
80109198:	ff 75 f0             	push   -0x10(%ebp)
8010919b:	e8 d0 fd ff ff       	call   80108f70 <i8254_send>
801091a0:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801091a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a6:	83 ec 0c             	sub    $0xc,%esp
801091a9:	50                   	push   %eax
801091aa:	e8 3b 9a ff ff       	call   80102bea <kfree>
801091af:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801091b2:	b8 02 00 00 00       	mov    $0x2,%eax
801091b7:	eb 54                	jmp    8010920d <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801091b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091bc:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801091c0:	66 3d 00 02          	cmp    $0x200,%ax
801091c4:	75 42                	jne    80109208 <arp_proc+0x16c>
801091c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c9:	83 c0 18             	add    $0x18,%eax
801091cc:	83 ec 04             	sub    $0x4,%esp
801091cf:	6a 04                	push   $0x4
801091d1:	50                   	push   %eax
801091d2:	68 e4 f4 10 80       	push   $0x8010f4e4
801091d7:	e8 e3 bc ff ff       	call   80104ebf <memcmp>
801091dc:	83 c4 10             	add    $0x10,%esp
801091df:	85 c0                	test   %eax,%eax
801091e1:	75 25                	jne    80109208 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801091e3:	83 ec 0c             	sub    $0xc,%esp
801091e6:	68 dc c2 10 80       	push   $0x8010c2dc
801091eb:	e8 04 72 ff ff       	call   801003f4 <cprintf>
801091f0:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801091f3:	83 ec 0c             	sub    $0xc,%esp
801091f6:	ff 75 f4             	push   -0xc(%ebp)
801091f9:	e8 af 01 00 00       	call   801093ad <arp_table_update>
801091fe:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109201:	b8 01 00 00 00       	mov    $0x1,%eax
80109206:	eb 05                	jmp    8010920d <arp_proc+0x171>
  }else{
    return -1;
80109208:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
8010920d:	c9                   	leave  
8010920e:	c3                   	ret    

8010920f <arp_scan>:

void arp_scan(){
8010920f:	55                   	push   %ebp
80109210:	89 e5                	mov    %esp,%ebp
80109212:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109215:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010921c:	eb 6f                	jmp    8010928d <arp_scan+0x7e>
    uint send = (uint)kalloc();
8010921e:	e8 61 9a ff ff       	call   80102c84 <kalloc>
80109223:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109226:	83 ec 04             	sub    $0x4,%esp
80109229:	ff 75 f4             	push   -0xc(%ebp)
8010922c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010922f:	50                   	push   %eax
80109230:	ff 75 ec             	push   -0x14(%ebp)
80109233:	e8 62 00 00 00       	call   8010929a <arp_broadcast>
80109238:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010923b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010923e:	83 ec 08             	sub    $0x8,%esp
80109241:	50                   	push   %eax
80109242:	ff 75 ec             	push   -0x14(%ebp)
80109245:	e8 26 fd ff ff       	call   80108f70 <i8254_send>
8010924a:	83 c4 10             	add    $0x10,%esp
8010924d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109250:	eb 22                	jmp    80109274 <arp_scan+0x65>
      microdelay(1);
80109252:	83 ec 0c             	sub    $0xc,%esp
80109255:	6a 01                	push   $0x1
80109257:	e8 bf 9d ff ff       	call   8010301b <microdelay>
8010925c:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010925f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109262:	83 ec 08             	sub    $0x8,%esp
80109265:	50                   	push   %eax
80109266:	ff 75 ec             	push   -0x14(%ebp)
80109269:	e8 02 fd ff ff       	call   80108f70 <i8254_send>
8010926e:	83 c4 10             	add    $0x10,%esp
80109271:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109274:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109278:	74 d8                	je     80109252 <arp_scan+0x43>
    }
    kfree((char *)send);
8010927a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010927d:	83 ec 0c             	sub    $0xc,%esp
80109280:	50                   	push   %eax
80109281:	e8 64 99 ff ff       	call   80102bea <kfree>
80109286:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109289:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010928d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109294:	7e 88                	jle    8010921e <arp_scan+0xf>
  }
}
80109296:	90                   	nop
80109297:	90                   	nop
80109298:	c9                   	leave  
80109299:	c3                   	ret    

8010929a <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010929a:	55                   	push   %ebp
8010929b:	89 e5                	mov    %esp,%ebp
8010929d:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801092a0:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801092a4:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801092a8:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801092ac:	8b 45 10             	mov    0x10(%ebp),%eax
801092af:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801092b2:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801092b9:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801092bf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801092c6:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801092cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801092cf:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801092d5:	8b 45 08             	mov    0x8(%ebp),%eax
801092d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801092db:	8b 45 08             	mov    0x8(%ebp),%eax
801092de:	83 c0 0e             	add    $0xe,%eax
801092e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801092e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801092eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ee:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801092f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f5:	83 ec 04             	sub    $0x4,%esp
801092f8:	6a 06                	push   $0x6
801092fa:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801092fd:	52                   	push   %edx
801092fe:	50                   	push   %eax
801092ff:	e8 13 bc ff ff       	call   80104f17 <memmove>
80109304:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930a:	83 c0 06             	add    $0x6,%eax
8010930d:	83 ec 04             	sub    $0x4,%esp
80109310:	6a 06                	push   $0x6
80109312:	68 c0 9d 11 80       	push   $0x80119dc0
80109317:	50                   	push   %eax
80109318:	e8 fa bb ff ff       	call   80104f17 <memmove>
8010931d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109320:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109323:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109328:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010932b:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109331:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109334:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109338:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010933b:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010933f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109342:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010934b:	8d 50 12             	lea    0x12(%eax),%edx
8010934e:	83 ec 04             	sub    $0x4,%esp
80109351:	6a 06                	push   $0x6
80109353:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109356:	50                   	push   %eax
80109357:	52                   	push   %edx
80109358:	e8 ba bb ff ff       	call   80104f17 <memmove>
8010935d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109360:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109363:	8d 50 18             	lea    0x18(%eax),%edx
80109366:	83 ec 04             	sub    $0x4,%esp
80109369:	6a 04                	push   $0x4
8010936b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010936e:	50                   	push   %eax
8010936f:	52                   	push   %edx
80109370:	e8 a2 bb ff ff       	call   80104f17 <memmove>
80109375:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010937b:	83 c0 08             	add    $0x8,%eax
8010937e:	83 ec 04             	sub    $0x4,%esp
80109381:	6a 06                	push   $0x6
80109383:	68 c0 9d 11 80       	push   $0x80119dc0
80109388:	50                   	push   %eax
80109389:	e8 89 bb ff ff       	call   80104f17 <memmove>
8010938e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109391:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109394:	83 c0 0e             	add    $0xe,%eax
80109397:	83 ec 04             	sub    $0x4,%esp
8010939a:	6a 04                	push   $0x4
8010939c:	68 e4 f4 10 80       	push   $0x8010f4e4
801093a1:	50                   	push   %eax
801093a2:	e8 70 bb ff ff       	call   80104f17 <memmove>
801093a7:	83 c4 10             	add    $0x10,%esp
}
801093aa:	90                   	nop
801093ab:	c9                   	leave  
801093ac:	c3                   	ret    

801093ad <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801093ad:	55                   	push   %ebp
801093ae:	89 e5                	mov    %esp,%ebp
801093b0:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801093b3:	8b 45 08             	mov    0x8(%ebp),%eax
801093b6:	83 c0 0e             	add    $0xe,%eax
801093b9:	83 ec 0c             	sub    $0xc,%esp
801093bc:	50                   	push   %eax
801093bd:	e8 bc 00 00 00       	call   8010947e <arp_table_search>
801093c2:	83 c4 10             	add    $0x10,%esp
801093c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801093c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801093cc:	78 2d                	js     801093fb <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801093ce:	8b 45 08             	mov    0x8(%ebp),%eax
801093d1:	8d 48 08             	lea    0x8(%eax),%ecx
801093d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093d7:	89 d0                	mov    %edx,%eax
801093d9:	c1 e0 02             	shl    $0x2,%eax
801093dc:	01 d0                	add    %edx,%eax
801093de:	01 c0                	add    %eax,%eax
801093e0:	01 d0                	add    %edx,%eax
801093e2:	05 e0 9d 11 80       	add    $0x80119de0,%eax
801093e7:	83 c0 04             	add    $0x4,%eax
801093ea:	83 ec 04             	sub    $0x4,%esp
801093ed:	6a 06                	push   $0x6
801093ef:	51                   	push   %ecx
801093f0:	50                   	push   %eax
801093f1:	e8 21 bb ff ff       	call   80104f17 <memmove>
801093f6:	83 c4 10             	add    $0x10,%esp
801093f9:	eb 70                	jmp    8010946b <arp_table_update+0xbe>
  }else{
    index += 1;
801093fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801093ff:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109402:	8b 45 08             	mov    0x8(%ebp),%eax
80109405:	8d 48 08             	lea    0x8(%eax),%ecx
80109408:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010940b:	89 d0                	mov    %edx,%eax
8010940d:	c1 e0 02             	shl    $0x2,%eax
80109410:	01 d0                	add    %edx,%eax
80109412:	01 c0                	add    %eax,%eax
80109414:	01 d0                	add    %edx,%eax
80109416:	05 e0 9d 11 80       	add    $0x80119de0,%eax
8010941b:	83 c0 04             	add    $0x4,%eax
8010941e:	83 ec 04             	sub    $0x4,%esp
80109421:	6a 06                	push   $0x6
80109423:	51                   	push   %ecx
80109424:	50                   	push   %eax
80109425:	e8 ed ba ff ff       	call   80104f17 <memmove>
8010942a:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
8010942d:	8b 45 08             	mov    0x8(%ebp),%eax
80109430:	8d 48 0e             	lea    0xe(%eax),%ecx
80109433:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109436:	89 d0                	mov    %edx,%eax
80109438:	c1 e0 02             	shl    $0x2,%eax
8010943b:	01 d0                	add    %edx,%eax
8010943d:	01 c0                	add    %eax,%eax
8010943f:	01 d0                	add    %edx,%eax
80109441:	05 e0 9d 11 80       	add    $0x80119de0,%eax
80109446:	83 ec 04             	sub    $0x4,%esp
80109449:	6a 04                	push   $0x4
8010944b:	51                   	push   %ecx
8010944c:	50                   	push   %eax
8010944d:	e8 c5 ba ff ff       	call   80104f17 <memmove>
80109452:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109455:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109458:	89 d0                	mov    %edx,%eax
8010945a:	c1 e0 02             	shl    $0x2,%eax
8010945d:	01 d0                	add    %edx,%eax
8010945f:	01 c0                	add    %eax,%eax
80109461:	01 d0                	add    %edx,%eax
80109463:	05 ea 9d 11 80       	add    $0x80119dea,%eax
80109468:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010946b:	83 ec 0c             	sub    $0xc,%esp
8010946e:	68 e0 9d 11 80       	push   $0x80119de0
80109473:	e8 83 00 00 00       	call   801094fb <print_arp_table>
80109478:	83 c4 10             	add    $0x10,%esp
}
8010947b:	90                   	nop
8010947c:	c9                   	leave  
8010947d:	c3                   	ret    

8010947e <arp_table_search>:

int arp_table_search(uchar *ip){
8010947e:	55                   	push   %ebp
8010947f:	89 e5                	mov    %esp,%ebp
80109481:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109484:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010948b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109492:	eb 59                	jmp    801094ed <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109494:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109497:	89 d0                	mov    %edx,%eax
80109499:	c1 e0 02             	shl    $0x2,%eax
8010949c:	01 d0                	add    %edx,%eax
8010949e:	01 c0                	add    %eax,%eax
801094a0:	01 d0                	add    %edx,%eax
801094a2:	05 e0 9d 11 80       	add    $0x80119de0,%eax
801094a7:	83 ec 04             	sub    $0x4,%esp
801094aa:	6a 04                	push   $0x4
801094ac:	ff 75 08             	push   0x8(%ebp)
801094af:	50                   	push   %eax
801094b0:	e8 0a ba ff ff       	call   80104ebf <memcmp>
801094b5:	83 c4 10             	add    $0x10,%esp
801094b8:	85 c0                	test   %eax,%eax
801094ba:	75 05                	jne    801094c1 <arp_table_search+0x43>
      return i;
801094bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094bf:	eb 38                	jmp    801094f9 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801094c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801094c4:	89 d0                	mov    %edx,%eax
801094c6:	c1 e0 02             	shl    $0x2,%eax
801094c9:	01 d0                	add    %edx,%eax
801094cb:	01 c0                	add    %eax,%eax
801094cd:	01 d0                	add    %edx,%eax
801094cf:	05 ea 9d 11 80       	add    $0x80119dea,%eax
801094d4:	0f b6 00             	movzbl (%eax),%eax
801094d7:	84 c0                	test   %al,%al
801094d9:	75 0e                	jne    801094e9 <arp_table_search+0x6b>
801094db:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801094df:	75 08                	jne    801094e9 <arp_table_search+0x6b>
      empty = -i;
801094e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094e4:	f7 d8                	neg    %eax
801094e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801094e9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801094ed:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801094f1:	7e a1                	jle    80109494 <arp_table_search+0x16>
    }
  }
  return empty-1;
801094f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f6:	83 e8 01             	sub    $0x1,%eax
}
801094f9:	c9                   	leave  
801094fa:	c3                   	ret    

801094fb <print_arp_table>:

void print_arp_table(){
801094fb:	55                   	push   %ebp
801094fc:	89 e5                	mov    %esp,%ebp
801094fe:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109501:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109508:	e9 92 00 00 00       	jmp    8010959f <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
8010950d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109510:	89 d0                	mov    %edx,%eax
80109512:	c1 e0 02             	shl    $0x2,%eax
80109515:	01 d0                	add    %edx,%eax
80109517:	01 c0                	add    %eax,%eax
80109519:	01 d0                	add    %edx,%eax
8010951b:	05 ea 9d 11 80       	add    $0x80119dea,%eax
80109520:	0f b6 00             	movzbl (%eax),%eax
80109523:	84 c0                	test   %al,%al
80109525:	74 74                	je     8010959b <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109527:	83 ec 08             	sub    $0x8,%esp
8010952a:	ff 75 f4             	push   -0xc(%ebp)
8010952d:	68 ef c2 10 80       	push   $0x8010c2ef
80109532:	e8 bd 6e ff ff       	call   801003f4 <cprintf>
80109537:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010953a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010953d:	89 d0                	mov    %edx,%eax
8010953f:	c1 e0 02             	shl    $0x2,%eax
80109542:	01 d0                	add    %edx,%eax
80109544:	01 c0                	add    %eax,%eax
80109546:	01 d0                	add    %edx,%eax
80109548:	05 e0 9d 11 80       	add    $0x80119de0,%eax
8010954d:	83 ec 0c             	sub    $0xc,%esp
80109550:	50                   	push   %eax
80109551:	e8 54 02 00 00       	call   801097aa <print_ipv4>
80109556:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109559:	83 ec 0c             	sub    $0xc,%esp
8010955c:	68 fe c2 10 80       	push   $0x8010c2fe
80109561:	e8 8e 6e ff ff       	call   801003f4 <cprintf>
80109566:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109569:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010956c:	89 d0                	mov    %edx,%eax
8010956e:	c1 e0 02             	shl    $0x2,%eax
80109571:	01 d0                	add    %edx,%eax
80109573:	01 c0                	add    %eax,%eax
80109575:	01 d0                	add    %edx,%eax
80109577:	05 e0 9d 11 80       	add    $0x80119de0,%eax
8010957c:	83 c0 04             	add    $0x4,%eax
8010957f:	83 ec 0c             	sub    $0xc,%esp
80109582:	50                   	push   %eax
80109583:	e8 70 02 00 00       	call   801097f8 <print_mac>
80109588:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010958b:	83 ec 0c             	sub    $0xc,%esp
8010958e:	68 00 c3 10 80       	push   $0x8010c300
80109593:	e8 5c 6e ff ff       	call   801003f4 <cprintf>
80109598:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010959b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010959f:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801095a3:	0f 8e 64 ff ff ff    	jle    8010950d <print_arp_table+0x12>
    }
  }
}
801095a9:	90                   	nop
801095aa:	90                   	nop
801095ab:	c9                   	leave  
801095ac:	c3                   	ret    

801095ad <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801095ad:	55                   	push   %ebp
801095ae:	89 e5                	mov    %esp,%ebp
801095b0:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801095b3:	8b 45 10             	mov    0x10(%ebp),%eax
801095b6:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801095bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801095bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801095c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801095c5:	83 c0 0e             	add    $0xe,%eax
801095c8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801095cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ce:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801095d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d5:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801095d9:	8b 45 08             	mov    0x8(%ebp),%eax
801095dc:	8d 50 08             	lea    0x8(%eax),%edx
801095df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e2:	83 ec 04             	sub    $0x4,%esp
801095e5:	6a 06                	push   $0x6
801095e7:	52                   	push   %edx
801095e8:	50                   	push   %eax
801095e9:	e8 29 b9 ff ff       	call   80104f17 <memmove>
801095ee:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801095f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f4:	83 c0 06             	add    $0x6,%eax
801095f7:	83 ec 04             	sub    $0x4,%esp
801095fa:	6a 06                	push   $0x6
801095fc:	68 c0 9d 11 80       	push   $0x80119dc0
80109601:	50                   	push   %eax
80109602:	e8 10 b9 ff ff       	call   80104f17 <memmove>
80109607:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010960a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109612:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109615:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010961b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010961e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109625:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010962c:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109632:	8b 45 08             	mov    0x8(%ebp),%eax
80109635:	8d 50 08             	lea    0x8(%eax),%edx
80109638:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010963b:	83 c0 12             	add    $0x12,%eax
8010963e:	83 ec 04             	sub    $0x4,%esp
80109641:	6a 06                	push   $0x6
80109643:	52                   	push   %edx
80109644:	50                   	push   %eax
80109645:	e8 cd b8 ff ff       	call   80104f17 <memmove>
8010964a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010964d:	8b 45 08             	mov    0x8(%ebp),%eax
80109650:	8d 50 0e             	lea    0xe(%eax),%edx
80109653:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109656:	83 c0 18             	add    $0x18,%eax
80109659:	83 ec 04             	sub    $0x4,%esp
8010965c:	6a 04                	push   $0x4
8010965e:	52                   	push   %edx
8010965f:	50                   	push   %eax
80109660:	e8 b2 b8 ff ff       	call   80104f17 <memmove>
80109665:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109668:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010966b:	83 c0 08             	add    $0x8,%eax
8010966e:	83 ec 04             	sub    $0x4,%esp
80109671:	6a 06                	push   $0x6
80109673:	68 c0 9d 11 80       	push   $0x80119dc0
80109678:	50                   	push   %eax
80109679:	e8 99 b8 ff ff       	call   80104f17 <memmove>
8010967e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109681:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109684:	83 c0 0e             	add    $0xe,%eax
80109687:	83 ec 04             	sub    $0x4,%esp
8010968a:	6a 04                	push   $0x4
8010968c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109691:	50                   	push   %eax
80109692:	e8 80 b8 ff ff       	call   80104f17 <memmove>
80109697:	83 c4 10             	add    $0x10,%esp
}
8010969a:	90                   	nop
8010969b:	c9                   	leave  
8010969c:	c3                   	ret    

8010969d <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010969d:	55                   	push   %ebp
8010969e:	89 e5                	mov    %esp,%ebp
801096a0:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801096a3:	83 ec 0c             	sub    $0xc,%esp
801096a6:	68 02 c3 10 80       	push   $0x8010c302
801096ab:	e8 44 6d ff ff       	call   801003f4 <cprintf>
801096b0:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801096b3:	8b 45 08             	mov    0x8(%ebp),%eax
801096b6:	83 c0 0e             	add    $0xe,%eax
801096b9:	83 ec 0c             	sub    $0xc,%esp
801096bc:	50                   	push   %eax
801096bd:	e8 e8 00 00 00       	call   801097aa <print_ipv4>
801096c2:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096c5:	83 ec 0c             	sub    $0xc,%esp
801096c8:	68 00 c3 10 80       	push   $0x8010c300
801096cd:	e8 22 6d ff ff       	call   801003f4 <cprintf>
801096d2:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801096d5:	8b 45 08             	mov    0x8(%ebp),%eax
801096d8:	83 c0 08             	add    $0x8,%eax
801096db:	83 ec 0c             	sub    $0xc,%esp
801096de:	50                   	push   %eax
801096df:	e8 14 01 00 00       	call   801097f8 <print_mac>
801096e4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096e7:	83 ec 0c             	sub    $0xc,%esp
801096ea:	68 00 c3 10 80       	push   $0x8010c300
801096ef:	e8 00 6d ff ff       	call   801003f4 <cprintf>
801096f4:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801096f7:	83 ec 0c             	sub    $0xc,%esp
801096fa:	68 19 c3 10 80       	push   $0x8010c319
801096ff:	e8 f0 6c ff ff       	call   801003f4 <cprintf>
80109704:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109707:	8b 45 08             	mov    0x8(%ebp),%eax
8010970a:	83 c0 18             	add    $0x18,%eax
8010970d:	83 ec 0c             	sub    $0xc,%esp
80109710:	50                   	push   %eax
80109711:	e8 94 00 00 00       	call   801097aa <print_ipv4>
80109716:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109719:	83 ec 0c             	sub    $0xc,%esp
8010971c:	68 00 c3 10 80       	push   $0x8010c300
80109721:	e8 ce 6c ff ff       	call   801003f4 <cprintf>
80109726:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109729:	8b 45 08             	mov    0x8(%ebp),%eax
8010972c:	83 c0 12             	add    $0x12,%eax
8010972f:	83 ec 0c             	sub    $0xc,%esp
80109732:	50                   	push   %eax
80109733:	e8 c0 00 00 00       	call   801097f8 <print_mac>
80109738:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010973b:	83 ec 0c             	sub    $0xc,%esp
8010973e:	68 00 c3 10 80       	push   $0x8010c300
80109743:	e8 ac 6c ff ff       	call   801003f4 <cprintf>
80109748:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010974b:	83 ec 0c             	sub    $0xc,%esp
8010974e:	68 30 c3 10 80       	push   $0x8010c330
80109753:	e8 9c 6c ff ff       	call   801003f4 <cprintf>
80109758:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010975b:	8b 45 08             	mov    0x8(%ebp),%eax
8010975e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109762:	66 3d 00 01          	cmp    $0x100,%ax
80109766:	75 12                	jne    8010977a <print_arp_info+0xdd>
80109768:	83 ec 0c             	sub    $0xc,%esp
8010976b:	68 3c c3 10 80       	push   $0x8010c33c
80109770:	e8 7f 6c ff ff       	call   801003f4 <cprintf>
80109775:	83 c4 10             	add    $0x10,%esp
80109778:	eb 1d                	jmp    80109797 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010977a:	8b 45 08             	mov    0x8(%ebp),%eax
8010977d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109781:	66 3d 00 02          	cmp    $0x200,%ax
80109785:	75 10                	jne    80109797 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109787:	83 ec 0c             	sub    $0xc,%esp
8010978a:	68 45 c3 10 80       	push   $0x8010c345
8010978f:	e8 60 6c ff ff       	call   801003f4 <cprintf>
80109794:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109797:	83 ec 0c             	sub    $0xc,%esp
8010979a:	68 00 c3 10 80       	push   $0x8010c300
8010979f:	e8 50 6c ff ff       	call   801003f4 <cprintf>
801097a4:	83 c4 10             	add    $0x10,%esp
}
801097a7:	90                   	nop
801097a8:	c9                   	leave  
801097a9:	c3                   	ret    

801097aa <print_ipv4>:

void print_ipv4(uchar *ip){
801097aa:	55                   	push   %ebp
801097ab:	89 e5                	mov    %esp,%ebp
801097ad:	53                   	push   %ebx
801097ae:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801097b1:	8b 45 08             	mov    0x8(%ebp),%eax
801097b4:	83 c0 03             	add    $0x3,%eax
801097b7:	0f b6 00             	movzbl (%eax),%eax
801097ba:	0f b6 d8             	movzbl %al,%ebx
801097bd:	8b 45 08             	mov    0x8(%ebp),%eax
801097c0:	83 c0 02             	add    $0x2,%eax
801097c3:	0f b6 00             	movzbl (%eax),%eax
801097c6:	0f b6 c8             	movzbl %al,%ecx
801097c9:	8b 45 08             	mov    0x8(%ebp),%eax
801097cc:	83 c0 01             	add    $0x1,%eax
801097cf:	0f b6 00             	movzbl (%eax),%eax
801097d2:	0f b6 d0             	movzbl %al,%edx
801097d5:	8b 45 08             	mov    0x8(%ebp),%eax
801097d8:	0f b6 00             	movzbl (%eax),%eax
801097db:	0f b6 c0             	movzbl %al,%eax
801097de:	83 ec 0c             	sub    $0xc,%esp
801097e1:	53                   	push   %ebx
801097e2:	51                   	push   %ecx
801097e3:	52                   	push   %edx
801097e4:	50                   	push   %eax
801097e5:	68 4c c3 10 80       	push   $0x8010c34c
801097ea:	e8 05 6c ff ff       	call   801003f4 <cprintf>
801097ef:	83 c4 20             	add    $0x20,%esp
}
801097f2:	90                   	nop
801097f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801097f6:	c9                   	leave  
801097f7:	c3                   	ret    

801097f8 <print_mac>:

void print_mac(uchar *mac){
801097f8:	55                   	push   %ebp
801097f9:	89 e5                	mov    %esp,%ebp
801097fb:	57                   	push   %edi
801097fc:	56                   	push   %esi
801097fd:	53                   	push   %ebx
801097fe:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109801:	8b 45 08             	mov    0x8(%ebp),%eax
80109804:	83 c0 05             	add    $0x5,%eax
80109807:	0f b6 00             	movzbl (%eax),%eax
8010980a:	0f b6 f8             	movzbl %al,%edi
8010980d:	8b 45 08             	mov    0x8(%ebp),%eax
80109810:	83 c0 04             	add    $0x4,%eax
80109813:	0f b6 00             	movzbl (%eax),%eax
80109816:	0f b6 f0             	movzbl %al,%esi
80109819:	8b 45 08             	mov    0x8(%ebp),%eax
8010981c:	83 c0 03             	add    $0x3,%eax
8010981f:	0f b6 00             	movzbl (%eax),%eax
80109822:	0f b6 d8             	movzbl %al,%ebx
80109825:	8b 45 08             	mov    0x8(%ebp),%eax
80109828:	83 c0 02             	add    $0x2,%eax
8010982b:	0f b6 00             	movzbl (%eax),%eax
8010982e:	0f b6 c8             	movzbl %al,%ecx
80109831:	8b 45 08             	mov    0x8(%ebp),%eax
80109834:	83 c0 01             	add    $0x1,%eax
80109837:	0f b6 00             	movzbl (%eax),%eax
8010983a:	0f b6 d0             	movzbl %al,%edx
8010983d:	8b 45 08             	mov    0x8(%ebp),%eax
80109840:	0f b6 00             	movzbl (%eax),%eax
80109843:	0f b6 c0             	movzbl %al,%eax
80109846:	83 ec 04             	sub    $0x4,%esp
80109849:	57                   	push   %edi
8010984a:	56                   	push   %esi
8010984b:	53                   	push   %ebx
8010984c:	51                   	push   %ecx
8010984d:	52                   	push   %edx
8010984e:	50                   	push   %eax
8010984f:	68 64 c3 10 80       	push   $0x8010c364
80109854:	e8 9b 6b ff ff       	call   801003f4 <cprintf>
80109859:	83 c4 20             	add    $0x20,%esp
}
8010985c:	90                   	nop
8010985d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109860:	5b                   	pop    %ebx
80109861:	5e                   	pop    %esi
80109862:	5f                   	pop    %edi
80109863:	5d                   	pop    %ebp
80109864:	c3                   	ret    

80109865 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109865:	55                   	push   %ebp
80109866:	89 e5                	mov    %esp,%ebp
80109868:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010986b:	8b 45 08             	mov    0x8(%ebp),%eax
8010986e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109871:	8b 45 08             	mov    0x8(%ebp),%eax
80109874:	83 c0 0e             	add    $0xe,%eax
80109877:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010987a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010987d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109881:	3c 08                	cmp    $0x8,%al
80109883:	75 1b                	jne    801098a0 <eth_proc+0x3b>
80109885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109888:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010988c:	3c 06                	cmp    $0x6,%al
8010988e:	75 10                	jne    801098a0 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109890:	83 ec 0c             	sub    $0xc,%esp
80109893:	ff 75 f0             	push   -0x10(%ebp)
80109896:	e8 01 f8 ff ff       	call   8010909c <arp_proc>
8010989b:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010989e:	eb 24                	jmp    801098c4 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801098a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098a3:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801098a7:	3c 08                	cmp    $0x8,%al
801098a9:	75 19                	jne    801098c4 <eth_proc+0x5f>
801098ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ae:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098b2:	84 c0                	test   %al,%al
801098b4:	75 0e                	jne    801098c4 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801098b6:	83 ec 0c             	sub    $0xc,%esp
801098b9:	ff 75 08             	push   0x8(%ebp)
801098bc:	e8 a3 00 00 00       	call   80109964 <ipv4_proc>
801098c1:	83 c4 10             	add    $0x10,%esp
}
801098c4:	90                   	nop
801098c5:	c9                   	leave  
801098c6:	c3                   	ret    

801098c7 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801098c7:	55                   	push   %ebp
801098c8:	89 e5                	mov    %esp,%ebp
801098ca:	83 ec 04             	sub    $0x4,%esp
801098cd:	8b 45 08             	mov    0x8(%ebp),%eax
801098d0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801098d4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098d8:	c1 e0 08             	shl    $0x8,%eax
801098db:	89 c2                	mov    %eax,%edx
801098dd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098e1:	66 c1 e8 08          	shr    $0x8,%ax
801098e5:	01 d0                	add    %edx,%eax
}
801098e7:	c9                   	leave  
801098e8:	c3                   	ret    

801098e9 <H2N_ushort>:

ushort H2N_ushort(ushort value){
801098e9:	55                   	push   %ebp
801098ea:	89 e5                	mov    %esp,%ebp
801098ec:	83 ec 04             	sub    $0x4,%esp
801098ef:	8b 45 08             	mov    0x8(%ebp),%eax
801098f2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801098f6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098fa:	c1 e0 08             	shl    $0x8,%eax
801098fd:	89 c2                	mov    %eax,%edx
801098ff:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109903:	66 c1 e8 08          	shr    $0x8,%ax
80109907:	01 d0                	add    %edx,%eax
}
80109909:	c9                   	leave  
8010990a:	c3                   	ret    

8010990b <H2N_uint>:

uint H2N_uint(uint value){
8010990b:	55                   	push   %ebp
8010990c:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010990e:	8b 45 08             	mov    0x8(%ebp),%eax
80109911:	c1 e0 18             	shl    $0x18,%eax
80109914:	25 00 00 00 0f       	and    $0xf000000,%eax
80109919:	89 c2                	mov    %eax,%edx
8010991b:	8b 45 08             	mov    0x8(%ebp),%eax
8010991e:	c1 e0 08             	shl    $0x8,%eax
80109921:	25 00 f0 00 00       	and    $0xf000,%eax
80109926:	09 c2                	or     %eax,%edx
80109928:	8b 45 08             	mov    0x8(%ebp),%eax
8010992b:	c1 e8 08             	shr    $0x8,%eax
8010992e:	83 e0 0f             	and    $0xf,%eax
80109931:	01 d0                	add    %edx,%eax
}
80109933:	5d                   	pop    %ebp
80109934:	c3                   	ret    

80109935 <N2H_uint>:

uint N2H_uint(uint value){
80109935:	55                   	push   %ebp
80109936:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109938:	8b 45 08             	mov    0x8(%ebp),%eax
8010993b:	c1 e0 18             	shl    $0x18,%eax
8010993e:	89 c2                	mov    %eax,%edx
80109940:	8b 45 08             	mov    0x8(%ebp),%eax
80109943:	c1 e0 08             	shl    $0x8,%eax
80109946:	25 00 00 ff 00       	and    $0xff0000,%eax
8010994b:	01 c2                	add    %eax,%edx
8010994d:	8b 45 08             	mov    0x8(%ebp),%eax
80109950:	c1 e8 08             	shr    $0x8,%eax
80109953:	25 00 ff 00 00       	and    $0xff00,%eax
80109958:	01 c2                	add    %eax,%edx
8010995a:	8b 45 08             	mov    0x8(%ebp),%eax
8010995d:	c1 e8 18             	shr    $0x18,%eax
80109960:	01 d0                	add    %edx,%eax
}
80109962:	5d                   	pop    %ebp
80109963:	c3                   	ret    

80109964 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109964:	55                   	push   %ebp
80109965:	89 e5                	mov    %esp,%ebp
80109967:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010996a:	8b 45 08             	mov    0x8(%ebp),%eax
8010996d:	83 c0 0e             	add    $0xe,%eax
80109970:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109976:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010997a:	0f b7 d0             	movzwl %ax,%edx
8010997d:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109982:	39 c2                	cmp    %eax,%edx
80109984:	74 60                	je     801099e6 <ipv4_proc+0x82>
80109986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109989:	83 c0 0c             	add    $0xc,%eax
8010998c:	83 ec 04             	sub    $0x4,%esp
8010998f:	6a 04                	push   $0x4
80109991:	50                   	push   %eax
80109992:	68 e4 f4 10 80       	push   $0x8010f4e4
80109997:	e8 23 b5 ff ff       	call   80104ebf <memcmp>
8010999c:	83 c4 10             	add    $0x10,%esp
8010999f:	85 c0                	test   %eax,%eax
801099a1:	74 43                	je     801099e6 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801099a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801099aa:	0f b7 c0             	movzwl %ax,%eax
801099ad:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801099b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801099b9:	3c 01                	cmp    $0x1,%al
801099bb:	75 10                	jne    801099cd <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801099bd:	83 ec 0c             	sub    $0xc,%esp
801099c0:	ff 75 08             	push   0x8(%ebp)
801099c3:	e8 a3 00 00 00       	call   80109a6b <icmp_proc>
801099c8:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801099cb:	eb 19                	jmp    801099e6 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801099cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d0:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801099d4:	3c 06                	cmp    $0x6,%al
801099d6:	75 0e                	jne    801099e6 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801099d8:	83 ec 0c             	sub    $0xc,%esp
801099db:	ff 75 08             	push   0x8(%ebp)
801099de:	e8 b3 03 00 00       	call   80109d96 <tcp_proc>
801099e3:	83 c4 10             	add    $0x10,%esp
}
801099e6:	90                   	nop
801099e7:	c9                   	leave  
801099e8:	c3                   	ret    

801099e9 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801099e9:	55                   	push   %ebp
801099ea:	89 e5                	mov    %esp,%ebp
801099ec:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801099ef:	8b 45 08             	mov    0x8(%ebp),%eax
801099f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801099f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099f8:	0f b6 00             	movzbl (%eax),%eax
801099fb:	83 e0 0f             	and    $0xf,%eax
801099fe:	01 c0                	add    %eax,%eax
80109a00:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109a03:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a0a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109a11:	eb 48                	jmp    80109a5b <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109a13:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a16:	01 c0                	add    %eax,%eax
80109a18:	89 c2                	mov    %eax,%edx
80109a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1d:	01 d0                	add    %edx,%eax
80109a1f:	0f b6 00             	movzbl (%eax),%eax
80109a22:	0f b6 c0             	movzbl %al,%eax
80109a25:	c1 e0 08             	shl    $0x8,%eax
80109a28:	89 c2                	mov    %eax,%edx
80109a2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a2d:	01 c0                	add    %eax,%eax
80109a2f:	8d 48 01             	lea    0x1(%eax),%ecx
80109a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a35:	01 c8                	add    %ecx,%eax
80109a37:	0f b6 00             	movzbl (%eax),%eax
80109a3a:	0f b6 c0             	movzbl %al,%eax
80109a3d:	01 d0                	add    %edx,%eax
80109a3f:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109a42:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109a49:	76 0c                	jbe    80109a57 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109a4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a4e:	0f b7 c0             	movzwl %ax,%eax
80109a51:	83 c0 01             	add    $0x1,%eax
80109a54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a57:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109a5b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109a5f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109a62:	7c af                	jl     80109a13 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a67:	f7 d0                	not    %eax
}
80109a69:	c9                   	leave  
80109a6a:	c3                   	ret    

80109a6b <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109a6b:	55                   	push   %ebp
80109a6c:	89 e5                	mov    %esp,%ebp
80109a6e:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109a71:	8b 45 08             	mov    0x8(%ebp),%eax
80109a74:	83 c0 0e             	add    $0xe,%eax
80109a77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a7d:	0f b6 00             	movzbl (%eax),%eax
80109a80:	0f b6 c0             	movzbl %al,%eax
80109a83:	83 e0 0f             	and    $0xf,%eax
80109a86:	c1 e0 02             	shl    $0x2,%eax
80109a89:	89 c2                	mov    %eax,%edx
80109a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a8e:	01 d0                	add    %edx,%eax
80109a90:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a96:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109a9a:	84 c0                	test   %al,%al
80109a9c:	75 4f                	jne    80109aed <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa1:	0f b6 00             	movzbl (%eax),%eax
80109aa4:	3c 08                	cmp    $0x8,%al
80109aa6:	75 45                	jne    80109aed <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109aa8:	e8 d7 91 ff ff       	call   80102c84 <kalloc>
80109aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109ab0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109ab7:	83 ec 04             	sub    $0x4,%esp
80109aba:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109abd:	50                   	push   %eax
80109abe:	ff 75 ec             	push   -0x14(%ebp)
80109ac1:	ff 75 08             	push   0x8(%ebp)
80109ac4:	e8 78 00 00 00       	call   80109b41 <icmp_reply_pkt_create>
80109ac9:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109acc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109acf:	83 ec 08             	sub    $0x8,%esp
80109ad2:	50                   	push   %eax
80109ad3:	ff 75 ec             	push   -0x14(%ebp)
80109ad6:	e8 95 f4 ff ff       	call   80108f70 <i8254_send>
80109adb:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109ade:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ae1:	83 ec 0c             	sub    $0xc,%esp
80109ae4:	50                   	push   %eax
80109ae5:	e8 00 91 ff ff       	call   80102bea <kfree>
80109aea:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109aed:	90                   	nop
80109aee:	c9                   	leave  
80109aef:	c3                   	ret    

80109af0 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109af0:	55                   	push   %ebp
80109af1:	89 e5                	mov    %esp,%ebp
80109af3:	53                   	push   %ebx
80109af4:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109af7:	8b 45 08             	mov    0x8(%ebp),%eax
80109afa:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109afe:	0f b7 c0             	movzwl %ax,%eax
80109b01:	83 ec 0c             	sub    $0xc,%esp
80109b04:	50                   	push   %eax
80109b05:	e8 bd fd ff ff       	call   801098c7 <N2H_ushort>
80109b0a:	83 c4 10             	add    $0x10,%esp
80109b0d:	0f b7 d8             	movzwl %ax,%ebx
80109b10:	8b 45 08             	mov    0x8(%ebp),%eax
80109b13:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b17:	0f b7 c0             	movzwl %ax,%eax
80109b1a:	83 ec 0c             	sub    $0xc,%esp
80109b1d:	50                   	push   %eax
80109b1e:	e8 a4 fd ff ff       	call   801098c7 <N2H_ushort>
80109b23:	83 c4 10             	add    $0x10,%esp
80109b26:	0f b7 c0             	movzwl %ax,%eax
80109b29:	83 ec 04             	sub    $0x4,%esp
80109b2c:	53                   	push   %ebx
80109b2d:	50                   	push   %eax
80109b2e:	68 83 c3 10 80       	push   $0x8010c383
80109b33:	e8 bc 68 ff ff       	call   801003f4 <cprintf>
80109b38:	83 c4 10             	add    $0x10,%esp
}
80109b3b:	90                   	nop
80109b3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b3f:	c9                   	leave  
80109b40:	c3                   	ret    

80109b41 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109b41:	55                   	push   %ebp
80109b42:	89 e5                	mov    %esp,%ebp
80109b44:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b47:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b50:	83 c0 0e             	add    $0xe,%eax
80109b53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b59:	0f b6 00             	movzbl (%eax),%eax
80109b5c:	0f b6 c0             	movzbl %al,%eax
80109b5f:	83 e0 0f             	and    $0xf,%eax
80109b62:	c1 e0 02             	shl    $0x2,%eax
80109b65:	89 c2                	mov    %eax,%edx
80109b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b6a:	01 d0                	add    %edx,%eax
80109b6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b72:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109b75:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b78:	83 c0 0e             	add    $0xe,%eax
80109b7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109b7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b81:	83 c0 14             	add    $0x14,%eax
80109b84:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109b87:	8b 45 10             	mov    0x10(%ebp),%eax
80109b8a:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b93:	8d 50 06             	lea    0x6(%eax),%edx
80109b96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b99:	83 ec 04             	sub    $0x4,%esp
80109b9c:	6a 06                	push   $0x6
80109b9e:	52                   	push   %edx
80109b9f:	50                   	push   %eax
80109ba0:	e8 72 b3 ff ff       	call   80104f17 <memmove>
80109ba5:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109ba8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bab:	83 c0 06             	add    $0x6,%eax
80109bae:	83 ec 04             	sub    $0x4,%esp
80109bb1:	6a 06                	push   $0x6
80109bb3:	68 c0 9d 11 80       	push   $0x80119dc0
80109bb8:	50                   	push   %eax
80109bb9:	e8 59 b3 ff ff       	call   80104f17 <memmove>
80109bbe:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109bc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bc4:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109bc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bcb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109bcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd2:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109bd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd8:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109bdc:	83 ec 0c             	sub    $0xc,%esp
80109bdf:	6a 54                	push   $0x54
80109be1:	e8 03 fd ff ff       	call   801098e9 <H2N_ushort>
80109be6:	83 c4 10             	add    $0x10,%esp
80109be9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bec:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109bf0:	0f b7 15 a0 a0 11 80 	movzwl 0x8011a0a0,%edx
80109bf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bfa:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109bfe:	0f b7 05 a0 a0 11 80 	movzwl 0x8011a0a0,%eax
80109c05:	83 c0 01             	add    $0x1,%eax
80109c08:	66 a3 a0 a0 11 80    	mov    %ax,0x8011a0a0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109c0e:	83 ec 0c             	sub    $0xc,%esp
80109c11:	68 00 40 00 00       	push   $0x4000
80109c16:	e8 ce fc ff ff       	call   801098e9 <H2N_ushort>
80109c1b:	83 c4 10             	add    $0x10,%esp
80109c1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c21:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c28:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c2f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109c33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c36:	83 c0 0c             	add    $0xc,%eax
80109c39:	83 ec 04             	sub    $0x4,%esp
80109c3c:	6a 04                	push   $0x4
80109c3e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109c43:	50                   	push   %eax
80109c44:	e8 ce b2 ff ff       	call   80104f17 <memmove>
80109c49:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c4f:	8d 50 0c             	lea    0xc(%eax),%edx
80109c52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c55:	83 c0 10             	add    $0x10,%eax
80109c58:	83 ec 04             	sub    $0x4,%esp
80109c5b:	6a 04                	push   $0x4
80109c5d:	52                   	push   %edx
80109c5e:	50                   	push   %eax
80109c5f:	e8 b3 b2 ff ff       	call   80104f17 <memmove>
80109c64:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c6a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c73:	83 ec 0c             	sub    $0xc,%esp
80109c76:	50                   	push   %eax
80109c77:	e8 6d fd ff ff       	call   801099e9 <ipv4_chksum>
80109c7c:	83 c4 10             	add    $0x10,%esp
80109c7f:	0f b7 c0             	movzwl %ax,%eax
80109c82:	83 ec 0c             	sub    $0xc,%esp
80109c85:	50                   	push   %eax
80109c86:	e8 5e fc ff ff       	call   801098e9 <H2N_ushort>
80109c8b:	83 c4 10             	add    $0x10,%esp
80109c8e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c91:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109c95:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c98:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109c9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c9e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ca5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cac:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109cb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cb3:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109cb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cba:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109cbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cc1:	8d 50 08             	lea    0x8(%eax),%edx
80109cc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cc7:	83 c0 08             	add    $0x8,%eax
80109cca:	83 ec 04             	sub    $0x4,%esp
80109ccd:	6a 08                	push   $0x8
80109ccf:	52                   	push   %edx
80109cd0:	50                   	push   %eax
80109cd1:	e8 41 b2 ff ff       	call   80104f17 <memmove>
80109cd6:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109cd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cdc:	8d 50 10             	lea    0x10(%eax),%edx
80109cdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ce2:	83 c0 10             	add    $0x10,%eax
80109ce5:	83 ec 04             	sub    $0x4,%esp
80109ce8:	6a 30                	push   $0x30
80109cea:	52                   	push   %edx
80109ceb:	50                   	push   %eax
80109cec:	e8 26 b2 ff ff       	call   80104f17 <memmove>
80109cf1:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109cf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cf7:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109cfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d00:	83 ec 0c             	sub    $0xc,%esp
80109d03:	50                   	push   %eax
80109d04:	e8 1c 00 00 00       	call   80109d25 <icmp_chksum>
80109d09:	83 c4 10             	add    $0x10,%esp
80109d0c:	0f b7 c0             	movzwl %ax,%eax
80109d0f:	83 ec 0c             	sub    $0xc,%esp
80109d12:	50                   	push   %eax
80109d13:	e8 d1 fb ff ff       	call   801098e9 <H2N_ushort>
80109d18:	83 c4 10             	add    $0x10,%esp
80109d1b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d1e:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109d22:	90                   	nop
80109d23:	c9                   	leave  
80109d24:	c3                   	ret    

80109d25 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109d25:	55                   	push   %ebp
80109d26:	89 e5                	mov    %esp,%ebp
80109d28:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109d31:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d38:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109d3f:	eb 48                	jmp    80109d89 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d41:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d44:	01 c0                	add    %eax,%eax
80109d46:	89 c2                	mov    %eax,%edx
80109d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d4b:	01 d0                	add    %edx,%eax
80109d4d:	0f b6 00             	movzbl (%eax),%eax
80109d50:	0f b6 c0             	movzbl %al,%eax
80109d53:	c1 e0 08             	shl    $0x8,%eax
80109d56:	89 c2                	mov    %eax,%edx
80109d58:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d5b:	01 c0                	add    %eax,%eax
80109d5d:	8d 48 01             	lea    0x1(%eax),%ecx
80109d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d63:	01 c8                	add    %ecx,%eax
80109d65:	0f b6 00             	movzbl (%eax),%eax
80109d68:	0f b6 c0             	movzbl %al,%eax
80109d6b:	01 d0                	add    %edx,%eax
80109d6d:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d70:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d77:	76 0c                	jbe    80109d85 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d7c:	0f b7 c0             	movzwl %ax,%eax
80109d7f:	83 c0 01             	add    $0x1,%eax
80109d82:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d85:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d89:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109d8d:	7e b2                	jle    80109d41 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109d8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d92:	f7 d0                	not    %eax
}
80109d94:	c9                   	leave  
80109d95:	c3                   	ret    

80109d96 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109d96:	55                   	push   %ebp
80109d97:	89 e5                	mov    %esp,%ebp
80109d99:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d9f:	83 c0 0e             	add    $0xe,%eax
80109da2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109da8:	0f b6 00             	movzbl (%eax),%eax
80109dab:	0f b6 c0             	movzbl %al,%eax
80109dae:	83 e0 0f             	and    $0xf,%eax
80109db1:	c1 e0 02             	shl    $0x2,%eax
80109db4:	89 c2                	mov    %eax,%edx
80109db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109db9:	01 d0                	add    %edx,%eax
80109dbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dc1:	83 c0 14             	add    $0x14,%eax
80109dc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109dc7:	e8 b8 8e ff ff       	call   80102c84 <kalloc>
80109dcc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109dcf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dd9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ddd:	0f b6 c0             	movzbl %al,%eax
80109de0:	83 e0 02             	and    $0x2,%eax
80109de3:	85 c0                	test   %eax,%eax
80109de5:	74 3d                	je     80109e24 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109de7:	83 ec 0c             	sub    $0xc,%esp
80109dea:	6a 00                	push   $0x0
80109dec:	6a 12                	push   $0x12
80109dee:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109df1:	50                   	push   %eax
80109df2:	ff 75 e8             	push   -0x18(%ebp)
80109df5:	ff 75 08             	push   0x8(%ebp)
80109df8:	e8 a2 01 00 00       	call   80109f9f <tcp_pkt_create>
80109dfd:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109e00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e03:	83 ec 08             	sub    $0x8,%esp
80109e06:	50                   	push   %eax
80109e07:	ff 75 e8             	push   -0x18(%ebp)
80109e0a:	e8 61 f1 ff ff       	call   80108f70 <i8254_send>
80109e0f:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109e12:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
80109e17:	83 c0 01             	add    $0x1,%eax
80109e1a:	a3 a4 a0 11 80       	mov    %eax,0x8011a0a4
80109e1f:	e9 69 01 00 00       	jmp    80109f8d <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e27:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e2b:	3c 18                	cmp    $0x18,%al
80109e2d:	0f 85 10 01 00 00    	jne    80109f43 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109e33:	83 ec 04             	sub    $0x4,%esp
80109e36:	6a 03                	push   $0x3
80109e38:	68 9e c3 10 80       	push   $0x8010c39e
80109e3d:	ff 75 ec             	push   -0x14(%ebp)
80109e40:	e8 7a b0 ff ff       	call   80104ebf <memcmp>
80109e45:	83 c4 10             	add    $0x10,%esp
80109e48:	85 c0                	test   %eax,%eax
80109e4a:	74 74                	je     80109ec0 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109e4c:	83 ec 0c             	sub    $0xc,%esp
80109e4f:	68 a2 c3 10 80       	push   $0x8010c3a2
80109e54:	e8 9b 65 ff ff       	call   801003f4 <cprintf>
80109e59:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e5c:	83 ec 0c             	sub    $0xc,%esp
80109e5f:	6a 00                	push   $0x0
80109e61:	6a 10                	push   $0x10
80109e63:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e66:	50                   	push   %eax
80109e67:	ff 75 e8             	push   -0x18(%ebp)
80109e6a:	ff 75 08             	push   0x8(%ebp)
80109e6d:	e8 2d 01 00 00       	call   80109f9f <tcp_pkt_create>
80109e72:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e75:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e78:	83 ec 08             	sub    $0x8,%esp
80109e7b:	50                   	push   %eax
80109e7c:	ff 75 e8             	push   -0x18(%ebp)
80109e7f:	e8 ec f0 ff ff       	call   80108f70 <i8254_send>
80109e84:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e8a:	83 c0 36             	add    $0x36,%eax
80109e8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e90:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109e93:	50                   	push   %eax
80109e94:	ff 75 e0             	push   -0x20(%ebp)
80109e97:	6a 00                	push   $0x0
80109e99:	6a 00                	push   $0x0
80109e9b:	e8 5a 04 00 00       	call   8010a2fa <http_proc>
80109ea0:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ea3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ea6:	83 ec 0c             	sub    $0xc,%esp
80109ea9:	50                   	push   %eax
80109eaa:	6a 18                	push   $0x18
80109eac:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109eaf:	50                   	push   %eax
80109eb0:	ff 75 e8             	push   -0x18(%ebp)
80109eb3:	ff 75 08             	push   0x8(%ebp)
80109eb6:	e8 e4 00 00 00       	call   80109f9f <tcp_pkt_create>
80109ebb:	83 c4 20             	add    $0x20,%esp
80109ebe:	eb 62                	jmp    80109f22 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ec0:	83 ec 0c             	sub    $0xc,%esp
80109ec3:	6a 00                	push   $0x0
80109ec5:	6a 10                	push   $0x10
80109ec7:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109eca:	50                   	push   %eax
80109ecb:	ff 75 e8             	push   -0x18(%ebp)
80109ece:	ff 75 08             	push   0x8(%ebp)
80109ed1:	e8 c9 00 00 00       	call   80109f9f <tcp_pkt_create>
80109ed6:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109ed9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109edc:	83 ec 08             	sub    $0x8,%esp
80109edf:	50                   	push   %eax
80109ee0:	ff 75 e8             	push   -0x18(%ebp)
80109ee3:	e8 88 f0 ff ff       	call   80108f70 <i8254_send>
80109ee8:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109eeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109eee:	83 c0 36             	add    $0x36,%eax
80109ef1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ef4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109ef7:	50                   	push   %eax
80109ef8:	ff 75 e4             	push   -0x1c(%ebp)
80109efb:	6a 00                	push   $0x0
80109efd:	6a 00                	push   $0x0
80109eff:	e8 f6 03 00 00       	call   8010a2fa <http_proc>
80109f04:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109f07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109f0a:	83 ec 0c             	sub    $0xc,%esp
80109f0d:	50                   	push   %eax
80109f0e:	6a 18                	push   $0x18
80109f10:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f13:	50                   	push   %eax
80109f14:	ff 75 e8             	push   -0x18(%ebp)
80109f17:	ff 75 08             	push   0x8(%ebp)
80109f1a:	e8 80 00 00 00       	call   80109f9f <tcp_pkt_create>
80109f1f:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109f22:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f25:	83 ec 08             	sub    $0x8,%esp
80109f28:	50                   	push   %eax
80109f29:	ff 75 e8             	push   -0x18(%ebp)
80109f2c:	e8 3f f0 ff ff       	call   80108f70 <i8254_send>
80109f31:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f34:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
80109f39:	83 c0 01             	add    $0x1,%eax
80109f3c:	a3 a4 a0 11 80       	mov    %eax,0x8011a0a4
80109f41:	eb 4a                	jmp    80109f8d <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f46:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f4a:	3c 10                	cmp    $0x10,%al
80109f4c:	75 3f                	jne    80109f8d <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109f4e:	a1 a8 a0 11 80       	mov    0x8011a0a8,%eax
80109f53:	83 f8 01             	cmp    $0x1,%eax
80109f56:	75 35                	jne    80109f8d <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109f58:	83 ec 0c             	sub    $0xc,%esp
80109f5b:	6a 00                	push   $0x0
80109f5d:	6a 01                	push   $0x1
80109f5f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f62:	50                   	push   %eax
80109f63:	ff 75 e8             	push   -0x18(%ebp)
80109f66:	ff 75 08             	push   0x8(%ebp)
80109f69:	e8 31 00 00 00       	call   80109f9f <tcp_pkt_create>
80109f6e:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f71:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f74:	83 ec 08             	sub    $0x8,%esp
80109f77:	50                   	push   %eax
80109f78:	ff 75 e8             	push   -0x18(%ebp)
80109f7b:	e8 f0 ef ff ff       	call   80108f70 <i8254_send>
80109f80:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109f83:	c7 05 a8 a0 11 80 00 	movl   $0x0,0x8011a0a8
80109f8a:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109f8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f90:	83 ec 0c             	sub    $0xc,%esp
80109f93:	50                   	push   %eax
80109f94:	e8 51 8c ff ff       	call   80102bea <kfree>
80109f99:	83 c4 10             	add    $0x10,%esp
}
80109f9c:	90                   	nop
80109f9d:	c9                   	leave  
80109f9e:	c3                   	ret    

80109f9f <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109f9f:	55                   	push   %ebp
80109fa0:	89 e5                	mov    %esp,%ebp
80109fa2:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109fab:	8b 45 08             	mov    0x8(%ebp),%eax
80109fae:	83 c0 0e             	add    $0xe,%eax
80109fb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fb7:	0f b6 00             	movzbl (%eax),%eax
80109fba:	0f b6 c0             	movzbl %al,%eax
80109fbd:	83 e0 0f             	and    $0xf,%eax
80109fc0:	c1 e0 02             	shl    $0x2,%eax
80109fc3:	89 c2                	mov    %eax,%edx
80109fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fc8:	01 d0                	add    %edx,%eax
80109fca:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fd0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fd6:	83 c0 0e             	add    $0xe,%eax
80109fd9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109fdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fdf:	83 c0 14             	add    $0x14,%eax
80109fe2:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109fe5:	8b 45 18             	mov    0x18(%ebp),%eax
80109fe8:	8d 50 36             	lea    0x36(%eax),%edx
80109feb:	8b 45 10             	mov    0x10(%ebp),%eax
80109fee:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ff3:	8d 50 06             	lea    0x6(%eax),%edx
80109ff6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ff9:	83 ec 04             	sub    $0x4,%esp
80109ffc:	6a 06                	push   $0x6
80109ffe:	52                   	push   %edx
80109fff:	50                   	push   %eax
8010a000:	e8 12 af ff ff       	call   80104f17 <memmove>
8010a005:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a008:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a00b:	83 c0 06             	add    $0x6,%eax
8010a00e:	83 ec 04             	sub    $0x4,%esp
8010a011:	6a 06                	push   $0x6
8010a013:	68 c0 9d 11 80       	push   $0x80119dc0
8010a018:	50                   	push   %eax
8010a019:	e8 f9 ae ff ff       	call   80104f17 <memmove>
8010a01e:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a021:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a024:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a028:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a02b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a02f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a032:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a035:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a038:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a03c:	8b 45 18             	mov    0x18(%ebp),%eax
8010a03f:	83 c0 28             	add    $0x28,%eax
8010a042:	0f b7 c0             	movzwl %ax,%eax
8010a045:	83 ec 0c             	sub    $0xc,%esp
8010a048:	50                   	push   %eax
8010a049:	e8 9b f8 ff ff       	call   801098e9 <H2N_ushort>
8010a04e:	83 c4 10             	add    $0x10,%esp
8010a051:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a054:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a058:	0f b7 15 a0 a0 11 80 	movzwl 0x8011a0a0,%edx
8010a05f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a062:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a066:	0f b7 05 a0 a0 11 80 	movzwl 0x8011a0a0,%eax
8010a06d:	83 c0 01             	add    $0x1,%eax
8010a070:	66 a3 a0 a0 11 80    	mov    %ax,0x8011a0a0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a076:	83 ec 0c             	sub    $0xc,%esp
8010a079:	6a 00                	push   $0x0
8010a07b:	e8 69 f8 ff ff       	call   801098e9 <H2N_ushort>
8010a080:	83 c4 10             	add    $0x10,%esp
8010a083:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a086:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a08a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a08d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a091:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a094:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a098:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a09b:	83 c0 0c             	add    $0xc,%eax
8010a09e:	83 ec 04             	sub    $0x4,%esp
8010a0a1:	6a 04                	push   $0x4
8010a0a3:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a0a8:	50                   	push   %eax
8010a0a9:	e8 69 ae ff ff       	call   80104f17 <memmove>
8010a0ae:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a0b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b4:	8d 50 0c             	lea    0xc(%eax),%edx
8010a0b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0ba:	83 c0 10             	add    $0x10,%eax
8010a0bd:	83 ec 04             	sub    $0x4,%esp
8010a0c0:	6a 04                	push   $0x4
8010a0c2:	52                   	push   %edx
8010a0c3:	50                   	push   %eax
8010a0c4:	e8 4e ae ff ff       	call   80104f17 <memmove>
8010a0c9:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a0cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0cf:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a0d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0d8:	83 ec 0c             	sub    $0xc,%esp
8010a0db:	50                   	push   %eax
8010a0dc:	e8 08 f9 ff ff       	call   801099e9 <ipv4_chksum>
8010a0e1:	83 c4 10             	add    $0x10,%esp
8010a0e4:	0f b7 c0             	movzwl %ax,%eax
8010a0e7:	83 ec 0c             	sub    $0xc,%esp
8010a0ea:	50                   	push   %eax
8010a0eb:	e8 f9 f7 ff ff       	call   801098e9 <H2N_ushort>
8010a0f0:	83 c4 10             	add    $0x10,%esp
8010a0f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0f6:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a0fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0fd:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a101:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a104:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a107:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a10a:	0f b7 10             	movzwl (%eax),%edx
8010a10d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a110:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a114:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
8010a119:	83 ec 0c             	sub    $0xc,%esp
8010a11c:	50                   	push   %eax
8010a11d:	e8 e9 f7 ff ff       	call   8010990b <H2N_uint>
8010a122:	83 c4 10             	add    $0x10,%esp
8010a125:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a128:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a12b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a12e:	8b 40 04             	mov    0x4(%eax),%eax
8010a131:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a137:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a13a:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a13d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a140:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a144:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a147:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a14b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a14e:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a152:	8b 45 14             	mov    0x14(%ebp),%eax
8010a155:	89 c2                	mov    %eax,%edx
8010a157:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a15a:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a15d:	83 ec 0c             	sub    $0xc,%esp
8010a160:	68 90 38 00 00       	push   $0x3890
8010a165:	e8 7f f7 ff ff       	call   801098e9 <H2N_ushort>
8010a16a:	83 c4 10             	add    $0x10,%esp
8010a16d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a170:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a174:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a177:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a17d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a180:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a186:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a189:	83 ec 0c             	sub    $0xc,%esp
8010a18c:	50                   	push   %eax
8010a18d:	e8 1f 00 00 00       	call   8010a1b1 <tcp_chksum>
8010a192:	83 c4 10             	add    $0x10,%esp
8010a195:	83 c0 08             	add    $0x8,%eax
8010a198:	0f b7 c0             	movzwl %ax,%eax
8010a19b:	83 ec 0c             	sub    $0xc,%esp
8010a19e:	50                   	push   %eax
8010a19f:	e8 45 f7 ff ff       	call   801098e9 <H2N_ushort>
8010a1a4:	83 c4 10             	add    $0x10,%esp
8010a1a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1aa:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a1ae:	90                   	nop
8010a1af:	c9                   	leave  
8010a1b0:	c3                   	ret    

8010a1b1 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a1b1:	55                   	push   %ebp
8010a1b2:	89 e5                	mov    %esp,%ebp
8010a1b4:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a1b7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a1bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1c0:	83 c0 14             	add    $0x14,%eax
8010a1c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a1c6:	83 ec 04             	sub    $0x4,%esp
8010a1c9:	6a 04                	push   $0x4
8010a1cb:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a1d0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1d3:	50                   	push   %eax
8010a1d4:	e8 3e ad ff ff       	call   80104f17 <memmove>
8010a1d9:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a1dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1df:	83 c0 0c             	add    $0xc,%eax
8010a1e2:	83 ec 04             	sub    $0x4,%esp
8010a1e5:	6a 04                	push   $0x4
8010a1e7:	50                   	push   %eax
8010a1e8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1eb:	83 c0 04             	add    $0x4,%eax
8010a1ee:	50                   	push   %eax
8010a1ef:	e8 23 ad ff ff       	call   80104f17 <memmove>
8010a1f4:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a1f7:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a1fb:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a1ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a202:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a206:	0f b7 c0             	movzwl %ax,%eax
8010a209:	83 ec 0c             	sub    $0xc,%esp
8010a20c:	50                   	push   %eax
8010a20d:	e8 b5 f6 ff ff       	call   801098c7 <N2H_ushort>
8010a212:	83 c4 10             	add    $0x10,%esp
8010a215:	83 e8 14             	sub    $0x14,%eax
8010a218:	0f b7 c0             	movzwl %ax,%eax
8010a21b:	83 ec 0c             	sub    $0xc,%esp
8010a21e:	50                   	push   %eax
8010a21f:	e8 c5 f6 ff ff       	call   801098e9 <H2N_ushort>
8010a224:	83 c4 10             	add    $0x10,%esp
8010a227:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a22b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a232:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a235:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a238:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a23f:	eb 33                	jmp    8010a274 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a241:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a244:	01 c0                	add    %eax,%eax
8010a246:	89 c2                	mov    %eax,%edx
8010a248:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a24b:	01 d0                	add    %edx,%eax
8010a24d:	0f b6 00             	movzbl (%eax),%eax
8010a250:	0f b6 c0             	movzbl %al,%eax
8010a253:	c1 e0 08             	shl    $0x8,%eax
8010a256:	89 c2                	mov    %eax,%edx
8010a258:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a25b:	01 c0                	add    %eax,%eax
8010a25d:	8d 48 01             	lea    0x1(%eax),%ecx
8010a260:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a263:	01 c8                	add    %ecx,%eax
8010a265:	0f b6 00             	movzbl (%eax),%eax
8010a268:	0f b6 c0             	movzbl %al,%eax
8010a26b:	01 d0                	add    %edx,%eax
8010a26d:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a270:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a274:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a278:	7e c7                	jle    8010a241 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a27a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a27d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a280:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a287:	eb 33                	jmp    8010a2bc <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a289:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a28c:	01 c0                	add    %eax,%eax
8010a28e:	89 c2                	mov    %eax,%edx
8010a290:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a293:	01 d0                	add    %edx,%eax
8010a295:	0f b6 00             	movzbl (%eax),%eax
8010a298:	0f b6 c0             	movzbl %al,%eax
8010a29b:	c1 e0 08             	shl    $0x8,%eax
8010a29e:	89 c2                	mov    %eax,%edx
8010a2a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2a3:	01 c0                	add    %eax,%eax
8010a2a5:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2ab:	01 c8                	add    %ecx,%eax
8010a2ad:	0f b6 00             	movzbl (%eax),%eax
8010a2b0:	0f b6 c0             	movzbl %al,%eax
8010a2b3:	01 d0                	add    %edx,%eax
8010a2b5:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a2b8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a2bc:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a2c0:	0f b7 c0             	movzwl %ax,%eax
8010a2c3:	83 ec 0c             	sub    $0xc,%esp
8010a2c6:	50                   	push   %eax
8010a2c7:	e8 fb f5 ff ff       	call   801098c7 <N2H_ushort>
8010a2cc:	83 c4 10             	add    $0x10,%esp
8010a2cf:	66 d1 e8             	shr    %ax
8010a2d2:	0f b7 c0             	movzwl %ax,%eax
8010a2d5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a2d8:	7c af                	jl     8010a289 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a2da:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2dd:	c1 e8 10             	shr    $0x10,%eax
8010a2e0:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a2e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2e6:	f7 d0                	not    %eax
}
8010a2e8:	c9                   	leave  
8010a2e9:	c3                   	ret    

8010a2ea <tcp_fin>:

void tcp_fin(){
8010a2ea:	55                   	push   %ebp
8010a2eb:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a2ed:	c7 05 a8 a0 11 80 01 	movl   $0x1,0x8011a0a8
8010a2f4:	00 00 00 
}
8010a2f7:	90                   	nop
8010a2f8:	5d                   	pop    %ebp
8010a2f9:	c3                   	ret    

8010a2fa <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a2fa:	55                   	push   %ebp
8010a2fb:	89 e5                	mov    %esp,%ebp
8010a2fd:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a300:	8b 45 10             	mov    0x10(%ebp),%eax
8010a303:	83 ec 04             	sub    $0x4,%esp
8010a306:	6a 00                	push   $0x0
8010a308:	68 ab c3 10 80       	push   $0x8010c3ab
8010a30d:	50                   	push   %eax
8010a30e:	e8 65 00 00 00       	call   8010a378 <http_strcpy>
8010a313:	83 c4 10             	add    $0x10,%esp
8010a316:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a319:	8b 45 10             	mov    0x10(%ebp),%eax
8010a31c:	83 ec 04             	sub    $0x4,%esp
8010a31f:	ff 75 f4             	push   -0xc(%ebp)
8010a322:	68 be c3 10 80       	push   $0x8010c3be
8010a327:	50                   	push   %eax
8010a328:	e8 4b 00 00 00       	call   8010a378 <http_strcpy>
8010a32d:	83 c4 10             	add    $0x10,%esp
8010a330:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a333:	8b 45 10             	mov    0x10(%ebp),%eax
8010a336:	83 ec 04             	sub    $0x4,%esp
8010a339:	ff 75 f4             	push   -0xc(%ebp)
8010a33c:	68 d9 c3 10 80       	push   $0x8010c3d9
8010a341:	50                   	push   %eax
8010a342:	e8 31 00 00 00       	call   8010a378 <http_strcpy>
8010a347:	83 c4 10             	add    $0x10,%esp
8010a34a:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a34d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a350:	83 e0 01             	and    $0x1,%eax
8010a353:	85 c0                	test   %eax,%eax
8010a355:	74 11                	je     8010a368 <http_proc+0x6e>
    char *payload = (char *)send;
8010a357:	8b 45 10             	mov    0x10(%ebp),%eax
8010a35a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a35d:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a360:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a363:	01 d0                	add    %edx,%eax
8010a365:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a368:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a36b:	8b 45 14             	mov    0x14(%ebp),%eax
8010a36e:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a370:	e8 75 ff ff ff       	call   8010a2ea <tcp_fin>
}
8010a375:	90                   	nop
8010a376:	c9                   	leave  
8010a377:	c3                   	ret    

8010a378 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a378:	55                   	push   %ebp
8010a379:	89 e5                	mov    %esp,%ebp
8010a37b:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a37e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a385:	eb 20                	jmp    8010a3a7 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a387:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a38a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a38d:	01 d0                	add    %edx,%eax
8010a38f:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a392:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a395:	01 ca                	add    %ecx,%edx
8010a397:	89 d1                	mov    %edx,%ecx
8010a399:	8b 55 08             	mov    0x8(%ebp),%edx
8010a39c:	01 ca                	add    %ecx,%edx
8010a39e:	0f b6 00             	movzbl (%eax),%eax
8010a3a1:	88 02                	mov    %al,(%edx)
    i++;
8010a3a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a3a7:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3aa:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3ad:	01 d0                	add    %edx,%eax
8010a3af:	0f b6 00             	movzbl (%eax),%eax
8010a3b2:	84 c0                	test   %al,%al
8010a3b4:	75 d1                	jne    8010a387 <http_strcpy+0xf>
  }
  return i;
8010a3b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a3b9:	c9                   	leave  
8010a3ba:	c3                   	ret    
