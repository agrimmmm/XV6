
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a6010113          	addi	sp,sp,-1440 # 80008a60 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8ce70713          	addi	a4,a4,-1842 # 80008920 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	24c78793          	addi	a5,a5,588 # 800062b0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdbc057>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	eea78793          	addi	a5,a5,-278 # 80000f98 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	664080e7          	jalr	1636(ra) # 80002790 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8d650513          	addi	a0,a0,-1834 # 80010a60 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	b64080e7          	jalr	-1180(ra) # 80000cf6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8c648493          	addi	s1,s1,-1850 # 80010a60 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	95690913          	addi	s2,s2,-1706 # 80010af8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	94e080e7          	jalr	-1714(ra) # 80001b0e <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	412080e7          	jalr	1042(ra) # 800025da <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	150080e7          	jalr	336(ra) # 80002326 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	528080e7          	jalr	1320(ra) # 8000273a <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	83a50513          	addi	a0,a0,-1990 # 80010a60 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	b7c080e7          	jalr	-1156(ra) # 80000daa <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	82450513          	addi	a0,a0,-2012 # 80010a60 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	b66080e7          	jalr	-1178(ra) # 80000daa <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	88f72323          	sw	a5,-1914(a4) # 80010af8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	79450513          	addi	a0,a0,1940 # 80010a60 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	a22080e7          	jalr	-1502(ra) # 80000cf6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	4f4080e7          	jalr	1268(ra) # 800027e6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	76650513          	addi	a0,a0,1894 # 80010a60 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	aa8080e7          	jalr	-1368(ra) # 80000daa <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	74270713          	addi	a4,a4,1858 # 80010a60 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	71878793          	addi	a5,a5,1816 # 80010a60 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7827a783          	lw	a5,1922(a5) # 80010af8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6d670713          	addi	a4,a4,1750 # 80010a60 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6c648493          	addi	s1,s1,1734 # 80010a60 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	68a70713          	addi	a4,a4,1674 # 80010a60 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72a23          	sw	a5,1812(a4) # 80010b00 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	64e78793          	addi	a5,a5,1614 # 80010a60 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6cc7a323          	sw	a2,1734(a5) # 80010afc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6ba50513          	addi	a0,a0,1722 # 80010af8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	f44080e7          	jalr	-188(ra) # 8000238a <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	60050513          	addi	a0,a0,1536 # 80010a60 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	7fe080e7          	jalr	2046(ra) # 80000c66 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00241797          	auipc	a5,0x241
    8000047c:	19878793          	addi	a5,a5,408 # 80241610 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5c07ab23          	sw	zero,1494(a5) # 80010b20 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b7c50513          	addi	a0,a0,-1156 # 800080e8 <digits+0xa8>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	36f72123          	sw	a5,866(a4) # 800088e0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	566dad83          	lw	s11,1382(s11) # 80010b20 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	51050513          	addi	a0,a0,1296 # 80010b08 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	6f6080e7          	jalr	1782(ra) # 80000cf6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	3b250513          	addi	a0,a0,946 # 80010b08 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	64c080e7          	jalr	1612(ra) # 80000daa <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	39648493          	addi	s1,s1,918 # 80010b08 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	4e2080e7          	jalr	1250(ra) # 80000c66 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	35650513          	addi	a0,a0,854 # 80010b28 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	48c080e7          	jalr	1164(ra) # 80000c66 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	4b4080e7          	jalr	1204(ra) # 80000caa <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0e27a783          	lw	a5,226(a5) # 800088e0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	526080e7          	jalr	1318(ra) # 80000d4a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0b27b783          	ld	a5,178(a5) # 800088e8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0b273703          	ld	a4,178(a4) # 800088f0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2c8a0a13          	addi	s4,s4,712 # 80010b28 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	08048493          	addi	s1,s1,128 # 800088e8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	08098993          	addi	s3,s3,128 # 800088f0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	af8080e7          	jalr	-1288(ra) # 8000238a <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	25a50513          	addi	a0,a0,602 # 80010b28 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	420080e7          	jalr	1056(ra) # 80000cf6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	0027a783          	lw	a5,2(a5) # 800088e0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	00873703          	ld	a4,8(a4) # 800088f0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	ff87b783          	ld	a5,-8(a5) # 800088e8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	22c98993          	addi	s3,s3,556 # 80010b28 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fe448493          	addi	s1,s1,-28 # 800088e8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fe490913          	addi	s2,s2,-28 # 800088f0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	a0a080e7          	jalr	-1526(ra) # 80002326 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1f648493          	addi	s1,s1,502 # 80010b28 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	fae7b523          	sd	a4,-86(a5) # 800088f0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	452080e7          	jalr	1106(ra) # 80000daa <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	16c48493          	addi	s1,s1,364 # 80010b28 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	330080e7          	jalr	816(ra) # 80000cf6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	3d2080e7          	jalr	978(ra) # 80000daa <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <incpgref>:
  }
  return (void*)r;
}

void incpgref(void* pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	1000                	addi	s0,sp,32
    800009f4:	84aa                	mv	s1,a0
  acquire(&pgref.lock);
    800009f6:	00010517          	auipc	a0,0x10
    800009fa:	18a50513          	addi	a0,a0,394 # 80010b80 <pgref>
    800009fe:	00000097          	auipc	ra,0x0
    80000a02:	2f8080e7          	jalr	760(ra) # 80000cf6 <acquire>
  if(pgref.count[(uint64)pa >> 12] < 0)
    80000a06:	00c4d793          	srli	a5,s1,0xc
    80000a0a:	00478713          	addi	a4,a5,4
    80000a0e:	00271693          	slli	a3,a4,0x2
    80000a12:	00010717          	auipc	a4,0x10
    80000a16:	16e70713          	addi	a4,a4,366 # 80010b80 <pgref>
    80000a1a:	9736                	add	a4,a4,a3
    80000a1c:	4718                	lw	a4,8(a4)
    80000a1e:	02074463          	bltz	a4,80000a46 <incpgref+0x5c>
    panic("incpgref");
  pgref.count[(uint64)pa >> 12]++;
    80000a22:	00010517          	auipc	a0,0x10
    80000a26:	15e50513          	addi	a0,a0,350 # 80010b80 <pgref>
    80000a2a:	0791                	addi	a5,a5,4
    80000a2c:	078a                	slli	a5,a5,0x2
    80000a2e:	97aa                	add	a5,a5,a0
    80000a30:	2705                	addiw	a4,a4,1
    80000a32:	c798                	sw	a4,8(a5)
  release(&pgref.lock);
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	376080e7          	jalr	886(ra) # 80000daa <release>
}
    80000a3c:	60e2                	ld	ra,24(sp)
    80000a3e:	6442                	ld	s0,16(sp)
    80000a40:	64a2                	ld	s1,8(sp)
    80000a42:	6105                	addi	sp,sp,32
    80000a44:	8082                	ret
    panic("incpgref");
    80000a46:	00007517          	auipc	a0,0x7
    80000a4a:	61a50513          	addi	a0,a0,1562 # 80008060 <digits+0x20>
    80000a4e:	00000097          	auipc	ra,0x0
    80000a52:	af0080e7          	jalr	-1296(ra) # 8000053e <panic>

0000000080000a56 <kalloc>:
{
    80000a56:	1101                	addi	sp,sp,-32
    80000a58:	ec06                	sd	ra,24(sp)
    80000a5a:	e822                	sd	s0,16(sp)
    80000a5c:	e426                	sd	s1,8(sp)
    80000a5e:	1000                	addi	s0,sp,32
  acquire(&kmem.lock);
    80000a60:	00010497          	auipc	s1,0x10
    80000a64:	10048493          	addi	s1,s1,256 # 80010b60 <kmem>
    80000a68:	8526                	mv	a0,s1
    80000a6a:	00000097          	auipc	ra,0x0
    80000a6e:	28c080e7          	jalr	652(ra) # 80000cf6 <acquire>
  r = kmem.freelist;
    80000a72:	6c84                	ld	s1,24(s1)
  if(r)
    80000a74:	cc8d                	beqz	s1,80000aae <kalloc+0x58>
    kmem.freelist = r->next;
    80000a76:	609c                	ld	a5,0(s1)
    80000a78:	00010517          	auipc	a0,0x10
    80000a7c:	0e850513          	addi	a0,a0,232 # 80010b60 <kmem>
    80000a80:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000a82:	00000097          	auipc	ra,0x0
    80000a86:	328080e7          	jalr	808(ra) # 80000daa <release>
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4595                	li	a1,5
    80000a8e:	8526                	mv	a0,s1
    80000a90:	00000097          	auipc	ra,0x0
    80000a94:	362080e7          	jalr	866(ra) # 80000df2 <memset>
    incpgref((void*)r);
    80000a98:	8526                	mv	a0,s1
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	f50080e7          	jalr	-176(ra) # 800009ea <incpgref>
}
    80000aa2:	8526                	mv	a0,s1
    80000aa4:	60e2                	ld	ra,24(sp)
    80000aa6:	6442                	ld	s0,16(sp)
    80000aa8:	64a2                	ld	s1,8(sp)
    80000aaa:	6105                	addi	sp,sp,32
    80000aac:	8082                	ret
  release(&kmem.lock);
    80000aae:	00010517          	auipc	a0,0x10
    80000ab2:	0b250513          	addi	a0,a0,178 # 80010b60 <kmem>
    80000ab6:	00000097          	auipc	ra,0x0
    80000aba:	2f4080e7          	jalr	756(ra) # 80000daa <release>
  if(r)
    80000abe:	b7d5                	j	80000aa2 <kalloc+0x4c>

0000000080000ac0 <decpgref>:

int decpgref(void* pa)
{
    80000ac0:	1101                	addi	sp,sp,-32
    80000ac2:	ec06                	sd	ra,24(sp)
    80000ac4:	e822                	sd	s0,16(sp)
    80000ac6:	e426                	sd	s1,8(sp)
    80000ac8:	1000                	addi	s0,sp,32
    80000aca:	84aa                	mv	s1,a0
  acquire(&pgref.lock);
    80000acc:	00010517          	auipc	a0,0x10
    80000ad0:	0b450513          	addi	a0,a0,180 # 80010b80 <pgref>
    80000ad4:	00000097          	auipc	ra,0x0
    80000ad8:	222080e7          	jalr	546(ra) # 80000cf6 <acquire>
  if(pgref.count[(uint64)pa >> 12] <= 0)
    80000adc:	00c4d513          	srli	a0,s1,0xc
    80000ae0:	00450793          	addi	a5,a0,4
    80000ae4:	00279713          	slli	a4,a5,0x2
    80000ae8:	00010797          	auipc	a5,0x10
    80000aec:	09878793          	addi	a5,a5,152 # 80010b80 <pgref>
    80000af0:	97ba                	add	a5,a5,a4
    80000af2:	479c                	lw	a5,8(a5)
    80000af4:	02f05d63          	blez	a5,80000b2e <decpgref+0x6e>
    panic("decpgref");
  pgref.count[(uint64)pa >> 12]--;
    80000af8:	37fd                	addiw	a5,a5,-1
    80000afa:	0007869b          	sext.w	a3,a5
    80000afe:	0511                	addi	a0,a0,4
    80000b00:	050a                	slli	a0,a0,0x2
    80000b02:	00010717          	auipc	a4,0x10
    80000b06:	07e70713          	addi	a4,a4,126 # 80010b80 <pgref>
    80000b0a:	953a                	add	a0,a0,a4
    80000b0c:	c51c                	sw	a5,8(a0)
  if(pgref.count[(uint64)pa >> 12] > 0)
    80000b0e:	02d04863          	bgtz	a3,80000b3e <decpgref+0x7e>
  {
    release(&pgref.lock);
    return 0;
  }
  release(&pgref.lock);
    80000b12:	00010517          	auipc	a0,0x10
    80000b16:	06e50513          	addi	a0,a0,110 # 80010b80 <pgref>
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	290080e7          	jalr	656(ra) # 80000daa <release>
  return 1;
    80000b22:	4505                	li	a0,1
}
    80000b24:	60e2                	ld	ra,24(sp)
    80000b26:	6442                	ld	s0,16(sp)
    80000b28:	64a2                	ld	s1,8(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret
    panic("decpgref");
    80000b2e:	00007517          	auipc	a0,0x7
    80000b32:	54250513          	addi	a0,a0,1346 # 80008070 <digits+0x30>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	a08080e7          	jalr	-1528(ra) # 8000053e <panic>
    release(&pgref.lock);
    80000b3e:	853a                	mv	a0,a4
    80000b40:	00000097          	auipc	ra,0x0
    80000b44:	26a080e7          	jalr	618(ra) # 80000daa <release>
    return 0;
    80000b48:	4501                	li	a0,0
    80000b4a:	bfe9                	j	80000b24 <decpgref+0x64>

0000000080000b4c <kfree>:
{
    80000b4c:	1101                	addi	sp,sp,-32
    80000b4e:	ec06                	sd	ra,24(sp)
    80000b50:	e822                	sd	s0,16(sp)
    80000b52:	e426                	sd	s1,8(sp)
    80000b54:	e04a                	sd	s2,0(sp)
    80000b56:	1000                	addi	s0,sp,32
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000b58:	03451793          	slli	a5,a0,0x34
    80000b5c:	e79d                	bnez	a5,80000b8a <kfree+0x3e>
    80000b5e:	84aa                	mv	s1,a0
    80000b60:	00242797          	auipc	a5,0x242
    80000b64:	c4878793          	addi	a5,a5,-952 # 802427a8 <end>
    80000b68:	02f56163          	bltu	a0,a5,80000b8a <kfree+0x3e>
    80000b6c:	47c5                	li	a5,17
    80000b6e:	07ee                	slli	a5,a5,0x1b
    80000b70:	00f57d63          	bgeu	a0,a5,80000b8a <kfree+0x3e>
  if(!decpgref(pa))
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	f4c080e7          	jalr	-180(ra) # 80000ac0 <decpgref>
    80000b7c:	ed19                	bnez	a0,80000b9a <kfree+0x4e>
}
    80000b7e:	60e2                	ld	ra,24(sp)
    80000b80:	6442                	ld	s0,16(sp)
    80000b82:	64a2                	ld	s1,8(sp)
    80000b84:	6902                	ld	s2,0(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret
    panic("kfree");
    80000b8a:	00007517          	auipc	a0,0x7
    80000b8e:	4f650513          	addi	a0,a0,1270 # 80008080 <digits+0x40>
    80000b92:	00000097          	auipc	ra,0x0
    80000b96:	9ac080e7          	jalr	-1620(ra) # 8000053e <panic>
  memset(pa, 1, PGSIZE);
    80000b9a:	6605                	lui	a2,0x1
    80000b9c:	4585                	li	a1,1
    80000b9e:	8526                	mv	a0,s1
    80000ba0:	00000097          	auipc	ra,0x0
    80000ba4:	252080e7          	jalr	594(ra) # 80000df2 <memset>
  acquire(&kmem.lock);
    80000ba8:	00010917          	auipc	s2,0x10
    80000bac:	fb890913          	addi	s2,s2,-72 # 80010b60 <kmem>
    80000bb0:	854a                	mv	a0,s2
    80000bb2:	00000097          	auipc	ra,0x0
    80000bb6:	144080e7          	jalr	324(ra) # 80000cf6 <acquire>
  r->next = kmem.freelist;
    80000bba:	01893783          	ld	a5,24(s2)
    80000bbe:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000bc0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000bc4:	854a                	mv	a0,s2
    80000bc6:	00000097          	auipc	ra,0x0
    80000bca:	1e4080e7          	jalr	484(ra) # 80000daa <release>
    80000bce:	bf45                	j	80000b7e <kfree+0x32>

0000000080000bd0 <freerange>:
{
    80000bd0:	7139                	addi	sp,sp,-64
    80000bd2:	fc06                	sd	ra,56(sp)
    80000bd4:	f822                	sd	s0,48(sp)
    80000bd6:	f426                	sd	s1,40(sp)
    80000bd8:	f04a                	sd	s2,32(sp)
    80000bda:	ec4e                	sd	s3,24(sp)
    80000bdc:	e852                	sd	s4,16(sp)
    80000bde:	e456                	sd	s5,8(sp)
    80000be0:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000be2:	6785                	lui	a5,0x1
    80000be4:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000be8:	94aa                	add	s1,s1,a0
    80000bea:	757d                	lui	a0,0xfffff
    80000bec:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000bee:	94be                	add	s1,s1,a5
    80000bf0:	0295e463          	bltu	a1,s1,80000c18 <freerange+0x48>
    80000bf4:	89ae                	mv	s3,a1
    80000bf6:	7afd                	lui	s5,0xfffff
    80000bf8:	6a05                	lui	s4,0x1
    80000bfa:	01548933          	add	s2,s1,s5
    incpgref(p);
    80000bfe:	854a                	mv	a0,s2
    80000c00:	00000097          	auipc	ra,0x0
    80000c04:	dea080e7          	jalr	-534(ra) # 800009ea <incpgref>
    kfree(p);
    80000c08:	854a                	mv	a0,s2
    80000c0a:	00000097          	auipc	ra,0x0
    80000c0e:	f42080e7          	jalr	-190(ra) # 80000b4c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000c12:	94d2                	add	s1,s1,s4
    80000c14:	fe99f3e3          	bgeu	s3,s1,80000bfa <freerange+0x2a>
}
    80000c18:	70e2                	ld	ra,56(sp)
    80000c1a:	7442                	ld	s0,48(sp)
    80000c1c:	74a2                	ld	s1,40(sp)
    80000c1e:	7902                	ld	s2,32(sp)
    80000c20:	69e2                	ld	s3,24(sp)
    80000c22:	6a42                	ld	s4,16(sp)
    80000c24:	6aa2                	ld	s5,8(sp)
    80000c26:	6121                	addi	sp,sp,64
    80000c28:	8082                	ret

0000000080000c2a <kinit>:
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000c32:	00007597          	auipc	a1,0x7
    80000c36:	45658593          	addi	a1,a1,1110 # 80008088 <digits+0x48>
    80000c3a:	00010517          	auipc	a0,0x10
    80000c3e:	f2650513          	addi	a0,a0,-218 # 80010b60 <kmem>
    80000c42:	00000097          	auipc	ra,0x0
    80000c46:	024080e7          	jalr	36(ra) # 80000c66 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000c4a:	45c5                	li	a1,17
    80000c4c:	05ee                	slli	a1,a1,0x1b
    80000c4e:	00242517          	auipc	a0,0x242
    80000c52:	b5a50513          	addi	a0,a0,-1190 # 802427a8 <end>
    80000c56:	00000097          	auipc	ra,0x0
    80000c5a:	f7a080e7          	jalr	-134(ra) # 80000bd0 <freerange>
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret

0000000080000c66 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c66:	1141                	addi	sp,sp,-16
    80000c68:	e422                	sd	s0,8(sp)
    80000c6a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c6c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c6e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c72:	00053823          	sd	zero,16(a0)
}
    80000c76:	6422                	ld	s0,8(sp)
    80000c78:	0141                	addi	sp,sp,16
    80000c7a:	8082                	ret

0000000080000c7c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c7c:	411c                	lw	a5,0(a0)
    80000c7e:	e399                	bnez	a5,80000c84 <holding+0x8>
    80000c80:	4501                	li	a0,0
  return r;
}
    80000c82:	8082                	ret
{
    80000c84:	1101                	addi	sp,sp,-32
    80000c86:	ec06                	sd	ra,24(sp)
    80000c88:	e822                	sd	s0,16(sp)
    80000c8a:	e426                	sd	s1,8(sp)
    80000c8c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c8e:	6904                	ld	s1,16(a0)
    80000c90:	00001097          	auipc	ra,0x1
    80000c94:	e62080e7          	jalr	-414(ra) # 80001af2 <mycpu>
    80000c98:	40a48533          	sub	a0,s1,a0
    80000c9c:	00153513          	seqz	a0,a0
}
    80000ca0:	60e2                	ld	ra,24(sp)
    80000ca2:	6442                	ld	s0,16(sp)
    80000ca4:	64a2                	ld	s1,8(sp)
    80000ca6:	6105                	addi	sp,sp,32
    80000ca8:	8082                	ret

0000000080000caa <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000caa:	1101                	addi	sp,sp,-32
    80000cac:	ec06                	sd	ra,24(sp)
    80000cae:	e822                	sd	s0,16(sp)
    80000cb0:	e426                	sd	s1,8(sp)
    80000cb2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb4:	100024f3          	csrr	s1,sstatus
    80000cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cbc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cbe:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000cc2:	00001097          	auipc	ra,0x1
    80000cc6:	e30080e7          	jalr	-464(ra) # 80001af2 <mycpu>
    80000cca:	5d3c                	lw	a5,120(a0)
    80000ccc:	cf89                	beqz	a5,80000ce6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cce:	00001097          	auipc	ra,0x1
    80000cd2:	e24080e7          	jalr	-476(ra) # 80001af2 <mycpu>
    80000cd6:	5d3c                	lw	a5,120(a0)
    80000cd8:	2785                	addiw	a5,a5,1
    80000cda:	dd3c                	sw	a5,120(a0)
}
    80000cdc:	60e2                	ld	ra,24(sp)
    80000cde:	6442                	ld	s0,16(sp)
    80000ce0:	64a2                	ld	s1,8(sp)
    80000ce2:	6105                	addi	sp,sp,32
    80000ce4:	8082                	ret
    mycpu()->intena = old;
    80000ce6:	00001097          	auipc	ra,0x1
    80000cea:	e0c080e7          	jalr	-500(ra) # 80001af2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cee:	8085                	srli	s1,s1,0x1
    80000cf0:	8885                	andi	s1,s1,1
    80000cf2:	dd64                	sw	s1,124(a0)
    80000cf4:	bfe9                	j	80000cce <push_off+0x24>

0000000080000cf6 <acquire>:
{
    80000cf6:	1101                	addi	sp,sp,-32
    80000cf8:	ec06                	sd	ra,24(sp)
    80000cfa:	e822                	sd	s0,16(sp)
    80000cfc:	e426                	sd	s1,8(sp)
    80000cfe:	1000                	addi	s0,sp,32
    80000d00:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d02:	00000097          	auipc	ra,0x0
    80000d06:	fa8080e7          	jalr	-88(ra) # 80000caa <push_off>
  if(holding(lk))
    80000d0a:	8526                	mv	a0,s1
    80000d0c:	00000097          	auipc	ra,0x0
    80000d10:	f70080e7          	jalr	-144(ra) # 80000c7c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d14:	4705                	li	a4,1
  if(holding(lk))
    80000d16:	e115                	bnez	a0,80000d3a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d18:	87ba                	mv	a5,a4
    80000d1a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d1e:	2781                	sext.w	a5,a5
    80000d20:	ffe5                	bnez	a5,80000d18 <acquire+0x22>
  __sync_synchronize();
    80000d22:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d26:	00001097          	auipc	ra,0x1
    80000d2a:	dcc080e7          	jalr	-564(ra) # 80001af2 <mycpu>
    80000d2e:	e888                	sd	a0,16(s1)
}
    80000d30:	60e2                	ld	ra,24(sp)
    80000d32:	6442                	ld	s0,16(sp)
    80000d34:	64a2                	ld	s1,8(sp)
    80000d36:	6105                	addi	sp,sp,32
    80000d38:	8082                	ret
    panic("acquire");
    80000d3a:	00007517          	auipc	a0,0x7
    80000d3e:	35650513          	addi	a0,a0,854 # 80008090 <digits+0x50>
    80000d42:	fffff097          	auipc	ra,0xfffff
    80000d46:	7fc080e7          	jalr	2044(ra) # 8000053e <panic>

0000000080000d4a <pop_off>:

void
pop_off(void)
{
    80000d4a:	1141                	addi	sp,sp,-16
    80000d4c:	e406                	sd	ra,8(sp)
    80000d4e:	e022                	sd	s0,0(sp)
    80000d50:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d52:	00001097          	auipc	ra,0x1
    80000d56:	da0080e7          	jalr	-608(ra) # 80001af2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d5a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d5e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d60:	e78d                	bnez	a5,80000d8a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d62:	5d3c                	lw	a5,120(a0)
    80000d64:	02f05b63          	blez	a5,80000d9a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d68:	37fd                	addiw	a5,a5,-1
    80000d6a:	0007871b          	sext.w	a4,a5
    80000d6e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d70:	eb09                	bnez	a4,80000d82 <pop_off+0x38>
    80000d72:	5d7c                	lw	a5,124(a0)
    80000d74:	c799                	beqz	a5,80000d82 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d76:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d7a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d7e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d82:	60a2                	ld	ra,8(sp)
    80000d84:	6402                	ld	s0,0(sp)
    80000d86:	0141                	addi	sp,sp,16
    80000d88:	8082                	ret
    panic("pop_off - interruptible");
    80000d8a:	00007517          	auipc	a0,0x7
    80000d8e:	30e50513          	addi	a0,a0,782 # 80008098 <digits+0x58>
    80000d92:	fffff097          	auipc	ra,0xfffff
    80000d96:	7ac080e7          	jalr	1964(ra) # 8000053e <panic>
    panic("pop_off");
    80000d9a:	00007517          	auipc	a0,0x7
    80000d9e:	31650513          	addi	a0,a0,790 # 800080b0 <digits+0x70>
    80000da2:	fffff097          	auipc	ra,0xfffff
    80000da6:	79c080e7          	jalr	1948(ra) # 8000053e <panic>

0000000080000daa <release>:
{
    80000daa:	1101                	addi	sp,sp,-32
    80000dac:	ec06                	sd	ra,24(sp)
    80000dae:	e822                	sd	s0,16(sp)
    80000db0:	e426                	sd	s1,8(sp)
    80000db2:	1000                	addi	s0,sp,32
    80000db4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000db6:	00000097          	auipc	ra,0x0
    80000dba:	ec6080e7          	jalr	-314(ra) # 80000c7c <holding>
    80000dbe:	c115                	beqz	a0,80000de2 <release+0x38>
  lk->cpu = 0;
    80000dc0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000dc4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000dc8:	0f50000f          	fence	iorw,ow
    80000dcc:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000dd0:	00000097          	auipc	ra,0x0
    80000dd4:	f7a080e7          	jalr	-134(ra) # 80000d4a <pop_off>
}
    80000dd8:	60e2                	ld	ra,24(sp)
    80000dda:	6442                	ld	s0,16(sp)
    80000ddc:	64a2                	ld	s1,8(sp)
    80000dde:	6105                	addi	sp,sp,32
    80000de0:	8082                	ret
    panic("release");
    80000de2:	00007517          	auipc	a0,0x7
    80000de6:	2d650513          	addi	a0,a0,726 # 800080b8 <digits+0x78>
    80000dea:	fffff097          	auipc	ra,0xfffff
    80000dee:	754080e7          	jalr	1876(ra) # 8000053e <panic>

0000000080000df2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000df2:	1141                	addi	sp,sp,-16
    80000df4:	e422                	sd	s0,8(sp)
    80000df6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000df8:	ca19                	beqz	a2,80000e0e <memset+0x1c>
    80000dfa:	87aa                	mv	a5,a0
    80000dfc:	1602                	slli	a2,a2,0x20
    80000dfe:	9201                	srli	a2,a2,0x20
    80000e00:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e04:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e08:	0785                	addi	a5,a5,1
    80000e0a:	fee79de3          	bne	a5,a4,80000e04 <memset+0x12>
  }
  return dst;
}
    80000e0e:	6422                	ld	s0,8(sp)
    80000e10:	0141                	addi	sp,sp,16
    80000e12:	8082                	ret

0000000080000e14 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e14:	1141                	addi	sp,sp,-16
    80000e16:	e422                	sd	s0,8(sp)
    80000e18:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e1a:	ca05                	beqz	a2,80000e4a <memcmp+0x36>
    80000e1c:	fff6069b          	addiw	a3,a2,-1
    80000e20:	1682                	slli	a3,a3,0x20
    80000e22:	9281                	srli	a3,a3,0x20
    80000e24:	0685                	addi	a3,a3,1
    80000e26:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e28:	00054783          	lbu	a5,0(a0)
    80000e2c:	0005c703          	lbu	a4,0(a1)
    80000e30:	00e79863          	bne	a5,a4,80000e40 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e34:	0505                	addi	a0,a0,1
    80000e36:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e38:	fed518e3          	bne	a0,a3,80000e28 <memcmp+0x14>
  }

  return 0;
    80000e3c:	4501                	li	a0,0
    80000e3e:	a019                	j	80000e44 <memcmp+0x30>
      return *s1 - *s2;
    80000e40:	40e7853b          	subw	a0,a5,a4
}
    80000e44:	6422                	ld	s0,8(sp)
    80000e46:	0141                	addi	sp,sp,16
    80000e48:	8082                	ret
  return 0;
    80000e4a:	4501                	li	a0,0
    80000e4c:	bfe5                	j	80000e44 <memcmp+0x30>

0000000080000e4e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e54:	c205                	beqz	a2,80000e74 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e56:	02a5e263          	bltu	a1,a0,80000e7a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e5a:	1602                	slli	a2,a2,0x20
    80000e5c:	9201                	srli	a2,a2,0x20
    80000e5e:	00c587b3          	add	a5,a1,a2
{
    80000e62:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e64:	0585                	addi	a1,a1,1
    80000e66:	0705                	addi	a4,a4,1
    80000e68:	fff5c683          	lbu	a3,-1(a1)
    80000e6c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e70:	fef59ae3          	bne	a1,a5,80000e64 <memmove+0x16>

  return dst;
}
    80000e74:	6422                	ld	s0,8(sp)
    80000e76:	0141                	addi	sp,sp,16
    80000e78:	8082                	ret
  if(s < d && s + n > d){
    80000e7a:	02061693          	slli	a3,a2,0x20
    80000e7e:	9281                	srli	a3,a3,0x20
    80000e80:	00d58733          	add	a4,a1,a3
    80000e84:	fce57be3          	bgeu	a0,a4,80000e5a <memmove+0xc>
    d += n;
    80000e88:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e8a:	fff6079b          	addiw	a5,a2,-1
    80000e8e:	1782                	slli	a5,a5,0x20
    80000e90:	9381                	srli	a5,a5,0x20
    80000e92:	fff7c793          	not	a5,a5
    80000e96:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e98:	177d                	addi	a4,a4,-1
    80000e9a:	16fd                	addi	a3,a3,-1
    80000e9c:	00074603          	lbu	a2,0(a4)
    80000ea0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000ea4:	fee79ae3          	bne	a5,a4,80000e98 <memmove+0x4a>
    80000ea8:	b7f1                	j	80000e74 <memmove+0x26>

0000000080000eaa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000eaa:	1141                	addi	sp,sp,-16
    80000eac:	e406                	sd	ra,8(sp)
    80000eae:	e022                	sd	s0,0(sp)
    80000eb0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000eb2:	00000097          	auipc	ra,0x0
    80000eb6:	f9c080e7          	jalr	-100(ra) # 80000e4e <memmove>
}
    80000eba:	60a2                	ld	ra,8(sp)
    80000ebc:	6402                	ld	s0,0(sp)
    80000ebe:	0141                	addi	sp,sp,16
    80000ec0:	8082                	ret

0000000080000ec2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ec2:	1141                	addi	sp,sp,-16
    80000ec4:	e422                	sd	s0,8(sp)
    80000ec6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ec8:	ce11                	beqz	a2,80000ee4 <strncmp+0x22>
    80000eca:	00054783          	lbu	a5,0(a0)
    80000ece:	cf89                	beqz	a5,80000ee8 <strncmp+0x26>
    80000ed0:	0005c703          	lbu	a4,0(a1)
    80000ed4:	00f71a63          	bne	a4,a5,80000ee8 <strncmp+0x26>
    n--, p++, q++;
    80000ed8:	367d                	addiw	a2,a2,-1
    80000eda:	0505                	addi	a0,a0,1
    80000edc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ede:	f675                	bnez	a2,80000eca <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ee0:	4501                	li	a0,0
    80000ee2:	a809                	j	80000ef4 <strncmp+0x32>
    80000ee4:	4501                	li	a0,0
    80000ee6:	a039                	j	80000ef4 <strncmp+0x32>
  if(n == 0)
    80000ee8:	ca09                	beqz	a2,80000efa <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000eea:	00054503          	lbu	a0,0(a0)
    80000eee:	0005c783          	lbu	a5,0(a1)
    80000ef2:	9d1d                	subw	a0,a0,a5
}
    80000ef4:	6422                	ld	s0,8(sp)
    80000ef6:	0141                	addi	sp,sp,16
    80000ef8:	8082                	ret
    return 0;
    80000efa:	4501                	li	a0,0
    80000efc:	bfe5                	j	80000ef4 <strncmp+0x32>

0000000080000efe <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000efe:	1141                	addi	sp,sp,-16
    80000f00:	e422                	sd	s0,8(sp)
    80000f02:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f04:	872a                	mv	a4,a0
    80000f06:	8832                	mv	a6,a2
    80000f08:	367d                	addiw	a2,a2,-1
    80000f0a:	01005963          	blez	a6,80000f1c <strncpy+0x1e>
    80000f0e:	0705                	addi	a4,a4,1
    80000f10:	0005c783          	lbu	a5,0(a1)
    80000f14:	fef70fa3          	sb	a5,-1(a4)
    80000f18:	0585                	addi	a1,a1,1
    80000f1a:	f7f5                	bnez	a5,80000f06 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f1c:	86ba                	mv	a3,a4
    80000f1e:	00c05c63          	blez	a2,80000f36 <strncpy+0x38>
    *s++ = 0;
    80000f22:	0685                	addi	a3,a3,1
    80000f24:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f28:	fff6c793          	not	a5,a3
    80000f2c:	9fb9                	addw	a5,a5,a4
    80000f2e:	010787bb          	addw	a5,a5,a6
    80000f32:	fef048e3          	bgtz	a5,80000f22 <strncpy+0x24>
  return os;
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f3c:	1141                	addi	sp,sp,-16
    80000f3e:	e422                	sd	s0,8(sp)
    80000f40:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f42:	02c05363          	blez	a2,80000f68 <safestrcpy+0x2c>
    80000f46:	fff6069b          	addiw	a3,a2,-1
    80000f4a:	1682                	slli	a3,a3,0x20
    80000f4c:	9281                	srli	a3,a3,0x20
    80000f4e:	96ae                	add	a3,a3,a1
    80000f50:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f52:	00d58963          	beq	a1,a3,80000f64 <safestrcpy+0x28>
    80000f56:	0585                	addi	a1,a1,1
    80000f58:	0785                	addi	a5,a5,1
    80000f5a:	fff5c703          	lbu	a4,-1(a1)
    80000f5e:	fee78fa3          	sb	a4,-1(a5)
    80000f62:	fb65                	bnez	a4,80000f52 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f64:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f68:	6422                	ld	s0,8(sp)
    80000f6a:	0141                	addi	sp,sp,16
    80000f6c:	8082                	ret

0000000080000f6e <strlen>:

int
strlen(const char *s)
{
    80000f6e:	1141                	addi	sp,sp,-16
    80000f70:	e422                	sd	s0,8(sp)
    80000f72:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f74:	00054783          	lbu	a5,0(a0)
    80000f78:	cf91                	beqz	a5,80000f94 <strlen+0x26>
    80000f7a:	0505                	addi	a0,a0,1
    80000f7c:	87aa                	mv	a5,a0
    80000f7e:	4685                	li	a3,1
    80000f80:	9e89                	subw	a3,a3,a0
    80000f82:	00f6853b          	addw	a0,a3,a5
    80000f86:	0785                	addi	a5,a5,1
    80000f88:	fff7c703          	lbu	a4,-1(a5)
    80000f8c:	fb7d                	bnez	a4,80000f82 <strlen+0x14>
    ;
  return n;
}
    80000f8e:	6422                	ld	s0,8(sp)
    80000f90:	0141                	addi	sp,sp,16
    80000f92:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f94:	4501                	li	a0,0
    80000f96:	bfe5                	j	80000f8e <strlen+0x20>

0000000080000f98 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f98:	1141                	addi	sp,sp,-16
    80000f9a:	e406                	sd	ra,8(sp)
    80000f9c:	e022                	sd	s0,0(sp)
    80000f9e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fa0:	00001097          	auipc	ra,0x1
    80000fa4:	b42080e7          	jalr	-1214(ra) # 80001ae2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fa8:	00008717          	auipc	a4,0x8
    80000fac:	95070713          	addi	a4,a4,-1712 # 800088f8 <started>
  if(cpuid() == 0){
    80000fb0:	c139                	beqz	a0,80000ff6 <main+0x5e>
    while(started == 0)
    80000fb2:	431c                	lw	a5,0(a4)
    80000fb4:	2781                	sext.w	a5,a5
    80000fb6:	dff5                	beqz	a5,80000fb2 <main+0x1a>
      ;
    __sync_synchronize();
    80000fb8:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fbc:	00001097          	auipc	ra,0x1
    80000fc0:	b26080e7          	jalr	-1242(ra) # 80001ae2 <cpuid>
    80000fc4:	85aa                	mv	a1,a0
    80000fc6:	00007517          	auipc	a0,0x7
    80000fca:	11250513          	addi	a0,a0,274 # 800080d8 <digits+0x98>
    80000fce:	fffff097          	auipc	ra,0xfffff
    80000fd2:	5ba080e7          	jalr	1466(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000fd6:	00000097          	auipc	ra,0x0
    80000fda:	0d8080e7          	jalr	216(ra) # 800010ae <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fde:	00002097          	auipc	ra,0x2
    80000fe2:	b26080e7          	jalr	-1242(ra) # 80002b04 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fe6:	00005097          	auipc	ra,0x5
    80000fea:	30a080e7          	jalr	778(ra) # 800062f0 <plicinithart>
  }

  scheduler();        
    80000fee:	00001097          	auipc	ra,0x1
    80000ff2:	050080e7          	jalr	80(ra) # 8000203e <scheduler>
    consoleinit();
    80000ff6:	fffff097          	auipc	ra,0xfffff
    80000ffa:	45a080e7          	jalr	1114(ra) # 80000450 <consoleinit>
    printfinit();
    80000ffe:	fffff097          	auipc	ra,0xfffff
    80001002:	76a080e7          	jalr	1898(ra) # 80000768 <printfinit>
    printf("\n");
    80001006:	00007517          	auipc	a0,0x7
    8000100a:	0e250513          	addi	a0,a0,226 # 800080e8 <digits+0xa8>
    8000100e:	fffff097          	auipc	ra,0xfffff
    80001012:	57a080e7          	jalr	1402(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80001016:	00007517          	auipc	a0,0x7
    8000101a:	0aa50513          	addi	a0,a0,170 # 800080c0 <digits+0x80>
    8000101e:	fffff097          	auipc	ra,0xfffff
    80001022:	56a080e7          	jalr	1386(ra) # 80000588 <printf>
    printf("\n");
    80001026:	00007517          	auipc	a0,0x7
    8000102a:	0c250513          	addi	a0,a0,194 # 800080e8 <digits+0xa8>
    8000102e:	fffff097          	auipc	ra,0xfffff
    80001032:	55a080e7          	jalr	1370(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80001036:	00000097          	auipc	ra,0x0
    8000103a:	bf4080e7          	jalr	-1036(ra) # 80000c2a <kinit>
    kvminit();       // create kernel page table
    8000103e:	00000097          	auipc	ra,0x0
    80001042:	326080e7          	jalr	806(ra) # 80001364 <kvminit>
    kvminithart();   // turn on paging
    80001046:	00000097          	auipc	ra,0x0
    8000104a:	068080e7          	jalr	104(ra) # 800010ae <kvminithart>
    procinit();      // process table
    8000104e:	00001097          	auipc	ra,0x1
    80001052:	9e0080e7          	jalr	-1568(ra) # 80001a2e <procinit>
    trapinit();      // trap vectors
    80001056:	00002097          	auipc	ra,0x2
    8000105a:	a86080e7          	jalr	-1402(ra) # 80002adc <trapinit>
    trapinithart();  // install kernel trap vector
    8000105e:	00002097          	auipc	ra,0x2
    80001062:	aa6080e7          	jalr	-1370(ra) # 80002b04 <trapinithart>
    plicinit();      // set up interrupt controller
    80001066:	00005097          	auipc	ra,0x5
    8000106a:	274080e7          	jalr	628(ra) # 800062da <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000106e:	00005097          	auipc	ra,0x5
    80001072:	282080e7          	jalr	642(ra) # 800062f0 <plicinithart>
    binit();         // buffer cache
    80001076:	00002097          	auipc	ra,0x2
    8000107a:	3fc080e7          	jalr	1020(ra) # 80003472 <binit>
    iinit();         // inode table
    8000107e:	00003097          	auipc	ra,0x3
    80001082:	aa0080e7          	jalr	-1376(ra) # 80003b1e <iinit>
    fileinit();      // file table
    80001086:	00004097          	auipc	ra,0x4
    8000108a:	a3e080e7          	jalr	-1474(ra) # 80004ac4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000108e:	00005097          	auipc	ra,0x5
    80001092:	36a080e7          	jalr	874(ra) # 800063f8 <virtio_disk_init>
    userinit();      // first user process
    80001096:	00001097          	auipc	ra,0x1
    8000109a:	d8a080e7          	jalr	-630(ra) # 80001e20 <userinit>
    __sync_synchronize();
    8000109e:	0ff0000f          	fence
    started = 1;
    800010a2:	4785                	li	a5,1
    800010a4:	00008717          	auipc	a4,0x8
    800010a8:	84f72a23          	sw	a5,-1964(a4) # 800088f8 <started>
    800010ac:	b789                	j	80000fee <main+0x56>

00000000800010ae <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010ae:	1141                	addi	sp,sp,-16
    800010b0:	e422                	sd	s0,8(sp)
    800010b2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800010b4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800010b8:	00008797          	auipc	a5,0x8
    800010bc:	8487b783          	ld	a5,-1976(a5) # 80008900 <kernel_pagetable>
    800010c0:	83b1                	srli	a5,a5,0xc
    800010c2:	577d                	li	a4,-1
    800010c4:	177e                	slli	a4,a4,0x3f
    800010c6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800010c8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800010cc:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800010d0:	6422                	ld	s0,8(sp)
    800010d2:	0141                	addi	sp,sp,16
    800010d4:	8082                	ret

00000000800010d6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010d6:	7139                	addi	sp,sp,-64
    800010d8:	fc06                	sd	ra,56(sp)
    800010da:	f822                	sd	s0,48(sp)
    800010dc:	f426                	sd	s1,40(sp)
    800010de:	f04a                	sd	s2,32(sp)
    800010e0:	ec4e                	sd	s3,24(sp)
    800010e2:	e852                	sd	s4,16(sp)
    800010e4:	e456                	sd	s5,8(sp)
    800010e6:	e05a                	sd	s6,0(sp)
    800010e8:	0080                	addi	s0,sp,64
    800010ea:	84aa                	mv	s1,a0
    800010ec:	89ae                	mv	s3,a1
    800010ee:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800010f0:	57fd                	li	a5,-1
    800010f2:	83e9                	srli	a5,a5,0x1a
    800010f4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010f6:	4b31                	li	s6,12
  if(va >= MAXVA)
    800010f8:	04b7f263          	bgeu	a5,a1,8000113c <walk+0x66>
    panic("walk");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	ff450513          	addi	a0,a0,-12 # 800080f0 <digits+0xb0>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	43a080e7          	jalr	1082(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000110c:	060a8663          	beqz	s5,80001178 <walk+0xa2>
    80001110:	00000097          	auipc	ra,0x0
    80001114:	946080e7          	jalr	-1722(ra) # 80000a56 <kalloc>
    80001118:	84aa                	mv	s1,a0
    8000111a:	c529                	beqz	a0,80001164 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000111c:	6605                	lui	a2,0x1
    8000111e:	4581                	li	a1,0
    80001120:	00000097          	auipc	ra,0x0
    80001124:	cd2080e7          	jalr	-814(ra) # 80000df2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001128:	00c4d793          	srli	a5,s1,0xc
    8000112c:	07aa                	slli	a5,a5,0xa
    8000112e:	0017e793          	ori	a5,a5,1
    80001132:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001136:	3a5d                	addiw	s4,s4,-9
    80001138:	036a0063          	beq	s4,s6,80001158 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000113c:	0149d933          	srl	s2,s3,s4
    80001140:	1ff97913          	andi	s2,s2,511
    80001144:	090e                	slli	s2,s2,0x3
    80001146:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001148:	00093483          	ld	s1,0(s2)
    8000114c:	0014f793          	andi	a5,s1,1
    80001150:	dfd5                	beqz	a5,8000110c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001152:	80a9                	srli	s1,s1,0xa
    80001154:	04b2                	slli	s1,s1,0xc
    80001156:	b7c5                	j	80001136 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001158:	00c9d513          	srli	a0,s3,0xc
    8000115c:	1ff57513          	andi	a0,a0,511
    80001160:	050e                	slli	a0,a0,0x3
    80001162:	9526                	add	a0,a0,s1
}
    80001164:	70e2                	ld	ra,56(sp)
    80001166:	7442                	ld	s0,48(sp)
    80001168:	74a2                	ld	s1,40(sp)
    8000116a:	7902                	ld	s2,32(sp)
    8000116c:	69e2                	ld	s3,24(sp)
    8000116e:	6a42                	ld	s4,16(sp)
    80001170:	6aa2                	ld	s5,8(sp)
    80001172:	6b02                	ld	s6,0(sp)
    80001174:	6121                	addi	sp,sp,64
    80001176:	8082                	ret
        return 0;
    80001178:	4501                	li	a0,0
    8000117a:	b7ed                	j	80001164 <walk+0x8e>

000000008000117c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000117c:	57fd                	li	a5,-1
    8000117e:	83e9                	srli	a5,a5,0x1a
    80001180:	00b7f463          	bgeu	a5,a1,80001188 <walkaddr+0xc>
    return 0;
    80001184:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001186:	8082                	ret
{
    80001188:	1141                	addi	sp,sp,-16
    8000118a:	e406                	sd	ra,8(sp)
    8000118c:	e022                	sd	s0,0(sp)
    8000118e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001190:	4601                	li	a2,0
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f44080e7          	jalr	-188(ra) # 800010d6 <walk>
  if(pte == 0)
    8000119a:	c105                	beqz	a0,800011ba <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000119c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000119e:	0117f693          	andi	a3,a5,17
    800011a2:	4745                	li	a4,17
    return 0;
    800011a4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011a6:	00e68663          	beq	a3,a4,800011b2 <walkaddr+0x36>
}
    800011aa:	60a2                	ld	ra,8(sp)
    800011ac:	6402                	ld	s0,0(sp)
    800011ae:	0141                	addi	sp,sp,16
    800011b0:	8082                	ret
  pa = PTE2PA(*pte);
    800011b2:	00a7d513          	srli	a0,a5,0xa
    800011b6:	0532                	slli	a0,a0,0xc
  return pa;
    800011b8:	bfcd                	j	800011aa <walkaddr+0x2e>
    return 0;
    800011ba:	4501                	li	a0,0
    800011bc:	b7fd                	j	800011aa <walkaddr+0x2e>

00000000800011be <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011be:	715d                	addi	sp,sp,-80
    800011c0:	e486                	sd	ra,72(sp)
    800011c2:	e0a2                	sd	s0,64(sp)
    800011c4:	fc26                	sd	s1,56(sp)
    800011c6:	f84a                	sd	s2,48(sp)
    800011c8:	f44e                	sd	s3,40(sp)
    800011ca:	f052                	sd	s4,32(sp)
    800011cc:	ec56                	sd	s5,24(sp)
    800011ce:	e85a                	sd	s6,16(sp)
    800011d0:	e45e                	sd	s7,8(sp)
    800011d2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800011d4:	c639                	beqz	a2,80001222 <mappages+0x64>
    800011d6:	8aaa                	mv	s5,a0
    800011d8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800011da:	77fd                	lui	a5,0xfffff
    800011dc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800011e0:	15fd                	addi	a1,a1,-1
    800011e2:	00c589b3          	add	s3,a1,a2
    800011e6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800011ea:	8952                	mv	s2,s4
    800011ec:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011f0:	6b85                	lui	s7,0x1
    800011f2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011f6:	4605                	li	a2,1
    800011f8:	85ca                	mv	a1,s2
    800011fa:	8556                	mv	a0,s5
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	eda080e7          	jalr	-294(ra) # 800010d6 <walk>
    80001204:	cd1d                	beqz	a0,80001242 <mappages+0x84>
    if(*pte & PTE_V)
    80001206:	611c                	ld	a5,0(a0)
    80001208:	8b85                	andi	a5,a5,1
    8000120a:	e785                	bnez	a5,80001232 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000120c:	80b1                	srli	s1,s1,0xc
    8000120e:	04aa                	slli	s1,s1,0xa
    80001210:	0164e4b3          	or	s1,s1,s6
    80001214:	0014e493          	ori	s1,s1,1
    80001218:	e104                	sd	s1,0(a0)
    if(a == last)
    8000121a:	05390063          	beq	s2,s3,8000125a <mappages+0x9c>
    a += PGSIZE;
    8000121e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001220:	bfc9                	j	800011f2 <mappages+0x34>
    panic("mappages: size");
    80001222:	00007517          	auipc	a0,0x7
    80001226:	ed650513          	addi	a0,a0,-298 # 800080f8 <digits+0xb8>
    8000122a:	fffff097          	auipc	ra,0xfffff
    8000122e:	314080e7          	jalr	788(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001232:	00007517          	auipc	a0,0x7
    80001236:	ed650513          	addi	a0,a0,-298 # 80008108 <digits+0xc8>
    8000123a:	fffff097          	auipc	ra,0xfffff
    8000123e:	304080e7          	jalr	772(ra) # 8000053e <panic>
      return -1;
    80001242:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001244:	60a6                	ld	ra,72(sp)
    80001246:	6406                	ld	s0,64(sp)
    80001248:	74e2                	ld	s1,56(sp)
    8000124a:	7942                	ld	s2,48(sp)
    8000124c:	79a2                	ld	s3,40(sp)
    8000124e:	7a02                	ld	s4,32(sp)
    80001250:	6ae2                	ld	s5,24(sp)
    80001252:	6b42                	ld	s6,16(sp)
    80001254:	6ba2                	ld	s7,8(sp)
    80001256:	6161                	addi	sp,sp,80
    80001258:	8082                	ret
  return 0;
    8000125a:	4501                	li	a0,0
    8000125c:	b7e5                	j	80001244 <mappages+0x86>

000000008000125e <kvmmap>:
{
    8000125e:	1141                	addi	sp,sp,-16
    80001260:	e406                	sd	ra,8(sp)
    80001262:	e022                	sd	s0,0(sp)
    80001264:	0800                	addi	s0,sp,16
    80001266:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001268:	86b2                	mv	a3,a2
    8000126a:	863e                	mv	a2,a5
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	f52080e7          	jalr	-174(ra) # 800011be <mappages>
    80001274:	e509                	bnez	a0,8000127e <kvmmap+0x20>
}
    80001276:	60a2                	ld	ra,8(sp)
    80001278:	6402                	ld	s0,0(sp)
    8000127a:	0141                	addi	sp,sp,16
    8000127c:	8082                	ret
    panic("kvmmap");
    8000127e:	00007517          	auipc	a0,0x7
    80001282:	e9a50513          	addi	a0,a0,-358 # 80008118 <digits+0xd8>
    80001286:	fffff097          	auipc	ra,0xfffff
    8000128a:	2b8080e7          	jalr	696(ra) # 8000053e <panic>

000000008000128e <kvmmake>:
{
    8000128e:	1101                	addi	sp,sp,-32
    80001290:	ec06                	sd	ra,24(sp)
    80001292:	e822                	sd	s0,16(sp)
    80001294:	e426                	sd	s1,8(sp)
    80001296:	e04a                	sd	s2,0(sp)
    80001298:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000129a:	fffff097          	auipc	ra,0xfffff
    8000129e:	7bc080e7          	jalr	1980(ra) # 80000a56 <kalloc>
    800012a2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012a4:	6605                	lui	a2,0x1
    800012a6:	4581                	li	a1,0
    800012a8:	00000097          	auipc	ra,0x0
    800012ac:	b4a080e7          	jalr	-1206(ra) # 80000df2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012b0:	4719                	li	a4,6
    800012b2:	6685                	lui	a3,0x1
    800012b4:	10000637          	lui	a2,0x10000
    800012b8:	100005b7          	lui	a1,0x10000
    800012bc:	8526                	mv	a0,s1
    800012be:	00000097          	auipc	ra,0x0
    800012c2:	fa0080e7          	jalr	-96(ra) # 8000125e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012c6:	4719                	li	a4,6
    800012c8:	6685                	lui	a3,0x1
    800012ca:	10001637          	lui	a2,0x10001
    800012ce:	100015b7          	lui	a1,0x10001
    800012d2:	8526                	mv	a0,s1
    800012d4:	00000097          	auipc	ra,0x0
    800012d8:	f8a080e7          	jalr	-118(ra) # 8000125e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012dc:	4719                	li	a4,6
    800012de:	004006b7          	lui	a3,0x400
    800012e2:	0c000637          	lui	a2,0xc000
    800012e6:	0c0005b7          	lui	a1,0xc000
    800012ea:	8526                	mv	a0,s1
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	f72080e7          	jalr	-142(ra) # 8000125e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012f4:	00007917          	auipc	s2,0x7
    800012f8:	d0c90913          	addi	s2,s2,-756 # 80008000 <etext>
    800012fc:	4729                	li	a4,10
    800012fe:	80007697          	auipc	a3,0x80007
    80001302:	d0268693          	addi	a3,a3,-766 # 8000 <_entry-0x7fff8000>
    80001306:	4605                	li	a2,1
    80001308:	067e                	slli	a2,a2,0x1f
    8000130a:	85b2                	mv	a1,a2
    8000130c:	8526                	mv	a0,s1
    8000130e:	00000097          	auipc	ra,0x0
    80001312:	f50080e7          	jalr	-176(ra) # 8000125e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001316:	4719                	li	a4,6
    80001318:	46c5                	li	a3,17
    8000131a:	06ee                	slli	a3,a3,0x1b
    8000131c:	412686b3          	sub	a3,a3,s2
    80001320:	864a                	mv	a2,s2
    80001322:	85ca                	mv	a1,s2
    80001324:	8526                	mv	a0,s1
    80001326:	00000097          	auipc	ra,0x0
    8000132a:	f38080e7          	jalr	-200(ra) # 8000125e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000132e:	4729                	li	a4,10
    80001330:	6685                	lui	a3,0x1
    80001332:	00006617          	auipc	a2,0x6
    80001336:	cce60613          	addi	a2,a2,-818 # 80007000 <_trampoline>
    8000133a:	040005b7          	lui	a1,0x4000
    8000133e:	15fd                	addi	a1,a1,-1
    80001340:	05b2                	slli	a1,a1,0xc
    80001342:	8526                	mv	a0,s1
    80001344:	00000097          	auipc	ra,0x0
    80001348:	f1a080e7          	jalr	-230(ra) # 8000125e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000134c:	8526                	mv	a0,s1
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	64a080e7          	jalr	1610(ra) # 80001998 <proc_mapstacks>
}
    80001356:	8526                	mv	a0,s1
    80001358:	60e2                	ld	ra,24(sp)
    8000135a:	6442                	ld	s0,16(sp)
    8000135c:	64a2                	ld	s1,8(sp)
    8000135e:	6902                	ld	s2,0(sp)
    80001360:	6105                	addi	sp,sp,32
    80001362:	8082                	ret

0000000080001364 <kvminit>:
{
    80001364:	1141                	addi	sp,sp,-16
    80001366:	e406                	sd	ra,8(sp)
    80001368:	e022                	sd	s0,0(sp)
    8000136a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000136c:	00000097          	auipc	ra,0x0
    80001370:	f22080e7          	jalr	-222(ra) # 8000128e <kvmmake>
    80001374:	00007797          	auipc	a5,0x7
    80001378:	58a7b623          	sd	a0,1420(a5) # 80008900 <kernel_pagetable>
}
    8000137c:	60a2                	ld	ra,8(sp)
    8000137e:	6402                	ld	s0,0(sp)
    80001380:	0141                	addi	sp,sp,16
    80001382:	8082                	ret

0000000080001384 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001384:	715d                	addi	sp,sp,-80
    80001386:	e486                	sd	ra,72(sp)
    80001388:	e0a2                	sd	s0,64(sp)
    8000138a:	fc26                	sd	s1,56(sp)
    8000138c:	f84a                	sd	s2,48(sp)
    8000138e:	f44e                	sd	s3,40(sp)
    80001390:	f052                	sd	s4,32(sp)
    80001392:	ec56                	sd	s5,24(sp)
    80001394:	e85a                	sd	s6,16(sp)
    80001396:	e45e                	sd	s7,8(sp)
    80001398:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000139a:	03459793          	slli	a5,a1,0x34
    8000139e:	e795                	bnez	a5,800013ca <uvmunmap+0x46>
    800013a0:	8a2a                	mv	s4,a0
    800013a2:	892e                	mv	s2,a1
    800013a4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013a6:	0632                	slli	a2,a2,0xc
    800013a8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013ac:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013ae:	6b05                	lui	s6,0x1
    800013b0:	0735e263          	bltu	a1,s3,80001414 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800013b4:	60a6                	ld	ra,72(sp)
    800013b6:	6406                	ld	s0,64(sp)
    800013b8:	74e2                	ld	s1,56(sp)
    800013ba:	7942                	ld	s2,48(sp)
    800013bc:	79a2                	ld	s3,40(sp)
    800013be:	7a02                	ld	s4,32(sp)
    800013c0:	6ae2                	ld	s5,24(sp)
    800013c2:	6b42                	ld	s6,16(sp)
    800013c4:	6ba2                	ld	s7,8(sp)
    800013c6:	6161                	addi	sp,sp,80
    800013c8:	8082                	ret
    panic("uvmunmap: not aligned");
    800013ca:	00007517          	auipc	a0,0x7
    800013ce:	d5650513          	addi	a0,a0,-682 # 80008120 <digits+0xe0>
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	16c080e7          	jalr	364(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800013da:	00007517          	auipc	a0,0x7
    800013de:	d5e50513          	addi	a0,a0,-674 # 80008138 <digits+0xf8>
    800013e2:	fffff097          	auipc	ra,0xfffff
    800013e6:	15c080e7          	jalr	348(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800013ea:	00007517          	auipc	a0,0x7
    800013ee:	d5e50513          	addi	a0,a0,-674 # 80008148 <digits+0x108>
    800013f2:	fffff097          	auipc	ra,0xfffff
    800013f6:	14c080e7          	jalr	332(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800013fa:	00007517          	auipc	a0,0x7
    800013fe:	d6650513          	addi	a0,a0,-666 # 80008160 <digits+0x120>
    80001402:	fffff097          	auipc	ra,0xfffff
    80001406:	13c080e7          	jalr	316(ra) # 8000053e <panic>
    *pte = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000140e:	995a                	add	s2,s2,s6
    80001410:	fb3972e3          	bgeu	s2,s3,800013b4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001414:	4601                	li	a2,0
    80001416:	85ca                	mv	a1,s2
    80001418:	8552                	mv	a0,s4
    8000141a:	00000097          	auipc	ra,0x0
    8000141e:	cbc080e7          	jalr	-836(ra) # 800010d6 <walk>
    80001422:	84aa                	mv	s1,a0
    80001424:	d95d                	beqz	a0,800013da <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001426:	6108                	ld	a0,0(a0)
    80001428:	00157793          	andi	a5,a0,1
    8000142c:	dfdd                	beqz	a5,800013ea <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000142e:	3ff57793          	andi	a5,a0,1023
    80001432:	fd7784e3          	beq	a5,s7,800013fa <uvmunmap+0x76>
    if(do_free){
    80001436:	fc0a8ae3          	beqz	s5,8000140a <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000143a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000143c:	0532                	slli	a0,a0,0xc
    8000143e:	fffff097          	auipc	ra,0xfffff
    80001442:	70e080e7          	jalr	1806(ra) # 80000b4c <kfree>
    80001446:	b7d1                	j	8000140a <uvmunmap+0x86>

0000000080001448 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001448:	1101                	addi	sp,sp,-32
    8000144a:	ec06                	sd	ra,24(sp)
    8000144c:	e822                	sd	s0,16(sp)
    8000144e:	e426                	sd	s1,8(sp)
    80001450:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001452:	fffff097          	auipc	ra,0xfffff
    80001456:	604080e7          	jalr	1540(ra) # 80000a56 <kalloc>
    8000145a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000145c:	c519                	beqz	a0,8000146a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000145e:	6605                	lui	a2,0x1
    80001460:	4581                	li	a1,0
    80001462:	00000097          	auipc	ra,0x0
    80001466:	990080e7          	jalr	-1648(ra) # 80000df2 <memset>
  return pagetable;
}
    8000146a:	8526                	mv	a0,s1
    8000146c:	60e2                	ld	ra,24(sp)
    8000146e:	6442                	ld	s0,16(sp)
    80001470:	64a2                	ld	s1,8(sp)
    80001472:	6105                	addi	sp,sp,32
    80001474:	8082                	ret

0000000080001476 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001476:	7179                	addi	sp,sp,-48
    80001478:	f406                	sd	ra,40(sp)
    8000147a:	f022                	sd	s0,32(sp)
    8000147c:	ec26                	sd	s1,24(sp)
    8000147e:	e84a                	sd	s2,16(sp)
    80001480:	e44e                	sd	s3,8(sp)
    80001482:	e052                	sd	s4,0(sp)
    80001484:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001486:	6785                	lui	a5,0x1
    80001488:	04f67863          	bgeu	a2,a5,800014d8 <uvmfirst+0x62>
    8000148c:	8a2a                	mv	s4,a0
    8000148e:	89ae                	mv	s3,a1
    80001490:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001492:	fffff097          	auipc	ra,0xfffff
    80001496:	5c4080e7          	jalr	1476(ra) # 80000a56 <kalloc>
    8000149a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000149c:	6605                	lui	a2,0x1
    8000149e:	4581                	li	a1,0
    800014a0:	00000097          	auipc	ra,0x0
    800014a4:	952080e7          	jalr	-1710(ra) # 80000df2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014a8:	4779                	li	a4,30
    800014aa:	86ca                	mv	a3,s2
    800014ac:	6605                	lui	a2,0x1
    800014ae:	4581                	li	a1,0
    800014b0:	8552                	mv	a0,s4
    800014b2:	00000097          	auipc	ra,0x0
    800014b6:	d0c080e7          	jalr	-756(ra) # 800011be <mappages>
  memmove(mem, src, sz);
    800014ba:	8626                	mv	a2,s1
    800014bc:	85ce                	mv	a1,s3
    800014be:	854a                	mv	a0,s2
    800014c0:	00000097          	auipc	ra,0x0
    800014c4:	98e080e7          	jalr	-1650(ra) # 80000e4e <memmove>
}
    800014c8:	70a2                	ld	ra,40(sp)
    800014ca:	7402                	ld	s0,32(sp)
    800014cc:	64e2                	ld	s1,24(sp)
    800014ce:	6942                	ld	s2,16(sp)
    800014d0:	69a2                	ld	s3,8(sp)
    800014d2:	6a02                	ld	s4,0(sp)
    800014d4:	6145                	addi	sp,sp,48
    800014d6:	8082                	ret
    panic("uvmfirst: more than a page");
    800014d8:	00007517          	auipc	a0,0x7
    800014dc:	ca050513          	addi	a0,a0,-864 # 80008178 <digits+0x138>
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	05e080e7          	jalr	94(ra) # 8000053e <panic>

00000000800014e8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014e8:	1101                	addi	sp,sp,-32
    800014ea:	ec06                	sd	ra,24(sp)
    800014ec:	e822                	sd	s0,16(sp)
    800014ee:	e426                	sd	s1,8(sp)
    800014f0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014f2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014f4:	00b67d63          	bgeu	a2,a1,8000150e <uvmdealloc+0x26>
    800014f8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014fa:	6785                	lui	a5,0x1
    800014fc:	17fd                	addi	a5,a5,-1
    800014fe:	00f60733          	add	a4,a2,a5
    80001502:	767d                	lui	a2,0xfffff
    80001504:	8f71                	and	a4,a4,a2
    80001506:	97ae                	add	a5,a5,a1
    80001508:	8ff1                	and	a5,a5,a2
    8000150a:	00f76863          	bltu	a4,a5,8000151a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000150e:	8526                	mv	a0,s1
    80001510:	60e2                	ld	ra,24(sp)
    80001512:	6442                	ld	s0,16(sp)
    80001514:	64a2                	ld	s1,8(sp)
    80001516:	6105                	addi	sp,sp,32
    80001518:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000151a:	8f99                	sub	a5,a5,a4
    8000151c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000151e:	4685                	li	a3,1
    80001520:	0007861b          	sext.w	a2,a5
    80001524:	85ba                	mv	a1,a4
    80001526:	00000097          	auipc	ra,0x0
    8000152a:	e5e080e7          	jalr	-418(ra) # 80001384 <uvmunmap>
    8000152e:	b7c5                	j	8000150e <uvmdealloc+0x26>

0000000080001530 <uvmalloc>:
  if(newsz < oldsz)
    80001530:	0ab66563          	bltu	a2,a1,800015da <uvmalloc+0xaa>
{
    80001534:	7139                	addi	sp,sp,-64
    80001536:	fc06                	sd	ra,56(sp)
    80001538:	f822                	sd	s0,48(sp)
    8000153a:	f426                	sd	s1,40(sp)
    8000153c:	f04a                	sd	s2,32(sp)
    8000153e:	ec4e                	sd	s3,24(sp)
    80001540:	e852                	sd	s4,16(sp)
    80001542:	e456                	sd	s5,8(sp)
    80001544:	e05a                	sd	s6,0(sp)
    80001546:	0080                	addi	s0,sp,64
    80001548:	8aaa                	mv	s5,a0
    8000154a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000154c:	6985                	lui	s3,0x1
    8000154e:	19fd                	addi	s3,s3,-1
    80001550:	95ce                	add	a1,a1,s3
    80001552:	79fd                	lui	s3,0xfffff
    80001554:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001558:	08c9f363          	bgeu	s3,a2,800015de <uvmalloc+0xae>
    8000155c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000155e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001562:	fffff097          	auipc	ra,0xfffff
    80001566:	4f4080e7          	jalr	1268(ra) # 80000a56 <kalloc>
    8000156a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000156c:	c51d                	beqz	a0,8000159a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000156e:	6605                	lui	a2,0x1
    80001570:	4581                	li	a1,0
    80001572:	00000097          	auipc	ra,0x0
    80001576:	880080e7          	jalr	-1920(ra) # 80000df2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000157a:	875a                	mv	a4,s6
    8000157c:	86a6                	mv	a3,s1
    8000157e:	6605                	lui	a2,0x1
    80001580:	85ca                	mv	a1,s2
    80001582:	8556                	mv	a0,s5
    80001584:	00000097          	auipc	ra,0x0
    80001588:	c3a080e7          	jalr	-966(ra) # 800011be <mappages>
    8000158c:	e90d                	bnez	a0,800015be <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000158e:	6785                	lui	a5,0x1
    80001590:	993e                	add	s2,s2,a5
    80001592:	fd4968e3          	bltu	s2,s4,80001562 <uvmalloc+0x32>
  return newsz;
    80001596:	8552                	mv	a0,s4
    80001598:	a809                	j	800015aa <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000159a:	864e                	mv	a2,s3
    8000159c:	85ca                	mv	a1,s2
    8000159e:	8556                	mv	a0,s5
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	f48080e7          	jalr	-184(ra) # 800014e8 <uvmdealloc>
      return 0;
    800015a8:	4501                	li	a0,0
}
    800015aa:	70e2                	ld	ra,56(sp)
    800015ac:	7442                	ld	s0,48(sp)
    800015ae:	74a2                	ld	s1,40(sp)
    800015b0:	7902                	ld	s2,32(sp)
    800015b2:	69e2                	ld	s3,24(sp)
    800015b4:	6a42                	ld	s4,16(sp)
    800015b6:	6aa2                	ld	s5,8(sp)
    800015b8:	6b02                	ld	s6,0(sp)
    800015ba:	6121                	addi	sp,sp,64
    800015bc:	8082                	ret
      kfree(mem);
    800015be:	8526                	mv	a0,s1
    800015c0:	fffff097          	auipc	ra,0xfffff
    800015c4:	58c080e7          	jalr	1420(ra) # 80000b4c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015c8:	864e                	mv	a2,s3
    800015ca:	85ca                	mv	a1,s2
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	f1a080e7          	jalr	-230(ra) # 800014e8 <uvmdealloc>
      return 0;
    800015d6:	4501                	li	a0,0
    800015d8:	bfc9                	j	800015aa <uvmalloc+0x7a>
    return oldsz;
    800015da:	852e                	mv	a0,a1
}
    800015dc:	8082                	ret
  return newsz;
    800015de:	8532                	mv	a0,a2
    800015e0:	b7e9                	j	800015aa <uvmalloc+0x7a>

00000000800015e2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015e2:	7179                	addi	sp,sp,-48
    800015e4:	f406                	sd	ra,40(sp)
    800015e6:	f022                	sd	s0,32(sp)
    800015e8:	ec26                	sd	s1,24(sp)
    800015ea:	e84a                	sd	s2,16(sp)
    800015ec:	e44e                	sd	s3,8(sp)
    800015ee:	e052                	sd	s4,0(sp)
    800015f0:	1800                	addi	s0,sp,48
    800015f2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015f4:	84aa                	mv	s1,a0
    800015f6:	6905                	lui	s2,0x1
    800015f8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015fa:	4985                	li	s3,1
    800015fc:	a821                	j	80001614 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015fe:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001600:	0532                	slli	a0,a0,0xc
    80001602:	00000097          	auipc	ra,0x0
    80001606:	fe0080e7          	jalr	-32(ra) # 800015e2 <freewalk>
      pagetable[i] = 0;
    8000160a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000160e:	04a1                	addi	s1,s1,8
    80001610:	03248163          	beq	s1,s2,80001632 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001614:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001616:	00f57793          	andi	a5,a0,15
    8000161a:	ff3782e3          	beq	a5,s3,800015fe <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000161e:	8905                	andi	a0,a0,1
    80001620:	d57d                	beqz	a0,8000160e <freewalk+0x2c>
      panic("freewalk: leaf");
    80001622:	00007517          	auipc	a0,0x7
    80001626:	b7650513          	addi	a0,a0,-1162 # 80008198 <digits+0x158>
    8000162a:	fffff097          	auipc	ra,0xfffff
    8000162e:	f14080e7          	jalr	-236(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001632:	8552                	mv	a0,s4
    80001634:	fffff097          	auipc	ra,0xfffff
    80001638:	518080e7          	jalr	1304(ra) # 80000b4c <kfree>
}
    8000163c:	70a2                	ld	ra,40(sp)
    8000163e:	7402                	ld	s0,32(sp)
    80001640:	64e2                	ld	s1,24(sp)
    80001642:	6942                	ld	s2,16(sp)
    80001644:	69a2                	ld	s3,8(sp)
    80001646:	6a02                	ld	s4,0(sp)
    80001648:	6145                	addi	sp,sp,48
    8000164a:	8082                	ret

000000008000164c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000164c:	1101                	addi	sp,sp,-32
    8000164e:	ec06                	sd	ra,24(sp)
    80001650:	e822                	sd	s0,16(sp)
    80001652:	e426                	sd	s1,8(sp)
    80001654:	1000                	addi	s0,sp,32
    80001656:	84aa                	mv	s1,a0
  if(sz > 0)
    80001658:	e999                	bnez	a1,8000166e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000165a:	8526                	mv	a0,s1
    8000165c:	00000097          	auipc	ra,0x0
    80001660:	f86080e7          	jalr	-122(ra) # 800015e2 <freewalk>
}
    80001664:	60e2                	ld	ra,24(sp)
    80001666:	6442                	ld	s0,16(sp)
    80001668:	64a2                	ld	s1,8(sp)
    8000166a:	6105                	addi	sp,sp,32
    8000166c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000166e:	6605                	lui	a2,0x1
    80001670:	167d                	addi	a2,a2,-1
    80001672:	962e                	add	a2,a2,a1
    80001674:	4685                	li	a3,1
    80001676:	8231                	srli	a2,a2,0xc
    80001678:	4581                	li	a1,0
    8000167a:	00000097          	auipc	ra,0x0
    8000167e:	d0a080e7          	jalr	-758(ra) # 80001384 <uvmunmap>
    80001682:	bfe1                	j	8000165a <uvmfree+0xe>

0000000080001684 <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    80001684:	715d                	addi	sp,sp,-80
    80001686:	e486                	sd	ra,72(sp)
    80001688:	e0a2                	sd	s0,64(sp)
    8000168a:	fc26                	sd	s1,56(sp)
    8000168c:	f84a                	sd	s2,48(sp)
    8000168e:	f44e                	sd	s3,40(sp)
    80001690:	f052                	sd	s4,32(sp)
    80001692:	ec56                	sd	s5,24(sp)
    80001694:	e85a                	sd	s6,16(sp)
    80001696:	e45e                	sd	s7,8(sp)
    80001698:	0880                	addi	s0,sp,80
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  // char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000169a:	ce5d                	beqz	a2,80001758 <uvmcopy+0xd4>
    8000169c:	8aaa                	mv	s5,a0
    8000169e:	8a2e                	mv	s4,a1
    800016a0:	89b2                	mv	s3,a2
    800016a2:	4481                	li	s1,0
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if(flags & PTE_W)
    {
      flags = (flags & (~PTE_W)) | PTE_COW;
      *pte = PA2PTE(pa) | flags;
    800016a4:	7b7d                	lui	s6,0xfffff
    800016a6:	002b5b13          	srli	s6,s6,0x2
    800016aa:	a0a1                	j	800016f2 <uvmcopy+0x6e>
      panic("uvmcopy: pte should exist");
    800016ac:	00007517          	auipc	a0,0x7
    800016b0:	afc50513          	addi	a0,a0,-1284 # 800081a8 <digits+0x168>
    800016b4:	fffff097          	auipc	ra,0xfffff
    800016b8:	e8a080e7          	jalr	-374(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800016bc:	00007517          	auipc	a0,0x7
    800016c0:	b0c50513          	addi	a0,a0,-1268 # 800081c8 <digits+0x188>
    800016c4:	fffff097          	auipc	ra,0xfffff
    800016c8:	e7a080e7          	jalr	-390(ra) # 8000053e <panic>
    }
    // if((mem = kalloc()) == 0)
    //   goto err;
    // memmove(mem, (char*)pa, PGSIZE);
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){
    800016cc:	86ca                	mv	a3,s2
    800016ce:	6605                	lui	a2,0x1
    800016d0:	85a6                	mv	a1,s1
    800016d2:	8552                	mv	a0,s4
    800016d4:	00000097          	auipc	ra,0x0
    800016d8:	aea080e7          	jalr	-1302(ra) # 800011be <mappages>
    800016dc:	8baa                	mv	s7,a0
    800016de:	e539                	bnez	a0,8000172c <uvmcopy+0xa8>
      // kfree(mem);
      goto err;
    }
    incpgref((void*)pa);
    800016e0:	854a                	mv	a0,s2
    800016e2:	fffff097          	auipc	ra,0xfffff
    800016e6:	308080e7          	jalr	776(ra) # 800009ea <incpgref>
  for(i = 0; i < sz; i += PGSIZE){
    800016ea:	6785                	lui	a5,0x1
    800016ec:	94be                	add	s1,s1,a5
    800016ee:	0534f963          	bgeu	s1,s3,80001740 <uvmcopy+0xbc>
    if((pte = walk(old, i, 0)) == 0)
    800016f2:	4601                	li	a2,0
    800016f4:	85a6                	mv	a1,s1
    800016f6:	8556                	mv	a0,s5
    800016f8:	00000097          	auipc	ra,0x0
    800016fc:	9de080e7          	jalr	-1570(ra) # 800010d6 <walk>
    80001700:	d555                	beqz	a0,800016ac <uvmcopy+0x28>
    if((*pte & PTE_V) == 0)
    80001702:	611c                	ld	a5,0(a0)
    80001704:	0017f713          	andi	a4,a5,1
    80001708:	db55                	beqz	a4,800016bc <uvmcopy+0x38>
    pa = PTE2PA(*pte);
    8000170a:	00a7d913          	srli	s2,a5,0xa
    8000170e:	0932                	slli	s2,s2,0xc
    flags = PTE_FLAGS(*pte);
    80001710:	3ff7f713          	andi	a4,a5,1023
    if(flags & PTE_W)
    80001714:	0047f693          	andi	a3,a5,4
    80001718:	dad5                	beqz	a3,800016cc <uvmcopy+0x48>
      flags = (flags & (~PTE_W)) | PTE_COW;
    8000171a:	efb77693          	andi	a3,a4,-261
    8000171e:	1006e713          	ori	a4,a3,256
      *pte = PA2PTE(pa) | flags;
    80001722:	0167f7b3          	and	a5,a5,s6
    80001726:	8fd9                	or	a5,a5,a4
    80001728:	e11c                	sd	a5,0(a0)
    8000172a:	b74d                	j	800016cc <uvmcopy+0x48>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000172c:	4685                	li	a3,1
    8000172e:	00c4d613          	srli	a2,s1,0xc
    80001732:	4581                	li	a1,0
    80001734:	8552                	mv	a0,s4
    80001736:	00000097          	auipc	ra,0x0
    8000173a:	c4e080e7          	jalr	-946(ra) # 80001384 <uvmunmap>
  return -1;
    8000173e:	5bfd                	li	s7,-1
}
    80001740:	855e                	mv	a0,s7
    80001742:	60a6                	ld	ra,72(sp)
    80001744:	6406                	ld	s0,64(sp)
    80001746:	74e2                	ld	s1,56(sp)
    80001748:	7942                	ld	s2,48(sp)
    8000174a:	79a2                	ld	s3,40(sp)
    8000174c:	7a02                	ld	s4,32(sp)
    8000174e:	6ae2                	ld	s5,24(sp)
    80001750:	6b42                	ld	s6,16(sp)
    80001752:	6ba2                	ld	s7,8(sp)
    80001754:	6161                	addi	sp,sp,80
    80001756:	8082                	ret
  return 0;
    80001758:	4b81                	li	s7,0
    8000175a:	b7dd                	j	80001740 <uvmcopy+0xbc>

000000008000175c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000175c:	1141                	addi	sp,sp,-16
    8000175e:	e406                	sd	ra,8(sp)
    80001760:	e022                	sd	s0,0(sp)
    80001762:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001764:	4601                	li	a2,0
    80001766:	00000097          	auipc	ra,0x0
    8000176a:	970080e7          	jalr	-1680(ra) # 800010d6 <walk>
  if(pte == 0)
    8000176e:	c901                	beqz	a0,8000177e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001770:	611c                	ld	a5,0(a0)
    80001772:	9bbd                	andi	a5,a5,-17
    80001774:	e11c                	sd	a5,0(a0)
}
    80001776:	60a2                	ld	ra,8(sp)
    80001778:	6402                	ld	s0,0(sp)
    8000177a:	0141                	addi	sp,sp,16
    8000177c:	8082                	ret
    panic("uvmclear");
    8000177e:	00007517          	auipc	a0,0x7
    80001782:	a6a50513          	addi	a0,a0,-1430 # 800081e8 <digits+0x1a8>
    80001786:	fffff097          	auipc	ra,0xfffff
    8000178a:	db8080e7          	jalr	-584(ra) # 8000053e <panic>

000000008000178e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000178e:	c6c5                	beqz	a3,80001836 <copyout+0xa8>
{
    80001790:	711d                	addi	sp,sp,-96
    80001792:	ec86                	sd	ra,88(sp)
    80001794:	e8a2                	sd	s0,80(sp)
    80001796:	e4a6                	sd	s1,72(sp)
    80001798:	e0ca                	sd	s2,64(sp)
    8000179a:	fc4e                	sd	s3,56(sp)
    8000179c:	f852                	sd	s4,48(sp)
    8000179e:	f456                	sd	s5,40(sp)
    800017a0:	f05a                	sd	s6,32(sp)
    800017a2:	ec5e                	sd	s7,24(sp)
    800017a4:	e862                	sd	s8,16(sp)
    800017a6:	e466                	sd	s9,8(sp)
    800017a8:	1080                	addi	s0,sp,96
    800017aa:	8baa                	mv	s7,a0
    800017ac:	8a2e                	mv	s4,a1
    800017ae:	8b32                	mv	s6,a2
    800017b0:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800017b2:	7cfd                	lui	s9,0xfffff
      pa0 = walkaddr(pagetable, va0);
    }
    if(pa0 == 0)
      return -1;
    
    n = PGSIZE - (dstva - va0);
    800017b4:	6c05                	lui	s8,0x1
    800017b6:	a091                	j	800017fa <copyout+0x6c>
      pgfault(va0, pagetable);
    800017b8:	85de                	mv	a1,s7
    800017ba:	854a                	mv	a0,s2
    800017bc:	00001097          	auipc	ra,0x1
    800017c0:	5b8080e7          	jalr	1464(ra) # 80002d74 <pgfault>
      pa0 = walkaddr(pagetable, va0);
    800017c4:	85ca                	mv	a1,s2
    800017c6:	855e                	mv	a0,s7
    800017c8:	00000097          	auipc	ra,0x0
    800017cc:	9b4080e7          	jalr	-1612(ra) # 8000117c <walkaddr>
    800017d0:	89aa                	mv	s3,a0
    if(pa0 == 0)
    800017d2:	e929                	bnez	a0,80001824 <copyout+0x96>
      return -1;
    800017d4:	557d                	li	a0,-1
    800017d6:	a09d                	j	8000183c <copyout+0xae>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017d8:	412a0533          	sub	a0,s4,s2
    800017dc:	0004861b          	sext.w	a2,s1
    800017e0:	85da                	mv	a1,s6
    800017e2:	954e                	add	a0,a0,s3
    800017e4:	fffff097          	auipc	ra,0xfffff
    800017e8:	66a080e7          	jalr	1642(ra) # 80000e4e <memmove>

    len -= n;
    800017ec:	409a8ab3          	sub	s5,s5,s1
    src += n;
    800017f0:	9b26                	add	s6,s6,s1
    dstva = va0 + PGSIZE;
    800017f2:	01890a33          	add	s4,s2,s8
  while(len > 0){
    800017f6:	020a8e63          	beqz	s5,80001832 <copyout+0xa4>
    va0 = PGROUNDDOWN(dstva);
    800017fa:	019a7933          	and	s2,s4,s9
    pa0 = walkaddr(pagetable, va0);
    800017fe:	85ca                	mv	a1,s2
    80001800:	855e                	mv	a0,s7
    80001802:	00000097          	auipc	ra,0x0
    80001806:	97a080e7          	jalr	-1670(ra) # 8000117c <walkaddr>
    8000180a:	89aa                	mv	s3,a0
    if(pa0 == 0)
    8000180c:	c51d                	beqz	a0,8000183a <copyout+0xac>
    if(PTE_FLAGS(*walk(pagetable, va0, 0)) & PTE_COW)
    8000180e:	4601                	li	a2,0
    80001810:	85ca                	mv	a1,s2
    80001812:	855e                	mv	a0,s7
    80001814:	00000097          	auipc	ra,0x0
    80001818:	8c2080e7          	jalr	-1854(ra) # 800010d6 <walk>
    8000181c:	611c                	ld	a5,0(a0)
    8000181e:	1007f793          	andi	a5,a5,256
    80001822:	fbd9                	bnez	a5,800017b8 <copyout+0x2a>
    n = PGSIZE - (dstva - va0);
    80001824:	414904b3          	sub	s1,s2,s4
    80001828:	94e2                	add	s1,s1,s8
    if(n > len)
    8000182a:	fa9af7e3          	bgeu	s5,s1,800017d8 <copyout+0x4a>
    8000182e:	84d6                	mv	s1,s5
    80001830:	b765                	j	800017d8 <copyout+0x4a>
  }
  return 0;
    80001832:	4501                	li	a0,0
    80001834:	a021                	j	8000183c <copyout+0xae>
    80001836:	4501                	li	a0,0
}
    80001838:	8082                	ret
      return -1;
    8000183a:	557d                	li	a0,-1
}
    8000183c:	60e6                	ld	ra,88(sp)
    8000183e:	6446                	ld	s0,80(sp)
    80001840:	64a6                	ld	s1,72(sp)
    80001842:	6906                	ld	s2,64(sp)
    80001844:	79e2                	ld	s3,56(sp)
    80001846:	7a42                	ld	s4,48(sp)
    80001848:	7aa2                	ld	s5,40(sp)
    8000184a:	7b02                	ld	s6,32(sp)
    8000184c:	6be2                	ld	s7,24(sp)
    8000184e:	6c42                	ld	s8,16(sp)
    80001850:	6ca2                	ld	s9,8(sp)
    80001852:	6125                	addi	sp,sp,96
    80001854:	8082                	ret

0000000080001856 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001856:	caa5                	beqz	a3,800018c6 <copyin+0x70>
{
    80001858:	715d                	addi	sp,sp,-80
    8000185a:	e486                	sd	ra,72(sp)
    8000185c:	e0a2                	sd	s0,64(sp)
    8000185e:	fc26                	sd	s1,56(sp)
    80001860:	f84a                	sd	s2,48(sp)
    80001862:	f44e                	sd	s3,40(sp)
    80001864:	f052                	sd	s4,32(sp)
    80001866:	ec56                	sd	s5,24(sp)
    80001868:	e85a                	sd	s6,16(sp)
    8000186a:	e45e                	sd	s7,8(sp)
    8000186c:	e062                	sd	s8,0(sp)
    8000186e:	0880                	addi	s0,sp,80
    80001870:	8b2a                	mv	s6,a0
    80001872:	8a2e                	mv	s4,a1
    80001874:	8c32                	mv	s8,a2
    80001876:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001878:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000187a:	6a85                	lui	s5,0x1
    8000187c:	a01d                	j	800018a2 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000187e:	018505b3          	add	a1,a0,s8
    80001882:	0004861b          	sext.w	a2,s1
    80001886:	412585b3          	sub	a1,a1,s2
    8000188a:	8552                	mv	a0,s4
    8000188c:	fffff097          	auipc	ra,0xfffff
    80001890:	5c2080e7          	jalr	1474(ra) # 80000e4e <memmove>

    len -= n;
    80001894:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001898:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000189a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000189e:	02098263          	beqz	s3,800018c2 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018a2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018a6:	85ca                	mv	a1,s2
    800018a8:	855a                	mv	a0,s6
    800018aa:	00000097          	auipc	ra,0x0
    800018ae:	8d2080e7          	jalr	-1838(ra) # 8000117c <walkaddr>
    if(pa0 == 0)
    800018b2:	cd01                	beqz	a0,800018ca <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018b4:	418904b3          	sub	s1,s2,s8
    800018b8:	94d6                	add	s1,s1,s5
    if(n > len)
    800018ba:	fc99f2e3          	bgeu	s3,s1,8000187e <copyin+0x28>
    800018be:	84ce                	mv	s1,s3
    800018c0:	bf7d                	j	8000187e <copyin+0x28>
  }
  return 0;
    800018c2:	4501                	li	a0,0
    800018c4:	a021                	j	800018cc <copyin+0x76>
    800018c6:	4501                	li	a0,0
}
    800018c8:	8082                	ret
      return -1;
    800018ca:	557d                	li	a0,-1
}
    800018cc:	60a6                	ld	ra,72(sp)
    800018ce:	6406                	ld	s0,64(sp)
    800018d0:	74e2                	ld	s1,56(sp)
    800018d2:	7942                	ld	s2,48(sp)
    800018d4:	79a2                	ld	s3,40(sp)
    800018d6:	7a02                	ld	s4,32(sp)
    800018d8:	6ae2                	ld	s5,24(sp)
    800018da:	6b42                	ld	s6,16(sp)
    800018dc:	6ba2                	ld	s7,8(sp)
    800018de:	6c02                	ld	s8,0(sp)
    800018e0:	6161                	addi	sp,sp,80
    800018e2:	8082                	ret

00000000800018e4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018e4:	c6c5                	beqz	a3,8000198c <copyinstr+0xa8>
{
    800018e6:	715d                	addi	sp,sp,-80
    800018e8:	e486                	sd	ra,72(sp)
    800018ea:	e0a2                	sd	s0,64(sp)
    800018ec:	fc26                	sd	s1,56(sp)
    800018ee:	f84a                	sd	s2,48(sp)
    800018f0:	f44e                	sd	s3,40(sp)
    800018f2:	f052                	sd	s4,32(sp)
    800018f4:	ec56                	sd	s5,24(sp)
    800018f6:	e85a                	sd	s6,16(sp)
    800018f8:	e45e                	sd	s7,8(sp)
    800018fa:	0880                	addi	s0,sp,80
    800018fc:	8a2a                	mv	s4,a0
    800018fe:	8b2e                	mv	s6,a1
    80001900:	8bb2                	mv	s7,a2
    80001902:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001904:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001906:	6985                	lui	s3,0x1
    80001908:	a035                	j	80001934 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000190a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000190e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001910:	0017b793          	seqz	a5,a5
    80001914:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001918:	60a6                	ld	ra,72(sp)
    8000191a:	6406                	ld	s0,64(sp)
    8000191c:	74e2                	ld	s1,56(sp)
    8000191e:	7942                	ld	s2,48(sp)
    80001920:	79a2                	ld	s3,40(sp)
    80001922:	7a02                	ld	s4,32(sp)
    80001924:	6ae2                	ld	s5,24(sp)
    80001926:	6b42                	ld	s6,16(sp)
    80001928:	6ba2                	ld	s7,8(sp)
    8000192a:	6161                	addi	sp,sp,80
    8000192c:	8082                	ret
    srcva = va0 + PGSIZE;
    8000192e:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001932:	c8a9                	beqz	s1,80001984 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001934:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001938:	85ca                	mv	a1,s2
    8000193a:	8552                	mv	a0,s4
    8000193c:	00000097          	auipc	ra,0x0
    80001940:	840080e7          	jalr	-1984(ra) # 8000117c <walkaddr>
    if(pa0 == 0)
    80001944:	c131                	beqz	a0,80001988 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001946:	41790833          	sub	a6,s2,s7
    8000194a:	984e                	add	a6,a6,s3
    if(n > max)
    8000194c:	0104f363          	bgeu	s1,a6,80001952 <copyinstr+0x6e>
    80001950:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001952:	955e                	add	a0,a0,s7
    80001954:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001958:	fc080be3          	beqz	a6,8000192e <copyinstr+0x4a>
    8000195c:	985a                	add	a6,a6,s6
    8000195e:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001960:	41650633          	sub	a2,a0,s6
    80001964:	14fd                	addi	s1,s1,-1
    80001966:	9b26                	add	s6,s6,s1
    80001968:	00f60733          	add	a4,a2,a5
    8000196c:	00074703          	lbu	a4,0(a4)
    80001970:	df49                	beqz	a4,8000190a <copyinstr+0x26>
        *dst = *p;
    80001972:	00e78023          	sb	a4,0(a5)
      --max;
    80001976:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000197a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000197c:	ff0796e3          	bne	a5,a6,80001968 <copyinstr+0x84>
      dst++;
    80001980:	8b42                	mv	s6,a6
    80001982:	b775                	j	8000192e <copyinstr+0x4a>
    80001984:	4781                	li	a5,0
    80001986:	b769                	j	80001910 <copyinstr+0x2c>
      return -1;
    80001988:	557d                	li	a0,-1
    8000198a:	b779                	j	80001918 <copyinstr+0x34>
  int got_null = 0;
    8000198c:	4781                	li	a5,0
  if(got_null){
    8000198e:	0017b793          	seqz	a5,a5
    80001992:	40f00533          	neg	a0,a5
}
    80001996:	8082                	ret

0000000080001998 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001998:	7139                	addi	sp,sp,-64
    8000199a:	fc06                	sd	ra,56(sp)
    8000199c:	f822                	sd	s0,48(sp)
    8000199e:	f426                	sd	s1,40(sp)
    800019a0:	f04a                	sd	s2,32(sp)
    800019a2:	ec4e                	sd	s3,24(sp)
    800019a4:	e852                	sd	s4,16(sp)
    800019a6:	e456                	sd	s5,8(sp)
    800019a8:	e05a                	sd	s6,0(sp)
    800019aa:	0080                	addi	s0,sp,64
    800019ac:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800019ae:	0022f497          	auipc	s1,0x22f
    800019b2:	61a48493          	addi	s1,s1,1562 # 80230fc8 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800019b6:	8b26                	mv	s6,s1
    800019b8:	00006a97          	auipc	s5,0x6
    800019bc:	648a8a93          	addi	s5,s5,1608 # 80008000 <etext>
    800019c0:	04000937          	lui	s2,0x4000
    800019c4:	197d                	addi	s2,s2,-1
    800019c6:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800019c8:	00236a17          	auipc	s4,0x236
    800019cc:	a00a0a13          	addi	s4,s4,-1536 # 802373c8 <tickslock>
    char *pa = kalloc();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	086080e7          	jalr	134(ra) # 80000a56 <kalloc>
    800019d8:	862a                	mv	a2,a0
    if (pa == 0)
    800019da:	c131                	beqz	a0,80001a1e <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    800019dc:	416485b3          	sub	a1,s1,s6
    800019e0:	8591                	srai	a1,a1,0x4
    800019e2:	000ab783          	ld	a5,0(s5)
    800019e6:	02f585b3          	mul	a1,a1,a5
    800019ea:	2585                	addiw	a1,a1,1
    800019ec:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019f0:	4719                	li	a4,6
    800019f2:	6685                	lui	a3,0x1
    800019f4:	40b905b3          	sub	a1,s2,a1
    800019f8:	854e                	mv	a0,s3
    800019fa:	00000097          	auipc	ra,0x0
    800019fe:	864080e7          	jalr	-1948(ra) # 8000125e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a02:	19048493          	addi	s1,s1,400
    80001a06:	fd4495e3          	bne	s1,s4,800019d0 <proc_mapstacks+0x38>
  }
}
    80001a0a:	70e2                	ld	ra,56(sp)
    80001a0c:	7442                	ld	s0,48(sp)
    80001a0e:	74a2                	ld	s1,40(sp)
    80001a10:	7902                	ld	s2,32(sp)
    80001a12:	69e2                	ld	s3,24(sp)
    80001a14:	6a42                	ld	s4,16(sp)
    80001a16:	6aa2                	ld	s5,8(sp)
    80001a18:	6b02                	ld	s6,0(sp)
    80001a1a:	6121                	addi	sp,sp,64
    80001a1c:	8082                	ret
      panic("kalloc");
    80001a1e:	00006517          	auipc	a0,0x6
    80001a22:	7da50513          	addi	a0,a0,2010 # 800081f8 <digits+0x1b8>
    80001a26:	fffff097          	auipc	ra,0xfffff
    80001a2a:	b18080e7          	jalr	-1256(ra) # 8000053e <panic>

0000000080001a2e <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001a2e:	7139                	addi	sp,sp,-64
    80001a30:	fc06                	sd	ra,56(sp)
    80001a32:	f822                	sd	s0,48(sp)
    80001a34:	f426                	sd	s1,40(sp)
    80001a36:	f04a                	sd	s2,32(sp)
    80001a38:	ec4e                	sd	s3,24(sp)
    80001a3a:	e852                	sd	s4,16(sp)
    80001a3c:	e456                	sd	s5,8(sp)
    80001a3e:	e05a                	sd	s6,0(sp)
    80001a40:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001a42:	00006597          	auipc	a1,0x6
    80001a46:	7be58593          	addi	a1,a1,1982 # 80008200 <digits+0x1c0>
    80001a4a:	0022f517          	auipc	a0,0x22f
    80001a4e:	14e50513          	addi	a0,a0,334 # 80230b98 <pid_lock>
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	214080e7          	jalr	532(ra) # 80000c66 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a5a:	00006597          	auipc	a1,0x6
    80001a5e:	7ae58593          	addi	a1,a1,1966 # 80008208 <digits+0x1c8>
    80001a62:	0022f517          	auipc	a0,0x22f
    80001a66:	14e50513          	addi	a0,a0,334 # 80230bb0 <wait_lock>
    80001a6a:	fffff097          	auipc	ra,0xfffff
    80001a6e:	1fc080e7          	jalr	508(ra) # 80000c66 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a72:	0022f497          	auipc	s1,0x22f
    80001a76:	55648493          	addi	s1,s1,1366 # 80230fc8 <proc>
  {
    initlock(&p->lock, "proc");
    80001a7a:	00006b17          	auipc	s6,0x6
    80001a7e:	79eb0b13          	addi	s6,s6,1950 # 80008218 <digits+0x1d8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001a82:	8aa6                	mv	s5,s1
    80001a84:	00006a17          	auipc	s4,0x6
    80001a88:	57ca0a13          	addi	s4,s4,1404 # 80008000 <etext>
    80001a8c:	04000937          	lui	s2,0x4000
    80001a90:	197d                	addi	s2,s2,-1
    80001a92:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a94:	00236997          	auipc	s3,0x236
    80001a98:	93498993          	addi	s3,s3,-1740 # 802373c8 <tickslock>
    initlock(&p->lock, "proc");
    80001a9c:	85da                	mv	a1,s6
    80001a9e:	8526                	mv	a0,s1
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	1c6080e7          	jalr	454(ra) # 80000c66 <initlock>
    p->state = UNUSED;
    80001aa8:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001aac:	415487b3          	sub	a5,s1,s5
    80001ab0:	8791                	srai	a5,a5,0x4
    80001ab2:	000a3703          	ld	a4,0(s4)
    80001ab6:	02e787b3          	mul	a5,a5,a4
    80001aba:	2785                	addiw	a5,a5,1
    80001abc:	00d7979b          	slliw	a5,a5,0xd
    80001ac0:	40f907b3          	sub	a5,s2,a5
    80001ac4:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001ac6:	19048493          	addi	s1,s1,400
    80001aca:	fd3499e3          	bne	s1,s3,80001a9c <procinit+0x6e>
  }
}
    80001ace:	70e2                	ld	ra,56(sp)
    80001ad0:	7442                	ld	s0,48(sp)
    80001ad2:	74a2                	ld	s1,40(sp)
    80001ad4:	7902                	ld	s2,32(sp)
    80001ad6:	69e2                	ld	s3,24(sp)
    80001ad8:	6a42                	ld	s4,16(sp)
    80001ada:	6aa2                	ld	s5,8(sp)
    80001adc:	6b02                	ld	s6,0(sp)
    80001ade:	6121                	addi	sp,sp,64
    80001ae0:	8082                	ret

0000000080001ae2 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001ae2:	1141                	addi	sp,sp,-16
    80001ae4:	e422                	sd	s0,8(sp)
    80001ae6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ae8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001aea:	2501                	sext.w	a0,a0
    80001aec:	6422                	ld	s0,8(sp)
    80001aee:	0141                	addi	sp,sp,16
    80001af0:	8082                	ret

0000000080001af2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001af2:	1141                	addi	sp,sp,-16
    80001af4:	e422                	sd	s0,8(sp)
    80001af6:	0800                	addi	s0,sp,16
    80001af8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001afa:	2781                	sext.w	a5,a5
    80001afc:	079e                	slli	a5,a5,0x7
  return c;
}
    80001afe:	0022f517          	auipc	a0,0x22f
    80001b02:	0ca50513          	addi	a0,a0,202 # 80230bc8 <cpus>
    80001b06:	953e                	add	a0,a0,a5
    80001b08:	6422                	ld	s0,8(sp)
    80001b0a:	0141                	addi	sp,sp,16
    80001b0c:	8082                	ret

0000000080001b0e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001b0e:	1101                	addi	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	1000                	addi	s0,sp,32
  push_off();
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	192080e7          	jalr	402(ra) # 80000caa <push_off>
    80001b20:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b22:	2781                	sext.w	a5,a5
    80001b24:	079e                	slli	a5,a5,0x7
    80001b26:	0022f717          	auipc	a4,0x22f
    80001b2a:	07270713          	addi	a4,a4,114 # 80230b98 <pid_lock>
    80001b2e:	97ba                	add	a5,a5,a4
    80001b30:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	218080e7          	jalr	536(ra) # 80000d4a <pop_off>
  return p;
}
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	60e2                	ld	ra,24(sp)
    80001b3e:	6442                	ld	s0,16(sp)
    80001b40:	64a2                	ld	s1,8(sp)
    80001b42:	6105                	addi	sp,sp,32
    80001b44:	8082                	ret

0000000080001b46 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b46:	1141                	addi	sp,sp,-16
    80001b48:	e406                	sd	ra,8(sp)
    80001b4a:	e022                	sd	s0,0(sp)
    80001b4c:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b4e:	00000097          	auipc	ra,0x0
    80001b52:	fc0080e7          	jalr	-64(ra) # 80001b0e <myproc>
    80001b56:	fffff097          	auipc	ra,0xfffff
    80001b5a:	254080e7          	jalr	596(ra) # 80000daa <release>

  if (first)
    80001b5e:	00007797          	auipc	a5,0x7
    80001b62:	d327a783          	lw	a5,-718(a5) # 80008890 <first.1>
    80001b66:	eb89                	bnez	a5,80001b78 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b68:	00001097          	auipc	ra,0x1
    80001b6c:	fb4080e7          	jalr	-76(ra) # 80002b1c <usertrapret>
}
    80001b70:	60a2                	ld	ra,8(sp)
    80001b72:	6402                	ld	s0,0(sp)
    80001b74:	0141                	addi	sp,sp,16
    80001b76:	8082                	ret
    first = 0;
    80001b78:	00007797          	auipc	a5,0x7
    80001b7c:	d007ac23          	sw	zero,-744(a5) # 80008890 <first.1>
    fsinit(ROOTDEV);
    80001b80:	4505                	li	a0,1
    80001b82:	00002097          	auipc	ra,0x2
    80001b86:	f1c080e7          	jalr	-228(ra) # 80003a9e <fsinit>
    80001b8a:	bff9                	j	80001b68 <forkret+0x22>

0000000080001b8c <allocpid>:
{
    80001b8c:	1101                	addi	sp,sp,-32
    80001b8e:	ec06                	sd	ra,24(sp)
    80001b90:	e822                	sd	s0,16(sp)
    80001b92:	e426                	sd	s1,8(sp)
    80001b94:	e04a                	sd	s2,0(sp)
    80001b96:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b98:	0022f917          	auipc	s2,0x22f
    80001b9c:	00090913          	mv	s2,s2
    80001ba0:	854a                	mv	a0,s2
    80001ba2:	fffff097          	auipc	ra,0xfffff
    80001ba6:	154080e7          	jalr	340(ra) # 80000cf6 <acquire>
  pid = nextpid;
    80001baa:	00007797          	auipc	a5,0x7
    80001bae:	cea78793          	addi	a5,a5,-790 # 80008894 <nextpid>
    80001bb2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bb4:	0014871b          	addiw	a4,s1,1
    80001bb8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bba:	854a                	mv	a0,s2
    80001bbc:	fffff097          	auipc	ra,0xfffff
    80001bc0:	1ee080e7          	jalr	494(ra) # 80000daa <release>
}
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6902                	ld	s2,0(sp)
    80001bce:	6105                	addi	sp,sp,32
    80001bd0:	8082                	ret

0000000080001bd2 <proc_pagetable>:
{
    80001bd2:	1101                	addi	sp,sp,-32
    80001bd4:	ec06                	sd	ra,24(sp)
    80001bd6:	e822                	sd	s0,16(sp)
    80001bd8:	e426                	sd	s1,8(sp)
    80001bda:	e04a                	sd	s2,0(sp)
    80001bdc:	1000                	addi	s0,sp,32
    80001bde:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	868080e7          	jalr	-1944(ra) # 80001448 <uvmcreate>
    80001be8:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001bea:	c121                	beqz	a0,80001c2a <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bec:	4729                	li	a4,10
    80001bee:	00005697          	auipc	a3,0x5
    80001bf2:	41268693          	addi	a3,a3,1042 # 80007000 <_trampoline>
    80001bf6:	6605                	lui	a2,0x1
    80001bf8:	040005b7          	lui	a1,0x4000
    80001bfc:	15fd                	addi	a1,a1,-1
    80001bfe:	05b2                	slli	a1,a1,0xc
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	5be080e7          	jalr	1470(ra) # 800011be <mappages>
    80001c08:	02054863          	bltz	a0,80001c38 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c0c:	4719                	li	a4,6
    80001c0e:	05893683          	ld	a3,88(s2) # 80230bf0 <cpus+0x28>
    80001c12:	6605                	lui	a2,0x1
    80001c14:	020005b7          	lui	a1,0x2000
    80001c18:	15fd                	addi	a1,a1,-1
    80001c1a:	05b6                	slli	a1,a1,0xd
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	5a0080e7          	jalr	1440(ra) # 800011be <mappages>
    80001c26:	02054163          	bltz	a0,80001c48 <proc_pagetable+0x76>
}
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	60e2                	ld	ra,24(sp)
    80001c2e:	6442                	ld	s0,16(sp)
    80001c30:	64a2                	ld	s1,8(sp)
    80001c32:	6902                	ld	s2,0(sp)
    80001c34:	6105                	addi	sp,sp,32
    80001c36:	8082                	ret
    uvmfree(pagetable, 0);
    80001c38:	4581                	li	a1,0
    80001c3a:	8526                	mv	a0,s1
    80001c3c:	00000097          	auipc	ra,0x0
    80001c40:	a10080e7          	jalr	-1520(ra) # 8000164c <uvmfree>
    return 0;
    80001c44:	4481                	li	s1,0
    80001c46:	b7d5                	j	80001c2a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c48:	4681                	li	a3,0
    80001c4a:	4605                	li	a2,1
    80001c4c:	040005b7          	lui	a1,0x4000
    80001c50:	15fd                	addi	a1,a1,-1
    80001c52:	05b2                	slli	a1,a1,0xc
    80001c54:	8526                	mv	a0,s1
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	72e080e7          	jalr	1838(ra) # 80001384 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c5e:	4581                	li	a1,0
    80001c60:	8526                	mv	a0,s1
    80001c62:	00000097          	auipc	ra,0x0
    80001c66:	9ea080e7          	jalr	-1558(ra) # 8000164c <uvmfree>
    return 0;
    80001c6a:	4481                	li	s1,0
    80001c6c:	bf7d                	j	80001c2a <proc_pagetable+0x58>

0000000080001c6e <proc_freepagetable>:
{
    80001c6e:	1101                	addi	sp,sp,-32
    80001c70:	ec06                	sd	ra,24(sp)
    80001c72:	e822                	sd	s0,16(sp)
    80001c74:	e426                	sd	s1,8(sp)
    80001c76:	e04a                	sd	s2,0(sp)
    80001c78:	1000                	addi	s0,sp,32
    80001c7a:	84aa                	mv	s1,a0
    80001c7c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c7e:	4681                	li	a3,0
    80001c80:	4605                	li	a2,1
    80001c82:	040005b7          	lui	a1,0x4000
    80001c86:	15fd                	addi	a1,a1,-1
    80001c88:	05b2                	slli	a1,a1,0xc
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	6fa080e7          	jalr	1786(ra) # 80001384 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c92:	4681                	li	a3,0
    80001c94:	4605                	li	a2,1
    80001c96:	020005b7          	lui	a1,0x2000
    80001c9a:	15fd                	addi	a1,a1,-1
    80001c9c:	05b6                	slli	a1,a1,0xd
    80001c9e:	8526                	mv	a0,s1
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	6e4080e7          	jalr	1764(ra) # 80001384 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ca8:	85ca                	mv	a1,s2
    80001caa:	8526                	mv	a0,s1
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	9a0080e7          	jalr	-1632(ra) # 8000164c <uvmfree>
}
    80001cb4:	60e2                	ld	ra,24(sp)
    80001cb6:	6442                	ld	s0,16(sp)
    80001cb8:	64a2                	ld	s1,8(sp)
    80001cba:	6902                	ld	s2,0(sp)
    80001cbc:	6105                	addi	sp,sp,32
    80001cbe:	8082                	ret

0000000080001cc0 <freeproc>:
{
    80001cc0:	1101                	addi	sp,sp,-32
    80001cc2:	ec06                	sd	ra,24(sp)
    80001cc4:	e822                	sd	s0,16(sp)
    80001cc6:	e426                	sd	s1,8(sp)
    80001cc8:	1000                	addi	s0,sp,32
    80001cca:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ccc:	6d28                	ld	a0,88(a0)
    80001cce:	c509                	beqz	a0,80001cd8 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	e7c080e7          	jalr	-388(ra) # 80000b4c <kfree>
  p->trapframe = 0;
    80001cd8:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001cdc:	68a8                	ld	a0,80(s1)
    80001cde:	c511                	beqz	a0,80001cea <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ce0:	64ac                	ld	a1,72(s1)
    80001ce2:	00000097          	auipc	ra,0x0
    80001ce6:	f8c080e7          	jalr	-116(ra) # 80001c6e <proc_freepagetable>
  p->pagetable = 0;
    80001cea:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cee:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cf2:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cf6:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001cfa:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cfe:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d02:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d06:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d0a:	0004ac23          	sw	zero,24(s1)
}
    80001d0e:	60e2                	ld	ra,24(sp)
    80001d10:	6442                	ld	s0,16(sp)
    80001d12:	64a2                	ld	s1,8(sp)
    80001d14:	6105                	addi	sp,sp,32
    80001d16:	8082                	ret

0000000080001d18 <allocproc>:
{
    80001d18:	1101                	addi	sp,sp,-32
    80001d1a:	ec06                	sd	ra,24(sp)
    80001d1c:	e822                	sd	s0,16(sp)
    80001d1e:	e426                	sd	s1,8(sp)
    80001d20:	e04a                	sd	s2,0(sp)
    80001d22:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001d24:	0022f497          	auipc	s1,0x22f
    80001d28:	2a448493          	addi	s1,s1,676 # 80230fc8 <proc>
    80001d2c:	00235917          	auipc	s2,0x235
    80001d30:	69c90913          	addi	s2,s2,1692 # 802373c8 <tickslock>
    acquire(&p->lock);
    80001d34:	8526                	mv	a0,s1
    80001d36:	fffff097          	auipc	ra,0xfffff
    80001d3a:	fc0080e7          	jalr	-64(ra) # 80000cf6 <acquire>
    if (p->state == UNUSED)
    80001d3e:	4c9c                	lw	a5,24(s1)
    80001d40:	cf81                	beqz	a5,80001d58 <allocproc+0x40>
      release(&p->lock);
    80001d42:	8526                	mv	a0,s1
    80001d44:	fffff097          	auipc	ra,0xfffff
    80001d48:	066080e7          	jalr	102(ra) # 80000daa <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001d4c:	19048493          	addi	s1,s1,400
    80001d50:	ff2492e3          	bne	s1,s2,80001d34 <allocproc+0x1c>
  return 0;
    80001d54:	4481                	li	s1,0
    80001d56:	a071                	j	80001de2 <allocproc+0xca>
  p->pid = allocpid();
    80001d58:	00000097          	auipc	ra,0x0
    80001d5c:	e34080e7          	jalr	-460(ra) # 80001b8c <allocpid>
    80001d60:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d62:	4785                	li	a5,1
    80001d64:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001d66:	fffff097          	auipc	ra,0xfffff
    80001d6a:	cf0080e7          	jalr	-784(ra) # 80000a56 <kalloc>
    80001d6e:	892a                	mv	s2,a0
    80001d70:	eca8                	sd	a0,88(s1)
    80001d72:	cd3d                	beqz	a0,80001df0 <allocproc+0xd8>
  p->pagetable = proc_pagetable(p);
    80001d74:	8526                	mv	a0,s1
    80001d76:	00000097          	auipc	ra,0x0
    80001d7a:	e5c080e7          	jalr	-420(ra) # 80001bd2 <proc_pagetable>
    80001d7e:	892a                	mv	s2,a0
    80001d80:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001d82:	c159                	beqz	a0,80001e08 <allocproc+0xf0>
  memset(&p->context, 0, sizeof(p->context));
    80001d84:	07000613          	li	a2,112
    80001d88:	4581                	li	a1,0
    80001d8a:	06048513          	addi	a0,s1,96
    80001d8e:	fffff097          	auipc	ra,0xfffff
    80001d92:	064080e7          	jalr	100(ra) # 80000df2 <memset>
  p->context.ra = (uint64)forkret;
    80001d96:	00000797          	auipc	a5,0x0
    80001d9a:	db078793          	addi	a5,a5,-592 # 80001b46 <forkret>
    80001d9e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001da0:	60bc                	ld	a5,64(s1)
    80001da2:	6705                	lui	a4,0x1
    80001da4:	97ba                	add	a5,a5,a4
    80001da6:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001da8:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001dac:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001db0:	00007797          	auipc	a5,0x7
    80001db4:	b607a783          	lw	a5,-1184(a5) # 80008910 <ticks>
    80001db8:	16f4a623          	sw	a5,364(s1)
  p->run_time = 0;
    80001dbc:	1604aa23          	sw	zero,372(s1)
  p->wtime = 0;
    80001dc0:	1604ac23          	sw	zero,376(s1)
  p->stime = 0;
    80001dc4:	1604ae23          	sw	zero,380(s1)
  p->SP = 50;
    80001dc8:	03200793          	li	a5,50
    80001dcc:	18f4a023          	sw	a5,384(s1)
  p->RBI = 25;
    80001dd0:	47e5                	li	a5,25
    80001dd2:	18f4a223          	sw	a5,388(s1)
  p->DP = 75;
    80001dd6:	04b00793          	li	a5,75
    80001dda:	18f4a423          	sw	a5,392(s1)
  p->sched_num = 0;
    80001dde:	1804a623          	sw	zero,396(s1)
}
    80001de2:	8526                	mv	a0,s1
    80001de4:	60e2                	ld	ra,24(sp)
    80001de6:	6442                	ld	s0,16(sp)
    80001de8:	64a2                	ld	s1,8(sp)
    80001dea:	6902                	ld	s2,0(sp)
    80001dec:	6105                	addi	sp,sp,32
    80001dee:	8082                	ret
    freeproc(p);
    80001df0:	8526                	mv	a0,s1
    80001df2:	00000097          	auipc	ra,0x0
    80001df6:	ece080e7          	jalr	-306(ra) # 80001cc0 <freeproc>
    release(&p->lock);
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	fae080e7          	jalr	-82(ra) # 80000daa <release>
    return 0;
    80001e04:	84ca                	mv	s1,s2
    80001e06:	bff1                	j	80001de2 <allocproc+0xca>
    freeproc(p);
    80001e08:	8526                	mv	a0,s1
    80001e0a:	00000097          	auipc	ra,0x0
    80001e0e:	eb6080e7          	jalr	-330(ra) # 80001cc0 <freeproc>
    release(&p->lock);
    80001e12:	8526                	mv	a0,s1
    80001e14:	fffff097          	auipc	ra,0xfffff
    80001e18:	f96080e7          	jalr	-106(ra) # 80000daa <release>
    return 0;
    80001e1c:	84ca                	mv	s1,s2
    80001e1e:	b7d1                	j	80001de2 <allocproc+0xca>

0000000080001e20 <userinit>:
{
    80001e20:	1101                	addi	sp,sp,-32
    80001e22:	ec06                	sd	ra,24(sp)
    80001e24:	e822                	sd	s0,16(sp)
    80001e26:	e426                	sd	s1,8(sp)
    80001e28:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e2a:	00000097          	auipc	ra,0x0
    80001e2e:	eee080e7          	jalr	-274(ra) # 80001d18 <allocproc>
    80001e32:	84aa                	mv	s1,a0
  initproc = p;
    80001e34:	00007797          	auipc	a5,0x7
    80001e38:	aca7ba23          	sd	a0,-1324(a5) # 80008908 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e3c:	03400613          	li	a2,52
    80001e40:	00007597          	auipc	a1,0x7
    80001e44:	a6058593          	addi	a1,a1,-1440 # 800088a0 <initcode>
    80001e48:	6928                	ld	a0,80(a0)
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	62c080e7          	jalr	1580(ra) # 80001476 <uvmfirst>
  p->sz = PGSIZE;
    80001e52:	6785                	lui	a5,0x1
    80001e54:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001e56:	6cb8                	ld	a4,88(s1)
    80001e58:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001e5c:	6cb8                	ld	a4,88(s1)
    80001e5e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e60:	4641                	li	a2,16
    80001e62:	00006597          	auipc	a1,0x6
    80001e66:	3be58593          	addi	a1,a1,958 # 80008220 <digits+0x1e0>
    80001e6a:	15848513          	addi	a0,s1,344
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	0ce080e7          	jalr	206(ra) # 80000f3c <safestrcpy>
  p->cwd = namei("/");
    80001e76:	00006517          	auipc	a0,0x6
    80001e7a:	3ba50513          	addi	a0,a0,954 # 80008230 <digits+0x1f0>
    80001e7e:	00002097          	auipc	ra,0x2
    80001e82:	642080e7          	jalr	1602(ra) # 800044c0 <namei>
    80001e86:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e8a:	478d                	li	a5,3
    80001e8c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e8e:	8526                	mv	a0,s1
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	f1a080e7          	jalr	-230(ra) # 80000daa <release>
}
    80001e98:	60e2                	ld	ra,24(sp)
    80001e9a:	6442                	ld	s0,16(sp)
    80001e9c:	64a2                	ld	s1,8(sp)
    80001e9e:	6105                	addi	sp,sp,32
    80001ea0:	8082                	ret

0000000080001ea2 <growproc>:
{
    80001ea2:	1101                	addi	sp,sp,-32
    80001ea4:	ec06                	sd	ra,24(sp)
    80001ea6:	e822                	sd	s0,16(sp)
    80001ea8:	e426                	sd	s1,8(sp)
    80001eaa:	e04a                	sd	s2,0(sp)
    80001eac:	1000                	addi	s0,sp,32
    80001eae:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001eb0:	00000097          	auipc	ra,0x0
    80001eb4:	c5e080e7          	jalr	-930(ra) # 80001b0e <myproc>
    80001eb8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001eba:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001ebc:	01204c63          	bgtz	s2,80001ed4 <growproc+0x32>
  else if (n < 0)
    80001ec0:	02094663          	bltz	s2,80001eec <growproc+0x4a>
  p->sz = sz;
    80001ec4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001ec6:	4501                	li	a0,0
}
    80001ec8:	60e2                	ld	ra,24(sp)
    80001eca:	6442                	ld	s0,16(sp)
    80001ecc:	64a2                	ld	s1,8(sp)
    80001ece:	6902                	ld	s2,0(sp)
    80001ed0:	6105                	addi	sp,sp,32
    80001ed2:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001ed4:	4691                	li	a3,4
    80001ed6:	00b90633          	add	a2,s2,a1
    80001eda:	6928                	ld	a0,80(a0)
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	654080e7          	jalr	1620(ra) # 80001530 <uvmalloc>
    80001ee4:	85aa                	mv	a1,a0
    80001ee6:	fd79                	bnez	a0,80001ec4 <growproc+0x22>
      return -1;
    80001ee8:	557d                	li	a0,-1
    80001eea:	bff9                	j	80001ec8 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001eec:	00b90633          	add	a2,s2,a1
    80001ef0:	6928                	ld	a0,80(a0)
    80001ef2:	fffff097          	auipc	ra,0xfffff
    80001ef6:	5f6080e7          	jalr	1526(ra) # 800014e8 <uvmdealloc>
    80001efa:	85aa                	mv	a1,a0
    80001efc:	b7e1                	j	80001ec4 <growproc+0x22>

0000000080001efe <fork>:
{
    80001efe:	7139                	addi	sp,sp,-64
    80001f00:	fc06                	sd	ra,56(sp)
    80001f02:	f822                	sd	s0,48(sp)
    80001f04:	f426                	sd	s1,40(sp)
    80001f06:	f04a                	sd	s2,32(sp)
    80001f08:	ec4e                	sd	s3,24(sp)
    80001f0a:	e852                	sd	s4,16(sp)
    80001f0c:	e456                	sd	s5,8(sp)
    80001f0e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001f10:	00000097          	auipc	ra,0x0
    80001f14:	bfe080e7          	jalr	-1026(ra) # 80001b0e <myproc>
    80001f18:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001f1a:	00000097          	auipc	ra,0x0
    80001f1e:	dfe080e7          	jalr	-514(ra) # 80001d18 <allocproc>
    80001f22:	10050c63          	beqz	a0,8000203a <fork+0x13c>
    80001f26:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001f28:	048ab603          	ld	a2,72(s5)
    80001f2c:	692c                	ld	a1,80(a0)
    80001f2e:	050ab503          	ld	a0,80(s5)
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	752080e7          	jalr	1874(ra) # 80001684 <uvmcopy>
    80001f3a:	04054863          	bltz	a0,80001f8a <fork+0x8c>
  np->sz = p->sz;
    80001f3e:	048ab783          	ld	a5,72(s5)
    80001f42:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f46:	058ab683          	ld	a3,88(s5)
    80001f4a:	87b6                	mv	a5,a3
    80001f4c:	058a3703          	ld	a4,88(s4)
    80001f50:	12068693          	addi	a3,a3,288
    80001f54:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f58:	6788                	ld	a0,8(a5)
    80001f5a:	6b8c                	ld	a1,16(a5)
    80001f5c:	6f90                	ld	a2,24(a5)
    80001f5e:	01073023          	sd	a6,0(a4)
    80001f62:	e708                	sd	a0,8(a4)
    80001f64:	eb0c                	sd	a1,16(a4)
    80001f66:	ef10                	sd	a2,24(a4)
    80001f68:	02078793          	addi	a5,a5,32
    80001f6c:	02070713          	addi	a4,a4,32
    80001f70:	fed792e3          	bne	a5,a3,80001f54 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f74:	058a3783          	ld	a5,88(s4)
    80001f78:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001f7c:	0d0a8493          	addi	s1,s5,208
    80001f80:	0d0a0913          	addi	s2,s4,208
    80001f84:	150a8993          	addi	s3,s5,336
    80001f88:	a00d                	j	80001faa <fork+0xac>
    freeproc(np);
    80001f8a:	8552                	mv	a0,s4
    80001f8c:	00000097          	auipc	ra,0x0
    80001f90:	d34080e7          	jalr	-716(ra) # 80001cc0 <freeproc>
    release(&np->lock);
    80001f94:	8552                	mv	a0,s4
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	e14080e7          	jalr	-492(ra) # 80000daa <release>
    return -1;
    80001f9e:	597d                	li	s2,-1
    80001fa0:	a059                	j	80002026 <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80001fa2:	04a1                	addi	s1,s1,8
    80001fa4:	0921                	addi	s2,s2,8
    80001fa6:	01348b63          	beq	s1,s3,80001fbc <fork+0xbe>
    if (p->ofile[i])
    80001faa:	6088                	ld	a0,0(s1)
    80001fac:	d97d                	beqz	a0,80001fa2 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001fae:	00003097          	auipc	ra,0x3
    80001fb2:	ba8080e7          	jalr	-1112(ra) # 80004b56 <filedup>
    80001fb6:	00a93023          	sd	a0,0(s2)
    80001fba:	b7e5                	j	80001fa2 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001fbc:	150ab503          	ld	a0,336(s5)
    80001fc0:	00002097          	auipc	ra,0x2
    80001fc4:	d1c080e7          	jalr	-740(ra) # 80003cdc <idup>
    80001fc8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fcc:	4641                	li	a2,16
    80001fce:	158a8593          	addi	a1,s5,344
    80001fd2:	158a0513          	addi	a0,s4,344
    80001fd6:	fffff097          	auipc	ra,0xfffff
    80001fda:	f66080e7          	jalr	-154(ra) # 80000f3c <safestrcpy>
  pid = np->pid;
    80001fde:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001fe2:	8552                	mv	a0,s4
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	dc6080e7          	jalr	-570(ra) # 80000daa <release>
  acquire(&wait_lock);
    80001fec:	0022f497          	auipc	s1,0x22f
    80001ff0:	bc448493          	addi	s1,s1,-1084 # 80230bb0 <wait_lock>
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	fffff097          	auipc	ra,0xfffff
    80001ffa:	d00080e7          	jalr	-768(ra) # 80000cf6 <acquire>
  np->parent = p;
    80001ffe:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80002002:	8526                	mv	a0,s1
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	da6080e7          	jalr	-602(ra) # 80000daa <release>
  acquire(&np->lock);
    8000200c:	8552                	mv	a0,s4
    8000200e:	fffff097          	auipc	ra,0xfffff
    80002012:	ce8080e7          	jalr	-792(ra) # 80000cf6 <acquire>
  np->state = RUNNABLE;
    80002016:	478d                	li	a5,3
    80002018:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000201c:	8552                	mv	a0,s4
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	d8c080e7          	jalr	-628(ra) # 80000daa <release>
}
    80002026:	854a                	mv	a0,s2
    80002028:	70e2                	ld	ra,56(sp)
    8000202a:	7442                	ld	s0,48(sp)
    8000202c:	74a2                	ld	s1,40(sp)
    8000202e:	7902                	ld	s2,32(sp)
    80002030:	69e2                	ld	s3,24(sp)
    80002032:	6a42                	ld	s4,16(sp)
    80002034:	6aa2                	ld	s5,8(sp)
    80002036:	6121                	addi	sp,sp,64
    80002038:	8082                	ret
    return -1;
    8000203a:	597d                	li	s2,-1
    8000203c:	b7ed                	j	80002026 <fork+0x128>

000000008000203e <scheduler>:
{
    8000203e:	711d                	addi	sp,sp,-96
    80002040:	ec86                	sd	ra,88(sp)
    80002042:	e8a2                	sd	s0,80(sp)
    80002044:	e4a6                	sd	s1,72(sp)
    80002046:	e0ca                	sd	s2,64(sp)
    80002048:	fc4e                	sd	s3,56(sp)
    8000204a:	f852                	sd	s4,48(sp)
    8000204c:	f456                	sd	s5,40(sp)
    8000204e:	f05a                	sd	s6,32(sp)
    80002050:	ec5e                	sd	s7,24(sp)
    80002052:	e862                	sd	s8,16(sp)
    80002054:	e466                	sd	s9,8(sp)
    80002056:	e06a                	sd	s10,0(sp)
    80002058:	1080                	addi	s0,sp,96
    8000205a:	8792                	mv	a5,tp
  int id = r_tp();
    8000205c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000205e:	00779c93          	slli	s9,a5,0x7
    80002062:	0022f717          	auipc	a4,0x22f
    80002066:	b3670713          	addi	a4,a4,-1226 # 80230b98 <pid_lock>
    8000206a:	9766                	add	a4,a4,s9
    8000206c:	02073823          	sd	zero,48(a4)
    swtch(&c->context, &p_new->context);
    80002070:	0022f717          	auipc	a4,0x22f
    80002074:	b6070713          	addi	a4,a4,-1184 # 80230bd0 <cpus+0x8>
    80002078:	9cba                	add	s9,s9,a4
      int frac = (num*50)/den;
    8000207a:	03200a13          	li	s4,50
      if(sum < 100)
    8000207e:	06300993          	li	s3,99
        p->DP = 100;
    80002082:	06400b13          	li	s6,100
    for(p = proc; p < &proc[NPROC]; p++)
    80002086:	00235917          	auipc	s2,0x235
    8000208a:	34290913          	addi	s2,s2,834 # 802373c8 <tickslock>
    acquire(&p_new->lock);
    8000208e:	0022fc17          	auipc	s8,0x22f
    80002092:	f3ac0c13          	addi	s8,s8,-198 # 80230fc8 <proc>
      if(p->state == RUNNABLE && p->DP <= p_new->DP)
    80002096:	4a8d                	li	s5,3
    c->proc = p_new;
    80002098:	079e                	slli	a5,a5,0x7
    8000209a:	0022fb97          	auipc	s7,0x22f
    8000209e:	afeb8b93          	addi	s7,s7,-1282 # 80230b98 <pid_lock>
    800020a2:	9bbe                	add	s7,s7,a5
    800020a4:	aaa9                	j	800021fe <scheduler+0x1c0>
    800020a6:	18e4a423          	sw	a4,392(s1)
      release(&p->lock);
    800020aa:	8526                	mv	a0,s1
    800020ac:	fffff097          	auipc	ra,0xfffff
    800020b0:	cfe080e7          	jalr	-770(ra) # 80000daa <release>
    for(p = proc; p < &proc[NPROC]; p++)
    800020b4:	19048493          	addi	s1,s1,400
    800020b8:	05248a63          	beq	s1,s2,8000210c <scheduler+0xce>
      acquire(&p->lock);
    800020bc:	8526                	mv	a0,s1
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	c38080e7          	jalr	-968(ra) # 80000cf6 <acquire>
      int num = (3*p->run_time) - p->stime - p->wtime;
    800020c6:	1744a703          	lw	a4,372(s1)
    800020ca:	17c4a603          	lw	a2,380(s1)
    800020ce:	1784a683          	lw	a3,376(s1)
    800020d2:	0017179b          	slliw	a5,a4,0x1
    800020d6:	9fb9                	addw	a5,a5,a4
    800020d8:	9f91                	subw	a5,a5,a2
    800020da:	9f95                	subw	a5,a5,a3
      int frac = (num*50)/den;
    800020dc:	034787bb          	mulw	a5,a5,s4
      int den = p->run_time + p->wtime + p->stime + 1;
    800020e0:	9f31                	addw	a4,a4,a2
    800020e2:	2705                	addiw	a4,a4,1
    800020e4:	9f35                	addw	a4,a4,a3
      int frac = (num*50)/den;
    800020e6:	02e7c7bb          	divw	a5,a5,a4
    800020ea:	0007871b          	sext.w	a4,a5
    800020ee:	fff74713          	not	a4,a4
    800020f2:	977d                	srai	a4,a4,0x3f
    800020f4:	8ff9                	and	a5,a5,a4
    800020f6:	18f4a223          	sw	a5,388(s1)
      int sum = p->RBI + p->SP;
    800020fa:	1804a703          	lw	a4,384(s1)
    800020fe:	9fb9                	addw	a5,a5,a4
    80002100:	0007871b          	sext.w	a4,a5
      if(sum < 100)
    80002104:	fae9d1e3          	bge	s3,a4,800020a6 <scheduler+0x68>
        p->DP = 100;
    80002108:	875a                	mv	a4,s6
    8000210a:	bf71                	j	800020a6 <scheduler+0x68>
    acquire(&p_new->lock);
    8000210c:	8562                	mv	a0,s8
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	be8080e7          	jalr	-1048(ra) # 80000cf6 <acquire>
    p_new = proc;
    80002116:	8d62                	mv	s10,s8
    for(p = proc+1; p < &proc[NPROC]; p++)
    80002118:	0022f497          	auipc	s1,0x22f
    8000211c:	04048493          	addi	s1,s1,64 # 80231158 <proc+0x190>
    80002120:	a895                	j	80002194 <scheduler+0x156>
          if(p->sched_num <= p_new->sched_num)
    80002122:	18c4a703          	lw	a4,396(s1)
    80002126:	18cd2783          	lw	a5,396(s10)
    8000212a:	04e7e063          	bltu	a5,a4,8000216a <scheduler+0x12c>
            if(p->sched_num == p_new->sched_num && p->ctime > p_new->ctime)
    8000212e:	00f70b63          	beq	a4,a5,80002144 <scheduler+0x106>
            else if(p->sched_num < p_new->sched_num)
    80002132:	02f77663          	bgeu	a4,a5,8000215e <scheduler+0x120>
              release(&p_new->lock);
    80002136:	856a                	mv	a0,s10
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	c72080e7          	jalr	-910(ra) # 80000daa <release>
              p_new = p;
    80002140:	8d26                	mv	s10,s1
    80002142:	a0a9                	j	8000218c <scheduler+0x14e>
            if(p->sched_num == p_new->sched_num && p->ctime > p_new->ctime)
    80002144:	16c4a603          	lw	a2,364(s1)
    80002148:	16cd2683          	lw	a3,364(s10)
    8000214c:	fec6f3e3          	bgeu	a3,a2,80002132 <scheduler+0xf4>
              release(&p_new->lock);
    80002150:	856a                	mv	a0,s10
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	c58080e7          	jalr	-936(ra) # 80000daa <release>
              p_new = p;
    8000215a:	8d26                	mv	s10,s1
    8000215c:	a805                	j	8000218c <scheduler+0x14e>
              release(&p->lock);
    8000215e:	8526                	mv	a0,s1
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	c4a080e7          	jalr	-950(ra) # 80000daa <release>
    80002168:	a015                	j	8000218c <scheduler+0x14e>
            release(&p->lock);
    8000216a:	8526                	mv	a0,s1
    8000216c:	fffff097          	auipc	ra,0xfffff
    80002170:	c3e080e7          	jalr	-962(ra) # 80000daa <release>
    80002174:	a821                	j	8000218c <scheduler+0x14e>
          release(&p->lock);
    80002176:	8526                	mv	a0,s1
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	c32080e7          	jalr	-974(ra) # 80000daa <release>
    80002180:	a031                	j	8000218c <scheduler+0x14e>
        release(&p->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	c26080e7          	jalr	-986(ra) # 80000daa <release>
    for(p = proc+1; p < &proc[NPROC]; p++)
    8000218c:	19048493          	addi	s1,s1,400
    80002190:	03248b63          	beq	s1,s2,800021c6 <scheduler+0x188>
      acquire(&p->lock);
    80002194:	8526                	mv	a0,s1
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	b60080e7          	jalr	-1184(ra) # 80000cf6 <acquire>
      if(p->state == RUNNABLE && p->DP <= p_new->DP)
    8000219e:	4c9c                	lw	a5,24(s1)
    800021a0:	ff5791e3          	bne	a5,s5,80002182 <scheduler+0x144>
    800021a4:	1884a703          	lw	a4,392(s1)
    800021a8:	188d2783          	lw	a5,392(s10)
    800021ac:	fce7ebe3          	bltu	a5,a4,80002182 <scheduler+0x144>
        if(p->DP == p_new->DP)
    800021b0:	f6f709e3          	beq	a4,a5,80002122 <scheduler+0xe4>
        else if(p->DP < p_new->DP)
    800021b4:	fcf771e3          	bgeu	a4,a5,80002176 <scheduler+0x138>
          release(&p_new->lock);
    800021b8:	856a                	mv	a0,s10
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	bf0080e7          	jalr	-1040(ra) # 80000daa <release>
          p_new = p;
    800021c2:	8d26                	mv	s10,s1
    800021c4:	b7e1                	j	8000218c <scheduler+0x14e>
    p_new->run_time = 0;
    800021c6:	160d2a23          	sw	zero,372(s10)
    p_new->sched_num++;
    800021ca:	18cd2783          	lw	a5,396(s10)
    800021ce:	2785                	addiw	a5,a5,1
    800021d0:	18fd2623          	sw	a5,396(s10)
    p_new->stime = 0;
    800021d4:	160d2e23          	sw	zero,380(s10)
    p_new->state = RUNNING;
    800021d8:	4791                	li	a5,4
    800021da:	00fd2c23          	sw	a5,24(s10)
    c->proc = p_new;
    800021de:	03abb823          	sd	s10,48(s7)
    swtch(&c->context, &p_new->context);
    800021e2:	060d0593          	addi	a1,s10,96
    800021e6:	8566                	mv	a0,s9
    800021e8:	00001097          	auipc	ra,0x1
    800021ec:	88a080e7          	jalr	-1910(ra) # 80002a72 <swtch>
    c->proc = 0;
    800021f0:	020bb823          	sd	zero,48(s7)
    release(&p_new->lock);
    800021f4:	856a                	mv	a0,s10
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	bb4080e7          	jalr	-1100(ra) # 80000daa <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002202:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002206:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++)
    8000220a:	0022f497          	auipc	s1,0x22f
    8000220e:	dbe48493          	addi	s1,s1,-578 # 80230fc8 <proc>
    80002212:	b56d                	j	800020bc <scheduler+0x7e>

0000000080002214 <sched>:
{
    80002214:	7179                	addi	sp,sp,-48
    80002216:	f406                	sd	ra,40(sp)
    80002218:	f022                	sd	s0,32(sp)
    8000221a:	ec26                	sd	s1,24(sp)
    8000221c:	e84a                	sd	s2,16(sp)
    8000221e:	e44e                	sd	s3,8(sp)
    80002220:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002222:	00000097          	auipc	ra,0x0
    80002226:	8ec080e7          	jalr	-1812(ra) # 80001b0e <myproc>
    8000222a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	a50080e7          	jalr	-1456(ra) # 80000c7c <holding>
    80002234:	c93d                	beqz	a0,800022aa <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002236:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002238:	2781                	sext.w	a5,a5
    8000223a:	079e                	slli	a5,a5,0x7
    8000223c:	0022f717          	auipc	a4,0x22f
    80002240:	95c70713          	addi	a4,a4,-1700 # 80230b98 <pid_lock>
    80002244:	97ba                	add	a5,a5,a4
    80002246:	0a87a703          	lw	a4,168(a5)
    8000224a:	4785                	li	a5,1
    8000224c:	06f71763          	bne	a4,a5,800022ba <sched+0xa6>
  if (p->state == RUNNING)
    80002250:	4c98                	lw	a4,24(s1)
    80002252:	4791                	li	a5,4
    80002254:	06f70b63          	beq	a4,a5,800022ca <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002258:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000225c:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000225e:	efb5                	bnez	a5,800022da <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002260:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002262:	0022f917          	auipc	s2,0x22f
    80002266:	93690913          	addi	s2,s2,-1738 # 80230b98 <pid_lock>
    8000226a:	2781                	sext.w	a5,a5
    8000226c:	079e                	slli	a5,a5,0x7
    8000226e:	97ca                	add	a5,a5,s2
    80002270:	0ac7a983          	lw	s3,172(a5)
    80002274:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002276:	2781                	sext.w	a5,a5
    80002278:	079e                	slli	a5,a5,0x7
    8000227a:	0022f597          	auipc	a1,0x22f
    8000227e:	95658593          	addi	a1,a1,-1706 # 80230bd0 <cpus+0x8>
    80002282:	95be                	add	a1,a1,a5
    80002284:	06048513          	addi	a0,s1,96
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	7ea080e7          	jalr	2026(ra) # 80002a72 <swtch>
    80002290:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002292:	2781                	sext.w	a5,a5
    80002294:	079e                	slli	a5,a5,0x7
    80002296:	97ca                	add	a5,a5,s2
    80002298:	0b37a623          	sw	s3,172(a5)
}
    8000229c:	70a2                	ld	ra,40(sp)
    8000229e:	7402                	ld	s0,32(sp)
    800022a0:	64e2                	ld	s1,24(sp)
    800022a2:	6942                	ld	s2,16(sp)
    800022a4:	69a2                	ld	s3,8(sp)
    800022a6:	6145                	addi	sp,sp,48
    800022a8:	8082                	ret
    panic("sched p->lock");
    800022aa:	00006517          	auipc	a0,0x6
    800022ae:	f8e50513          	addi	a0,a0,-114 # 80008238 <digits+0x1f8>
    800022b2:	ffffe097          	auipc	ra,0xffffe
    800022b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
    panic("sched locks");
    800022ba:	00006517          	auipc	a0,0x6
    800022be:	f8e50513          	addi	a0,a0,-114 # 80008248 <digits+0x208>
    800022c2:	ffffe097          	auipc	ra,0xffffe
    800022c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
    panic("sched running");
    800022ca:	00006517          	auipc	a0,0x6
    800022ce:	f8e50513          	addi	a0,a0,-114 # 80008258 <digits+0x218>
    800022d2:	ffffe097          	auipc	ra,0xffffe
    800022d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
    panic("sched interruptible");
    800022da:	00006517          	auipc	a0,0x6
    800022de:	f8e50513          	addi	a0,a0,-114 # 80008268 <digits+0x228>
    800022e2:	ffffe097          	auipc	ra,0xffffe
    800022e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>

00000000800022ea <yield>:
{
    800022ea:	1101                	addi	sp,sp,-32
    800022ec:	ec06                	sd	ra,24(sp)
    800022ee:	e822                	sd	s0,16(sp)
    800022f0:	e426                	sd	s1,8(sp)
    800022f2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022f4:	00000097          	auipc	ra,0x0
    800022f8:	81a080e7          	jalr	-2022(ra) # 80001b0e <myproc>
    800022fc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	9f8080e7          	jalr	-1544(ra) # 80000cf6 <acquire>
  p->state = RUNNABLE;
    80002306:	478d                	li	a5,3
    80002308:	cc9c                	sw	a5,24(s1)
  sched();
    8000230a:	00000097          	auipc	ra,0x0
    8000230e:	f0a080e7          	jalr	-246(ra) # 80002214 <sched>
  release(&p->lock);
    80002312:	8526                	mv	a0,s1
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	a96080e7          	jalr	-1386(ra) # 80000daa <release>
}
    8000231c:	60e2                	ld	ra,24(sp)
    8000231e:	6442                	ld	s0,16(sp)
    80002320:	64a2                	ld	s1,8(sp)
    80002322:	6105                	addi	sp,sp,32
    80002324:	8082                	ret

0000000080002326 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002326:	7179                	addi	sp,sp,-48
    80002328:	f406                	sd	ra,40(sp)
    8000232a:	f022                	sd	s0,32(sp)
    8000232c:	ec26                	sd	s1,24(sp)
    8000232e:	e84a                	sd	s2,16(sp)
    80002330:	e44e                	sd	s3,8(sp)
    80002332:	1800                	addi	s0,sp,48
    80002334:	89aa                	mv	s3,a0
    80002336:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	7d6080e7          	jalr	2006(ra) # 80001b0e <myproc>
    80002340:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	9b4080e7          	jalr	-1612(ra) # 80000cf6 <acquire>
  release(lk);
    8000234a:	854a                	mv	a0,s2
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	a5e080e7          	jalr	-1442(ra) # 80000daa <release>

  // Go to sleep.
  p->chan = chan;
    80002354:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002358:	4789                	li	a5,2
    8000235a:	cc9c                	sw	a5,24(s1)

  sched();
    8000235c:	00000097          	auipc	ra,0x0
    80002360:	eb8080e7          	jalr	-328(ra) # 80002214 <sched>

  // Tidy up.
  p->chan = 0;
    80002364:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	a40080e7          	jalr	-1472(ra) # 80000daa <release>
  acquire(lk);
    80002372:	854a                	mv	a0,s2
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	982080e7          	jalr	-1662(ra) # 80000cf6 <acquire>
}
    8000237c:	70a2                	ld	ra,40(sp)
    8000237e:	7402                	ld	s0,32(sp)
    80002380:	64e2                	ld	s1,24(sp)
    80002382:	6942                	ld	s2,16(sp)
    80002384:	69a2                	ld	s3,8(sp)
    80002386:	6145                	addi	sp,sp,48
    80002388:	8082                	ret

000000008000238a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000238a:	7139                	addi	sp,sp,-64
    8000238c:	fc06                	sd	ra,56(sp)
    8000238e:	f822                	sd	s0,48(sp)
    80002390:	f426                	sd	s1,40(sp)
    80002392:	f04a                	sd	s2,32(sp)
    80002394:	ec4e                	sd	s3,24(sp)
    80002396:	e852                	sd	s4,16(sp)
    80002398:	e456                	sd	s5,8(sp)
    8000239a:	0080                	addi	s0,sp,64
    8000239c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000239e:	0022f497          	auipc	s1,0x22f
    800023a2:	c2a48493          	addi	s1,s1,-982 # 80230fc8 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800023a6:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800023a8:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800023aa:	00235917          	auipc	s2,0x235
    800023ae:	01e90913          	addi	s2,s2,30 # 802373c8 <tickslock>
    800023b2:	a811                	j	800023c6 <wakeup+0x3c>
      }
      release(&p->lock);
    800023b4:	8526                	mv	a0,s1
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	9f4080e7          	jalr	-1548(ra) # 80000daa <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023be:	19048493          	addi	s1,s1,400
    800023c2:	03248663          	beq	s1,s2,800023ee <wakeup+0x64>
    if (p != myproc())
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	748080e7          	jalr	1864(ra) # 80001b0e <myproc>
    800023ce:	fea488e3          	beq	s1,a0,800023be <wakeup+0x34>
      acquire(&p->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	922080e7          	jalr	-1758(ra) # 80000cf6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800023dc:	4c9c                	lw	a5,24(s1)
    800023de:	fd379be3          	bne	a5,s3,800023b4 <wakeup+0x2a>
    800023e2:	709c                	ld	a5,32(s1)
    800023e4:	fd4798e3          	bne	a5,s4,800023b4 <wakeup+0x2a>
        p->state = RUNNABLE;
    800023e8:	0154ac23          	sw	s5,24(s1)
    800023ec:	b7e1                	j	800023b4 <wakeup+0x2a>
    }
  }
}
    800023ee:	70e2                	ld	ra,56(sp)
    800023f0:	7442                	ld	s0,48(sp)
    800023f2:	74a2                	ld	s1,40(sp)
    800023f4:	7902                	ld	s2,32(sp)
    800023f6:	69e2                	ld	s3,24(sp)
    800023f8:	6a42                	ld	s4,16(sp)
    800023fa:	6aa2                	ld	s5,8(sp)
    800023fc:	6121                	addi	sp,sp,64
    800023fe:	8082                	ret

0000000080002400 <reparent>:
{
    80002400:	7179                	addi	sp,sp,-48
    80002402:	f406                	sd	ra,40(sp)
    80002404:	f022                	sd	s0,32(sp)
    80002406:	ec26                	sd	s1,24(sp)
    80002408:	e84a                	sd	s2,16(sp)
    8000240a:	e44e                	sd	s3,8(sp)
    8000240c:	e052                	sd	s4,0(sp)
    8000240e:	1800                	addi	s0,sp,48
    80002410:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002412:	0022f497          	auipc	s1,0x22f
    80002416:	bb648493          	addi	s1,s1,-1098 # 80230fc8 <proc>
      pp->parent = initproc;
    8000241a:	00006a17          	auipc	s4,0x6
    8000241e:	4eea0a13          	addi	s4,s4,1262 # 80008908 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002422:	00235997          	auipc	s3,0x235
    80002426:	fa698993          	addi	s3,s3,-90 # 802373c8 <tickslock>
    8000242a:	a029                	j	80002434 <reparent+0x34>
    8000242c:	19048493          	addi	s1,s1,400
    80002430:	01348d63          	beq	s1,s3,8000244a <reparent+0x4a>
    if (pp->parent == p)
    80002434:	7c9c                	ld	a5,56(s1)
    80002436:	ff279be3          	bne	a5,s2,8000242c <reparent+0x2c>
      pp->parent = initproc;
    8000243a:	000a3503          	ld	a0,0(s4)
    8000243e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002440:	00000097          	auipc	ra,0x0
    80002444:	f4a080e7          	jalr	-182(ra) # 8000238a <wakeup>
    80002448:	b7d5                	j	8000242c <reparent+0x2c>
}
    8000244a:	70a2                	ld	ra,40(sp)
    8000244c:	7402                	ld	s0,32(sp)
    8000244e:	64e2                	ld	s1,24(sp)
    80002450:	6942                	ld	s2,16(sp)
    80002452:	69a2                	ld	s3,8(sp)
    80002454:	6a02                	ld	s4,0(sp)
    80002456:	6145                	addi	sp,sp,48
    80002458:	8082                	ret

000000008000245a <exit>:
{
    8000245a:	7179                	addi	sp,sp,-48
    8000245c:	f406                	sd	ra,40(sp)
    8000245e:	f022                	sd	s0,32(sp)
    80002460:	ec26                	sd	s1,24(sp)
    80002462:	e84a                	sd	s2,16(sp)
    80002464:	e44e                	sd	s3,8(sp)
    80002466:	e052                	sd	s4,0(sp)
    80002468:	1800                	addi	s0,sp,48
    8000246a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	6a2080e7          	jalr	1698(ra) # 80001b0e <myproc>
    80002474:	89aa                	mv	s3,a0
  if (p == initproc)
    80002476:	00006797          	auipc	a5,0x6
    8000247a:	4927b783          	ld	a5,1170(a5) # 80008908 <initproc>
    8000247e:	0d050493          	addi	s1,a0,208
    80002482:	15050913          	addi	s2,a0,336
    80002486:	02a79363          	bne	a5,a0,800024ac <exit+0x52>
    panic("init exiting");
    8000248a:	00006517          	auipc	a0,0x6
    8000248e:	df650513          	addi	a0,a0,-522 # 80008280 <digits+0x240>
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	0ac080e7          	jalr	172(ra) # 8000053e <panic>
      fileclose(f);
    8000249a:	00002097          	auipc	ra,0x2
    8000249e:	70e080e7          	jalr	1806(ra) # 80004ba8 <fileclose>
      p->ofile[fd] = 0;
    800024a2:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800024a6:	04a1                	addi	s1,s1,8
    800024a8:	01248563          	beq	s1,s2,800024b2 <exit+0x58>
    if (p->ofile[fd])
    800024ac:	6088                	ld	a0,0(s1)
    800024ae:	f575                	bnez	a0,8000249a <exit+0x40>
    800024b0:	bfdd                	j	800024a6 <exit+0x4c>
  begin_op();
    800024b2:	00002097          	auipc	ra,0x2
    800024b6:	22a080e7          	jalr	554(ra) # 800046dc <begin_op>
  iput(p->cwd);
    800024ba:	1509b503          	ld	a0,336(s3)
    800024be:	00002097          	auipc	ra,0x2
    800024c2:	a16080e7          	jalr	-1514(ra) # 80003ed4 <iput>
  end_op();
    800024c6:	00002097          	auipc	ra,0x2
    800024ca:	296080e7          	jalr	662(ra) # 8000475c <end_op>
  p->cwd = 0;
    800024ce:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800024d2:	0022e497          	auipc	s1,0x22e
    800024d6:	6de48493          	addi	s1,s1,1758 # 80230bb0 <wait_lock>
    800024da:	8526                	mv	a0,s1
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	81a080e7          	jalr	-2022(ra) # 80000cf6 <acquire>
  reparent(p);
    800024e4:	854e                	mv	a0,s3
    800024e6:	00000097          	auipc	ra,0x0
    800024ea:	f1a080e7          	jalr	-230(ra) # 80002400 <reparent>
  wakeup(p->parent);
    800024ee:	0389b503          	ld	a0,56(s3)
    800024f2:	00000097          	auipc	ra,0x0
    800024f6:	e98080e7          	jalr	-360(ra) # 8000238a <wakeup>
  acquire(&p->lock);
    800024fa:	854e                	mv	a0,s3
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	7fa080e7          	jalr	2042(ra) # 80000cf6 <acquire>
  p->xstate = status;
    80002504:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002508:	4795                	li	a5,5
    8000250a:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000250e:	00006797          	auipc	a5,0x6
    80002512:	4027a783          	lw	a5,1026(a5) # 80008910 <ticks>
    80002516:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000251a:	8526                	mv	a0,s1
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	88e080e7          	jalr	-1906(ra) # 80000daa <release>
  sched();
    80002524:	00000097          	auipc	ra,0x0
    80002528:	cf0080e7          	jalr	-784(ra) # 80002214 <sched>
  panic("zombie exit");
    8000252c:	00006517          	auipc	a0,0x6
    80002530:	d6450513          	addi	a0,a0,-668 # 80008290 <digits+0x250>
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	00a080e7          	jalr	10(ra) # 8000053e <panic>

000000008000253c <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000253c:	7179                	addi	sp,sp,-48
    8000253e:	f406                	sd	ra,40(sp)
    80002540:	f022                	sd	s0,32(sp)
    80002542:	ec26                	sd	s1,24(sp)
    80002544:	e84a                	sd	s2,16(sp)
    80002546:	e44e                	sd	s3,8(sp)
    80002548:	1800                	addi	s0,sp,48
    8000254a:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000254c:	0022f497          	auipc	s1,0x22f
    80002550:	a7c48493          	addi	s1,s1,-1412 # 80230fc8 <proc>
    80002554:	00235997          	auipc	s3,0x235
    80002558:	e7498993          	addi	s3,s3,-396 # 802373c8 <tickslock>
  {
    acquire(&p->lock);
    8000255c:	8526                	mv	a0,s1
    8000255e:	ffffe097          	auipc	ra,0xffffe
    80002562:	798080e7          	jalr	1944(ra) # 80000cf6 <acquire>
    if (p->pid == pid)
    80002566:	589c                	lw	a5,48(s1)
    80002568:	01278d63          	beq	a5,s2,80002582 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000256c:	8526                	mv	a0,s1
    8000256e:	fffff097          	auipc	ra,0xfffff
    80002572:	83c080e7          	jalr	-1988(ra) # 80000daa <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002576:	19048493          	addi	s1,s1,400
    8000257a:	ff3491e3          	bne	s1,s3,8000255c <kill+0x20>
  }
  return -1;
    8000257e:	557d                	li	a0,-1
    80002580:	a829                	j	8000259a <kill+0x5e>
      p->killed = 1;
    80002582:	4785                	li	a5,1
    80002584:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002586:	4c98                	lw	a4,24(s1)
    80002588:	4789                	li	a5,2
    8000258a:	00f70f63          	beq	a4,a5,800025a8 <kill+0x6c>
      release(&p->lock);
    8000258e:	8526                	mv	a0,s1
    80002590:	fffff097          	auipc	ra,0xfffff
    80002594:	81a080e7          	jalr	-2022(ra) # 80000daa <release>
      return 0;
    80002598:	4501                	li	a0,0
}
    8000259a:	70a2                	ld	ra,40(sp)
    8000259c:	7402                	ld	s0,32(sp)
    8000259e:	64e2                	ld	s1,24(sp)
    800025a0:	6942                	ld	s2,16(sp)
    800025a2:	69a2                	ld	s3,8(sp)
    800025a4:	6145                	addi	sp,sp,48
    800025a6:	8082                	ret
        p->state = RUNNABLE;
    800025a8:	478d                	li	a5,3
    800025aa:	cc9c                	sw	a5,24(s1)
    800025ac:	b7cd                	j	8000258e <kill+0x52>

00000000800025ae <setkilled>:

void setkilled(struct proc *p)
{
    800025ae:	1101                	addi	sp,sp,-32
    800025b0:	ec06                	sd	ra,24(sp)
    800025b2:	e822                	sd	s0,16(sp)
    800025b4:	e426                	sd	s1,8(sp)
    800025b6:	1000                	addi	s0,sp,32
    800025b8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	73c080e7          	jalr	1852(ra) # 80000cf6 <acquire>
  p->killed = 1;
    800025c2:	4785                	li	a5,1
    800025c4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800025c6:	8526                	mv	a0,s1
    800025c8:	ffffe097          	auipc	ra,0xffffe
    800025cc:	7e2080e7          	jalr	2018(ra) # 80000daa <release>
}
    800025d0:	60e2                	ld	ra,24(sp)
    800025d2:	6442                	ld	s0,16(sp)
    800025d4:	64a2                	ld	s1,8(sp)
    800025d6:	6105                	addi	sp,sp,32
    800025d8:	8082                	ret

00000000800025da <killed>:

int killed(struct proc *p)
{
    800025da:	1101                	addi	sp,sp,-32
    800025dc:	ec06                	sd	ra,24(sp)
    800025de:	e822                	sd	s0,16(sp)
    800025e0:	e426                	sd	s1,8(sp)
    800025e2:	e04a                	sd	s2,0(sp)
    800025e4:	1000                	addi	s0,sp,32
    800025e6:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	70e080e7          	jalr	1806(ra) # 80000cf6 <acquire>
  k = p->killed;
    800025f0:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800025f4:	8526                	mv	a0,s1
    800025f6:	ffffe097          	auipc	ra,0xffffe
    800025fa:	7b4080e7          	jalr	1972(ra) # 80000daa <release>
  return k;
}
    800025fe:	854a                	mv	a0,s2
    80002600:	60e2                	ld	ra,24(sp)
    80002602:	6442                	ld	s0,16(sp)
    80002604:	64a2                	ld	s1,8(sp)
    80002606:	6902                	ld	s2,0(sp)
    80002608:	6105                	addi	sp,sp,32
    8000260a:	8082                	ret

000000008000260c <wait>:
{
    8000260c:	715d                	addi	sp,sp,-80
    8000260e:	e486                	sd	ra,72(sp)
    80002610:	e0a2                	sd	s0,64(sp)
    80002612:	fc26                	sd	s1,56(sp)
    80002614:	f84a                	sd	s2,48(sp)
    80002616:	f44e                	sd	s3,40(sp)
    80002618:	f052                	sd	s4,32(sp)
    8000261a:	ec56                	sd	s5,24(sp)
    8000261c:	e85a                	sd	s6,16(sp)
    8000261e:	e45e                	sd	s7,8(sp)
    80002620:	e062                	sd	s8,0(sp)
    80002622:	0880                	addi	s0,sp,80
    80002624:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002626:	fffff097          	auipc	ra,0xfffff
    8000262a:	4e8080e7          	jalr	1256(ra) # 80001b0e <myproc>
    8000262e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002630:	0022e517          	auipc	a0,0x22e
    80002634:	58050513          	addi	a0,a0,1408 # 80230bb0 <wait_lock>
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	6be080e7          	jalr	1726(ra) # 80000cf6 <acquire>
    havekids = 0;
    80002640:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002642:	4a15                	li	s4,5
        havekids = 1;
    80002644:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002646:	00235997          	auipc	s3,0x235
    8000264a:	d8298993          	addi	s3,s3,-638 # 802373c8 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000264e:	0022ec17          	auipc	s8,0x22e
    80002652:	562c0c13          	addi	s8,s8,1378 # 80230bb0 <wait_lock>
    havekids = 0;
    80002656:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002658:	0022f497          	auipc	s1,0x22f
    8000265c:	97048493          	addi	s1,s1,-1680 # 80230fc8 <proc>
    80002660:	a0bd                	j	800026ce <wait+0xc2>
          pid = pp->pid;
    80002662:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002666:	000b0e63          	beqz	s6,80002682 <wait+0x76>
    8000266a:	4691                	li	a3,4
    8000266c:	02c48613          	addi	a2,s1,44
    80002670:	85da                	mv	a1,s6
    80002672:	05093503          	ld	a0,80(s2)
    80002676:	fffff097          	auipc	ra,0xfffff
    8000267a:	118080e7          	jalr	280(ra) # 8000178e <copyout>
    8000267e:	02054563          	bltz	a0,800026a8 <wait+0x9c>
          freeproc(pp);
    80002682:	8526                	mv	a0,s1
    80002684:	fffff097          	auipc	ra,0xfffff
    80002688:	63c080e7          	jalr	1596(ra) # 80001cc0 <freeproc>
          release(&pp->lock);
    8000268c:	8526                	mv	a0,s1
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	71c080e7          	jalr	1820(ra) # 80000daa <release>
          release(&wait_lock);
    80002696:	0022e517          	auipc	a0,0x22e
    8000269a:	51a50513          	addi	a0,a0,1306 # 80230bb0 <wait_lock>
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	70c080e7          	jalr	1804(ra) # 80000daa <release>
          return pid;
    800026a6:	a0b5                	j	80002712 <wait+0x106>
            release(&pp->lock);
    800026a8:	8526                	mv	a0,s1
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	700080e7          	jalr	1792(ra) # 80000daa <release>
            release(&wait_lock);
    800026b2:	0022e517          	auipc	a0,0x22e
    800026b6:	4fe50513          	addi	a0,a0,1278 # 80230bb0 <wait_lock>
    800026ba:	ffffe097          	auipc	ra,0xffffe
    800026be:	6f0080e7          	jalr	1776(ra) # 80000daa <release>
            return -1;
    800026c2:	59fd                	li	s3,-1
    800026c4:	a0b9                	j	80002712 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800026c6:	19048493          	addi	s1,s1,400
    800026ca:	03348463          	beq	s1,s3,800026f2 <wait+0xe6>
      if (pp->parent == p)
    800026ce:	7c9c                	ld	a5,56(s1)
    800026d0:	ff279be3          	bne	a5,s2,800026c6 <wait+0xba>
        acquire(&pp->lock);
    800026d4:	8526                	mv	a0,s1
    800026d6:	ffffe097          	auipc	ra,0xffffe
    800026da:	620080e7          	jalr	1568(ra) # 80000cf6 <acquire>
        if (pp->state == ZOMBIE)
    800026de:	4c9c                	lw	a5,24(s1)
    800026e0:	f94781e3          	beq	a5,s4,80002662 <wait+0x56>
        release(&pp->lock);
    800026e4:	8526                	mv	a0,s1
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	6c4080e7          	jalr	1732(ra) # 80000daa <release>
        havekids = 1;
    800026ee:	8756                	mv	a4,s5
    800026f0:	bfd9                	j	800026c6 <wait+0xba>
    if (!havekids || killed(p))
    800026f2:	c719                	beqz	a4,80002700 <wait+0xf4>
    800026f4:	854a                	mv	a0,s2
    800026f6:	00000097          	auipc	ra,0x0
    800026fa:	ee4080e7          	jalr	-284(ra) # 800025da <killed>
    800026fe:	c51d                	beqz	a0,8000272c <wait+0x120>
      release(&wait_lock);
    80002700:	0022e517          	auipc	a0,0x22e
    80002704:	4b050513          	addi	a0,a0,1200 # 80230bb0 <wait_lock>
    80002708:	ffffe097          	auipc	ra,0xffffe
    8000270c:	6a2080e7          	jalr	1698(ra) # 80000daa <release>
      return -1;
    80002710:	59fd                	li	s3,-1
}
    80002712:	854e                	mv	a0,s3
    80002714:	60a6                	ld	ra,72(sp)
    80002716:	6406                	ld	s0,64(sp)
    80002718:	74e2                	ld	s1,56(sp)
    8000271a:	7942                	ld	s2,48(sp)
    8000271c:	79a2                	ld	s3,40(sp)
    8000271e:	7a02                	ld	s4,32(sp)
    80002720:	6ae2                	ld	s5,24(sp)
    80002722:	6b42                	ld	s6,16(sp)
    80002724:	6ba2                	ld	s7,8(sp)
    80002726:	6c02                	ld	s8,0(sp)
    80002728:	6161                	addi	sp,sp,80
    8000272a:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000272c:	85e2                	mv	a1,s8
    8000272e:	854a                	mv	a0,s2
    80002730:	00000097          	auipc	ra,0x0
    80002734:	bf6080e7          	jalr	-1034(ra) # 80002326 <sleep>
    havekids = 0;
    80002738:	bf39                	j	80002656 <wait+0x4a>

000000008000273a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000273a:	7179                	addi	sp,sp,-48
    8000273c:	f406                	sd	ra,40(sp)
    8000273e:	f022                	sd	s0,32(sp)
    80002740:	ec26                	sd	s1,24(sp)
    80002742:	e84a                	sd	s2,16(sp)
    80002744:	e44e                	sd	s3,8(sp)
    80002746:	e052                	sd	s4,0(sp)
    80002748:	1800                	addi	s0,sp,48
    8000274a:	84aa                	mv	s1,a0
    8000274c:	892e                	mv	s2,a1
    8000274e:	89b2                	mv	s3,a2
    80002750:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002752:	fffff097          	auipc	ra,0xfffff
    80002756:	3bc080e7          	jalr	956(ra) # 80001b0e <myproc>
  if (user_dst)
    8000275a:	c08d                	beqz	s1,8000277c <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000275c:	86d2                	mv	a3,s4
    8000275e:	864e                	mv	a2,s3
    80002760:	85ca                	mv	a1,s2
    80002762:	6928                	ld	a0,80(a0)
    80002764:	fffff097          	auipc	ra,0xfffff
    80002768:	02a080e7          	jalr	42(ra) # 8000178e <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000276c:	70a2                	ld	ra,40(sp)
    8000276e:	7402                	ld	s0,32(sp)
    80002770:	64e2                	ld	s1,24(sp)
    80002772:	6942                	ld	s2,16(sp)
    80002774:	69a2                	ld	s3,8(sp)
    80002776:	6a02                	ld	s4,0(sp)
    80002778:	6145                	addi	sp,sp,48
    8000277a:	8082                	ret
    memmove((char *)dst, src, len);
    8000277c:	000a061b          	sext.w	a2,s4
    80002780:	85ce                	mv	a1,s3
    80002782:	854a                	mv	a0,s2
    80002784:	ffffe097          	auipc	ra,0xffffe
    80002788:	6ca080e7          	jalr	1738(ra) # 80000e4e <memmove>
    return 0;
    8000278c:	8526                	mv	a0,s1
    8000278e:	bff9                	j	8000276c <either_copyout+0x32>

0000000080002790 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002790:	7179                	addi	sp,sp,-48
    80002792:	f406                	sd	ra,40(sp)
    80002794:	f022                	sd	s0,32(sp)
    80002796:	ec26                	sd	s1,24(sp)
    80002798:	e84a                	sd	s2,16(sp)
    8000279a:	e44e                	sd	s3,8(sp)
    8000279c:	e052                	sd	s4,0(sp)
    8000279e:	1800                	addi	s0,sp,48
    800027a0:	892a                	mv	s2,a0
    800027a2:	84ae                	mv	s1,a1
    800027a4:	89b2                	mv	s3,a2
    800027a6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027a8:	fffff097          	auipc	ra,0xfffff
    800027ac:	366080e7          	jalr	870(ra) # 80001b0e <myproc>
  if (user_src)
    800027b0:	c08d                	beqz	s1,800027d2 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800027b2:	86d2                	mv	a3,s4
    800027b4:	864e                	mv	a2,s3
    800027b6:	85ca                	mv	a1,s2
    800027b8:	6928                	ld	a0,80(a0)
    800027ba:	fffff097          	auipc	ra,0xfffff
    800027be:	09c080e7          	jalr	156(ra) # 80001856 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800027c2:	70a2                	ld	ra,40(sp)
    800027c4:	7402                	ld	s0,32(sp)
    800027c6:	64e2                	ld	s1,24(sp)
    800027c8:	6942                	ld	s2,16(sp)
    800027ca:	69a2                	ld	s3,8(sp)
    800027cc:	6a02                	ld	s4,0(sp)
    800027ce:	6145                	addi	sp,sp,48
    800027d0:	8082                	ret
    memmove(dst, (char *)src, len);
    800027d2:	000a061b          	sext.w	a2,s4
    800027d6:	85ce                	mv	a1,s3
    800027d8:	854a                	mv	a0,s2
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	674080e7          	jalr	1652(ra) # 80000e4e <memmove>
    return 0;
    800027e2:	8526                	mv	a0,s1
    800027e4:	bff9                	j	800027c2 <either_copyin+0x32>

00000000800027e6 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800027e6:	715d                	addi	sp,sp,-80
    800027e8:	e486                	sd	ra,72(sp)
    800027ea:	e0a2                	sd	s0,64(sp)
    800027ec:	fc26                	sd	s1,56(sp)
    800027ee:	f84a                	sd	s2,48(sp)
    800027f0:	f44e                	sd	s3,40(sp)
    800027f2:	f052                	sd	s4,32(sp)
    800027f4:	ec56                	sd	s5,24(sp)
    800027f6:	e85a                	sd	s6,16(sp)
    800027f8:	e45e                	sd	s7,8(sp)
    800027fa:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800027fc:	00006517          	auipc	a0,0x6
    80002800:	8ec50513          	addi	a0,a0,-1812 # 800080e8 <digits+0xa8>
    80002804:	ffffe097          	auipc	ra,0xffffe
    80002808:	d84080e7          	jalr	-636(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000280c:	0022f497          	auipc	s1,0x22f
    80002810:	91448493          	addi	s1,s1,-1772 # 80231120 <proc+0x158>
    80002814:	00235917          	auipc	s2,0x235
    80002818:	d0c90913          	addi	s2,s2,-756 # 80237520 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000281c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000281e:	00006997          	auipc	s3,0x6
    80002822:	a8298993          	addi	s3,s3,-1406 # 800082a0 <digits+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    80002826:	00006a97          	auipc	s5,0x6
    8000282a:	a82a8a93          	addi	s5,s5,-1406 # 800082a8 <digits+0x268>
    printf("\n");
    8000282e:	00006a17          	auipc	s4,0x6
    80002832:	8baa0a13          	addi	s4,s4,-1862 # 800080e8 <digits+0xa8>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002836:	00006b97          	auipc	s7,0x6
    8000283a:	ab2b8b93          	addi	s7,s7,-1358 # 800082e8 <states.0>
    8000283e:	a00d                	j	80002860 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002840:	ed86a583          	lw	a1,-296(a3)
    80002844:	8556                	mv	a0,s5
    80002846:	ffffe097          	auipc	ra,0xffffe
    8000284a:	d42080e7          	jalr	-702(ra) # 80000588 <printf>
    printf("\n");
    8000284e:	8552                	mv	a0,s4
    80002850:	ffffe097          	auipc	ra,0xffffe
    80002854:	d38080e7          	jalr	-712(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002858:	19048493          	addi	s1,s1,400
    8000285c:	03248163          	beq	s1,s2,8000287e <procdump+0x98>
    if (p->state == UNUSED)
    80002860:	86a6                	mv	a3,s1
    80002862:	ec04a783          	lw	a5,-320(s1)
    80002866:	dbed                	beqz	a5,80002858 <procdump+0x72>
      state = "???";
    80002868:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000286a:	fcfb6be3          	bltu	s6,a5,80002840 <procdump+0x5a>
    8000286e:	1782                	slli	a5,a5,0x20
    80002870:	9381                	srli	a5,a5,0x20
    80002872:	078e                	slli	a5,a5,0x3
    80002874:	97de                	add	a5,a5,s7
    80002876:	6390                	ld	a2,0(a5)
    80002878:	f661                	bnez	a2,80002840 <procdump+0x5a>
      state = "???";
    8000287a:	864e                	mv	a2,s3
    8000287c:	b7d1                	j	80002840 <procdump+0x5a>
  }
}
    8000287e:	60a6                	ld	ra,72(sp)
    80002880:	6406                	ld	s0,64(sp)
    80002882:	74e2                	ld	s1,56(sp)
    80002884:	7942                	ld	s2,48(sp)
    80002886:	79a2                	ld	s3,40(sp)
    80002888:	7a02                	ld	s4,32(sp)
    8000288a:	6ae2                	ld	s5,24(sp)
    8000288c:	6b42                	ld	s6,16(sp)
    8000288e:	6ba2                	ld	s7,8(sp)
    80002890:	6161                	addi	sp,sp,80
    80002892:	8082                	ret

0000000080002894 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002894:	711d                	addi	sp,sp,-96
    80002896:	ec86                	sd	ra,88(sp)
    80002898:	e8a2                	sd	s0,80(sp)
    8000289a:	e4a6                	sd	s1,72(sp)
    8000289c:	e0ca                	sd	s2,64(sp)
    8000289e:	fc4e                	sd	s3,56(sp)
    800028a0:	f852                	sd	s4,48(sp)
    800028a2:	f456                	sd	s5,40(sp)
    800028a4:	f05a                	sd	s6,32(sp)
    800028a6:	ec5e                	sd	s7,24(sp)
    800028a8:	e862                	sd	s8,16(sp)
    800028aa:	e466                	sd	s9,8(sp)
    800028ac:	e06a                	sd	s10,0(sp)
    800028ae:	1080                	addi	s0,sp,96
    800028b0:	8b2a                	mv	s6,a0
    800028b2:	8bae                	mv	s7,a1
    800028b4:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800028b6:	fffff097          	auipc	ra,0xfffff
    800028ba:	258080e7          	jalr	600(ra) # 80001b0e <myproc>
    800028be:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800028c0:	0022e517          	auipc	a0,0x22e
    800028c4:	2f050513          	addi	a0,a0,752 # 80230bb0 <wait_lock>
    800028c8:	ffffe097          	auipc	ra,0xffffe
    800028cc:	42e080e7          	jalr	1070(ra) # 80000cf6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800028d0:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800028d2:	4a15                	li	s4,5
        havekids = 1;
    800028d4:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800028d6:	00235997          	auipc	s3,0x235
    800028da:	af298993          	addi	s3,s3,-1294 # 802373c8 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800028de:	0022ed17          	auipc	s10,0x22e
    800028e2:	2d2d0d13          	addi	s10,s10,722 # 80230bb0 <wait_lock>
    havekids = 0;
    800028e6:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800028e8:	0022e497          	auipc	s1,0x22e
    800028ec:	6e048493          	addi	s1,s1,1760 # 80230fc8 <proc>
    800028f0:	a059                	j	80002976 <waitx+0xe2>
          pid = np->pid;
    800028f2:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800028f6:	1684a703          	lw	a4,360(s1)
    800028fa:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800028fe:	16c4a783          	lw	a5,364(s1)
    80002902:	9f3d                	addw	a4,a4,a5
    80002904:	1704a783          	lw	a5,368(s1)
    80002908:	9f99                	subw	a5,a5,a4
    8000290a:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000290e:	000b0e63          	beqz	s6,8000292a <waitx+0x96>
    80002912:	4691                	li	a3,4
    80002914:	02c48613          	addi	a2,s1,44
    80002918:	85da                	mv	a1,s6
    8000291a:	05093503          	ld	a0,80(s2)
    8000291e:	fffff097          	auipc	ra,0xfffff
    80002922:	e70080e7          	jalr	-400(ra) # 8000178e <copyout>
    80002926:	02054563          	bltz	a0,80002950 <waitx+0xbc>
          freeproc(np);
    8000292a:	8526                	mv	a0,s1
    8000292c:	fffff097          	auipc	ra,0xfffff
    80002930:	394080e7          	jalr	916(ra) # 80001cc0 <freeproc>
          release(&np->lock);
    80002934:	8526                	mv	a0,s1
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	474080e7          	jalr	1140(ra) # 80000daa <release>
          release(&wait_lock);
    8000293e:	0022e517          	auipc	a0,0x22e
    80002942:	27250513          	addi	a0,a0,626 # 80230bb0 <wait_lock>
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	464080e7          	jalr	1124(ra) # 80000daa <release>
          return pid;
    8000294e:	a09d                	j	800029b4 <waitx+0x120>
            release(&np->lock);
    80002950:	8526                	mv	a0,s1
    80002952:	ffffe097          	auipc	ra,0xffffe
    80002956:	458080e7          	jalr	1112(ra) # 80000daa <release>
            release(&wait_lock);
    8000295a:	0022e517          	auipc	a0,0x22e
    8000295e:	25650513          	addi	a0,a0,598 # 80230bb0 <wait_lock>
    80002962:	ffffe097          	auipc	ra,0xffffe
    80002966:	448080e7          	jalr	1096(ra) # 80000daa <release>
            return -1;
    8000296a:	59fd                	li	s3,-1
    8000296c:	a0a1                	j	800029b4 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    8000296e:	19048493          	addi	s1,s1,400
    80002972:	03348463          	beq	s1,s3,8000299a <waitx+0x106>
      if (np->parent == p)
    80002976:	7c9c                	ld	a5,56(s1)
    80002978:	ff279be3          	bne	a5,s2,8000296e <waitx+0xda>
        acquire(&np->lock);
    8000297c:	8526                	mv	a0,s1
    8000297e:	ffffe097          	auipc	ra,0xffffe
    80002982:	378080e7          	jalr	888(ra) # 80000cf6 <acquire>
        if (np->state == ZOMBIE)
    80002986:	4c9c                	lw	a5,24(s1)
    80002988:	f74785e3          	beq	a5,s4,800028f2 <waitx+0x5e>
        release(&np->lock);
    8000298c:	8526                	mv	a0,s1
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	41c080e7          	jalr	1052(ra) # 80000daa <release>
        havekids = 1;
    80002996:	8756                	mv	a4,s5
    80002998:	bfd9                	j	8000296e <waitx+0xda>
    if (!havekids || p->killed)
    8000299a:	c701                	beqz	a4,800029a2 <waitx+0x10e>
    8000299c:	02892783          	lw	a5,40(s2)
    800029a0:	cb8d                	beqz	a5,800029d2 <waitx+0x13e>
      release(&wait_lock);
    800029a2:	0022e517          	auipc	a0,0x22e
    800029a6:	20e50513          	addi	a0,a0,526 # 80230bb0 <wait_lock>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	400080e7          	jalr	1024(ra) # 80000daa <release>
      return -1;
    800029b2:	59fd                	li	s3,-1
  }
}
    800029b4:	854e                	mv	a0,s3
    800029b6:	60e6                	ld	ra,88(sp)
    800029b8:	6446                	ld	s0,80(sp)
    800029ba:	64a6                	ld	s1,72(sp)
    800029bc:	6906                	ld	s2,64(sp)
    800029be:	79e2                	ld	s3,56(sp)
    800029c0:	7a42                	ld	s4,48(sp)
    800029c2:	7aa2                	ld	s5,40(sp)
    800029c4:	7b02                	ld	s6,32(sp)
    800029c6:	6be2                	ld	s7,24(sp)
    800029c8:	6c42                	ld	s8,16(sp)
    800029ca:	6ca2                	ld	s9,8(sp)
    800029cc:	6d02                	ld	s10,0(sp)
    800029ce:	6125                	addi	sp,sp,96
    800029d0:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800029d2:	85ea                	mv	a1,s10
    800029d4:	854a                	mv	a0,s2
    800029d6:	00000097          	auipc	ra,0x0
    800029da:	950080e7          	jalr	-1712(ra) # 80002326 <sleep>
    havekids = 0;
    800029de:	b721                	j	800028e6 <waitx+0x52>

00000000800029e0 <update_time>:

void update_time()
{
    800029e0:	7139                	addi	sp,sp,-64
    800029e2:	fc06                	sd	ra,56(sp)
    800029e4:	f822                	sd	s0,48(sp)
    800029e6:	f426                	sd	s1,40(sp)
    800029e8:	f04a                	sd	s2,32(sp)
    800029ea:	ec4e                	sd	s3,24(sp)
    800029ec:	e852                	sd	s4,16(sp)
    800029ee:	e456                	sd	s5,8(sp)
    800029f0:	0080                	addi	s0,sp,64
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    800029f2:	0022e497          	auipc	s1,0x22e
    800029f6:	5d648493          	addi	s1,s1,1494 # 80230fc8 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    800029fa:	4991                	li	s3,4
    {
      p->rtime++;
      p->run_time++;
    }
    else if(p->state == SLEEPING)
    800029fc:	4a09                	li	s4,2
    {
      p->stime++;
    }
    else if(p->state == RUNNABLE)
    800029fe:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002a00:	00235917          	auipc	s2,0x235
    80002a04:	9c890913          	addi	s2,s2,-1592 # 802373c8 <tickslock>
    80002a08:	a025                	j	80002a30 <update_time+0x50>
      p->rtime++;
    80002a0a:	1684a783          	lw	a5,360(s1)
    80002a0e:	2785                	addiw	a5,a5,1
    80002a10:	16f4a423          	sw	a5,360(s1)
      p->run_time++;
    80002a14:	1744a783          	lw	a5,372(s1)
    80002a18:	2785                	addiw	a5,a5,1
    80002a1a:	16f4aa23          	sw	a5,372(s1)
    {
      p->wtime++;
    }
    release(&p->lock);
    80002a1e:	8526                	mv	a0,s1
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	38a080e7          	jalr	906(ra) # 80000daa <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a28:	19048493          	addi	s1,s1,400
    80002a2c:	03248a63          	beq	s1,s2,80002a60 <update_time+0x80>
    acquire(&p->lock);
    80002a30:	8526                	mv	a0,s1
    80002a32:	ffffe097          	auipc	ra,0xffffe
    80002a36:	2c4080e7          	jalr	708(ra) # 80000cf6 <acquire>
    if (p->state == RUNNING)
    80002a3a:	4c9c                	lw	a5,24(s1)
    80002a3c:	fd3787e3          	beq	a5,s3,80002a0a <update_time+0x2a>
    else if(p->state == SLEEPING)
    80002a40:	01478a63          	beq	a5,s4,80002a54 <update_time+0x74>
    else if(p->state == RUNNABLE)
    80002a44:	fd579de3          	bne	a5,s5,80002a1e <update_time+0x3e>
      p->wtime++;
    80002a48:	1784a783          	lw	a5,376(s1)
    80002a4c:	2785                	addiw	a5,a5,1
    80002a4e:	16f4ac23          	sw	a5,376(s1)
    80002a52:	b7f1                	j	80002a1e <update_time+0x3e>
      p->stime++;
    80002a54:	17c4a783          	lw	a5,380(s1)
    80002a58:	2785                	addiw	a5,a5,1
    80002a5a:	16f4ae23          	sw	a5,380(s1)
    80002a5e:	b7c1                	j	80002a1e <update_time+0x3e>
  }
    80002a60:	70e2                	ld	ra,56(sp)
    80002a62:	7442                	ld	s0,48(sp)
    80002a64:	74a2                	ld	s1,40(sp)
    80002a66:	7902                	ld	s2,32(sp)
    80002a68:	69e2                	ld	s3,24(sp)
    80002a6a:	6a42                	ld	s4,16(sp)
    80002a6c:	6aa2                	ld	s5,8(sp)
    80002a6e:	6121                	addi	sp,sp,64
    80002a70:	8082                	ret

0000000080002a72 <swtch>:
    80002a72:	00153023          	sd	ra,0(a0)
    80002a76:	00253423          	sd	sp,8(a0)
    80002a7a:	e900                	sd	s0,16(a0)
    80002a7c:	ed04                	sd	s1,24(a0)
    80002a7e:	03253023          	sd	s2,32(a0)
    80002a82:	03353423          	sd	s3,40(a0)
    80002a86:	03453823          	sd	s4,48(a0)
    80002a8a:	03553c23          	sd	s5,56(a0)
    80002a8e:	05653023          	sd	s6,64(a0)
    80002a92:	05753423          	sd	s7,72(a0)
    80002a96:	05853823          	sd	s8,80(a0)
    80002a9a:	05953c23          	sd	s9,88(a0)
    80002a9e:	07a53023          	sd	s10,96(a0)
    80002aa2:	07b53423          	sd	s11,104(a0)
    80002aa6:	0005b083          	ld	ra,0(a1)
    80002aaa:	0085b103          	ld	sp,8(a1)
    80002aae:	6980                	ld	s0,16(a1)
    80002ab0:	6d84                	ld	s1,24(a1)
    80002ab2:	0205b903          	ld	s2,32(a1)
    80002ab6:	0285b983          	ld	s3,40(a1)
    80002aba:	0305ba03          	ld	s4,48(a1)
    80002abe:	0385ba83          	ld	s5,56(a1)
    80002ac2:	0405bb03          	ld	s6,64(a1)
    80002ac6:	0485bb83          	ld	s7,72(a1)
    80002aca:	0505bc03          	ld	s8,80(a1)
    80002ace:	0585bc83          	ld	s9,88(a1)
    80002ad2:	0605bd03          	ld	s10,96(a1)
    80002ad6:	0685bd83          	ld	s11,104(a1)
    80002ada:	8082                	ret

0000000080002adc <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002adc:	1141                	addi	sp,sp,-16
    80002ade:	e406                	sd	ra,8(sp)
    80002ae0:	e022                	sd	s0,0(sp)
    80002ae2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ae4:	00006597          	auipc	a1,0x6
    80002ae8:	83458593          	addi	a1,a1,-1996 # 80008318 <states.0+0x30>
    80002aec:	00235517          	auipc	a0,0x235
    80002af0:	8dc50513          	addi	a0,a0,-1828 # 802373c8 <tickslock>
    80002af4:	ffffe097          	auipc	ra,0xffffe
    80002af8:	172080e7          	jalr	370(ra) # 80000c66 <initlock>
}
    80002afc:	60a2                	ld	ra,8(sp)
    80002afe:	6402                	ld	s0,0(sp)
    80002b00:	0141                	addi	sp,sp,16
    80002b02:	8082                	ret

0000000080002b04 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002b04:	1141                	addi	sp,sp,-16
    80002b06:	e422                	sd	s0,8(sp)
    80002b08:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b0a:	00003797          	auipc	a5,0x3
    80002b0e:	71678793          	addi	a5,a5,1814 # 80006220 <kernelvec>
    80002b12:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b16:	6422                	ld	s0,8(sp)
    80002b18:	0141                	addi	sp,sp,16
    80002b1a:	8082                	ret

0000000080002b1c <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002b1c:	1141                	addi	sp,sp,-16
    80002b1e:	e406                	sd	ra,8(sp)
    80002b20:	e022                	sd	s0,0(sp)
    80002b22:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b24:	fffff097          	auipc	ra,0xfffff
    80002b28:	fea080e7          	jalr	-22(ra) # 80001b0e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b2c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b30:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b32:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b36:	00004617          	auipc	a2,0x4
    80002b3a:	4ca60613          	addi	a2,a2,1226 # 80007000 <_trampoline>
    80002b3e:	00004697          	auipc	a3,0x4
    80002b42:	4c268693          	addi	a3,a3,1218 # 80007000 <_trampoline>
    80002b46:	8e91                	sub	a3,a3,a2
    80002b48:	040007b7          	lui	a5,0x4000
    80002b4c:	17fd                	addi	a5,a5,-1
    80002b4e:	07b2                	slli	a5,a5,0xc
    80002b50:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b52:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b56:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b58:	180026f3          	csrr	a3,satp
    80002b5c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b5e:	6d38                	ld	a4,88(a0)
    80002b60:	6134                	ld	a3,64(a0)
    80002b62:	6585                	lui	a1,0x1
    80002b64:	96ae                	add	a3,a3,a1
    80002b66:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b68:	6d38                	ld	a4,88(a0)
    80002b6a:	00000697          	auipc	a3,0x0
    80002b6e:	2d868693          	addi	a3,a3,728 # 80002e42 <usertrap>
    80002b72:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002b74:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b76:	8692                	mv	a3,tp
    80002b78:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b7a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b7e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b82:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b86:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b8a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b8c:	6f18                	ld	a4,24(a4)
    80002b8e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b92:	6928                	ld	a0,80(a0)
    80002b94:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b96:	00004717          	auipc	a4,0x4
    80002b9a:	50670713          	addi	a4,a4,1286 # 8000709c <userret>
    80002b9e:	8f11                	sub	a4,a4,a2
    80002ba0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002ba2:	577d                	li	a4,-1
    80002ba4:	177e                	slli	a4,a4,0x3f
    80002ba6:	8d59                	or	a0,a0,a4
    80002ba8:	9782                	jalr	a5
}
    80002baa:	60a2                	ld	ra,8(sp)
    80002bac:	6402                	ld	s0,0(sp)
    80002bae:	0141                	addi	sp,sp,16
    80002bb0:	8082                	ret

0000000080002bb2 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002bb2:	1101                	addi	sp,sp,-32
    80002bb4:	ec06                	sd	ra,24(sp)
    80002bb6:	e822                	sd	s0,16(sp)
    80002bb8:	e426                	sd	s1,8(sp)
    80002bba:	e04a                	sd	s2,0(sp)
    80002bbc:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002bbe:	00235917          	auipc	s2,0x235
    80002bc2:	80a90913          	addi	s2,s2,-2038 # 802373c8 <tickslock>
    80002bc6:	854a                	mv	a0,s2
    80002bc8:	ffffe097          	auipc	ra,0xffffe
    80002bcc:	12e080e7          	jalr	302(ra) # 80000cf6 <acquire>
  ticks++;
    80002bd0:	00006497          	auipc	s1,0x6
    80002bd4:	d4048493          	addi	s1,s1,-704 # 80008910 <ticks>
    80002bd8:	409c                	lw	a5,0(s1)
    80002bda:	2785                	addiw	a5,a5,1
    80002bdc:	c09c                	sw	a5,0(s1)
  update_time();
    80002bde:	00000097          	auipc	ra,0x0
    80002be2:	e02080e7          	jalr	-510(ra) # 800029e0 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002be6:	8526                	mv	a0,s1
    80002be8:	fffff097          	auipc	ra,0xfffff
    80002bec:	7a2080e7          	jalr	1954(ra) # 8000238a <wakeup>
  release(&tickslock);
    80002bf0:	854a                	mv	a0,s2
    80002bf2:	ffffe097          	auipc	ra,0xffffe
    80002bf6:	1b8080e7          	jalr	440(ra) # 80000daa <release>
}
    80002bfa:	60e2                	ld	ra,24(sp)
    80002bfc:	6442                	ld	s0,16(sp)
    80002bfe:	64a2                	ld	s1,8(sp)
    80002c00:	6902                	ld	s2,0(sp)
    80002c02:	6105                	addi	sp,sp,32
    80002c04:	8082                	ret

0000000080002c06 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002c06:	1101                	addi	sp,sp,-32
    80002c08:	ec06                	sd	ra,24(sp)
    80002c0a:	e822                	sd	s0,16(sp)
    80002c0c:	e426                	sd	s1,8(sp)
    80002c0e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c10:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002c14:	00074d63          	bltz	a4,80002c2e <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002c18:	57fd                	li	a5,-1
    80002c1a:	17fe                	slli	a5,a5,0x3f
    80002c1c:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002c1e:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002c20:	06f70363          	beq	a4,a5,80002c86 <devintr+0x80>
  }
}
    80002c24:	60e2                	ld	ra,24(sp)
    80002c26:	6442                	ld	s0,16(sp)
    80002c28:	64a2                	ld	s1,8(sp)
    80002c2a:	6105                	addi	sp,sp,32
    80002c2c:	8082                	ret
      (scause & 0xff) == 9)
    80002c2e:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002c32:	46a5                	li	a3,9
    80002c34:	fed792e3          	bne	a5,a3,80002c18 <devintr+0x12>
    int irq = plic_claim();
    80002c38:	00003097          	auipc	ra,0x3
    80002c3c:	6f0080e7          	jalr	1776(ra) # 80006328 <plic_claim>
    80002c40:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002c42:	47a9                	li	a5,10
    80002c44:	02f50763          	beq	a0,a5,80002c72 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002c48:	4785                	li	a5,1
    80002c4a:	02f50963          	beq	a0,a5,80002c7c <devintr+0x76>
    return 1;
    80002c4e:	4505                	li	a0,1
    else if (irq)
    80002c50:	d8f1                	beqz	s1,80002c24 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c52:	85a6                	mv	a1,s1
    80002c54:	00005517          	auipc	a0,0x5
    80002c58:	6cc50513          	addi	a0,a0,1740 # 80008320 <states.0+0x38>
    80002c5c:	ffffe097          	auipc	ra,0xffffe
    80002c60:	92c080e7          	jalr	-1748(ra) # 80000588 <printf>
      plic_complete(irq);
    80002c64:	8526                	mv	a0,s1
    80002c66:	00003097          	auipc	ra,0x3
    80002c6a:	6e6080e7          	jalr	1766(ra) # 8000634c <plic_complete>
    return 1;
    80002c6e:	4505                	li	a0,1
    80002c70:	bf55                	j	80002c24 <devintr+0x1e>
      uartintr();
    80002c72:	ffffe097          	auipc	ra,0xffffe
    80002c76:	d28080e7          	jalr	-728(ra) # 8000099a <uartintr>
    80002c7a:	b7ed                	j	80002c64 <devintr+0x5e>
      virtio_disk_intr();
    80002c7c:	00004097          	auipc	ra,0x4
    80002c80:	b9c080e7          	jalr	-1124(ra) # 80006818 <virtio_disk_intr>
    80002c84:	b7c5                	j	80002c64 <devintr+0x5e>
    if (cpuid() == 0)
    80002c86:	fffff097          	auipc	ra,0xfffff
    80002c8a:	e5c080e7          	jalr	-420(ra) # 80001ae2 <cpuid>
    80002c8e:	c901                	beqz	a0,80002c9e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c90:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c94:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c96:	14479073          	csrw	sip,a5
    return 2;
    80002c9a:	4509                	li	a0,2
    80002c9c:	b761                	j	80002c24 <devintr+0x1e>
      clockintr();
    80002c9e:	00000097          	auipc	ra,0x0
    80002ca2:	f14080e7          	jalr	-236(ra) # 80002bb2 <clockintr>
    80002ca6:	b7ed                	j	80002c90 <devintr+0x8a>

0000000080002ca8 <kerneltrap>:
{
    80002ca8:	7179                	addi	sp,sp,-48
    80002caa:	f406                	sd	ra,40(sp)
    80002cac:	f022                	sd	s0,32(sp)
    80002cae:	ec26                	sd	s1,24(sp)
    80002cb0:	e84a                	sd	s2,16(sp)
    80002cb2:	e44e                	sd	s3,8(sp)
    80002cb4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cb6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cba:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cbe:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002cc2:	1004f793          	andi	a5,s1,256
    80002cc6:	cb85                	beqz	a5,80002cf6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cc8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ccc:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002cce:	ef85                	bnez	a5,80002d06 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002cd0:	00000097          	auipc	ra,0x0
    80002cd4:	f36080e7          	jalr	-202(ra) # 80002c06 <devintr>
    80002cd8:	cd1d                	beqz	a0,80002d16 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cda:	4789                	li	a5,2
    80002cdc:	06f50a63          	beq	a0,a5,80002d50 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ce0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ce4:	10049073          	csrw	sstatus,s1
}
    80002ce8:	70a2                	ld	ra,40(sp)
    80002cea:	7402                	ld	s0,32(sp)
    80002cec:	64e2                	ld	s1,24(sp)
    80002cee:	6942                	ld	s2,16(sp)
    80002cf0:	69a2                	ld	s3,8(sp)
    80002cf2:	6145                	addi	sp,sp,48
    80002cf4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cf6:	00005517          	auipc	a0,0x5
    80002cfa:	64a50513          	addi	a0,a0,1610 # 80008340 <states.0+0x58>
    80002cfe:	ffffe097          	auipc	ra,0xffffe
    80002d02:	840080e7          	jalr	-1984(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002d06:	00005517          	auipc	a0,0x5
    80002d0a:	66250513          	addi	a0,a0,1634 # 80008368 <states.0+0x80>
    80002d0e:	ffffe097          	auipc	ra,0xffffe
    80002d12:	830080e7          	jalr	-2000(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002d16:	85ce                	mv	a1,s3
    80002d18:	00005517          	auipc	a0,0x5
    80002d1c:	67050513          	addi	a0,a0,1648 # 80008388 <states.0+0xa0>
    80002d20:	ffffe097          	auipc	ra,0xffffe
    80002d24:	868080e7          	jalr	-1944(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d28:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d2c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d30:	00005517          	auipc	a0,0x5
    80002d34:	66850513          	addi	a0,a0,1640 # 80008398 <states.0+0xb0>
    80002d38:	ffffe097          	auipc	ra,0xffffe
    80002d3c:	850080e7          	jalr	-1968(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002d40:	00005517          	auipc	a0,0x5
    80002d44:	67050513          	addi	a0,a0,1648 # 800083b0 <states.0+0xc8>
    80002d48:	ffffd097          	auipc	ra,0xffffd
    80002d4c:	7f6080e7          	jalr	2038(ra) # 8000053e <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d50:	fffff097          	auipc	ra,0xfffff
    80002d54:	dbe080e7          	jalr	-578(ra) # 80001b0e <myproc>
    80002d58:	d541                	beqz	a0,80002ce0 <kerneltrap+0x38>
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	db4080e7          	jalr	-588(ra) # 80001b0e <myproc>
    80002d62:	4d18                	lw	a4,24(a0)
    80002d64:	4791                	li	a5,4
    80002d66:	f6f71de3          	bne	a4,a5,80002ce0 <kerneltrap+0x38>
    yield();
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	580080e7          	jalr	1408(ra) # 800022ea <yield>
    80002d72:	b7bd                	j	80002ce0 <kerneltrap+0x38>

0000000080002d74 <pgfault>:

int pgfault(uint64 va, pagetable_t pagetable)
{
    80002d74:	7139                	addi	sp,sp,-64
    80002d76:	fc06                	sd	ra,56(sp)
    80002d78:	f822                	sd	s0,48(sp)
    80002d7a:	f426                	sd	s1,40(sp)
    80002d7c:	f04a                	sd	s2,32(sp)
    80002d7e:	ec4e                	sd	s3,24(sp)
    80002d80:	e852                	sd	s4,16(sp)
    80002d82:	e456                	sd	s5,8(sp)
    80002d84:	0080                	addi	s0,sp,64
    80002d86:	84aa                	mv	s1,a0
    80002d88:	892e                	mv	s2,a1
  struct proc* p;
  p = myproc();
    80002d8a:	fffff097          	auipc	ra,0xfffff
    80002d8e:	d84080e7          	jalr	-636(ra) # 80001b0e <myproc>
  if(va >= MAXVA || ((va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE) && (va <= PGROUNDDOWN(p->trapframe->sp))))
    80002d92:	57fd                	li	a5,-1
    80002d94:	83e9                	srli	a5,a5,0x1a
    80002d96:	0897ec63          	bltu	a5,s1,80002e2e <pgfault+0xba>
    80002d9a:	6d38                	ld	a4,88(a0)
    80002d9c:	77fd                	lui	a5,0xfffff
    80002d9e:	7b18                	ld	a4,48(a4)
    80002da0:	8f7d                	and	a4,a4,a5
    80002da2:	97ba                	add	a5,a5,a4
    80002da4:	00f4e463          	bltu	s1,a5,80002dac <pgfault+0x38>
    80002da8:	08977563          	bgeu	a4,s1,80002e32 <pgfault+0xbe>
    return -1;

  va = PGROUNDDOWN(va);
    80002dac:	757d                	lui	a0,0xfffff
    80002dae:	8ce9                	and	s1,s1,a0
  pte_t *pte = walk(pagetable, va, 0);
    80002db0:	4601                	li	a2,0
    80002db2:	85a6                	mv	a1,s1
    80002db4:	854a                	mv	a0,s2
    80002db6:	ffffe097          	auipc	ra,0xffffe
    80002dba:	320080e7          	jalr	800(ra) # 800010d6 <walk>
  if(pte == 0)
    80002dbe:	cd25                	beqz	a0,80002e36 <pgfault+0xc2>
    return -1;

  uint64 pa = PTE2PA(*pte);
    80002dc0:	6108                	ld	a0,0(a0)
    80002dc2:	00a55993          	srli	s3,a0,0xa
    80002dc6:	09b2                	slli	s3,s3,0xc
  if(pa == 0)
    80002dc8:	06098963          	beqz	s3,80002e3a <pgfault+0xc6>
    return -1;

  int flags = PTE_FLAGS(*pte);
    80002dcc:	0005071b          	sext.w	a4,a0
  if(flags & PTE_COW)
    80002dd0:	10057513          	andi	a0,a0,256
    80002dd4:	e911                	bnez	a0,80002de8 <pgfault+0x74>
    memmove(mem, (void*)pa, PGSIZE);
    uvmunmap(pagetable,va, 1, 1);
    mappages(pagetable, va, PGSIZE, (uint64)mem, flags);
  }
  return 0;
}
    80002dd6:	70e2                	ld	ra,56(sp)
    80002dd8:	7442                	ld	s0,48(sp)
    80002dda:	74a2                	ld	s1,40(sp)
    80002ddc:	7902                	ld	s2,32(sp)
    80002dde:	69e2                	ld	s3,24(sp)
    80002de0:	6a42                	ld	s4,16(sp)
    80002de2:	6aa2                	ld	s5,8(sp)
    80002de4:	6121                	addi	sp,sp,64
    80002de6:	8082                	ret
    flags = (flags | PTE_W) & (~PTE_COW);
    80002de8:	2fb77713          	andi	a4,a4,763
    80002dec:	00476a13          	ori	s4,a4,4
    char* mem = kalloc();
    80002df0:	ffffe097          	auipc	ra,0xffffe
    80002df4:	c66080e7          	jalr	-922(ra) # 80000a56 <kalloc>
    80002df8:	8aaa                	mv	s5,a0
    if(mem == 0)
    80002dfa:	c131                	beqz	a0,80002e3e <pgfault+0xca>
    memmove(mem, (void*)pa, PGSIZE);
    80002dfc:	6605                	lui	a2,0x1
    80002dfe:	85ce                	mv	a1,s3
    80002e00:	ffffe097          	auipc	ra,0xffffe
    80002e04:	04e080e7          	jalr	78(ra) # 80000e4e <memmove>
    uvmunmap(pagetable,va, 1, 1);
    80002e08:	4685                	li	a3,1
    80002e0a:	4605                	li	a2,1
    80002e0c:	85a6                	mv	a1,s1
    80002e0e:	854a                	mv	a0,s2
    80002e10:	ffffe097          	auipc	ra,0xffffe
    80002e14:	574080e7          	jalr	1396(ra) # 80001384 <uvmunmap>
    mappages(pagetable, va, PGSIZE, (uint64)mem, flags);
    80002e18:	8752                	mv	a4,s4
    80002e1a:	86d6                	mv	a3,s5
    80002e1c:	6605                	lui	a2,0x1
    80002e1e:	85a6                	mv	a1,s1
    80002e20:	854a                	mv	a0,s2
    80002e22:	ffffe097          	auipc	ra,0xffffe
    80002e26:	39c080e7          	jalr	924(ra) # 800011be <mappages>
  return 0;
    80002e2a:	4501                	li	a0,0
    80002e2c:	b76d                	j	80002dd6 <pgfault+0x62>
    return -1;
    80002e2e:	557d                	li	a0,-1
    80002e30:	b75d                	j	80002dd6 <pgfault+0x62>
    80002e32:	557d                	li	a0,-1
    80002e34:	b74d                	j	80002dd6 <pgfault+0x62>
    return -1;
    80002e36:	557d                	li	a0,-1
    80002e38:	bf79                	j	80002dd6 <pgfault+0x62>
    return -1;
    80002e3a:	557d                	li	a0,-1
    80002e3c:	bf69                	j	80002dd6 <pgfault+0x62>
      return -1;
    80002e3e:	557d                	li	a0,-1
    80002e40:	bf59                	j	80002dd6 <pgfault+0x62>

0000000080002e42 <usertrap>:
{
    80002e42:	1101                	addi	sp,sp,-32
    80002e44:	ec06                	sd	ra,24(sp)
    80002e46:	e822                	sd	s0,16(sp)
    80002e48:	e426                	sd	s1,8(sp)
    80002e4a:	e04a                	sd	s2,0(sp)
    80002e4c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e4e:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002e52:	1007f793          	andi	a5,a5,256
    80002e56:	e7b9                	bnez	a5,80002ea4 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e58:	00003797          	auipc	a5,0x3
    80002e5c:	3c878793          	addi	a5,a5,968 # 80006220 <kernelvec>
    80002e60:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e64:	fffff097          	auipc	ra,0xfffff
    80002e68:	caa080e7          	jalr	-854(ra) # 80001b0e <myproc>
    80002e6c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e6e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e70:	14102773          	csrr	a4,sepc
    80002e74:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e76:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002e7a:	47a1                	li	a5,8
    80002e7c:	02f70c63          	beq	a4,a5,80002eb4 <usertrap+0x72>
    80002e80:	14202773          	csrr	a4,scause
  else if (r_scause() == 15)
    80002e84:	47bd                	li	a5,15
    80002e86:	08f70063          	beq	a4,a5,80002f06 <usertrap+0xc4>
  else if ((which_dev = devintr()) != 0)
    80002e8a:	00000097          	auipc	ra,0x0
    80002e8e:	d7c080e7          	jalr	-644(ra) # 80002c06 <devintr>
    80002e92:	892a                	mv	s2,a0
    80002e94:	c551                	beqz	a0,80002f20 <usertrap+0xde>
  if (killed(p))
    80002e96:	8526                	mv	a0,s1
    80002e98:	fffff097          	auipc	ra,0xfffff
    80002e9c:	742080e7          	jalr	1858(ra) # 800025da <killed>
    80002ea0:	c979                	beqz	a0,80002f76 <usertrap+0x134>
    80002ea2:	a86d                	j	80002f5c <usertrap+0x11a>
    panic("usertrap: not from user mode");
    80002ea4:	00005517          	auipc	a0,0x5
    80002ea8:	51c50513          	addi	a0,a0,1308 # 800083c0 <states.0+0xd8>
    80002eac:	ffffd097          	auipc	ra,0xffffd
    80002eb0:	692080e7          	jalr	1682(ra) # 8000053e <panic>
    if (killed(p))
    80002eb4:	fffff097          	auipc	ra,0xfffff
    80002eb8:	726080e7          	jalr	1830(ra) # 800025da <killed>
    80002ebc:	ed1d                	bnez	a0,80002efa <usertrap+0xb8>
    p->trapframe->epc += 4;
    80002ebe:	6cb8                	ld	a4,88(s1)
    80002ec0:	6f1c                	ld	a5,24(a4)
    80002ec2:	0791                	addi	a5,a5,4
    80002ec4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ec6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002eca:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ece:	10079073          	csrw	sstatus,a5
    syscall();
    80002ed2:	00000097          	auipc	ra,0x0
    80002ed6:	232080e7          	jalr	562(ra) # 80003104 <syscall>
  if (killed(p))
    80002eda:	8526                	mv	a0,s1
    80002edc:	fffff097          	auipc	ra,0xfffff
    80002ee0:	6fe080e7          	jalr	1790(ra) # 800025da <killed>
    80002ee4:	e93d                	bnez	a0,80002f5a <usertrap+0x118>
  usertrapret();
    80002ee6:	00000097          	auipc	ra,0x0
    80002eea:	c36080e7          	jalr	-970(ra) # 80002b1c <usertrapret>
}
    80002eee:	60e2                	ld	ra,24(sp)
    80002ef0:	6442                	ld	s0,16(sp)
    80002ef2:	64a2                	ld	s1,8(sp)
    80002ef4:	6902                	ld	s2,0(sp)
    80002ef6:	6105                	addi	sp,sp,32
    80002ef8:	8082                	ret
      exit(-1);
    80002efa:	557d                	li	a0,-1
    80002efc:	fffff097          	auipc	ra,0xfffff
    80002f00:	55e080e7          	jalr	1374(ra) # 8000245a <exit>
    80002f04:	bf6d                	j	80002ebe <usertrap+0x7c>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f06:	14302573          	csrr	a0,stval
    int check = pgfault(r_stval(), p->pagetable);
    80002f0a:	68ac                	ld	a1,80(s1)
    80002f0c:	00000097          	auipc	ra,0x0
    80002f10:	e68080e7          	jalr	-408(ra) # 80002d74 <pgfault>
    if(check == -1)
    80002f14:	57fd                	li	a5,-1
    80002f16:	fcf512e3          	bne	a0,a5,80002eda <usertrap+0x98>
      p->killed = 1;
    80002f1a:	4785                	li	a5,1
    80002f1c:	d49c                	sw	a5,40(s1)
    80002f1e:	bf75                	j	80002eda <usertrap+0x98>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f20:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f24:	5890                	lw	a2,48(s1)
    80002f26:	00005517          	auipc	a0,0x5
    80002f2a:	4ba50513          	addi	a0,a0,1210 # 800083e0 <states.0+0xf8>
    80002f2e:	ffffd097          	auipc	ra,0xffffd
    80002f32:	65a080e7          	jalr	1626(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f36:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f3a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f3e:	00005517          	auipc	a0,0x5
    80002f42:	4d250513          	addi	a0,a0,1234 # 80008410 <states.0+0x128>
    80002f46:	ffffd097          	auipc	ra,0xffffd
    80002f4a:	642080e7          	jalr	1602(ra) # 80000588 <printf>
    setkilled(p);
    80002f4e:	8526                	mv	a0,s1
    80002f50:	fffff097          	auipc	ra,0xfffff
    80002f54:	65e080e7          	jalr	1630(ra) # 800025ae <setkilled>
    80002f58:	b749                	j	80002eda <usertrap+0x98>
  if (killed(p))
    80002f5a:	4901                	li	s2,0
    printf("MAAR DO AAJ\n");
    80002f5c:	00005517          	auipc	a0,0x5
    80002f60:	4d450513          	addi	a0,a0,1236 # 80008430 <states.0+0x148>
    80002f64:	ffffd097          	auipc	ra,0xffffd
    80002f68:	624080e7          	jalr	1572(ra) # 80000588 <printf>
    exit(-1);
    80002f6c:	557d                	li	a0,-1
    80002f6e:	fffff097          	auipc	ra,0xfffff
    80002f72:	4ec080e7          	jalr	1260(ra) # 8000245a <exit>
  if (which_dev == 2)
    80002f76:	4789                	li	a5,2
    80002f78:	f6f917e3          	bne	s2,a5,80002ee6 <usertrap+0xa4>
    yield();
    80002f7c:	fffff097          	auipc	ra,0xfffff
    80002f80:	36e080e7          	jalr	878(ra) # 800022ea <yield>
    80002f84:	b78d                	j	80002ee6 <usertrap+0xa4>

0000000080002f86 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f86:	1101                	addi	sp,sp,-32
    80002f88:	ec06                	sd	ra,24(sp)
    80002f8a:	e822                	sd	s0,16(sp)
    80002f8c:	e426                	sd	s1,8(sp)
    80002f8e:	1000                	addi	s0,sp,32
    80002f90:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f92:	fffff097          	auipc	ra,0xfffff
    80002f96:	b7c080e7          	jalr	-1156(ra) # 80001b0e <myproc>
  switch (n) {
    80002f9a:	4795                	li	a5,5
    80002f9c:	0497e163          	bltu	a5,s1,80002fde <argraw+0x58>
    80002fa0:	048a                	slli	s1,s1,0x2
    80002fa2:	00005717          	auipc	a4,0x5
    80002fa6:	4c670713          	addi	a4,a4,1222 # 80008468 <states.0+0x180>
    80002faa:	94ba                	add	s1,s1,a4
    80002fac:	409c                	lw	a5,0(s1)
    80002fae:	97ba                	add	a5,a5,a4
    80002fb0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002fb2:	6d3c                	ld	a5,88(a0)
    80002fb4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002fb6:	60e2                	ld	ra,24(sp)
    80002fb8:	6442                	ld	s0,16(sp)
    80002fba:	64a2                	ld	s1,8(sp)
    80002fbc:	6105                	addi	sp,sp,32
    80002fbe:	8082                	ret
    return p->trapframe->a1;
    80002fc0:	6d3c                	ld	a5,88(a0)
    80002fc2:	7fa8                	ld	a0,120(a5)
    80002fc4:	bfcd                	j	80002fb6 <argraw+0x30>
    return p->trapframe->a2;
    80002fc6:	6d3c                	ld	a5,88(a0)
    80002fc8:	63c8                	ld	a0,128(a5)
    80002fca:	b7f5                	j	80002fb6 <argraw+0x30>
    return p->trapframe->a3;
    80002fcc:	6d3c                	ld	a5,88(a0)
    80002fce:	67c8                	ld	a0,136(a5)
    80002fd0:	b7dd                	j	80002fb6 <argraw+0x30>
    return p->trapframe->a4;
    80002fd2:	6d3c                	ld	a5,88(a0)
    80002fd4:	6bc8                	ld	a0,144(a5)
    80002fd6:	b7c5                	j	80002fb6 <argraw+0x30>
    return p->trapframe->a5;
    80002fd8:	6d3c                	ld	a5,88(a0)
    80002fda:	6fc8                	ld	a0,152(a5)
    80002fdc:	bfe9                	j	80002fb6 <argraw+0x30>
  panic("argraw");
    80002fde:	00005517          	auipc	a0,0x5
    80002fe2:	46250513          	addi	a0,a0,1122 # 80008440 <states.0+0x158>
    80002fe6:	ffffd097          	auipc	ra,0xffffd
    80002fea:	558080e7          	jalr	1368(ra) # 8000053e <panic>

0000000080002fee <fetchaddr>:
{
    80002fee:	1101                	addi	sp,sp,-32
    80002ff0:	ec06                	sd	ra,24(sp)
    80002ff2:	e822                	sd	s0,16(sp)
    80002ff4:	e426                	sd	s1,8(sp)
    80002ff6:	e04a                	sd	s2,0(sp)
    80002ff8:	1000                	addi	s0,sp,32
    80002ffa:	84aa                	mv	s1,a0
    80002ffc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ffe:	fffff097          	auipc	ra,0xfffff
    80003002:	b10080e7          	jalr	-1264(ra) # 80001b0e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003006:	653c                	ld	a5,72(a0)
    80003008:	02f4f863          	bgeu	s1,a5,80003038 <fetchaddr+0x4a>
    8000300c:	00848713          	addi	a4,s1,8
    80003010:	02e7e663          	bltu	a5,a4,8000303c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003014:	46a1                	li	a3,8
    80003016:	8626                	mv	a2,s1
    80003018:	85ca                	mv	a1,s2
    8000301a:	6928                	ld	a0,80(a0)
    8000301c:	fffff097          	auipc	ra,0xfffff
    80003020:	83a080e7          	jalr	-1990(ra) # 80001856 <copyin>
    80003024:	00a03533          	snez	a0,a0
    80003028:	40a00533          	neg	a0,a0
}
    8000302c:	60e2                	ld	ra,24(sp)
    8000302e:	6442                	ld	s0,16(sp)
    80003030:	64a2                	ld	s1,8(sp)
    80003032:	6902                	ld	s2,0(sp)
    80003034:	6105                	addi	sp,sp,32
    80003036:	8082                	ret
    return -1;
    80003038:	557d                	li	a0,-1
    8000303a:	bfcd                	j	8000302c <fetchaddr+0x3e>
    8000303c:	557d                	li	a0,-1
    8000303e:	b7fd                	j	8000302c <fetchaddr+0x3e>

0000000080003040 <fetchstr>:
{
    80003040:	7179                	addi	sp,sp,-48
    80003042:	f406                	sd	ra,40(sp)
    80003044:	f022                	sd	s0,32(sp)
    80003046:	ec26                	sd	s1,24(sp)
    80003048:	e84a                	sd	s2,16(sp)
    8000304a:	e44e                	sd	s3,8(sp)
    8000304c:	1800                	addi	s0,sp,48
    8000304e:	892a                	mv	s2,a0
    80003050:	84ae                	mv	s1,a1
    80003052:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003054:	fffff097          	auipc	ra,0xfffff
    80003058:	aba080e7          	jalr	-1350(ra) # 80001b0e <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000305c:	86ce                	mv	a3,s3
    8000305e:	864a                	mv	a2,s2
    80003060:	85a6                	mv	a1,s1
    80003062:	6928                	ld	a0,80(a0)
    80003064:	fffff097          	auipc	ra,0xfffff
    80003068:	880080e7          	jalr	-1920(ra) # 800018e4 <copyinstr>
    8000306c:	00054e63          	bltz	a0,80003088 <fetchstr+0x48>
  return strlen(buf);
    80003070:	8526                	mv	a0,s1
    80003072:	ffffe097          	auipc	ra,0xffffe
    80003076:	efc080e7          	jalr	-260(ra) # 80000f6e <strlen>
}
    8000307a:	70a2                	ld	ra,40(sp)
    8000307c:	7402                	ld	s0,32(sp)
    8000307e:	64e2                	ld	s1,24(sp)
    80003080:	6942                	ld	s2,16(sp)
    80003082:	69a2                	ld	s3,8(sp)
    80003084:	6145                	addi	sp,sp,48
    80003086:	8082                	ret
    return -1;
    80003088:	557d                	li	a0,-1
    8000308a:	bfc5                	j	8000307a <fetchstr+0x3a>

000000008000308c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000308c:	1101                	addi	sp,sp,-32
    8000308e:	ec06                	sd	ra,24(sp)
    80003090:	e822                	sd	s0,16(sp)
    80003092:	e426                	sd	s1,8(sp)
    80003094:	1000                	addi	s0,sp,32
    80003096:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003098:	00000097          	auipc	ra,0x0
    8000309c:	eee080e7          	jalr	-274(ra) # 80002f86 <argraw>
    800030a0:	c088                	sw	a0,0(s1)
}
    800030a2:	60e2                	ld	ra,24(sp)
    800030a4:	6442                	ld	s0,16(sp)
    800030a6:	64a2                	ld	s1,8(sp)
    800030a8:	6105                	addi	sp,sp,32
    800030aa:	8082                	ret

00000000800030ac <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800030ac:	1101                	addi	sp,sp,-32
    800030ae:	ec06                	sd	ra,24(sp)
    800030b0:	e822                	sd	s0,16(sp)
    800030b2:	e426                	sd	s1,8(sp)
    800030b4:	1000                	addi	s0,sp,32
    800030b6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030b8:	00000097          	auipc	ra,0x0
    800030bc:	ece080e7          	jalr	-306(ra) # 80002f86 <argraw>
    800030c0:	e088                	sd	a0,0(s1)
}
    800030c2:	60e2                	ld	ra,24(sp)
    800030c4:	6442                	ld	s0,16(sp)
    800030c6:	64a2                	ld	s1,8(sp)
    800030c8:	6105                	addi	sp,sp,32
    800030ca:	8082                	ret

00000000800030cc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800030cc:	7179                	addi	sp,sp,-48
    800030ce:	f406                	sd	ra,40(sp)
    800030d0:	f022                	sd	s0,32(sp)
    800030d2:	ec26                	sd	s1,24(sp)
    800030d4:	e84a                	sd	s2,16(sp)
    800030d6:	1800                	addi	s0,sp,48
    800030d8:	84ae                	mv	s1,a1
    800030da:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800030dc:	fd840593          	addi	a1,s0,-40
    800030e0:	00000097          	auipc	ra,0x0
    800030e4:	fcc080e7          	jalr	-52(ra) # 800030ac <argaddr>
  return fetchstr(addr, buf, max);
    800030e8:	864a                	mv	a2,s2
    800030ea:	85a6                	mv	a1,s1
    800030ec:	fd843503          	ld	a0,-40(s0)
    800030f0:	00000097          	auipc	ra,0x0
    800030f4:	f50080e7          	jalr	-176(ra) # 80003040 <fetchstr>
}
    800030f8:	70a2                	ld	ra,40(sp)
    800030fa:	7402                	ld	s0,32(sp)
    800030fc:	64e2                	ld	s1,24(sp)
    800030fe:	6942                	ld	s2,16(sp)
    80003100:	6145                	addi	sp,sp,48
    80003102:	8082                	ret

0000000080003104 <syscall>:
[SYS_setpriority] sys_set_priority,
};

void
syscall(void)
{
    80003104:	1101                	addi	sp,sp,-32
    80003106:	ec06                	sd	ra,24(sp)
    80003108:	e822                	sd	s0,16(sp)
    8000310a:	e426                	sd	s1,8(sp)
    8000310c:	e04a                	sd	s2,0(sp)
    8000310e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003110:	fffff097          	auipc	ra,0xfffff
    80003114:	9fe080e7          	jalr	-1538(ra) # 80001b0e <myproc>
    80003118:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000311a:	05853903          	ld	s2,88(a0)
    8000311e:	0a893783          	ld	a5,168(s2)
    80003122:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003126:	37fd                	addiw	a5,a5,-1
    80003128:	475d                	li	a4,23
    8000312a:	00f76f63          	bltu	a4,a5,80003148 <syscall+0x44>
    8000312e:	00369713          	slli	a4,a3,0x3
    80003132:	00005797          	auipc	a5,0x5
    80003136:	34e78793          	addi	a5,a5,846 # 80008480 <syscalls>
    8000313a:	97ba                	add	a5,a5,a4
    8000313c:	639c                	ld	a5,0(a5)
    8000313e:	c789                	beqz	a5,80003148 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003140:	9782                	jalr	a5
    80003142:	06a93823          	sd	a0,112(s2)
    80003146:	a839                	j	80003164 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003148:	15848613          	addi	a2,s1,344
    8000314c:	588c                	lw	a1,48(s1)
    8000314e:	00005517          	auipc	a0,0x5
    80003152:	2fa50513          	addi	a0,a0,762 # 80008448 <states.0+0x160>
    80003156:	ffffd097          	auipc	ra,0xffffd
    8000315a:	432080e7          	jalr	1074(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000315e:	6cbc                	ld	a5,88(s1)
    80003160:	577d                	li	a4,-1
    80003162:	fbb8                	sd	a4,112(a5)
  }
}
    80003164:	60e2                	ld	ra,24(sp)
    80003166:	6442                	ld	s0,16(sp)
    80003168:	64a2                	ld	s1,8(sp)
    8000316a:	6902                	ld	s2,0(sp)
    8000316c:	6105                	addi	sp,sp,32
    8000316e:	8082                	ret

0000000080003170 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003170:	1101                	addi	sp,sp,-32
    80003172:	ec06                	sd	ra,24(sp)
    80003174:	e822                	sd	s0,16(sp)
    80003176:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003178:	fec40593          	addi	a1,s0,-20
    8000317c:	4501                	li	a0,0
    8000317e:	00000097          	auipc	ra,0x0
    80003182:	f0e080e7          	jalr	-242(ra) # 8000308c <argint>
  exit(n);
    80003186:	fec42503          	lw	a0,-20(s0)
    8000318a:	fffff097          	auipc	ra,0xfffff
    8000318e:	2d0080e7          	jalr	720(ra) # 8000245a <exit>
  return 0; // not reached
}
    80003192:	4501                	li	a0,0
    80003194:	60e2                	ld	ra,24(sp)
    80003196:	6442                	ld	s0,16(sp)
    80003198:	6105                	addi	sp,sp,32
    8000319a:	8082                	ret

000000008000319c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000319c:	1141                	addi	sp,sp,-16
    8000319e:	e406                	sd	ra,8(sp)
    800031a0:	e022                	sd	s0,0(sp)
    800031a2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800031a4:	fffff097          	auipc	ra,0xfffff
    800031a8:	96a080e7          	jalr	-1686(ra) # 80001b0e <myproc>
}
    800031ac:	5908                	lw	a0,48(a0)
    800031ae:	60a2                	ld	ra,8(sp)
    800031b0:	6402                	ld	s0,0(sp)
    800031b2:	0141                	addi	sp,sp,16
    800031b4:	8082                	ret

00000000800031b6 <sys_fork>:

uint64
sys_fork(void)
{
    800031b6:	1141                	addi	sp,sp,-16
    800031b8:	e406                	sd	ra,8(sp)
    800031ba:	e022                	sd	s0,0(sp)
    800031bc:	0800                	addi	s0,sp,16
  return fork();
    800031be:	fffff097          	auipc	ra,0xfffff
    800031c2:	d40080e7          	jalr	-704(ra) # 80001efe <fork>
}
    800031c6:	60a2                	ld	ra,8(sp)
    800031c8:	6402                	ld	s0,0(sp)
    800031ca:	0141                	addi	sp,sp,16
    800031cc:	8082                	ret

00000000800031ce <sys_wait>:

uint64
sys_wait(void)
{
    800031ce:	1101                	addi	sp,sp,-32
    800031d0:	ec06                	sd	ra,24(sp)
    800031d2:	e822                	sd	s0,16(sp)
    800031d4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800031d6:	fe840593          	addi	a1,s0,-24
    800031da:	4501                	li	a0,0
    800031dc:	00000097          	auipc	ra,0x0
    800031e0:	ed0080e7          	jalr	-304(ra) # 800030ac <argaddr>
  return wait(p);
    800031e4:	fe843503          	ld	a0,-24(s0)
    800031e8:	fffff097          	auipc	ra,0xfffff
    800031ec:	424080e7          	jalr	1060(ra) # 8000260c <wait>
}
    800031f0:	60e2                	ld	ra,24(sp)
    800031f2:	6442                	ld	s0,16(sp)
    800031f4:	6105                	addi	sp,sp,32
    800031f6:	8082                	ret

00000000800031f8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800031f8:	7179                	addi	sp,sp,-48
    800031fa:	f406                	sd	ra,40(sp)
    800031fc:	f022                	sd	s0,32(sp)
    800031fe:	ec26                	sd	s1,24(sp)
    80003200:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003202:	fdc40593          	addi	a1,s0,-36
    80003206:	4501                	li	a0,0
    80003208:	00000097          	auipc	ra,0x0
    8000320c:	e84080e7          	jalr	-380(ra) # 8000308c <argint>
  addr = myproc()->sz;
    80003210:	fffff097          	auipc	ra,0xfffff
    80003214:	8fe080e7          	jalr	-1794(ra) # 80001b0e <myproc>
    80003218:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    8000321a:	fdc42503          	lw	a0,-36(s0)
    8000321e:	fffff097          	auipc	ra,0xfffff
    80003222:	c84080e7          	jalr	-892(ra) # 80001ea2 <growproc>
    80003226:	00054863          	bltz	a0,80003236 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000322a:	8526                	mv	a0,s1
    8000322c:	70a2                	ld	ra,40(sp)
    8000322e:	7402                	ld	s0,32(sp)
    80003230:	64e2                	ld	s1,24(sp)
    80003232:	6145                	addi	sp,sp,48
    80003234:	8082                	ret
    return -1;
    80003236:	54fd                	li	s1,-1
    80003238:	bfcd                	j	8000322a <sys_sbrk+0x32>

000000008000323a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000323a:	7139                	addi	sp,sp,-64
    8000323c:	fc06                	sd	ra,56(sp)
    8000323e:	f822                	sd	s0,48(sp)
    80003240:	f426                	sd	s1,40(sp)
    80003242:	f04a                	sd	s2,32(sp)
    80003244:	ec4e                	sd	s3,24(sp)
    80003246:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003248:	fcc40593          	addi	a1,s0,-52
    8000324c:	4501                	li	a0,0
    8000324e:	00000097          	auipc	ra,0x0
    80003252:	e3e080e7          	jalr	-450(ra) # 8000308c <argint>
  acquire(&tickslock);
    80003256:	00234517          	auipc	a0,0x234
    8000325a:	17250513          	addi	a0,a0,370 # 802373c8 <tickslock>
    8000325e:	ffffe097          	auipc	ra,0xffffe
    80003262:	a98080e7          	jalr	-1384(ra) # 80000cf6 <acquire>
  ticks0 = ticks;
    80003266:	00005917          	auipc	s2,0x5
    8000326a:	6aa92903          	lw	s2,1706(s2) # 80008910 <ticks>
  while (ticks - ticks0 < n)
    8000326e:	fcc42783          	lw	a5,-52(s0)
    80003272:	cf9d                	beqz	a5,800032b0 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003274:	00234997          	auipc	s3,0x234
    80003278:	15498993          	addi	s3,s3,340 # 802373c8 <tickslock>
    8000327c:	00005497          	auipc	s1,0x5
    80003280:	69448493          	addi	s1,s1,1684 # 80008910 <ticks>
    if (killed(myproc()))
    80003284:	fffff097          	auipc	ra,0xfffff
    80003288:	88a080e7          	jalr	-1910(ra) # 80001b0e <myproc>
    8000328c:	fffff097          	auipc	ra,0xfffff
    80003290:	34e080e7          	jalr	846(ra) # 800025da <killed>
    80003294:	ed15                	bnez	a0,800032d0 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003296:	85ce                	mv	a1,s3
    80003298:	8526                	mv	a0,s1
    8000329a:	fffff097          	auipc	ra,0xfffff
    8000329e:	08c080e7          	jalr	140(ra) # 80002326 <sleep>
  while (ticks - ticks0 < n)
    800032a2:	409c                	lw	a5,0(s1)
    800032a4:	412787bb          	subw	a5,a5,s2
    800032a8:	fcc42703          	lw	a4,-52(s0)
    800032ac:	fce7ece3          	bltu	a5,a4,80003284 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800032b0:	00234517          	auipc	a0,0x234
    800032b4:	11850513          	addi	a0,a0,280 # 802373c8 <tickslock>
    800032b8:	ffffe097          	auipc	ra,0xffffe
    800032bc:	af2080e7          	jalr	-1294(ra) # 80000daa <release>
  return 0;
    800032c0:	4501                	li	a0,0
}
    800032c2:	70e2                	ld	ra,56(sp)
    800032c4:	7442                	ld	s0,48(sp)
    800032c6:	74a2                	ld	s1,40(sp)
    800032c8:	7902                	ld	s2,32(sp)
    800032ca:	69e2                	ld	s3,24(sp)
    800032cc:	6121                	addi	sp,sp,64
    800032ce:	8082                	ret
      release(&tickslock);
    800032d0:	00234517          	auipc	a0,0x234
    800032d4:	0f850513          	addi	a0,a0,248 # 802373c8 <tickslock>
    800032d8:	ffffe097          	auipc	ra,0xffffe
    800032dc:	ad2080e7          	jalr	-1326(ra) # 80000daa <release>
      return -1;
    800032e0:	557d                	li	a0,-1
    800032e2:	b7c5                	j	800032c2 <sys_sleep+0x88>

00000000800032e4 <sys_kill>:

uint64
sys_kill(void)
{
    800032e4:	1101                	addi	sp,sp,-32
    800032e6:	ec06                	sd	ra,24(sp)
    800032e8:	e822                	sd	s0,16(sp)
    800032ea:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800032ec:	fec40593          	addi	a1,s0,-20
    800032f0:	4501                	li	a0,0
    800032f2:	00000097          	auipc	ra,0x0
    800032f6:	d9a080e7          	jalr	-614(ra) # 8000308c <argint>
  return kill(pid);
    800032fa:	fec42503          	lw	a0,-20(s0)
    800032fe:	fffff097          	auipc	ra,0xfffff
    80003302:	23e080e7          	jalr	574(ra) # 8000253c <kill>
}
    80003306:	60e2                	ld	ra,24(sp)
    80003308:	6442                	ld	s0,16(sp)
    8000330a:	6105                	addi	sp,sp,32
    8000330c:	8082                	ret

000000008000330e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000330e:	1101                	addi	sp,sp,-32
    80003310:	ec06                	sd	ra,24(sp)
    80003312:	e822                	sd	s0,16(sp)
    80003314:	e426                	sd	s1,8(sp)
    80003316:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003318:	00234517          	auipc	a0,0x234
    8000331c:	0b050513          	addi	a0,a0,176 # 802373c8 <tickslock>
    80003320:	ffffe097          	auipc	ra,0xffffe
    80003324:	9d6080e7          	jalr	-1578(ra) # 80000cf6 <acquire>
  xticks = ticks;
    80003328:	00005497          	auipc	s1,0x5
    8000332c:	5e84a483          	lw	s1,1512(s1) # 80008910 <ticks>
  release(&tickslock);
    80003330:	00234517          	auipc	a0,0x234
    80003334:	09850513          	addi	a0,a0,152 # 802373c8 <tickslock>
    80003338:	ffffe097          	auipc	ra,0xffffe
    8000333c:	a72080e7          	jalr	-1422(ra) # 80000daa <release>
  return xticks;
}
    80003340:	02049513          	slli	a0,s1,0x20
    80003344:	9101                	srli	a0,a0,0x20
    80003346:	60e2                	ld	ra,24(sp)
    80003348:	6442                	ld	s0,16(sp)
    8000334a:	64a2                	ld	s1,8(sp)
    8000334c:	6105                	addi	sp,sp,32
    8000334e:	8082                	ret

0000000080003350 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003350:	7139                	addi	sp,sp,-64
    80003352:	fc06                	sd	ra,56(sp)
    80003354:	f822                	sd	s0,48(sp)
    80003356:	f426                	sd	s1,40(sp)
    80003358:	f04a                	sd	s2,32(sp)
    8000335a:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000335c:	fd840593          	addi	a1,s0,-40
    80003360:	4501                	li	a0,0
    80003362:	00000097          	auipc	ra,0x0
    80003366:	d4a080e7          	jalr	-694(ra) # 800030ac <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000336a:	fd040593          	addi	a1,s0,-48
    8000336e:	4505                	li	a0,1
    80003370:	00000097          	auipc	ra,0x0
    80003374:	d3c080e7          	jalr	-708(ra) # 800030ac <argaddr>
  argaddr(2, &addr2);
    80003378:	fc840593          	addi	a1,s0,-56
    8000337c:	4509                	li	a0,2
    8000337e:	00000097          	auipc	ra,0x0
    80003382:	d2e080e7          	jalr	-722(ra) # 800030ac <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003386:	fc040613          	addi	a2,s0,-64
    8000338a:	fc440593          	addi	a1,s0,-60
    8000338e:	fd843503          	ld	a0,-40(s0)
    80003392:	fffff097          	auipc	ra,0xfffff
    80003396:	502080e7          	jalr	1282(ra) # 80002894 <waitx>
    8000339a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	772080e7          	jalr	1906(ra) # 80001b0e <myproc>
    800033a4:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800033a6:	4691                	li	a3,4
    800033a8:	fc440613          	addi	a2,s0,-60
    800033ac:	fd043583          	ld	a1,-48(s0)
    800033b0:	6928                	ld	a0,80(a0)
    800033b2:	ffffe097          	auipc	ra,0xffffe
    800033b6:	3dc080e7          	jalr	988(ra) # 8000178e <copyout>
    return -1;
    800033ba:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800033bc:	00054f63          	bltz	a0,800033da <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800033c0:	4691                	li	a3,4
    800033c2:	fc040613          	addi	a2,s0,-64
    800033c6:	fc843583          	ld	a1,-56(s0)
    800033ca:	68a8                	ld	a0,80(s1)
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	3c2080e7          	jalr	962(ra) # 8000178e <copyout>
    800033d4:	00054a63          	bltz	a0,800033e8 <sys_waitx+0x98>
    return -1;
  return ret;
    800033d8:	87ca                	mv	a5,s2
}
    800033da:	853e                	mv	a0,a5
    800033dc:	70e2                	ld	ra,56(sp)
    800033de:	7442                	ld	s0,48(sp)
    800033e0:	74a2                	ld	s1,40(sp)
    800033e2:	7902                	ld	s2,32(sp)
    800033e4:	6121                	addi	sp,sp,64
    800033e6:	8082                	ret
    return -1;
    800033e8:	57fd                	li	a5,-1
    800033ea:	bfc5                	j	800033da <sys_waitx+0x8a>

00000000800033ec <sys_set_priority>:

uint64
sys_set_priority(void)
{
    800033ec:	7179                	addi	sp,sp,-48
    800033ee:	f406                	sd	ra,40(sp)
    800033f0:	f022                	sd	s0,32(sp)
    800033f2:	ec26                	sd	s1,24(sp)
    800033f4:	1800                	addi	s0,sp,48
  int pid, new_priority;
  argint(0, &pid);
    800033f6:	fdc40593          	addi	a1,s0,-36
    800033fa:	4501                	li	a0,0
    800033fc:	00000097          	auipc	ra,0x0
    80003400:	c90080e7          	jalr	-880(ra) # 8000308c <argint>
  argint(1, &new_priority);
    80003404:	fd840593          	addi	a1,s0,-40
    80003408:	4505                	li	a0,1
    8000340a:	00000097          	auipc	ra,0x0
    8000340e:	c82080e7          	jalr	-894(ra) # 8000308c <argint>
  if(new_priority < 0 || new_priority > 100)
    80003412:	fd842583          	lw	a1,-40(s0)
    80003416:	0005881b          	sext.w	a6,a1
    8000341a:	06400793          	li	a5,100
    return -1;      // Invalid priority value
    8000341e:	557d                	li	a0,-1
  if(new_priority < 0 || new_priority > 100)
    80003420:	0307ef63          	bltu	a5,a6,8000345e <sys_set_priority+0x72>

  struct proc* p;
  for(p = proc; p < &proc[NPROC]; p++)
  {
    if(p->pid == pid)
    80003424:	fdc42683          	lw	a3,-36(s0)
  for(p = proc; p < &proc[NPROC]; p++)
    80003428:	0022e797          	auipc	a5,0x22e
    8000342c:	ba078793          	addi	a5,a5,-1120 # 80230fc8 <proc>
    80003430:	00234617          	auipc	a2,0x234
    80003434:	f9860613          	addi	a2,a2,-104 # 802373c8 <tickslock>
    if(p->pid == pid)
    80003438:	5b98                	lw	a4,48(a5)
    8000343a:	00d70863          	beq	a4,a3,8000344a <sys_set_priority+0x5e>
  for(p = proc; p < &proc[NPROC]; p++)
    8000343e:	19078793          	addi	a5,a5,400
    80003442:	fec79be3          	bne	a5,a2,80003438 <sys_set_priority+0x4c>
        yield();

      return old_priority;
    }
  }
  return -1;
    80003446:	557d                	li	a0,-1
    80003448:	a819                	j	8000345e <sys_set_priority+0x72>
      p->RBI = 25;
    8000344a:	4765                	li	a4,25
    8000344c:	18e7a223          	sw	a4,388(a5)
      int old_priority = p->SP;
    80003450:	1807a483          	lw	s1,384(a5)
      p->SP = new_priority;
    80003454:	1907a023          	sw	a6,384(a5)
      if(new_priority < old_priority)
    80003458:	0095c863          	blt	a1,s1,80003468 <sys_set_priority+0x7c>
      return old_priority;
    8000345c:	8526                	mv	a0,s1
    8000345e:	70a2                	ld	ra,40(sp)
    80003460:	7402                	ld	s0,32(sp)
    80003462:	64e2                	ld	s1,24(sp)
    80003464:	6145                	addi	sp,sp,48
    80003466:	8082                	ret
        yield();
    80003468:	fffff097          	auipc	ra,0xfffff
    8000346c:	e82080e7          	jalr	-382(ra) # 800022ea <yield>
    80003470:	b7f5                	j	8000345c <sys_set_priority+0x70>

0000000080003472 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003472:	7179                	addi	sp,sp,-48
    80003474:	f406                	sd	ra,40(sp)
    80003476:	f022                	sd	s0,32(sp)
    80003478:	ec26                	sd	s1,24(sp)
    8000347a:	e84a                	sd	s2,16(sp)
    8000347c:	e44e                	sd	s3,8(sp)
    8000347e:	e052                	sd	s4,0(sp)
    80003480:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003482:	00005597          	auipc	a1,0x5
    80003486:	0c658593          	addi	a1,a1,198 # 80008548 <syscalls+0xc8>
    8000348a:	00234517          	auipc	a0,0x234
    8000348e:	f5650513          	addi	a0,a0,-170 # 802373e0 <bcache>
    80003492:	ffffd097          	auipc	ra,0xffffd
    80003496:	7d4080e7          	jalr	2004(ra) # 80000c66 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000349a:	0023c797          	auipc	a5,0x23c
    8000349e:	f4678793          	addi	a5,a5,-186 # 8023f3e0 <bcache+0x8000>
    800034a2:	0023c717          	auipc	a4,0x23c
    800034a6:	1a670713          	addi	a4,a4,422 # 8023f648 <bcache+0x8268>
    800034aa:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034ae:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034b2:	00234497          	auipc	s1,0x234
    800034b6:	f4648493          	addi	s1,s1,-186 # 802373f8 <bcache+0x18>
    b->next = bcache.head.next;
    800034ba:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034bc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034be:	00005a17          	auipc	s4,0x5
    800034c2:	092a0a13          	addi	s4,s4,146 # 80008550 <syscalls+0xd0>
    b->next = bcache.head.next;
    800034c6:	2b893783          	ld	a5,696(s2)
    800034ca:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800034cc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034d0:	85d2                	mv	a1,s4
    800034d2:	01048513          	addi	a0,s1,16
    800034d6:	00001097          	auipc	ra,0x1
    800034da:	4c4080e7          	jalr	1220(ra) # 8000499a <initsleeplock>
    bcache.head.next->prev = b;
    800034de:	2b893783          	ld	a5,696(s2)
    800034e2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034e4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034e8:	45848493          	addi	s1,s1,1112
    800034ec:	fd349de3          	bne	s1,s3,800034c6 <binit+0x54>
  }
}
    800034f0:	70a2                	ld	ra,40(sp)
    800034f2:	7402                	ld	s0,32(sp)
    800034f4:	64e2                	ld	s1,24(sp)
    800034f6:	6942                	ld	s2,16(sp)
    800034f8:	69a2                	ld	s3,8(sp)
    800034fa:	6a02                	ld	s4,0(sp)
    800034fc:	6145                	addi	sp,sp,48
    800034fe:	8082                	ret

0000000080003500 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003500:	7179                	addi	sp,sp,-48
    80003502:	f406                	sd	ra,40(sp)
    80003504:	f022                	sd	s0,32(sp)
    80003506:	ec26                	sd	s1,24(sp)
    80003508:	e84a                	sd	s2,16(sp)
    8000350a:	e44e                	sd	s3,8(sp)
    8000350c:	1800                	addi	s0,sp,48
    8000350e:	892a                	mv	s2,a0
    80003510:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003512:	00234517          	auipc	a0,0x234
    80003516:	ece50513          	addi	a0,a0,-306 # 802373e0 <bcache>
    8000351a:	ffffd097          	auipc	ra,0xffffd
    8000351e:	7dc080e7          	jalr	2012(ra) # 80000cf6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003522:	0023c497          	auipc	s1,0x23c
    80003526:	1764b483          	ld	s1,374(s1) # 8023f698 <bcache+0x82b8>
    8000352a:	0023c797          	auipc	a5,0x23c
    8000352e:	11e78793          	addi	a5,a5,286 # 8023f648 <bcache+0x8268>
    80003532:	02f48f63          	beq	s1,a5,80003570 <bread+0x70>
    80003536:	873e                	mv	a4,a5
    80003538:	a021                	j	80003540 <bread+0x40>
    8000353a:	68a4                	ld	s1,80(s1)
    8000353c:	02e48a63          	beq	s1,a4,80003570 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003540:	449c                	lw	a5,8(s1)
    80003542:	ff279ce3          	bne	a5,s2,8000353a <bread+0x3a>
    80003546:	44dc                	lw	a5,12(s1)
    80003548:	ff3799e3          	bne	a5,s3,8000353a <bread+0x3a>
      b->refcnt++;
    8000354c:	40bc                	lw	a5,64(s1)
    8000354e:	2785                	addiw	a5,a5,1
    80003550:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003552:	00234517          	auipc	a0,0x234
    80003556:	e8e50513          	addi	a0,a0,-370 # 802373e0 <bcache>
    8000355a:	ffffe097          	auipc	ra,0xffffe
    8000355e:	850080e7          	jalr	-1968(ra) # 80000daa <release>
      acquiresleep(&b->lock);
    80003562:	01048513          	addi	a0,s1,16
    80003566:	00001097          	auipc	ra,0x1
    8000356a:	46e080e7          	jalr	1134(ra) # 800049d4 <acquiresleep>
      return b;
    8000356e:	a8b9                	j	800035cc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003570:	0023c497          	auipc	s1,0x23c
    80003574:	1204b483          	ld	s1,288(s1) # 8023f690 <bcache+0x82b0>
    80003578:	0023c797          	auipc	a5,0x23c
    8000357c:	0d078793          	addi	a5,a5,208 # 8023f648 <bcache+0x8268>
    80003580:	00f48863          	beq	s1,a5,80003590 <bread+0x90>
    80003584:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003586:	40bc                	lw	a5,64(s1)
    80003588:	cf81                	beqz	a5,800035a0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000358a:	64a4                	ld	s1,72(s1)
    8000358c:	fee49de3          	bne	s1,a4,80003586 <bread+0x86>
  panic("bget: no buffers");
    80003590:	00005517          	auipc	a0,0x5
    80003594:	fc850513          	addi	a0,a0,-56 # 80008558 <syscalls+0xd8>
    80003598:	ffffd097          	auipc	ra,0xffffd
    8000359c:	fa6080e7          	jalr	-90(ra) # 8000053e <panic>
      b->dev = dev;
    800035a0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800035a4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800035a8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035ac:	4785                	li	a5,1
    800035ae:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035b0:	00234517          	auipc	a0,0x234
    800035b4:	e3050513          	addi	a0,a0,-464 # 802373e0 <bcache>
    800035b8:	ffffd097          	auipc	ra,0xffffd
    800035bc:	7f2080e7          	jalr	2034(ra) # 80000daa <release>
      acquiresleep(&b->lock);
    800035c0:	01048513          	addi	a0,s1,16
    800035c4:	00001097          	auipc	ra,0x1
    800035c8:	410080e7          	jalr	1040(ra) # 800049d4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800035cc:	409c                	lw	a5,0(s1)
    800035ce:	cb89                	beqz	a5,800035e0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035d0:	8526                	mv	a0,s1
    800035d2:	70a2                	ld	ra,40(sp)
    800035d4:	7402                	ld	s0,32(sp)
    800035d6:	64e2                	ld	s1,24(sp)
    800035d8:	6942                	ld	s2,16(sp)
    800035da:	69a2                	ld	s3,8(sp)
    800035dc:	6145                	addi	sp,sp,48
    800035de:	8082                	ret
    virtio_disk_rw(b, 0);
    800035e0:	4581                	li	a1,0
    800035e2:	8526                	mv	a0,s1
    800035e4:	00003097          	auipc	ra,0x3
    800035e8:	000080e7          	jalr	ra # 800065e4 <virtio_disk_rw>
    b->valid = 1;
    800035ec:	4785                	li	a5,1
    800035ee:	c09c                	sw	a5,0(s1)
  return b;
    800035f0:	b7c5                	j	800035d0 <bread+0xd0>

00000000800035f2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035f2:	1101                	addi	sp,sp,-32
    800035f4:	ec06                	sd	ra,24(sp)
    800035f6:	e822                	sd	s0,16(sp)
    800035f8:	e426                	sd	s1,8(sp)
    800035fa:	1000                	addi	s0,sp,32
    800035fc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035fe:	0541                	addi	a0,a0,16
    80003600:	00001097          	auipc	ra,0x1
    80003604:	46e080e7          	jalr	1134(ra) # 80004a6e <holdingsleep>
    80003608:	cd01                	beqz	a0,80003620 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000360a:	4585                	li	a1,1
    8000360c:	8526                	mv	a0,s1
    8000360e:	00003097          	auipc	ra,0x3
    80003612:	fd6080e7          	jalr	-42(ra) # 800065e4 <virtio_disk_rw>
}
    80003616:	60e2                	ld	ra,24(sp)
    80003618:	6442                	ld	s0,16(sp)
    8000361a:	64a2                	ld	s1,8(sp)
    8000361c:	6105                	addi	sp,sp,32
    8000361e:	8082                	ret
    panic("bwrite");
    80003620:	00005517          	auipc	a0,0x5
    80003624:	f5050513          	addi	a0,a0,-176 # 80008570 <syscalls+0xf0>
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	f16080e7          	jalr	-234(ra) # 8000053e <panic>

0000000080003630 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003630:	1101                	addi	sp,sp,-32
    80003632:	ec06                	sd	ra,24(sp)
    80003634:	e822                	sd	s0,16(sp)
    80003636:	e426                	sd	s1,8(sp)
    80003638:	e04a                	sd	s2,0(sp)
    8000363a:	1000                	addi	s0,sp,32
    8000363c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000363e:	01050913          	addi	s2,a0,16
    80003642:	854a                	mv	a0,s2
    80003644:	00001097          	auipc	ra,0x1
    80003648:	42a080e7          	jalr	1066(ra) # 80004a6e <holdingsleep>
    8000364c:	c92d                	beqz	a0,800036be <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000364e:	854a                	mv	a0,s2
    80003650:	00001097          	auipc	ra,0x1
    80003654:	3da080e7          	jalr	986(ra) # 80004a2a <releasesleep>

  acquire(&bcache.lock);
    80003658:	00234517          	auipc	a0,0x234
    8000365c:	d8850513          	addi	a0,a0,-632 # 802373e0 <bcache>
    80003660:	ffffd097          	auipc	ra,0xffffd
    80003664:	696080e7          	jalr	1686(ra) # 80000cf6 <acquire>
  b->refcnt--;
    80003668:	40bc                	lw	a5,64(s1)
    8000366a:	37fd                	addiw	a5,a5,-1
    8000366c:	0007871b          	sext.w	a4,a5
    80003670:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003672:	eb05                	bnez	a4,800036a2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003674:	68bc                	ld	a5,80(s1)
    80003676:	64b8                	ld	a4,72(s1)
    80003678:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000367a:	64bc                	ld	a5,72(s1)
    8000367c:	68b8                	ld	a4,80(s1)
    8000367e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003680:	0023c797          	auipc	a5,0x23c
    80003684:	d6078793          	addi	a5,a5,-672 # 8023f3e0 <bcache+0x8000>
    80003688:	2b87b703          	ld	a4,696(a5)
    8000368c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000368e:	0023c717          	auipc	a4,0x23c
    80003692:	fba70713          	addi	a4,a4,-70 # 8023f648 <bcache+0x8268>
    80003696:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003698:	2b87b703          	ld	a4,696(a5)
    8000369c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000369e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800036a2:	00234517          	auipc	a0,0x234
    800036a6:	d3e50513          	addi	a0,a0,-706 # 802373e0 <bcache>
    800036aa:	ffffd097          	auipc	ra,0xffffd
    800036ae:	700080e7          	jalr	1792(ra) # 80000daa <release>
}
    800036b2:	60e2                	ld	ra,24(sp)
    800036b4:	6442                	ld	s0,16(sp)
    800036b6:	64a2                	ld	s1,8(sp)
    800036b8:	6902                	ld	s2,0(sp)
    800036ba:	6105                	addi	sp,sp,32
    800036bc:	8082                	ret
    panic("brelse");
    800036be:	00005517          	auipc	a0,0x5
    800036c2:	eba50513          	addi	a0,a0,-326 # 80008578 <syscalls+0xf8>
    800036c6:	ffffd097          	auipc	ra,0xffffd
    800036ca:	e78080e7          	jalr	-392(ra) # 8000053e <panic>

00000000800036ce <bpin>:

void
bpin(struct buf *b) {
    800036ce:	1101                	addi	sp,sp,-32
    800036d0:	ec06                	sd	ra,24(sp)
    800036d2:	e822                	sd	s0,16(sp)
    800036d4:	e426                	sd	s1,8(sp)
    800036d6:	1000                	addi	s0,sp,32
    800036d8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036da:	00234517          	auipc	a0,0x234
    800036de:	d0650513          	addi	a0,a0,-762 # 802373e0 <bcache>
    800036e2:	ffffd097          	auipc	ra,0xffffd
    800036e6:	614080e7          	jalr	1556(ra) # 80000cf6 <acquire>
  b->refcnt++;
    800036ea:	40bc                	lw	a5,64(s1)
    800036ec:	2785                	addiw	a5,a5,1
    800036ee:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036f0:	00234517          	auipc	a0,0x234
    800036f4:	cf050513          	addi	a0,a0,-784 # 802373e0 <bcache>
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	6b2080e7          	jalr	1714(ra) # 80000daa <release>
}
    80003700:	60e2                	ld	ra,24(sp)
    80003702:	6442                	ld	s0,16(sp)
    80003704:	64a2                	ld	s1,8(sp)
    80003706:	6105                	addi	sp,sp,32
    80003708:	8082                	ret

000000008000370a <bunpin>:

void
bunpin(struct buf *b) {
    8000370a:	1101                	addi	sp,sp,-32
    8000370c:	ec06                	sd	ra,24(sp)
    8000370e:	e822                	sd	s0,16(sp)
    80003710:	e426                	sd	s1,8(sp)
    80003712:	1000                	addi	s0,sp,32
    80003714:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003716:	00234517          	auipc	a0,0x234
    8000371a:	cca50513          	addi	a0,a0,-822 # 802373e0 <bcache>
    8000371e:	ffffd097          	auipc	ra,0xffffd
    80003722:	5d8080e7          	jalr	1496(ra) # 80000cf6 <acquire>
  b->refcnt--;
    80003726:	40bc                	lw	a5,64(s1)
    80003728:	37fd                	addiw	a5,a5,-1
    8000372a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000372c:	00234517          	auipc	a0,0x234
    80003730:	cb450513          	addi	a0,a0,-844 # 802373e0 <bcache>
    80003734:	ffffd097          	auipc	ra,0xffffd
    80003738:	676080e7          	jalr	1654(ra) # 80000daa <release>
}
    8000373c:	60e2                	ld	ra,24(sp)
    8000373e:	6442                	ld	s0,16(sp)
    80003740:	64a2                	ld	s1,8(sp)
    80003742:	6105                	addi	sp,sp,32
    80003744:	8082                	ret

0000000080003746 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003746:	1101                	addi	sp,sp,-32
    80003748:	ec06                	sd	ra,24(sp)
    8000374a:	e822                	sd	s0,16(sp)
    8000374c:	e426                	sd	s1,8(sp)
    8000374e:	e04a                	sd	s2,0(sp)
    80003750:	1000                	addi	s0,sp,32
    80003752:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003754:	00d5d59b          	srliw	a1,a1,0xd
    80003758:	0023c797          	auipc	a5,0x23c
    8000375c:	3647a783          	lw	a5,868(a5) # 8023fabc <sb+0x1c>
    80003760:	9dbd                	addw	a1,a1,a5
    80003762:	00000097          	auipc	ra,0x0
    80003766:	d9e080e7          	jalr	-610(ra) # 80003500 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000376a:	0074f713          	andi	a4,s1,7
    8000376e:	4785                	li	a5,1
    80003770:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003774:	14ce                	slli	s1,s1,0x33
    80003776:	90d9                	srli	s1,s1,0x36
    80003778:	00950733          	add	a4,a0,s1
    8000377c:	05874703          	lbu	a4,88(a4)
    80003780:	00e7f6b3          	and	a3,a5,a4
    80003784:	c69d                	beqz	a3,800037b2 <bfree+0x6c>
    80003786:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003788:	94aa                	add	s1,s1,a0
    8000378a:	fff7c793          	not	a5,a5
    8000378e:	8ff9                	and	a5,a5,a4
    80003790:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003794:	00001097          	auipc	ra,0x1
    80003798:	120080e7          	jalr	288(ra) # 800048b4 <log_write>
  brelse(bp);
    8000379c:	854a                	mv	a0,s2
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	e92080e7          	jalr	-366(ra) # 80003630 <brelse>
}
    800037a6:	60e2                	ld	ra,24(sp)
    800037a8:	6442                	ld	s0,16(sp)
    800037aa:	64a2                	ld	s1,8(sp)
    800037ac:	6902                	ld	s2,0(sp)
    800037ae:	6105                	addi	sp,sp,32
    800037b0:	8082                	ret
    panic("freeing free block");
    800037b2:	00005517          	auipc	a0,0x5
    800037b6:	dce50513          	addi	a0,a0,-562 # 80008580 <syscalls+0x100>
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	d84080e7          	jalr	-636(ra) # 8000053e <panic>

00000000800037c2 <balloc>:
{
    800037c2:	711d                	addi	sp,sp,-96
    800037c4:	ec86                	sd	ra,88(sp)
    800037c6:	e8a2                	sd	s0,80(sp)
    800037c8:	e4a6                	sd	s1,72(sp)
    800037ca:	e0ca                	sd	s2,64(sp)
    800037cc:	fc4e                	sd	s3,56(sp)
    800037ce:	f852                	sd	s4,48(sp)
    800037d0:	f456                	sd	s5,40(sp)
    800037d2:	f05a                	sd	s6,32(sp)
    800037d4:	ec5e                	sd	s7,24(sp)
    800037d6:	e862                	sd	s8,16(sp)
    800037d8:	e466                	sd	s9,8(sp)
    800037da:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037dc:	0023c797          	auipc	a5,0x23c
    800037e0:	2c87a783          	lw	a5,712(a5) # 8023faa4 <sb+0x4>
    800037e4:	10078163          	beqz	a5,800038e6 <balloc+0x124>
    800037e8:	8baa                	mv	s7,a0
    800037ea:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037ec:	0023cb17          	auipc	s6,0x23c
    800037f0:	2b4b0b13          	addi	s6,s6,692 # 8023faa0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037f4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037f6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037f8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037fa:	6c89                	lui	s9,0x2
    800037fc:	a061                	j	80003884 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037fe:	974a                	add	a4,a4,s2
    80003800:	8fd5                	or	a5,a5,a3
    80003802:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003806:	854a                	mv	a0,s2
    80003808:	00001097          	auipc	ra,0x1
    8000380c:	0ac080e7          	jalr	172(ra) # 800048b4 <log_write>
        brelse(bp);
    80003810:	854a                	mv	a0,s2
    80003812:	00000097          	auipc	ra,0x0
    80003816:	e1e080e7          	jalr	-482(ra) # 80003630 <brelse>
  bp = bread(dev, bno);
    8000381a:	85a6                	mv	a1,s1
    8000381c:	855e                	mv	a0,s7
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	ce2080e7          	jalr	-798(ra) # 80003500 <bread>
    80003826:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003828:	40000613          	li	a2,1024
    8000382c:	4581                	li	a1,0
    8000382e:	05850513          	addi	a0,a0,88
    80003832:	ffffd097          	auipc	ra,0xffffd
    80003836:	5c0080e7          	jalr	1472(ra) # 80000df2 <memset>
  log_write(bp);
    8000383a:	854a                	mv	a0,s2
    8000383c:	00001097          	auipc	ra,0x1
    80003840:	078080e7          	jalr	120(ra) # 800048b4 <log_write>
  brelse(bp);
    80003844:	854a                	mv	a0,s2
    80003846:	00000097          	auipc	ra,0x0
    8000384a:	dea080e7          	jalr	-534(ra) # 80003630 <brelse>
}
    8000384e:	8526                	mv	a0,s1
    80003850:	60e6                	ld	ra,88(sp)
    80003852:	6446                	ld	s0,80(sp)
    80003854:	64a6                	ld	s1,72(sp)
    80003856:	6906                	ld	s2,64(sp)
    80003858:	79e2                	ld	s3,56(sp)
    8000385a:	7a42                	ld	s4,48(sp)
    8000385c:	7aa2                	ld	s5,40(sp)
    8000385e:	7b02                	ld	s6,32(sp)
    80003860:	6be2                	ld	s7,24(sp)
    80003862:	6c42                	ld	s8,16(sp)
    80003864:	6ca2                	ld	s9,8(sp)
    80003866:	6125                	addi	sp,sp,96
    80003868:	8082                	ret
    brelse(bp);
    8000386a:	854a                	mv	a0,s2
    8000386c:	00000097          	auipc	ra,0x0
    80003870:	dc4080e7          	jalr	-572(ra) # 80003630 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003874:	015c87bb          	addw	a5,s9,s5
    80003878:	00078a9b          	sext.w	s5,a5
    8000387c:	004b2703          	lw	a4,4(s6)
    80003880:	06eaf363          	bgeu	s5,a4,800038e6 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003884:	41fad79b          	sraiw	a5,s5,0x1f
    80003888:	0137d79b          	srliw	a5,a5,0x13
    8000388c:	015787bb          	addw	a5,a5,s5
    80003890:	40d7d79b          	sraiw	a5,a5,0xd
    80003894:	01cb2583          	lw	a1,28(s6)
    80003898:	9dbd                	addw	a1,a1,a5
    8000389a:	855e                	mv	a0,s7
    8000389c:	00000097          	auipc	ra,0x0
    800038a0:	c64080e7          	jalr	-924(ra) # 80003500 <bread>
    800038a4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038a6:	004b2503          	lw	a0,4(s6)
    800038aa:	000a849b          	sext.w	s1,s5
    800038ae:	8662                	mv	a2,s8
    800038b0:	faa4fde3          	bgeu	s1,a0,8000386a <balloc+0xa8>
      m = 1 << (bi % 8);
    800038b4:	41f6579b          	sraiw	a5,a2,0x1f
    800038b8:	01d7d69b          	srliw	a3,a5,0x1d
    800038bc:	00c6873b          	addw	a4,a3,a2
    800038c0:	00777793          	andi	a5,a4,7
    800038c4:	9f95                	subw	a5,a5,a3
    800038c6:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800038ca:	4037571b          	sraiw	a4,a4,0x3
    800038ce:	00e906b3          	add	a3,s2,a4
    800038d2:	0586c683          	lbu	a3,88(a3)
    800038d6:	00d7f5b3          	and	a1,a5,a3
    800038da:	d195                	beqz	a1,800037fe <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038dc:	2605                	addiw	a2,a2,1
    800038de:	2485                	addiw	s1,s1,1
    800038e0:	fd4618e3          	bne	a2,s4,800038b0 <balloc+0xee>
    800038e4:	b759                	j	8000386a <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800038e6:	00005517          	auipc	a0,0x5
    800038ea:	cb250513          	addi	a0,a0,-846 # 80008598 <syscalls+0x118>
    800038ee:	ffffd097          	auipc	ra,0xffffd
    800038f2:	c9a080e7          	jalr	-870(ra) # 80000588 <printf>
  return 0;
    800038f6:	4481                	li	s1,0
    800038f8:	bf99                	j	8000384e <balloc+0x8c>

00000000800038fa <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800038fa:	7179                	addi	sp,sp,-48
    800038fc:	f406                	sd	ra,40(sp)
    800038fe:	f022                	sd	s0,32(sp)
    80003900:	ec26                	sd	s1,24(sp)
    80003902:	e84a                	sd	s2,16(sp)
    80003904:	e44e                	sd	s3,8(sp)
    80003906:	e052                	sd	s4,0(sp)
    80003908:	1800                	addi	s0,sp,48
    8000390a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000390c:	47ad                	li	a5,11
    8000390e:	02b7e763          	bltu	a5,a1,8000393c <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003912:	02059493          	slli	s1,a1,0x20
    80003916:	9081                	srli	s1,s1,0x20
    80003918:	048a                	slli	s1,s1,0x2
    8000391a:	94aa                	add	s1,s1,a0
    8000391c:	0504a903          	lw	s2,80(s1)
    80003920:	06091e63          	bnez	s2,8000399c <bmap+0xa2>
      addr = balloc(ip->dev);
    80003924:	4108                	lw	a0,0(a0)
    80003926:	00000097          	auipc	ra,0x0
    8000392a:	e9c080e7          	jalr	-356(ra) # 800037c2 <balloc>
    8000392e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003932:	06090563          	beqz	s2,8000399c <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003936:	0524a823          	sw	s2,80(s1)
    8000393a:	a08d                	j	8000399c <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000393c:	ff45849b          	addiw	s1,a1,-12
    80003940:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003944:	0ff00793          	li	a5,255
    80003948:	08e7e563          	bltu	a5,a4,800039d2 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000394c:	08052903          	lw	s2,128(a0)
    80003950:	00091d63          	bnez	s2,8000396a <bmap+0x70>
      addr = balloc(ip->dev);
    80003954:	4108                	lw	a0,0(a0)
    80003956:	00000097          	auipc	ra,0x0
    8000395a:	e6c080e7          	jalr	-404(ra) # 800037c2 <balloc>
    8000395e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003962:	02090d63          	beqz	s2,8000399c <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003966:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000396a:	85ca                	mv	a1,s2
    8000396c:	0009a503          	lw	a0,0(s3)
    80003970:	00000097          	auipc	ra,0x0
    80003974:	b90080e7          	jalr	-1136(ra) # 80003500 <bread>
    80003978:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000397a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000397e:	02049593          	slli	a1,s1,0x20
    80003982:	9181                	srli	a1,a1,0x20
    80003984:	058a                	slli	a1,a1,0x2
    80003986:	00b784b3          	add	s1,a5,a1
    8000398a:	0004a903          	lw	s2,0(s1)
    8000398e:	02090063          	beqz	s2,800039ae <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003992:	8552                	mv	a0,s4
    80003994:	00000097          	auipc	ra,0x0
    80003998:	c9c080e7          	jalr	-868(ra) # 80003630 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000399c:	854a                	mv	a0,s2
    8000399e:	70a2                	ld	ra,40(sp)
    800039a0:	7402                	ld	s0,32(sp)
    800039a2:	64e2                	ld	s1,24(sp)
    800039a4:	6942                	ld	s2,16(sp)
    800039a6:	69a2                	ld	s3,8(sp)
    800039a8:	6a02                	ld	s4,0(sp)
    800039aa:	6145                	addi	sp,sp,48
    800039ac:	8082                	ret
      addr = balloc(ip->dev);
    800039ae:	0009a503          	lw	a0,0(s3)
    800039b2:	00000097          	auipc	ra,0x0
    800039b6:	e10080e7          	jalr	-496(ra) # 800037c2 <balloc>
    800039ba:	0005091b          	sext.w	s2,a0
      if(addr){
    800039be:	fc090ae3          	beqz	s2,80003992 <bmap+0x98>
        a[bn] = addr;
    800039c2:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800039c6:	8552                	mv	a0,s4
    800039c8:	00001097          	auipc	ra,0x1
    800039cc:	eec080e7          	jalr	-276(ra) # 800048b4 <log_write>
    800039d0:	b7c9                	j	80003992 <bmap+0x98>
  panic("bmap: out of range");
    800039d2:	00005517          	auipc	a0,0x5
    800039d6:	bde50513          	addi	a0,a0,-1058 # 800085b0 <syscalls+0x130>
    800039da:	ffffd097          	auipc	ra,0xffffd
    800039de:	b64080e7          	jalr	-1180(ra) # 8000053e <panic>

00000000800039e2 <iget>:
{
    800039e2:	7179                	addi	sp,sp,-48
    800039e4:	f406                	sd	ra,40(sp)
    800039e6:	f022                	sd	s0,32(sp)
    800039e8:	ec26                	sd	s1,24(sp)
    800039ea:	e84a                	sd	s2,16(sp)
    800039ec:	e44e                	sd	s3,8(sp)
    800039ee:	e052                	sd	s4,0(sp)
    800039f0:	1800                	addi	s0,sp,48
    800039f2:	89aa                	mv	s3,a0
    800039f4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039f6:	0023c517          	auipc	a0,0x23c
    800039fa:	0ca50513          	addi	a0,a0,202 # 8023fac0 <itable>
    800039fe:	ffffd097          	auipc	ra,0xffffd
    80003a02:	2f8080e7          	jalr	760(ra) # 80000cf6 <acquire>
  empty = 0;
    80003a06:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a08:	0023c497          	auipc	s1,0x23c
    80003a0c:	0d048493          	addi	s1,s1,208 # 8023fad8 <itable+0x18>
    80003a10:	0023e697          	auipc	a3,0x23e
    80003a14:	b5868693          	addi	a3,a3,-1192 # 80241568 <log>
    80003a18:	a039                	j	80003a26 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a1a:	02090b63          	beqz	s2,80003a50 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a1e:	08848493          	addi	s1,s1,136
    80003a22:	02d48a63          	beq	s1,a3,80003a56 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a26:	449c                	lw	a5,8(s1)
    80003a28:	fef059e3          	blez	a5,80003a1a <iget+0x38>
    80003a2c:	4098                	lw	a4,0(s1)
    80003a2e:	ff3716e3          	bne	a4,s3,80003a1a <iget+0x38>
    80003a32:	40d8                	lw	a4,4(s1)
    80003a34:	ff4713e3          	bne	a4,s4,80003a1a <iget+0x38>
      ip->ref++;
    80003a38:	2785                	addiw	a5,a5,1
    80003a3a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a3c:	0023c517          	auipc	a0,0x23c
    80003a40:	08450513          	addi	a0,a0,132 # 8023fac0 <itable>
    80003a44:	ffffd097          	auipc	ra,0xffffd
    80003a48:	366080e7          	jalr	870(ra) # 80000daa <release>
      return ip;
    80003a4c:	8926                	mv	s2,s1
    80003a4e:	a03d                	j	80003a7c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a50:	f7f9                	bnez	a5,80003a1e <iget+0x3c>
    80003a52:	8926                	mv	s2,s1
    80003a54:	b7e9                	j	80003a1e <iget+0x3c>
  if(empty == 0)
    80003a56:	02090c63          	beqz	s2,80003a8e <iget+0xac>
  ip->dev = dev;
    80003a5a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a5e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a62:	4785                	li	a5,1
    80003a64:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a68:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a6c:	0023c517          	auipc	a0,0x23c
    80003a70:	05450513          	addi	a0,a0,84 # 8023fac0 <itable>
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	336080e7          	jalr	822(ra) # 80000daa <release>
}
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	70a2                	ld	ra,40(sp)
    80003a80:	7402                	ld	s0,32(sp)
    80003a82:	64e2                	ld	s1,24(sp)
    80003a84:	6942                	ld	s2,16(sp)
    80003a86:	69a2                	ld	s3,8(sp)
    80003a88:	6a02                	ld	s4,0(sp)
    80003a8a:	6145                	addi	sp,sp,48
    80003a8c:	8082                	ret
    panic("iget: no inodes");
    80003a8e:	00005517          	auipc	a0,0x5
    80003a92:	b3a50513          	addi	a0,a0,-1222 # 800085c8 <syscalls+0x148>
    80003a96:	ffffd097          	auipc	ra,0xffffd
    80003a9a:	aa8080e7          	jalr	-1368(ra) # 8000053e <panic>

0000000080003a9e <fsinit>:
fsinit(int dev) {
    80003a9e:	7179                	addi	sp,sp,-48
    80003aa0:	f406                	sd	ra,40(sp)
    80003aa2:	f022                	sd	s0,32(sp)
    80003aa4:	ec26                	sd	s1,24(sp)
    80003aa6:	e84a                	sd	s2,16(sp)
    80003aa8:	e44e                	sd	s3,8(sp)
    80003aaa:	1800                	addi	s0,sp,48
    80003aac:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003aae:	4585                	li	a1,1
    80003ab0:	00000097          	auipc	ra,0x0
    80003ab4:	a50080e7          	jalr	-1456(ra) # 80003500 <bread>
    80003ab8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003aba:	0023c997          	auipc	s3,0x23c
    80003abe:	fe698993          	addi	s3,s3,-26 # 8023faa0 <sb>
    80003ac2:	02000613          	li	a2,32
    80003ac6:	05850593          	addi	a1,a0,88
    80003aca:	854e                	mv	a0,s3
    80003acc:	ffffd097          	auipc	ra,0xffffd
    80003ad0:	382080e7          	jalr	898(ra) # 80000e4e <memmove>
  brelse(bp);
    80003ad4:	8526                	mv	a0,s1
    80003ad6:	00000097          	auipc	ra,0x0
    80003ada:	b5a080e7          	jalr	-1190(ra) # 80003630 <brelse>
  if(sb.magic != FSMAGIC)
    80003ade:	0009a703          	lw	a4,0(s3)
    80003ae2:	102037b7          	lui	a5,0x10203
    80003ae6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003aea:	02f71263          	bne	a4,a5,80003b0e <fsinit+0x70>
  initlog(dev, &sb);
    80003aee:	0023c597          	auipc	a1,0x23c
    80003af2:	fb258593          	addi	a1,a1,-78 # 8023faa0 <sb>
    80003af6:	854a                	mv	a0,s2
    80003af8:	00001097          	auipc	ra,0x1
    80003afc:	b40080e7          	jalr	-1216(ra) # 80004638 <initlog>
}
    80003b00:	70a2                	ld	ra,40(sp)
    80003b02:	7402                	ld	s0,32(sp)
    80003b04:	64e2                	ld	s1,24(sp)
    80003b06:	6942                	ld	s2,16(sp)
    80003b08:	69a2                	ld	s3,8(sp)
    80003b0a:	6145                	addi	sp,sp,48
    80003b0c:	8082                	ret
    panic("invalid file system");
    80003b0e:	00005517          	auipc	a0,0x5
    80003b12:	aca50513          	addi	a0,a0,-1334 # 800085d8 <syscalls+0x158>
    80003b16:	ffffd097          	auipc	ra,0xffffd
    80003b1a:	a28080e7          	jalr	-1496(ra) # 8000053e <panic>

0000000080003b1e <iinit>:
{
    80003b1e:	7179                	addi	sp,sp,-48
    80003b20:	f406                	sd	ra,40(sp)
    80003b22:	f022                	sd	s0,32(sp)
    80003b24:	ec26                	sd	s1,24(sp)
    80003b26:	e84a                	sd	s2,16(sp)
    80003b28:	e44e                	sd	s3,8(sp)
    80003b2a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b2c:	00005597          	auipc	a1,0x5
    80003b30:	ac458593          	addi	a1,a1,-1340 # 800085f0 <syscalls+0x170>
    80003b34:	0023c517          	auipc	a0,0x23c
    80003b38:	f8c50513          	addi	a0,a0,-116 # 8023fac0 <itable>
    80003b3c:	ffffd097          	auipc	ra,0xffffd
    80003b40:	12a080e7          	jalr	298(ra) # 80000c66 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b44:	0023c497          	auipc	s1,0x23c
    80003b48:	fa448493          	addi	s1,s1,-92 # 8023fae8 <itable+0x28>
    80003b4c:	0023e997          	auipc	s3,0x23e
    80003b50:	a2c98993          	addi	s3,s3,-1492 # 80241578 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b54:	00005917          	auipc	s2,0x5
    80003b58:	aa490913          	addi	s2,s2,-1372 # 800085f8 <syscalls+0x178>
    80003b5c:	85ca                	mv	a1,s2
    80003b5e:	8526                	mv	a0,s1
    80003b60:	00001097          	auipc	ra,0x1
    80003b64:	e3a080e7          	jalr	-454(ra) # 8000499a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b68:	08848493          	addi	s1,s1,136
    80003b6c:	ff3498e3          	bne	s1,s3,80003b5c <iinit+0x3e>
}
    80003b70:	70a2                	ld	ra,40(sp)
    80003b72:	7402                	ld	s0,32(sp)
    80003b74:	64e2                	ld	s1,24(sp)
    80003b76:	6942                	ld	s2,16(sp)
    80003b78:	69a2                	ld	s3,8(sp)
    80003b7a:	6145                	addi	sp,sp,48
    80003b7c:	8082                	ret

0000000080003b7e <ialloc>:
{
    80003b7e:	715d                	addi	sp,sp,-80
    80003b80:	e486                	sd	ra,72(sp)
    80003b82:	e0a2                	sd	s0,64(sp)
    80003b84:	fc26                	sd	s1,56(sp)
    80003b86:	f84a                	sd	s2,48(sp)
    80003b88:	f44e                	sd	s3,40(sp)
    80003b8a:	f052                	sd	s4,32(sp)
    80003b8c:	ec56                	sd	s5,24(sp)
    80003b8e:	e85a                	sd	s6,16(sp)
    80003b90:	e45e                	sd	s7,8(sp)
    80003b92:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b94:	0023c717          	auipc	a4,0x23c
    80003b98:	f1872703          	lw	a4,-232(a4) # 8023faac <sb+0xc>
    80003b9c:	4785                	li	a5,1
    80003b9e:	04e7fa63          	bgeu	a5,a4,80003bf2 <ialloc+0x74>
    80003ba2:	8aaa                	mv	s5,a0
    80003ba4:	8bae                	mv	s7,a1
    80003ba6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003ba8:	0023ca17          	auipc	s4,0x23c
    80003bac:	ef8a0a13          	addi	s4,s4,-264 # 8023faa0 <sb>
    80003bb0:	00048b1b          	sext.w	s6,s1
    80003bb4:	0044d793          	srli	a5,s1,0x4
    80003bb8:	018a2583          	lw	a1,24(s4)
    80003bbc:	9dbd                	addw	a1,a1,a5
    80003bbe:	8556                	mv	a0,s5
    80003bc0:	00000097          	auipc	ra,0x0
    80003bc4:	940080e7          	jalr	-1728(ra) # 80003500 <bread>
    80003bc8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003bca:	05850993          	addi	s3,a0,88
    80003bce:	00f4f793          	andi	a5,s1,15
    80003bd2:	079a                	slli	a5,a5,0x6
    80003bd4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003bd6:	00099783          	lh	a5,0(s3)
    80003bda:	c3a1                	beqz	a5,80003c1a <ialloc+0x9c>
    brelse(bp);
    80003bdc:	00000097          	auipc	ra,0x0
    80003be0:	a54080e7          	jalr	-1452(ra) # 80003630 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003be4:	0485                	addi	s1,s1,1
    80003be6:	00ca2703          	lw	a4,12(s4)
    80003bea:	0004879b          	sext.w	a5,s1
    80003bee:	fce7e1e3          	bltu	a5,a4,80003bb0 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003bf2:	00005517          	auipc	a0,0x5
    80003bf6:	a0e50513          	addi	a0,a0,-1522 # 80008600 <syscalls+0x180>
    80003bfa:	ffffd097          	auipc	ra,0xffffd
    80003bfe:	98e080e7          	jalr	-1650(ra) # 80000588 <printf>
  return 0;
    80003c02:	4501                	li	a0,0
}
    80003c04:	60a6                	ld	ra,72(sp)
    80003c06:	6406                	ld	s0,64(sp)
    80003c08:	74e2                	ld	s1,56(sp)
    80003c0a:	7942                	ld	s2,48(sp)
    80003c0c:	79a2                	ld	s3,40(sp)
    80003c0e:	7a02                	ld	s4,32(sp)
    80003c10:	6ae2                	ld	s5,24(sp)
    80003c12:	6b42                	ld	s6,16(sp)
    80003c14:	6ba2                	ld	s7,8(sp)
    80003c16:	6161                	addi	sp,sp,80
    80003c18:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003c1a:	04000613          	li	a2,64
    80003c1e:	4581                	li	a1,0
    80003c20:	854e                	mv	a0,s3
    80003c22:	ffffd097          	auipc	ra,0xffffd
    80003c26:	1d0080e7          	jalr	464(ra) # 80000df2 <memset>
      dip->type = type;
    80003c2a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c2e:	854a                	mv	a0,s2
    80003c30:	00001097          	auipc	ra,0x1
    80003c34:	c84080e7          	jalr	-892(ra) # 800048b4 <log_write>
      brelse(bp);
    80003c38:	854a                	mv	a0,s2
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	9f6080e7          	jalr	-1546(ra) # 80003630 <brelse>
      return iget(dev, inum);
    80003c42:	85da                	mv	a1,s6
    80003c44:	8556                	mv	a0,s5
    80003c46:	00000097          	auipc	ra,0x0
    80003c4a:	d9c080e7          	jalr	-612(ra) # 800039e2 <iget>
    80003c4e:	bf5d                	j	80003c04 <ialloc+0x86>

0000000080003c50 <iupdate>:
{
    80003c50:	1101                	addi	sp,sp,-32
    80003c52:	ec06                	sd	ra,24(sp)
    80003c54:	e822                	sd	s0,16(sp)
    80003c56:	e426                	sd	s1,8(sp)
    80003c58:	e04a                	sd	s2,0(sp)
    80003c5a:	1000                	addi	s0,sp,32
    80003c5c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c5e:	415c                	lw	a5,4(a0)
    80003c60:	0047d79b          	srliw	a5,a5,0x4
    80003c64:	0023c597          	auipc	a1,0x23c
    80003c68:	e545a583          	lw	a1,-428(a1) # 8023fab8 <sb+0x18>
    80003c6c:	9dbd                	addw	a1,a1,a5
    80003c6e:	4108                	lw	a0,0(a0)
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	890080e7          	jalr	-1904(ra) # 80003500 <bread>
    80003c78:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c7a:	05850793          	addi	a5,a0,88
    80003c7e:	40c8                	lw	a0,4(s1)
    80003c80:	893d                	andi	a0,a0,15
    80003c82:	051a                	slli	a0,a0,0x6
    80003c84:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c86:	04449703          	lh	a4,68(s1)
    80003c8a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c8e:	04649703          	lh	a4,70(s1)
    80003c92:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c96:	04849703          	lh	a4,72(s1)
    80003c9a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c9e:	04a49703          	lh	a4,74(s1)
    80003ca2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ca6:	44f8                	lw	a4,76(s1)
    80003ca8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003caa:	03400613          	li	a2,52
    80003cae:	05048593          	addi	a1,s1,80
    80003cb2:	0531                	addi	a0,a0,12
    80003cb4:	ffffd097          	auipc	ra,0xffffd
    80003cb8:	19a080e7          	jalr	410(ra) # 80000e4e <memmove>
  log_write(bp);
    80003cbc:	854a                	mv	a0,s2
    80003cbe:	00001097          	auipc	ra,0x1
    80003cc2:	bf6080e7          	jalr	-1034(ra) # 800048b4 <log_write>
  brelse(bp);
    80003cc6:	854a                	mv	a0,s2
    80003cc8:	00000097          	auipc	ra,0x0
    80003ccc:	968080e7          	jalr	-1688(ra) # 80003630 <brelse>
}
    80003cd0:	60e2                	ld	ra,24(sp)
    80003cd2:	6442                	ld	s0,16(sp)
    80003cd4:	64a2                	ld	s1,8(sp)
    80003cd6:	6902                	ld	s2,0(sp)
    80003cd8:	6105                	addi	sp,sp,32
    80003cda:	8082                	ret

0000000080003cdc <idup>:
{
    80003cdc:	1101                	addi	sp,sp,-32
    80003cde:	ec06                	sd	ra,24(sp)
    80003ce0:	e822                	sd	s0,16(sp)
    80003ce2:	e426                	sd	s1,8(sp)
    80003ce4:	1000                	addi	s0,sp,32
    80003ce6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ce8:	0023c517          	auipc	a0,0x23c
    80003cec:	dd850513          	addi	a0,a0,-552 # 8023fac0 <itable>
    80003cf0:	ffffd097          	auipc	ra,0xffffd
    80003cf4:	006080e7          	jalr	6(ra) # 80000cf6 <acquire>
  ip->ref++;
    80003cf8:	449c                	lw	a5,8(s1)
    80003cfa:	2785                	addiw	a5,a5,1
    80003cfc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cfe:	0023c517          	auipc	a0,0x23c
    80003d02:	dc250513          	addi	a0,a0,-574 # 8023fac0 <itable>
    80003d06:	ffffd097          	auipc	ra,0xffffd
    80003d0a:	0a4080e7          	jalr	164(ra) # 80000daa <release>
}
    80003d0e:	8526                	mv	a0,s1
    80003d10:	60e2                	ld	ra,24(sp)
    80003d12:	6442                	ld	s0,16(sp)
    80003d14:	64a2                	ld	s1,8(sp)
    80003d16:	6105                	addi	sp,sp,32
    80003d18:	8082                	ret

0000000080003d1a <ilock>:
{
    80003d1a:	1101                	addi	sp,sp,-32
    80003d1c:	ec06                	sd	ra,24(sp)
    80003d1e:	e822                	sd	s0,16(sp)
    80003d20:	e426                	sd	s1,8(sp)
    80003d22:	e04a                	sd	s2,0(sp)
    80003d24:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d26:	c115                	beqz	a0,80003d4a <ilock+0x30>
    80003d28:	84aa                	mv	s1,a0
    80003d2a:	451c                	lw	a5,8(a0)
    80003d2c:	00f05f63          	blez	a5,80003d4a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d30:	0541                	addi	a0,a0,16
    80003d32:	00001097          	auipc	ra,0x1
    80003d36:	ca2080e7          	jalr	-862(ra) # 800049d4 <acquiresleep>
  if(ip->valid == 0){
    80003d3a:	40bc                	lw	a5,64(s1)
    80003d3c:	cf99                	beqz	a5,80003d5a <ilock+0x40>
}
    80003d3e:	60e2                	ld	ra,24(sp)
    80003d40:	6442                	ld	s0,16(sp)
    80003d42:	64a2                	ld	s1,8(sp)
    80003d44:	6902                	ld	s2,0(sp)
    80003d46:	6105                	addi	sp,sp,32
    80003d48:	8082                	ret
    panic("ilock");
    80003d4a:	00005517          	auipc	a0,0x5
    80003d4e:	8ce50513          	addi	a0,a0,-1842 # 80008618 <syscalls+0x198>
    80003d52:	ffffc097          	auipc	ra,0xffffc
    80003d56:	7ec080e7          	jalr	2028(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d5a:	40dc                	lw	a5,4(s1)
    80003d5c:	0047d79b          	srliw	a5,a5,0x4
    80003d60:	0023c597          	auipc	a1,0x23c
    80003d64:	d585a583          	lw	a1,-680(a1) # 8023fab8 <sb+0x18>
    80003d68:	9dbd                	addw	a1,a1,a5
    80003d6a:	4088                	lw	a0,0(s1)
    80003d6c:	fffff097          	auipc	ra,0xfffff
    80003d70:	794080e7          	jalr	1940(ra) # 80003500 <bread>
    80003d74:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d76:	05850593          	addi	a1,a0,88
    80003d7a:	40dc                	lw	a5,4(s1)
    80003d7c:	8bbd                	andi	a5,a5,15
    80003d7e:	079a                	slli	a5,a5,0x6
    80003d80:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d82:	00059783          	lh	a5,0(a1)
    80003d86:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d8a:	00259783          	lh	a5,2(a1)
    80003d8e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d92:	00459783          	lh	a5,4(a1)
    80003d96:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d9a:	00659783          	lh	a5,6(a1)
    80003d9e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003da2:	459c                	lw	a5,8(a1)
    80003da4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003da6:	03400613          	li	a2,52
    80003daa:	05b1                	addi	a1,a1,12
    80003dac:	05048513          	addi	a0,s1,80
    80003db0:	ffffd097          	auipc	ra,0xffffd
    80003db4:	09e080e7          	jalr	158(ra) # 80000e4e <memmove>
    brelse(bp);
    80003db8:	854a                	mv	a0,s2
    80003dba:	00000097          	auipc	ra,0x0
    80003dbe:	876080e7          	jalr	-1930(ra) # 80003630 <brelse>
    ip->valid = 1;
    80003dc2:	4785                	li	a5,1
    80003dc4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003dc6:	04449783          	lh	a5,68(s1)
    80003dca:	fbb5                	bnez	a5,80003d3e <ilock+0x24>
      panic("ilock: no type");
    80003dcc:	00005517          	auipc	a0,0x5
    80003dd0:	85450513          	addi	a0,a0,-1964 # 80008620 <syscalls+0x1a0>
    80003dd4:	ffffc097          	auipc	ra,0xffffc
    80003dd8:	76a080e7          	jalr	1898(ra) # 8000053e <panic>

0000000080003ddc <iunlock>:
{
    80003ddc:	1101                	addi	sp,sp,-32
    80003dde:	ec06                	sd	ra,24(sp)
    80003de0:	e822                	sd	s0,16(sp)
    80003de2:	e426                	sd	s1,8(sp)
    80003de4:	e04a                	sd	s2,0(sp)
    80003de6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003de8:	c905                	beqz	a0,80003e18 <iunlock+0x3c>
    80003dea:	84aa                	mv	s1,a0
    80003dec:	01050913          	addi	s2,a0,16
    80003df0:	854a                	mv	a0,s2
    80003df2:	00001097          	auipc	ra,0x1
    80003df6:	c7c080e7          	jalr	-900(ra) # 80004a6e <holdingsleep>
    80003dfa:	cd19                	beqz	a0,80003e18 <iunlock+0x3c>
    80003dfc:	449c                	lw	a5,8(s1)
    80003dfe:	00f05d63          	blez	a5,80003e18 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e02:	854a                	mv	a0,s2
    80003e04:	00001097          	auipc	ra,0x1
    80003e08:	c26080e7          	jalr	-986(ra) # 80004a2a <releasesleep>
}
    80003e0c:	60e2                	ld	ra,24(sp)
    80003e0e:	6442                	ld	s0,16(sp)
    80003e10:	64a2                	ld	s1,8(sp)
    80003e12:	6902                	ld	s2,0(sp)
    80003e14:	6105                	addi	sp,sp,32
    80003e16:	8082                	ret
    panic("iunlock");
    80003e18:	00005517          	auipc	a0,0x5
    80003e1c:	81850513          	addi	a0,a0,-2024 # 80008630 <syscalls+0x1b0>
    80003e20:	ffffc097          	auipc	ra,0xffffc
    80003e24:	71e080e7          	jalr	1822(ra) # 8000053e <panic>

0000000080003e28 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e28:	7179                	addi	sp,sp,-48
    80003e2a:	f406                	sd	ra,40(sp)
    80003e2c:	f022                	sd	s0,32(sp)
    80003e2e:	ec26                	sd	s1,24(sp)
    80003e30:	e84a                	sd	s2,16(sp)
    80003e32:	e44e                	sd	s3,8(sp)
    80003e34:	e052                	sd	s4,0(sp)
    80003e36:	1800                	addi	s0,sp,48
    80003e38:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e3a:	05050493          	addi	s1,a0,80
    80003e3e:	08050913          	addi	s2,a0,128
    80003e42:	a021                	j	80003e4a <itrunc+0x22>
    80003e44:	0491                	addi	s1,s1,4
    80003e46:	01248d63          	beq	s1,s2,80003e60 <itrunc+0x38>
    if(ip->addrs[i]){
    80003e4a:	408c                	lw	a1,0(s1)
    80003e4c:	dde5                	beqz	a1,80003e44 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e4e:	0009a503          	lw	a0,0(s3)
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	8f4080e7          	jalr	-1804(ra) # 80003746 <bfree>
      ip->addrs[i] = 0;
    80003e5a:	0004a023          	sw	zero,0(s1)
    80003e5e:	b7dd                	j	80003e44 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e60:	0809a583          	lw	a1,128(s3)
    80003e64:	e185                	bnez	a1,80003e84 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e66:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e6a:	854e                	mv	a0,s3
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	de4080e7          	jalr	-540(ra) # 80003c50 <iupdate>
}
    80003e74:	70a2                	ld	ra,40(sp)
    80003e76:	7402                	ld	s0,32(sp)
    80003e78:	64e2                	ld	s1,24(sp)
    80003e7a:	6942                	ld	s2,16(sp)
    80003e7c:	69a2                	ld	s3,8(sp)
    80003e7e:	6a02                	ld	s4,0(sp)
    80003e80:	6145                	addi	sp,sp,48
    80003e82:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e84:	0009a503          	lw	a0,0(s3)
    80003e88:	fffff097          	auipc	ra,0xfffff
    80003e8c:	678080e7          	jalr	1656(ra) # 80003500 <bread>
    80003e90:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e92:	05850493          	addi	s1,a0,88
    80003e96:	45850913          	addi	s2,a0,1112
    80003e9a:	a021                	j	80003ea2 <itrunc+0x7a>
    80003e9c:	0491                	addi	s1,s1,4
    80003e9e:	01248b63          	beq	s1,s2,80003eb4 <itrunc+0x8c>
      if(a[j])
    80003ea2:	408c                	lw	a1,0(s1)
    80003ea4:	dde5                	beqz	a1,80003e9c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003ea6:	0009a503          	lw	a0,0(s3)
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	89c080e7          	jalr	-1892(ra) # 80003746 <bfree>
    80003eb2:	b7ed                	j	80003e9c <itrunc+0x74>
    brelse(bp);
    80003eb4:	8552                	mv	a0,s4
    80003eb6:	fffff097          	auipc	ra,0xfffff
    80003eba:	77a080e7          	jalr	1914(ra) # 80003630 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ebe:	0809a583          	lw	a1,128(s3)
    80003ec2:	0009a503          	lw	a0,0(s3)
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	880080e7          	jalr	-1920(ra) # 80003746 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ece:	0809a023          	sw	zero,128(s3)
    80003ed2:	bf51                	j	80003e66 <itrunc+0x3e>

0000000080003ed4 <iput>:
{
    80003ed4:	1101                	addi	sp,sp,-32
    80003ed6:	ec06                	sd	ra,24(sp)
    80003ed8:	e822                	sd	s0,16(sp)
    80003eda:	e426                	sd	s1,8(sp)
    80003edc:	e04a                	sd	s2,0(sp)
    80003ede:	1000                	addi	s0,sp,32
    80003ee0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ee2:	0023c517          	auipc	a0,0x23c
    80003ee6:	bde50513          	addi	a0,a0,-1058 # 8023fac0 <itable>
    80003eea:	ffffd097          	auipc	ra,0xffffd
    80003eee:	e0c080e7          	jalr	-500(ra) # 80000cf6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ef2:	4498                	lw	a4,8(s1)
    80003ef4:	4785                	li	a5,1
    80003ef6:	02f70363          	beq	a4,a5,80003f1c <iput+0x48>
  ip->ref--;
    80003efa:	449c                	lw	a5,8(s1)
    80003efc:	37fd                	addiw	a5,a5,-1
    80003efe:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f00:	0023c517          	auipc	a0,0x23c
    80003f04:	bc050513          	addi	a0,a0,-1088 # 8023fac0 <itable>
    80003f08:	ffffd097          	auipc	ra,0xffffd
    80003f0c:	ea2080e7          	jalr	-350(ra) # 80000daa <release>
}
    80003f10:	60e2                	ld	ra,24(sp)
    80003f12:	6442                	ld	s0,16(sp)
    80003f14:	64a2                	ld	s1,8(sp)
    80003f16:	6902                	ld	s2,0(sp)
    80003f18:	6105                	addi	sp,sp,32
    80003f1a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f1c:	40bc                	lw	a5,64(s1)
    80003f1e:	dff1                	beqz	a5,80003efa <iput+0x26>
    80003f20:	04a49783          	lh	a5,74(s1)
    80003f24:	fbf9                	bnez	a5,80003efa <iput+0x26>
    acquiresleep(&ip->lock);
    80003f26:	01048913          	addi	s2,s1,16
    80003f2a:	854a                	mv	a0,s2
    80003f2c:	00001097          	auipc	ra,0x1
    80003f30:	aa8080e7          	jalr	-1368(ra) # 800049d4 <acquiresleep>
    release(&itable.lock);
    80003f34:	0023c517          	auipc	a0,0x23c
    80003f38:	b8c50513          	addi	a0,a0,-1140 # 8023fac0 <itable>
    80003f3c:	ffffd097          	auipc	ra,0xffffd
    80003f40:	e6e080e7          	jalr	-402(ra) # 80000daa <release>
    itrunc(ip);
    80003f44:	8526                	mv	a0,s1
    80003f46:	00000097          	auipc	ra,0x0
    80003f4a:	ee2080e7          	jalr	-286(ra) # 80003e28 <itrunc>
    ip->type = 0;
    80003f4e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f52:	8526                	mv	a0,s1
    80003f54:	00000097          	auipc	ra,0x0
    80003f58:	cfc080e7          	jalr	-772(ra) # 80003c50 <iupdate>
    ip->valid = 0;
    80003f5c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f60:	854a                	mv	a0,s2
    80003f62:	00001097          	auipc	ra,0x1
    80003f66:	ac8080e7          	jalr	-1336(ra) # 80004a2a <releasesleep>
    acquire(&itable.lock);
    80003f6a:	0023c517          	auipc	a0,0x23c
    80003f6e:	b5650513          	addi	a0,a0,-1194 # 8023fac0 <itable>
    80003f72:	ffffd097          	auipc	ra,0xffffd
    80003f76:	d84080e7          	jalr	-636(ra) # 80000cf6 <acquire>
    80003f7a:	b741                	j	80003efa <iput+0x26>

0000000080003f7c <iunlockput>:
{
    80003f7c:	1101                	addi	sp,sp,-32
    80003f7e:	ec06                	sd	ra,24(sp)
    80003f80:	e822                	sd	s0,16(sp)
    80003f82:	e426                	sd	s1,8(sp)
    80003f84:	1000                	addi	s0,sp,32
    80003f86:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f88:	00000097          	auipc	ra,0x0
    80003f8c:	e54080e7          	jalr	-428(ra) # 80003ddc <iunlock>
  iput(ip);
    80003f90:	8526                	mv	a0,s1
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	f42080e7          	jalr	-190(ra) # 80003ed4 <iput>
}
    80003f9a:	60e2                	ld	ra,24(sp)
    80003f9c:	6442                	ld	s0,16(sp)
    80003f9e:	64a2                	ld	s1,8(sp)
    80003fa0:	6105                	addi	sp,sp,32
    80003fa2:	8082                	ret

0000000080003fa4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003fa4:	1141                	addi	sp,sp,-16
    80003fa6:	e422                	sd	s0,8(sp)
    80003fa8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003faa:	411c                	lw	a5,0(a0)
    80003fac:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003fae:	415c                	lw	a5,4(a0)
    80003fb0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003fb2:	04451783          	lh	a5,68(a0)
    80003fb6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003fba:	04a51783          	lh	a5,74(a0)
    80003fbe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003fc2:	04c56783          	lwu	a5,76(a0)
    80003fc6:	e99c                	sd	a5,16(a1)
}
    80003fc8:	6422                	ld	s0,8(sp)
    80003fca:	0141                	addi	sp,sp,16
    80003fcc:	8082                	ret

0000000080003fce <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fce:	457c                	lw	a5,76(a0)
    80003fd0:	0ed7e963          	bltu	a5,a3,800040c2 <readi+0xf4>
{
    80003fd4:	7159                	addi	sp,sp,-112
    80003fd6:	f486                	sd	ra,104(sp)
    80003fd8:	f0a2                	sd	s0,96(sp)
    80003fda:	eca6                	sd	s1,88(sp)
    80003fdc:	e8ca                	sd	s2,80(sp)
    80003fde:	e4ce                	sd	s3,72(sp)
    80003fe0:	e0d2                	sd	s4,64(sp)
    80003fe2:	fc56                	sd	s5,56(sp)
    80003fe4:	f85a                	sd	s6,48(sp)
    80003fe6:	f45e                	sd	s7,40(sp)
    80003fe8:	f062                	sd	s8,32(sp)
    80003fea:	ec66                	sd	s9,24(sp)
    80003fec:	e86a                	sd	s10,16(sp)
    80003fee:	e46e                	sd	s11,8(sp)
    80003ff0:	1880                	addi	s0,sp,112
    80003ff2:	8b2a                	mv	s6,a0
    80003ff4:	8bae                	mv	s7,a1
    80003ff6:	8a32                	mv	s4,a2
    80003ff8:	84b6                	mv	s1,a3
    80003ffa:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ffc:	9f35                	addw	a4,a4,a3
    return 0;
    80003ffe:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004000:	0ad76063          	bltu	a4,a3,800040a0 <readi+0xd2>
  if(off + n > ip->size)
    80004004:	00e7f463          	bgeu	a5,a4,8000400c <readi+0x3e>
    n = ip->size - off;
    80004008:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000400c:	0a0a8963          	beqz	s5,800040be <readi+0xf0>
    80004010:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004012:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004016:	5c7d                	li	s8,-1
    80004018:	a82d                	j	80004052 <readi+0x84>
    8000401a:	020d1d93          	slli	s11,s10,0x20
    8000401e:	020ddd93          	srli	s11,s11,0x20
    80004022:	05890793          	addi	a5,s2,88
    80004026:	86ee                	mv	a3,s11
    80004028:	963e                	add	a2,a2,a5
    8000402a:	85d2                	mv	a1,s4
    8000402c:	855e                	mv	a0,s7
    8000402e:	ffffe097          	auipc	ra,0xffffe
    80004032:	70c080e7          	jalr	1804(ra) # 8000273a <either_copyout>
    80004036:	05850d63          	beq	a0,s8,80004090 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000403a:	854a                	mv	a0,s2
    8000403c:	fffff097          	auipc	ra,0xfffff
    80004040:	5f4080e7          	jalr	1524(ra) # 80003630 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004044:	013d09bb          	addw	s3,s10,s3
    80004048:	009d04bb          	addw	s1,s10,s1
    8000404c:	9a6e                	add	s4,s4,s11
    8000404e:	0559f763          	bgeu	s3,s5,8000409c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80004052:	00a4d59b          	srliw	a1,s1,0xa
    80004056:	855a                	mv	a0,s6
    80004058:	00000097          	auipc	ra,0x0
    8000405c:	8a2080e7          	jalr	-1886(ra) # 800038fa <bmap>
    80004060:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004064:	cd85                	beqz	a1,8000409c <readi+0xce>
    bp = bread(ip->dev, addr);
    80004066:	000b2503          	lw	a0,0(s6)
    8000406a:	fffff097          	auipc	ra,0xfffff
    8000406e:	496080e7          	jalr	1174(ra) # 80003500 <bread>
    80004072:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004074:	3ff4f613          	andi	a2,s1,1023
    80004078:	40cc87bb          	subw	a5,s9,a2
    8000407c:	413a873b          	subw	a4,s5,s3
    80004080:	8d3e                	mv	s10,a5
    80004082:	2781                	sext.w	a5,a5
    80004084:	0007069b          	sext.w	a3,a4
    80004088:	f8f6f9e3          	bgeu	a3,a5,8000401a <readi+0x4c>
    8000408c:	8d3a                	mv	s10,a4
    8000408e:	b771                	j	8000401a <readi+0x4c>
      brelse(bp);
    80004090:	854a                	mv	a0,s2
    80004092:	fffff097          	auipc	ra,0xfffff
    80004096:	59e080e7          	jalr	1438(ra) # 80003630 <brelse>
      tot = -1;
    8000409a:	59fd                	li	s3,-1
  }
  return tot;
    8000409c:	0009851b          	sext.w	a0,s3
}
    800040a0:	70a6                	ld	ra,104(sp)
    800040a2:	7406                	ld	s0,96(sp)
    800040a4:	64e6                	ld	s1,88(sp)
    800040a6:	6946                	ld	s2,80(sp)
    800040a8:	69a6                	ld	s3,72(sp)
    800040aa:	6a06                	ld	s4,64(sp)
    800040ac:	7ae2                	ld	s5,56(sp)
    800040ae:	7b42                	ld	s6,48(sp)
    800040b0:	7ba2                	ld	s7,40(sp)
    800040b2:	7c02                	ld	s8,32(sp)
    800040b4:	6ce2                	ld	s9,24(sp)
    800040b6:	6d42                	ld	s10,16(sp)
    800040b8:	6da2                	ld	s11,8(sp)
    800040ba:	6165                	addi	sp,sp,112
    800040bc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040be:	89d6                	mv	s3,s5
    800040c0:	bff1                	j	8000409c <readi+0xce>
    return 0;
    800040c2:	4501                	li	a0,0
}
    800040c4:	8082                	ret

00000000800040c6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040c6:	457c                	lw	a5,76(a0)
    800040c8:	10d7e863          	bltu	a5,a3,800041d8 <writei+0x112>
{
    800040cc:	7159                	addi	sp,sp,-112
    800040ce:	f486                	sd	ra,104(sp)
    800040d0:	f0a2                	sd	s0,96(sp)
    800040d2:	eca6                	sd	s1,88(sp)
    800040d4:	e8ca                	sd	s2,80(sp)
    800040d6:	e4ce                	sd	s3,72(sp)
    800040d8:	e0d2                	sd	s4,64(sp)
    800040da:	fc56                	sd	s5,56(sp)
    800040dc:	f85a                	sd	s6,48(sp)
    800040de:	f45e                	sd	s7,40(sp)
    800040e0:	f062                	sd	s8,32(sp)
    800040e2:	ec66                	sd	s9,24(sp)
    800040e4:	e86a                	sd	s10,16(sp)
    800040e6:	e46e                	sd	s11,8(sp)
    800040e8:	1880                	addi	s0,sp,112
    800040ea:	8aaa                	mv	s5,a0
    800040ec:	8bae                	mv	s7,a1
    800040ee:	8a32                	mv	s4,a2
    800040f0:	8936                	mv	s2,a3
    800040f2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800040f4:	00e687bb          	addw	a5,a3,a4
    800040f8:	0ed7e263          	bltu	a5,a3,800041dc <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040fc:	00043737          	lui	a4,0x43
    80004100:	0ef76063          	bltu	a4,a5,800041e0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004104:	0c0b0863          	beqz	s6,800041d4 <writei+0x10e>
    80004108:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000410a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000410e:	5c7d                	li	s8,-1
    80004110:	a091                	j	80004154 <writei+0x8e>
    80004112:	020d1d93          	slli	s11,s10,0x20
    80004116:	020ddd93          	srli	s11,s11,0x20
    8000411a:	05848793          	addi	a5,s1,88
    8000411e:	86ee                	mv	a3,s11
    80004120:	8652                	mv	a2,s4
    80004122:	85de                	mv	a1,s7
    80004124:	953e                	add	a0,a0,a5
    80004126:	ffffe097          	auipc	ra,0xffffe
    8000412a:	66a080e7          	jalr	1642(ra) # 80002790 <either_copyin>
    8000412e:	07850263          	beq	a0,s8,80004192 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004132:	8526                	mv	a0,s1
    80004134:	00000097          	auipc	ra,0x0
    80004138:	780080e7          	jalr	1920(ra) # 800048b4 <log_write>
    brelse(bp);
    8000413c:	8526                	mv	a0,s1
    8000413e:	fffff097          	auipc	ra,0xfffff
    80004142:	4f2080e7          	jalr	1266(ra) # 80003630 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004146:	013d09bb          	addw	s3,s10,s3
    8000414a:	012d093b          	addw	s2,s10,s2
    8000414e:	9a6e                	add	s4,s4,s11
    80004150:	0569f663          	bgeu	s3,s6,8000419c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004154:	00a9559b          	srliw	a1,s2,0xa
    80004158:	8556                	mv	a0,s5
    8000415a:	fffff097          	auipc	ra,0xfffff
    8000415e:	7a0080e7          	jalr	1952(ra) # 800038fa <bmap>
    80004162:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004166:	c99d                	beqz	a1,8000419c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004168:	000aa503          	lw	a0,0(s5)
    8000416c:	fffff097          	auipc	ra,0xfffff
    80004170:	394080e7          	jalr	916(ra) # 80003500 <bread>
    80004174:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004176:	3ff97513          	andi	a0,s2,1023
    8000417a:	40ac87bb          	subw	a5,s9,a0
    8000417e:	413b073b          	subw	a4,s6,s3
    80004182:	8d3e                	mv	s10,a5
    80004184:	2781                	sext.w	a5,a5
    80004186:	0007069b          	sext.w	a3,a4
    8000418a:	f8f6f4e3          	bgeu	a3,a5,80004112 <writei+0x4c>
    8000418e:	8d3a                	mv	s10,a4
    80004190:	b749                	j	80004112 <writei+0x4c>
      brelse(bp);
    80004192:	8526                	mv	a0,s1
    80004194:	fffff097          	auipc	ra,0xfffff
    80004198:	49c080e7          	jalr	1180(ra) # 80003630 <brelse>
  }

  if(off > ip->size)
    8000419c:	04caa783          	lw	a5,76(s5)
    800041a0:	0127f463          	bgeu	a5,s2,800041a8 <writei+0xe2>
    ip->size = off;
    800041a4:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800041a8:	8556                	mv	a0,s5
    800041aa:	00000097          	auipc	ra,0x0
    800041ae:	aa6080e7          	jalr	-1370(ra) # 80003c50 <iupdate>

  return tot;
    800041b2:	0009851b          	sext.w	a0,s3
}
    800041b6:	70a6                	ld	ra,104(sp)
    800041b8:	7406                	ld	s0,96(sp)
    800041ba:	64e6                	ld	s1,88(sp)
    800041bc:	6946                	ld	s2,80(sp)
    800041be:	69a6                	ld	s3,72(sp)
    800041c0:	6a06                	ld	s4,64(sp)
    800041c2:	7ae2                	ld	s5,56(sp)
    800041c4:	7b42                	ld	s6,48(sp)
    800041c6:	7ba2                	ld	s7,40(sp)
    800041c8:	7c02                	ld	s8,32(sp)
    800041ca:	6ce2                	ld	s9,24(sp)
    800041cc:	6d42                	ld	s10,16(sp)
    800041ce:	6da2                	ld	s11,8(sp)
    800041d0:	6165                	addi	sp,sp,112
    800041d2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041d4:	89da                	mv	s3,s6
    800041d6:	bfc9                	j	800041a8 <writei+0xe2>
    return -1;
    800041d8:	557d                	li	a0,-1
}
    800041da:	8082                	ret
    return -1;
    800041dc:	557d                	li	a0,-1
    800041de:	bfe1                	j	800041b6 <writei+0xf0>
    return -1;
    800041e0:	557d                	li	a0,-1
    800041e2:	bfd1                	j	800041b6 <writei+0xf0>

00000000800041e4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041e4:	1141                	addi	sp,sp,-16
    800041e6:	e406                	sd	ra,8(sp)
    800041e8:	e022                	sd	s0,0(sp)
    800041ea:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041ec:	4639                	li	a2,14
    800041ee:	ffffd097          	auipc	ra,0xffffd
    800041f2:	cd4080e7          	jalr	-812(ra) # 80000ec2 <strncmp>
}
    800041f6:	60a2                	ld	ra,8(sp)
    800041f8:	6402                	ld	s0,0(sp)
    800041fa:	0141                	addi	sp,sp,16
    800041fc:	8082                	ret

00000000800041fe <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041fe:	7139                	addi	sp,sp,-64
    80004200:	fc06                	sd	ra,56(sp)
    80004202:	f822                	sd	s0,48(sp)
    80004204:	f426                	sd	s1,40(sp)
    80004206:	f04a                	sd	s2,32(sp)
    80004208:	ec4e                	sd	s3,24(sp)
    8000420a:	e852                	sd	s4,16(sp)
    8000420c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000420e:	04451703          	lh	a4,68(a0)
    80004212:	4785                	li	a5,1
    80004214:	00f71a63          	bne	a4,a5,80004228 <dirlookup+0x2a>
    80004218:	892a                	mv	s2,a0
    8000421a:	89ae                	mv	s3,a1
    8000421c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000421e:	457c                	lw	a5,76(a0)
    80004220:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004222:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004224:	e79d                	bnez	a5,80004252 <dirlookup+0x54>
    80004226:	a8a5                	j	8000429e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004228:	00004517          	auipc	a0,0x4
    8000422c:	41050513          	addi	a0,a0,1040 # 80008638 <syscalls+0x1b8>
    80004230:	ffffc097          	auipc	ra,0xffffc
    80004234:	30e080e7          	jalr	782(ra) # 8000053e <panic>
      panic("dirlookup read");
    80004238:	00004517          	auipc	a0,0x4
    8000423c:	41850513          	addi	a0,a0,1048 # 80008650 <syscalls+0x1d0>
    80004240:	ffffc097          	auipc	ra,0xffffc
    80004244:	2fe080e7          	jalr	766(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004248:	24c1                	addiw	s1,s1,16
    8000424a:	04c92783          	lw	a5,76(s2)
    8000424e:	04f4f763          	bgeu	s1,a5,8000429c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004252:	4741                	li	a4,16
    80004254:	86a6                	mv	a3,s1
    80004256:	fc040613          	addi	a2,s0,-64
    8000425a:	4581                	li	a1,0
    8000425c:	854a                	mv	a0,s2
    8000425e:	00000097          	auipc	ra,0x0
    80004262:	d70080e7          	jalr	-656(ra) # 80003fce <readi>
    80004266:	47c1                	li	a5,16
    80004268:	fcf518e3          	bne	a0,a5,80004238 <dirlookup+0x3a>
    if(de.inum == 0)
    8000426c:	fc045783          	lhu	a5,-64(s0)
    80004270:	dfe1                	beqz	a5,80004248 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004272:	fc240593          	addi	a1,s0,-62
    80004276:	854e                	mv	a0,s3
    80004278:	00000097          	auipc	ra,0x0
    8000427c:	f6c080e7          	jalr	-148(ra) # 800041e4 <namecmp>
    80004280:	f561                	bnez	a0,80004248 <dirlookup+0x4a>
      if(poff)
    80004282:	000a0463          	beqz	s4,8000428a <dirlookup+0x8c>
        *poff = off;
    80004286:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000428a:	fc045583          	lhu	a1,-64(s0)
    8000428e:	00092503          	lw	a0,0(s2)
    80004292:	fffff097          	auipc	ra,0xfffff
    80004296:	750080e7          	jalr	1872(ra) # 800039e2 <iget>
    8000429a:	a011                	j	8000429e <dirlookup+0xa0>
  return 0;
    8000429c:	4501                	li	a0,0
}
    8000429e:	70e2                	ld	ra,56(sp)
    800042a0:	7442                	ld	s0,48(sp)
    800042a2:	74a2                	ld	s1,40(sp)
    800042a4:	7902                	ld	s2,32(sp)
    800042a6:	69e2                	ld	s3,24(sp)
    800042a8:	6a42                	ld	s4,16(sp)
    800042aa:	6121                	addi	sp,sp,64
    800042ac:	8082                	ret

00000000800042ae <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042ae:	711d                	addi	sp,sp,-96
    800042b0:	ec86                	sd	ra,88(sp)
    800042b2:	e8a2                	sd	s0,80(sp)
    800042b4:	e4a6                	sd	s1,72(sp)
    800042b6:	e0ca                	sd	s2,64(sp)
    800042b8:	fc4e                	sd	s3,56(sp)
    800042ba:	f852                	sd	s4,48(sp)
    800042bc:	f456                	sd	s5,40(sp)
    800042be:	f05a                	sd	s6,32(sp)
    800042c0:	ec5e                	sd	s7,24(sp)
    800042c2:	e862                	sd	s8,16(sp)
    800042c4:	e466                	sd	s9,8(sp)
    800042c6:	1080                	addi	s0,sp,96
    800042c8:	84aa                	mv	s1,a0
    800042ca:	8aae                	mv	s5,a1
    800042cc:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042ce:	00054703          	lbu	a4,0(a0)
    800042d2:	02f00793          	li	a5,47
    800042d6:	02f70363          	beq	a4,a5,800042fc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042da:	ffffe097          	auipc	ra,0xffffe
    800042de:	834080e7          	jalr	-1996(ra) # 80001b0e <myproc>
    800042e2:	15053503          	ld	a0,336(a0)
    800042e6:	00000097          	auipc	ra,0x0
    800042ea:	9f6080e7          	jalr	-1546(ra) # 80003cdc <idup>
    800042ee:	89aa                	mv	s3,a0
  while(*path == '/')
    800042f0:	02f00913          	li	s2,47
  len = path - s;
    800042f4:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800042f6:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042f8:	4b85                	li	s7,1
    800042fa:	a865                	j	800043b2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800042fc:	4585                	li	a1,1
    800042fe:	4505                	li	a0,1
    80004300:	fffff097          	auipc	ra,0xfffff
    80004304:	6e2080e7          	jalr	1762(ra) # 800039e2 <iget>
    80004308:	89aa                	mv	s3,a0
    8000430a:	b7dd                	j	800042f0 <namex+0x42>
      iunlockput(ip);
    8000430c:	854e                	mv	a0,s3
    8000430e:	00000097          	auipc	ra,0x0
    80004312:	c6e080e7          	jalr	-914(ra) # 80003f7c <iunlockput>
      return 0;
    80004316:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004318:	854e                	mv	a0,s3
    8000431a:	60e6                	ld	ra,88(sp)
    8000431c:	6446                	ld	s0,80(sp)
    8000431e:	64a6                	ld	s1,72(sp)
    80004320:	6906                	ld	s2,64(sp)
    80004322:	79e2                	ld	s3,56(sp)
    80004324:	7a42                	ld	s4,48(sp)
    80004326:	7aa2                	ld	s5,40(sp)
    80004328:	7b02                	ld	s6,32(sp)
    8000432a:	6be2                	ld	s7,24(sp)
    8000432c:	6c42                	ld	s8,16(sp)
    8000432e:	6ca2                	ld	s9,8(sp)
    80004330:	6125                	addi	sp,sp,96
    80004332:	8082                	ret
      iunlock(ip);
    80004334:	854e                	mv	a0,s3
    80004336:	00000097          	auipc	ra,0x0
    8000433a:	aa6080e7          	jalr	-1370(ra) # 80003ddc <iunlock>
      return ip;
    8000433e:	bfe9                	j	80004318 <namex+0x6a>
      iunlockput(ip);
    80004340:	854e                	mv	a0,s3
    80004342:	00000097          	auipc	ra,0x0
    80004346:	c3a080e7          	jalr	-966(ra) # 80003f7c <iunlockput>
      return 0;
    8000434a:	89e6                	mv	s3,s9
    8000434c:	b7f1                	j	80004318 <namex+0x6a>
  len = path - s;
    8000434e:	40b48633          	sub	a2,s1,a1
    80004352:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004356:	099c5463          	bge	s8,s9,800043de <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000435a:	4639                	li	a2,14
    8000435c:	8552                	mv	a0,s4
    8000435e:	ffffd097          	auipc	ra,0xffffd
    80004362:	af0080e7          	jalr	-1296(ra) # 80000e4e <memmove>
  while(*path == '/')
    80004366:	0004c783          	lbu	a5,0(s1)
    8000436a:	01279763          	bne	a5,s2,80004378 <namex+0xca>
    path++;
    8000436e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004370:	0004c783          	lbu	a5,0(s1)
    80004374:	ff278de3          	beq	a5,s2,8000436e <namex+0xc0>
    ilock(ip);
    80004378:	854e                	mv	a0,s3
    8000437a:	00000097          	auipc	ra,0x0
    8000437e:	9a0080e7          	jalr	-1632(ra) # 80003d1a <ilock>
    if(ip->type != T_DIR){
    80004382:	04499783          	lh	a5,68(s3)
    80004386:	f97793e3          	bne	a5,s7,8000430c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000438a:	000a8563          	beqz	s5,80004394 <namex+0xe6>
    8000438e:	0004c783          	lbu	a5,0(s1)
    80004392:	d3cd                	beqz	a5,80004334 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004394:	865a                	mv	a2,s6
    80004396:	85d2                	mv	a1,s4
    80004398:	854e                	mv	a0,s3
    8000439a:	00000097          	auipc	ra,0x0
    8000439e:	e64080e7          	jalr	-412(ra) # 800041fe <dirlookup>
    800043a2:	8caa                	mv	s9,a0
    800043a4:	dd51                	beqz	a0,80004340 <namex+0x92>
    iunlockput(ip);
    800043a6:	854e                	mv	a0,s3
    800043a8:	00000097          	auipc	ra,0x0
    800043ac:	bd4080e7          	jalr	-1068(ra) # 80003f7c <iunlockput>
    ip = next;
    800043b0:	89e6                	mv	s3,s9
  while(*path == '/')
    800043b2:	0004c783          	lbu	a5,0(s1)
    800043b6:	05279763          	bne	a5,s2,80004404 <namex+0x156>
    path++;
    800043ba:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043bc:	0004c783          	lbu	a5,0(s1)
    800043c0:	ff278de3          	beq	a5,s2,800043ba <namex+0x10c>
  if(*path == 0)
    800043c4:	c79d                	beqz	a5,800043f2 <namex+0x144>
    path++;
    800043c6:	85a6                	mv	a1,s1
  len = path - s;
    800043c8:	8cda                	mv	s9,s6
    800043ca:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800043cc:	01278963          	beq	a5,s2,800043de <namex+0x130>
    800043d0:	dfbd                	beqz	a5,8000434e <namex+0xa0>
    path++;
    800043d2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800043d4:	0004c783          	lbu	a5,0(s1)
    800043d8:	ff279ce3          	bne	a5,s2,800043d0 <namex+0x122>
    800043dc:	bf8d                	j	8000434e <namex+0xa0>
    memmove(name, s, len);
    800043de:	2601                	sext.w	a2,a2
    800043e0:	8552                	mv	a0,s4
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	a6c080e7          	jalr	-1428(ra) # 80000e4e <memmove>
    name[len] = 0;
    800043ea:	9cd2                	add	s9,s9,s4
    800043ec:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800043f0:	bf9d                	j	80004366 <namex+0xb8>
  if(nameiparent){
    800043f2:	f20a83e3          	beqz	s5,80004318 <namex+0x6a>
    iput(ip);
    800043f6:	854e                	mv	a0,s3
    800043f8:	00000097          	auipc	ra,0x0
    800043fc:	adc080e7          	jalr	-1316(ra) # 80003ed4 <iput>
    return 0;
    80004400:	4981                	li	s3,0
    80004402:	bf19                	j	80004318 <namex+0x6a>
  if(*path == 0)
    80004404:	d7fd                	beqz	a5,800043f2 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004406:	0004c783          	lbu	a5,0(s1)
    8000440a:	85a6                	mv	a1,s1
    8000440c:	b7d1                	j	800043d0 <namex+0x122>

000000008000440e <dirlink>:
{
    8000440e:	7139                	addi	sp,sp,-64
    80004410:	fc06                	sd	ra,56(sp)
    80004412:	f822                	sd	s0,48(sp)
    80004414:	f426                	sd	s1,40(sp)
    80004416:	f04a                	sd	s2,32(sp)
    80004418:	ec4e                	sd	s3,24(sp)
    8000441a:	e852                	sd	s4,16(sp)
    8000441c:	0080                	addi	s0,sp,64
    8000441e:	892a                	mv	s2,a0
    80004420:	8a2e                	mv	s4,a1
    80004422:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004424:	4601                	li	a2,0
    80004426:	00000097          	auipc	ra,0x0
    8000442a:	dd8080e7          	jalr	-552(ra) # 800041fe <dirlookup>
    8000442e:	e93d                	bnez	a0,800044a4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004430:	04c92483          	lw	s1,76(s2)
    80004434:	c49d                	beqz	s1,80004462 <dirlink+0x54>
    80004436:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004438:	4741                	li	a4,16
    8000443a:	86a6                	mv	a3,s1
    8000443c:	fc040613          	addi	a2,s0,-64
    80004440:	4581                	li	a1,0
    80004442:	854a                	mv	a0,s2
    80004444:	00000097          	auipc	ra,0x0
    80004448:	b8a080e7          	jalr	-1142(ra) # 80003fce <readi>
    8000444c:	47c1                	li	a5,16
    8000444e:	06f51163          	bne	a0,a5,800044b0 <dirlink+0xa2>
    if(de.inum == 0)
    80004452:	fc045783          	lhu	a5,-64(s0)
    80004456:	c791                	beqz	a5,80004462 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004458:	24c1                	addiw	s1,s1,16
    8000445a:	04c92783          	lw	a5,76(s2)
    8000445e:	fcf4ede3          	bltu	s1,a5,80004438 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004462:	4639                	li	a2,14
    80004464:	85d2                	mv	a1,s4
    80004466:	fc240513          	addi	a0,s0,-62
    8000446a:	ffffd097          	auipc	ra,0xffffd
    8000446e:	a94080e7          	jalr	-1388(ra) # 80000efe <strncpy>
  de.inum = inum;
    80004472:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004476:	4741                	li	a4,16
    80004478:	86a6                	mv	a3,s1
    8000447a:	fc040613          	addi	a2,s0,-64
    8000447e:	4581                	li	a1,0
    80004480:	854a                	mv	a0,s2
    80004482:	00000097          	auipc	ra,0x0
    80004486:	c44080e7          	jalr	-956(ra) # 800040c6 <writei>
    8000448a:	1541                	addi	a0,a0,-16
    8000448c:	00a03533          	snez	a0,a0
    80004490:	40a00533          	neg	a0,a0
}
    80004494:	70e2                	ld	ra,56(sp)
    80004496:	7442                	ld	s0,48(sp)
    80004498:	74a2                	ld	s1,40(sp)
    8000449a:	7902                	ld	s2,32(sp)
    8000449c:	69e2                	ld	s3,24(sp)
    8000449e:	6a42                	ld	s4,16(sp)
    800044a0:	6121                	addi	sp,sp,64
    800044a2:	8082                	ret
    iput(ip);
    800044a4:	00000097          	auipc	ra,0x0
    800044a8:	a30080e7          	jalr	-1488(ra) # 80003ed4 <iput>
    return -1;
    800044ac:	557d                	li	a0,-1
    800044ae:	b7dd                	j	80004494 <dirlink+0x86>
      panic("dirlink read");
    800044b0:	00004517          	auipc	a0,0x4
    800044b4:	1b050513          	addi	a0,a0,432 # 80008660 <syscalls+0x1e0>
    800044b8:	ffffc097          	auipc	ra,0xffffc
    800044bc:	086080e7          	jalr	134(ra) # 8000053e <panic>

00000000800044c0 <namei>:

struct inode*
namei(char *path)
{
    800044c0:	1101                	addi	sp,sp,-32
    800044c2:	ec06                	sd	ra,24(sp)
    800044c4:	e822                	sd	s0,16(sp)
    800044c6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800044c8:	fe040613          	addi	a2,s0,-32
    800044cc:	4581                	li	a1,0
    800044ce:	00000097          	auipc	ra,0x0
    800044d2:	de0080e7          	jalr	-544(ra) # 800042ae <namex>
}
    800044d6:	60e2                	ld	ra,24(sp)
    800044d8:	6442                	ld	s0,16(sp)
    800044da:	6105                	addi	sp,sp,32
    800044dc:	8082                	ret

00000000800044de <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044de:	1141                	addi	sp,sp,-16
    800044e0:	e406                	sd	ra,8(sp)
    800044e2:	e022                	sd	s0,0(sp)
    800044e4:	0800                	addi	s0,sp,16
    800044e6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044e8:	4585                	li	a1,1
    800044ea:	00000097          	auipc	ra,0x0
    800044ee:	dc4080e7          	jalr	-572(ra) # 800042ae <namex>
}
    800044f2:	60a2                	ld	ra,8(sp)
    800044f4:	6402                	ld	s0,0(sp)
    800044f6:	0141                	addi	sp,sp,16
    800044f8:	8082                	ret

00000000800044fa <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044fa:	1101                	addi	sp,sp,-32
    800044fc:	ec06                	sd	ra,24(sp)
    800044fe:	e822                	sd	s0,16(sp)
    80004500:	e426                	sd	s1,8(sp)
    80004502:	e04a                	sd	s2,0(sp)
    80004504:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004506:	0023d917          	auipc	s2,0x23d
    8000450a:	06290913          	addi	s2,s2,98 # 80241568 <log>
    8000450e:	01892583          	lw	a1,24(s2)
    80004512:	02892503          	lw	a0,40(s2)
    80004516:	fffff097          	auipc	ra,0xfffff
    8000451a:	fea080e7          	jalr	-22(ra) # 80003500 <bread>
    8000451e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004520:	02c92683          	lw	a3,44(s2)
    80004524:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004526:	02d05763          	blez	a3,80004554 <write_head+0x5a>
    8000452a:	0023d797          	auipc	a5,0x23d
    8000452e:	06e78793          	addi	a5,a5,110 # 80241598 <log+0x30>
    80004532:	05c50713          	addi	a4,a0,92
    80004536:	36fd                	addiw	a3,a3,-1
    80004538:	1682                	slli	a3,a3,0x20
    8000453a:	9281                	srli	a3,a3,0x20
    8000453c:	068a                	slli	a3,a3,0x2
    8000453e:	0023d617          	auipc	a2,0x23d
    80004542:	05e60613          	addi	a2,a2,94 # 8024159c <log+0x34>
    80004546:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004548:	4390                	lw	a2,0(a5)
    8000454a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000454c:	0791                	addi	a5,a5,4
    8000454e:	0711                	addi	a4,a4,4
    80004550:	fed79ce3          	bne	a5,a3,80004548 <write_head+0x4e>
  }
  bwrite(buf);
    80004554:	8526                	mv	a0,s1
    80004556:	fffff097          	auipc	ra,0xfffff
    8000455a:	09c080e7          	jalr	156(ra) # 800035f2 <bwrite>
  brelse(buf);
    8000455e:	8526                	mv	a0,s1
    80004560:	fffff097          	auipc	ra,0xfffff
    80004564:	0d0080e7          	jalr	208(ra) # 80003630 <brelse>
}
    80004568:	60e2                	ld	ra,24(sp)
    8000456a:	6442                	ld	s0,16(sp)
    8000456c:	64a2                	ld	s1,8(sp)
    8000456e:	6902                	ld	s2,0(sp)
    80004570:	6105                	addi	sp,sp,32
    80004572:	8082                	ret

0000000080004574 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004574:	0023d797          	auipc	a5,0x23d
    80004578:	0207a783          	lw	a5,32(a5) # 80241594 <log+0x2c>
    8000457c:	0af05d63          	blez	a5,80004636 <install_trans+0xc2>
{
    80004580:	7139                	addi	sp,sp,-64
    80004582:	fc06                	sd	ra,56(sp)
    80004584:	f822                	sd	s0,48(sp)
    80004586:	f426                	sd	s1,40(sp)
    80004588:	f04a                	sd	s2,32(sp)
    8000458a:	ec4e                	sd	s3,24(sp)
    8000458c:	e852                	sd	s4,16(sp)
    8000458e:	e456                	sd	s5,8(sp)
    80004590:	e05a                	sd	s6,0(sp)
    80004592:	0080                	addi	s0,sp,64
    80004594:	8b2a                	mv	s6,a0
    80004596:	0023da97          	auipc	s5,0x23d
    8000459a:	002a8a93          	addi	s5,s5,2 # 80241598 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000459e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045a0:	0023d997          	auipc	s3,0x23d
    800045a4:	fc898993          	addi	s3,s3,-56 # 80241568 <log>
    800045a8:	a00d                	j	800045ca <install_trans+0x56>
    brelse(lbuf);
    800045aa:	854a                	mv	a0,s2
    800045ac:	fffff097          	auipc	ra,0xfffff
    800045b0:	084080e7          	jalr	132(ra) # 80003630 <brelse>
    brelse(dbuf);
    800045b4:	8526                	mv	a0,s1
    800045b6:	fffff097          	auipc	ra,0xfffff
    800045ba:	07a080e7          	jalr	122(ra) # 80003630 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045be:	2a05                	addiw	s4,s4,1
    800045c0:	0a91                	addi	s5,s5,4
    800045c2:	02c9a783          	lw	a5,44(s3)
    800045c6:	04fa5e63          	bge	s4,a5,80004622 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045ca:	0189a583          	lw	a1,24(s3)
    800045ce:	014585bb          	addw	a1,a1,s4
    800045d2:	2585                	addiw	a1,a1,1
    800045d4:	0289a503          	lw	a0,40(s3)
    800045d8:	fffff097          	auipc	ra,0xfffff
    800045dc:	f28080e7          	jalr	-216(ra) # 80003500 <bread>
    800045e0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045e2:	000aa583          	lw	a1,0(s5)
    800045e6:	0289a503          	lw	a0,40(s3)
    800045ea:	fffff097          	auipc	ra,0xfffff
    800045ee:	f16080e7          	jalr	-234(ra) # 80003500 <bread>
    800045f2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045f4:	40000613          	li	a2,1024
    800045f8:	05890593          	addi	a1,s2,88
    800045fc:	05850513          	addi	a0,a0,88
    80004600:	ffffd097          	auipc	ra,0xffffd
    80004604:	84e080e7          	jalr	-1970(ra) # 80000e4e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004608:	8526                	mv	a0,s1
    8000460a:	fffff097          	auipc	ra,0xfffff
    8000460e:	fe8080e7          	jalr	-24(ra) # 800035f2 <bwrite>
    if(recovering == 0)
    80004612:	f80b1ce3          	bnez	s6,800045aa <install_trans+0x36>
      bunpin(dbuf);
    80004616:	8526                	mv	a0,s1
    80004618:	fffff097          	auipc	ra,0xfffff
    8000461c:	0f2080e7          	jalr	242(ra) # 8000370a <bunpin>
    80004620:	b769                	j	800045aa <install_trans+0x36>
}
    80004622:	70e2                	ld	ra,56(sp)
    80004624:	7442                	ld	s0,48(sp)
    80004626:	74a2                	ld	s1,40(sp)
    80004628:	7902                	ld	s2,32(sp)
    8000462a:	69e2                	ld	s3,24(sp)
    8000462c:	6a42                	ld	s4,16(sp)
    8000462e:	6aa2                	ld	s5,8(sp)
    80004630:	6b02                	ld	s6,0(sp)
    80004632:	6121                	addi	sp,sp,64
    80004634:	8082                	ret
    80004636:	8082                	ret

0000000080004638 <initlog>:
{
    80004638:	7179                	addi	sp,sp,-48
    8000463a:	f406                	sd	ra,40(sp)
    8000463c:	f022                	sd	s0,32(sp)
    8000463e:	ec26                	sd	s1,24(sp)
    80004640:	e84a                	sd	s2,16(sp)
    80004642:	e44e                	sd	s3,8(sp)
    80004644:	1800                	addi	s0,sp,48
    80004646:	892a                	mv	s2,a0
    80004648:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000464a:	0023d497          	auipc	s1,0x23d
    8000464e:	f1e48493          	addi	s1,s1,-226 # 80241568 <log>
    80004652:	00004597          	auipc	a1,0x4
    80004656:	01e58593          	addi	a1,a1,30 # 80008670 <syscalls+0x1f0>
    8000465a:	8526                	mv	a0,s1
    8000465c:	ffffc097          	auipc	ra,0xffffc
    80004660:	60a080e7          	jalr	1546(ra) # 80000c66 <initlock>
  log.start = sb->logstart;
    80004664:	0149a583          	lw	a1,20(s3)
    80004668:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000466a:	0109a783          	lw	a5,16(s3)
    8000466e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004670:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004674:	854a                	mv	a0,s2
    80004676:	fffff097          	auipc	ra,0xfffff
    8000467a:	e8a080e7          	jalr	-374(ra) # 80003500 <bread>
  log.lh.n = lh->n;
    8000467e:	4d34                	lw	a3,88(a0)
    80004680:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004682:	02d05563          	blez	a3,800046ac <initlog+0x74>
    80004686:	05c50793          	addi	a5,a0,92
    8000468a:	0023d717          	auipc	a4,0x23d
    8000468e:	f0e70713          	addi	a4,a4,-242 # 80241598 <log+0x30>
    80004692:	36fd                	addiw	a3,a3,-1
    80004694:	1682                	slli	a3,a3,0x20
    80004696:	9281                	srli	a3,a3,0x20
    80004698:	068a                	slli	a3,a3,0x2
    8000469a:	06050613          	addi	a2,a0,96
    8000469e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800046a0:	4390                	lw	a2,0(a5)
    800046a2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046a4:	0791                	addi	a5,a5,4
    800046a6:	0711                	addi	a4,a4,4
    800046a8:	fed79ce3          	bne	a5,a3,800046a0 <initlog+0x68>
  brelse(buf);
    800046ac:	fffff097          	auipc	ra,0xfffff
    800046b0:	f84080e7          	jalr	-124(ra) # 80003630 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800046b4:	4505                	li	a0,1
    800046b6:	00000097          	auipc	ra,0x0
    800046ba:	ebe080e7          	jalr	-322(ra) # 80004574 <install_trans>
  log.lh.n = 0;
    800046be:	0023d797          	auipc	a5,0x23d
    800046c2:	ec07ab23          	sw	zero,-298(a5) # 80241594 <log+0x2c>
  write_head(); // clear the log
    800046c6:	00000097          	auipc	ra,0x0
    800046ca:	e34080e7          	jalr	-460(ra) # 800044fa <write_head>
}
    800046ce:	70a2                	ld	ra,40(sp)
    800046d0:	7402                	ld	s0,32(sp)
    800046d2:	64e2                	ld	s1,24(sp)
    800046d4:	6942                	ld	s2,16(sp)
    800046d6:	69a2                	ld	s3,8(sp)
    800046d8:	6145                	addi	sp,sp,48
    800046da:	8082                	ret

00000000800046dc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046dc:	1101                	addi	sp,sp,-32
    800046de:	ec06                	sd	ra,24(sp)
    800046e0:	e822                	sd	s0,16(sp)
    800046e2:	e426                	sd	s1,8(sp)
    800046e4:	e04a                	sd	s2,0(sp)
    800046e6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046e8:	0023d517          	auipc	a0,0x23d
    800046ec:	e8050513          	addi	a0,a0,-384 # 80241568 <log>
    800046f0:	ffffc097          	auipc	ra,0xffffc
    800046f4:	606080e7          	jalr	1542(ra) # 80000cf6 <acquire>
  while(1){
    if(log.committing){
    800046f8:	0023d497          	auipc	s1,0x23d
    800046fc:	e7048493          	addi	s1,s1,-400 # 80241568 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004700:	4979                	li	s2,30
    80004702:	a039                	j	80004710 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004704:	85a6                	mv	a1,s1
    80004706:	8526                	mv	a0,s1
    80004708:	ffffe097          	auipc	ra,0xffffe
    8000470c:	c1e080e7          	jalr	-994(ra) # 80002326 <sleep>
    if(log.committing){
    80004710:	50dc                	lw	a5,36(s1)
    80004712:	fbed                	bnez	a5,80004704 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004714:	509c                	lw	a5,32(s1)
    80004716:	0017871b          	addiw	a4,a5,1
    8000471a:	0007069b          	sext.w	a3,a4
    8000471e:	0027179b          	slliw	a5,a4,0x2
    80004722:	9fb9                	addw	a5,a5,a4
    80004724:	0017979b          	slliw	a5,a5,0x1
    80004728:	54d8                	lw	a4,44(s1)
    8000472a:	9fb9                	addw	a5,a5,a4
    8000472c:	00f95963          	bge	s2,a5,8000473e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004730:	85a6                	mv	a1,s1
    80004732:	8526                	mv	a0,s1
    80004734:	ffffe097          	auipc	ra,0xffffe
    80004738:	bf2080e7          	jalr	-1038(ra) # 80002326 <sleep>
    8000473c:	bfd1                	j	80004710 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000473e:	0023d517          	auipc	a0,0x23d
    80004742:	e2a50513          	addi	a0,a0,-470 # 80241568 <log>
    80004746:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	662080e7          	jalr	1634(ra) # 80000daa <release>
      break;
    }
  }
}
    80004750:	60e2                	ld	ra,24(sp)
    80004752:	6442                	ld	s0,16(sp)
    80004754:	64a2                	ld	s1,8(sp)
    80004756:	6902                	ld	s2,0(sp)
    80004758:	6105                	addi	sp,sp,32
    8000475a:	8082                	ret

000000008000475c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000475c:	7139                	addi	sp,sp,-64
    8000475e:	fc06                	sd	ra,56(sp)
    80004760:	f822                	sd	s0,48(sp)
    80004762:	f426                	sd	s1,40(sp)
    80004764:	f04a                	sd	s2,32(sp)
    80004766:	ec4e                	sd	s3,24(sp)
    80004768:	e852                	sd	s4,16(sp)
    8000476a:	e456                	sd	s5,8(sp)
    8000476c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000476e:	0023d497          	auipc	s1,0x23d
    80004772:	dfa48493          	addi	s1,s1,-518 # 80241568 <log>
    80004776:	8526                	mv	a0,s1
    80004778:	ffffc097          	auipc	ra,0xffffc
    8000477c:	57e080e7          	jalr	1406(ra) # 80000cf6 <acquire>
  log.outstanding -= 1;
    80004780:	509c                	lw	a5,32(s1)
    80004782:	37fd                	addiw	a5,a5,-1
    80004784:	0007891b          	sext.w	s2,a5
    80004788:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000478a:	50dc                	lw	a5,36(s1)
    8000478c:	e7b9                	bnez	a5,800047da <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000478e:	04091e63          	bnez	s2,800047ea <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004792:	0023d497          	auipc	s1,0x23d
    80004796:	dd648493          	addi	s1,s1,-554 # 80241568 <log>
    8000479a:	4785                	li	a5,1
    8000479c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000479e:	8526                	mv	a0,s1
    800047a0:	ffffc097          	auipc	ra,0xffffc
    800047a4:	60a080e7          	jalr	1546(ra) # 80000daa <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800047a8:	54dc                	lw	a5,44(s1)
    800047aa:	06f04763          	bgtz	a5,80004818 <end_op+0xbc>
    acquire(&log.lock);
    800047ae:	0023d497          	auipc	s1,0x23d
    800047b2:	dba48493          	addi	s1,s1,-582 # 80241568 <log>
    800047b6:	8526                	mv	a0,s1
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	53e080e7          	jalr	1342(ra) # 80000cf6 <acquire>
    log.committing = 0;
    800047c0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800047c4:	8526                	mv	a0,s1
    800047c6:	ffffe097          	auipc	ra,0xffffe
    800047ca:	bc4080e7          	jalr	-1084(ra) # 8000238a <wakeup>
    release(&log.lock);
    800047ce:	8526                	mv	a0,s1
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	5da080e7          	jalr	1498(ra) # 80000daa <release>
}
    800047d8:	a03d                	j	80004806 <end_op+0xaa>
    panic("log.committing");
    800047da:	00004517          	auipc	a0,0x4
    800047de:	e9e50513          	addi	a0,a0,-354 # 80008678 <syscalls+0x1f8>
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	d5c080e7          	jalr	-676(ra) # 8000053e <panic>
    wakeup(&log);
    800047ea:	0023d497          	auipc	s1,0x23d
    800047ee:	d7e48493          	addi	s1,s1,-642 # 80241568 <log>
    800047f2:	8526                	mv	a0,s1
    800047f4:	ffffe097          	auipc	ra,0xffffe
    800047f8:	b96080e7          	jalr	-1130(ra) # 8000238a <wakeup>
  release(&log.lock);
    800047fc:	8526                	mv	a0,s1
    800047fe:	ffffc097          	auipc	ra,0xffffc
    80004802:	5ac080e7          	jalr	1452(ra) # 80000daa <release>
}
    80004806:	70e2                	ld	ra,56(sp)
    80004808:	7442                	ld	s0,48(sp)
    8000480a:	74a2                	ld	s1,40(sp)
    8000480c:	7902                	ld	s2,32(sp)
    8000480e:	69e2                	ld	s3,24(sp)
    80004810:	6a42                	ld	s4,16(sp)
    80004812:	6aa2                	ld	s5,8(sp)
    80004814:	6121                	addi	sp,sp,64
    80004816:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004818:	0023da97          	auipc	s5,0x23d
    8000481c:	d80a8a93          	addi	s5,s5,-640 # 80241598 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004820:	0023da17          	auipc	s4,0x23d
    80004824:	d48a0a13          	addi	s4,s4,-696 # 80241568 <log>
    80004828:	018a2583          	lw	a1,24(s4)
    8000482c:	012585bb          	addw	a1,a1,s2
    80004830:	2585                	addiw	a1,a1,1
    80004832:	028a2503          	lw	a0,40(s4)
    80004836:	fffff097          	auipc	ra,0xfffff
    8000483a:	cca080e7          	jalr	-822(ra) # 80003500 <bread>
    8000483e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004840:	000aa583          	lw	a1,0(s5)
    80004844:	028a2503          	lw	a0,40(s4)
    80004848:	fffff097          	auipc	ra,0xfffff
    8000484c:	cb8080e7          	jalr	-840(ra) # 80003500 <bread>
    80004850:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004852:	40000613          	li	a2,1024
    80004856:	05850593          	addi	a1,a0,88
    8000485a:	05848513          	addi	a0,s1,88
    8000485e:	ffffc097          	auipc	ra,0xffffc
    80004862:	5f0080e7          	jalr	1520(ra) # 80000e4e <memmove>
    bwrite(to);  // write the log
    80004866:	8526                	mv	a0,s1
    80004868:	fffff097          	auipc	ra,0xfffff
    8000486c:	d8a080e7          	jalr	-630(ra) # 800035f2 <bwrite>
    brelse(from);
    80004870:	854e                	mv	a0,s3
    80004872:	fffff097          	auipc	ra,0xfffff
    80004876:	dbe080e7          	jalr	-578(ra) # 80003630 <brelse>
    brelse(to);
    8000487a:	8526                	mv	a0,s1
    8000487c:	fffff097          	auipc	ra,0xfffff
    80004880:	db4080e7          	jalr	-588(ra) # 80003630 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004884:	2905                	addiw	s2,s2,1
    80004886:	0a91                	addi	s5,s5,4
    80004888:	02ca2783          	lw	a5,44(s4)
    8000488c:	f8f94ee3          	blt	s2,a5,80004828 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004890:	00000097          	auipc	ra,0x0
    80004894:	c6a080e7          	jalr	-918(ra) # 800044fa <write_head>
    install_trans(0); // Now install writes to home locations
    80004898:	4501                	li	a0,0
    8000489a:	00000097          	auipc	ra,0x0
    8000489e:	cda080e7          	jalr	-806(ra) # 80004574 <install_trans>
    log.lh.n = 0;
    800048a2:	0023d797          	auipc	a5,0x23d
    800048a6:	ce07a923          	sw	zero,-782(a5) # 80241594 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800048aa:	00000097          	auipc	ra,0x0
    800048ae:	c50080e7          	jalr	-944(ra) # 800044fa <write_head>
    800048b2:	bdf5                	j	800047ae <end_op+0x52>

00000000800048b4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800048b4:	1101                	addi	sp,sp,-32
    800048b6:	ec06                	sd	ra,24(sp)
    800048b8:	e822                	sd	s0,16(sp)
    800048ba:	e426                	sd	s1,8(sp)
    800048bc:	e04a                	sd	s2,0(sp)
    800048be:	1000                	addi	s0,sp,32
    800048c0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800048c2:	0023d917          	auipc	s2,0x23d
    800048c6:	ca690913          	addi	s2,s2,-858 # 80241568 <log>
    800048ca:	854a                	mv	a0,s2
    800048cc:	ffffc097          	auipc	ra,0xffffc
    800048d0:	42a080e7          	jalr	1066(ra) # 80000cf6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800048d4:	02c92603          	lw	a2,44(s2)
    800048d8:	47f5                	li	a5,29
    800048da:	06c7c563          	blt	a5,a2,80004944 <log_write+0x90>
    800048de:	0023d797          	auipc	a5,0x23d
    800048e2:	ca67a783          	lw	a5,-858(a5) # 80241584 <log+0x1c>
    800048e6:	37fd                	addiw	a5,a5,-1
    800048e8:	04f65e63          	bge	a2,a5,80004944 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048ec:	0023d797          	auipc	a5,0x23d
    800048f0:	c9c7a783          	lw	a5,-868(a5) # 80241588 <log+0x20>
    800048f4:	06f05063          	blez	a5,80004954 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048f8:	4781                	li	a5,0
    800048fa:	06c05563          	blez	a2,80004964 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048fe:	44cc                	lw	a1,12(s1)
    80004900:	0023d717          	auipc	a4,0x23d
    80004904:	c9870713          	addi	a4,a4,-872 # 80241598 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004908:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000490a:	4314                	lw	a3,0(a4)
    8000490c:	04b68c63          	beq	a3,a1,80004964 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004910:	2785                	addiw	a5,a5,1
    80004912:	0711                	addi	a4,a4,4
    80004914:	fef61be3          	bne	a2,a5,8000490a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004918:	0621                	addi	a2,a2,8
    8000491a:	060a                	slli	a2,a2,0x2
    8000491c:	0023d797          	auipc	a5,0x23d
    80004920:	c4c78793          	addi	a5,a5,-948 # 80241568 <log>
    80004924:	963e                	add	a2,a2,a5
    80004926:	44dc                	lw	a5,12(s1)
    80004928:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000492a:	8526                	mv	a0,s1
    8000492c:	fffff097          	auipc	ra,0xfffff
    80004930:	da2080e7          	jalr	-606(ra) # 800036ce <bpin>
    log.lh.n++;
    80004934:	0023d717          	auipc	a4,0x23d
    80004938:	c3470713          	addi	a4,a4,-972 # 80241568 <log>
    8000493c:	575c                	lw	a5,44(a4)
    8000493e:	2785                	addiw	a5,a5,1
    80004940:	d75c                	sw	a5,44(a4)
    80004942:	a835                	j	8000497e <log_write+0xca>
    panic("too big a transaction");
    80004944:	00004517          	auipc	a0,0x4
    80004948:	d4450513          	addi	a0,a0,-700 # 80008688 <syscalls+0x208>
    8000494c:	ffffc097          	auipc	ra,0xffffc
    80004950:	bf2080e7          	jalr	-1038(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004954:	00004517          	auipc	a0,0x4
    80004958:	d4c50513          	addi	a0,a0,-692 # 800086a0 <syscalls+0x220>
    8000495c:	ffffc097          	auipc	ra,0xffffc
    80004960:	be2080e7          	jalr	-1054(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004964:	00878713          	addi	a4,a5,8
    80004968:	00271693          	slli	a3,a4,0x2
    8000496c:	0023d717          	auipc	a4,0x23d
    80004970:	bfc70713          	addi	a4,a4,-1028 # 80241568 <log>
    80004974:	9736                	add	a4,a4,a3
    80004976:	44d4                	lw	a3,12(s1)
    80004978:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000497a:	faf608e3          	beq	a2,a5,8000492a <log_write+0x76>
  }
  release(&log.lock);
    8000497e:	0023d517          	auipc	a0,0x23d
    80004982:	bea50513          	addi	a0,a0,-1046 # 80241568 <log>
    80004986:	ffffc097          	auipc	ra,0xffffc
    8000498a:	424080e7          	jalr	1060(ra) # 80000daa <release>
}
    8000498e:	60e2                	ld	ra,24(sp)
    80004990:	6442                	ld	s0,16(sp)
    80004992:	64a2                	ld	s1,8(sp)
    80004994:	6902                	ld	s2,0(sp)
    80004996:	6105                	addi	sp,sp,32
    80004998:	8082                	ret

000000008000499a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000499a:	1101                	addi	sp,sp,-32
    8000499c:	ec06                	sd	ra,24(sp)
    8000499e:	e822                	sd	s0,16(sp)
    800049a0:	e426                	sd	s1,8(sp)
    800049a2:	e04a                	sd	s2,0(sp)
    800049a4:	1000                	addi	s0,sp,32
    800049a6:	84aa                	mv	s1,a0
    800049a8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049aa:	00004597          	auipc	a1,0x4
    800049ae:	d1658593          	addi	a1,a1,-746 # 800086c0 <syscalls+0x240>
    800049b2:	0521                	addi	a0,a0,8
    800049b4:	ffffc097          	auipc	ra,0xffffc
    800049b8:	2b2080e7          	jalr	690(ra) # 80000c66 <initlock>
  lk->name = name;
    800049bc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800049c0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049c4:	0204a423          	sw	zero,40(s1)
}
    800049c8:	60e2                	ld	ra,24(sp)
    800049ca:	6442                	ld	s0,16(sp)
    800049cc:	64a2                	ld	s1,8(sp)
    800049ce:	6902                	ld	s2,0(sp)
    800049d0:	6105                	addi	sp,sp,32
    800049d2:	8082                	ret

00000000800049d4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049d4:	1101                	addi	sp,sp,-32
    800049d6:	ec06                	sd	ra,24(sp)
    800049d8:	e822                	sd	s0,16(sp)
    800049da:	e426                	sd	s1,8(sp)
    800049dc:	e04a                	sd	s2,0(sp)
    800049de:	1000                	addi	s0,sp,32
    800049e0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049e2:	00850913          	addi	s2,a0,8
    800049e6:	854a                	mv	a0,s2
    800049e8:	ffffc097          	auipc	ra,0xffffc
    800049ec:	30e080e7          	jalr	782(ra) # 80000cf6 <acquire>
  while (lk->locked) {
    800049f0:	409c                	lw	a5,0(s1)
    800049f2:	cb89                	beqz	a5,80004a04 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049f4:	85ca                	mv	a1,s2
    800049f6:	8526                	mv	a0,s1
    800049f8:	ffffe097          	auipc	ra,0xffffe
    800049fc:	92e080e7          	jalr	-1746(ra) # 80002326 <sleep>
  while (lk->locked) {
    80004a00:	409c                	lw	a5,0(s1)
    80004a02:	fbed                	bnez	a5,800049f4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004a04:	4785                	li	a5,1
    80004a06:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a08:	ffffd097          	auipc	ra,0xffffd
    80004a0c:	106080e7          	jalr	262(ra) # 80001b0e <myproc>
    80004a10:	591c                	lw	a5,48(a0)
    80004a12:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a14:	854a                	mv	a0,s2
    80004a16:	ffffc097          	auipc	ra,0xffffc
    80004a1a:	394080e7          	jalr	916(ra) # 80000daa <release>
}
    80004a1e:	60e2                	ld	ra,24(sp)
    80004a20:	6442                	ld	s0,16(sp)
    80004a22:	64a2                	ld	s1,8(sp)
    80004a24:	6902                	ld	s2,0(sp)
    80004a26:	6105                	addi	sp,sp,32
    80004a28:	8082                	ret

0000000080004a2a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a2a:	1101                	addi	sp,sp,-32
    80004a2c:	ec06                	sd	ra,24(sp)
    80004a2e:	e822                	sd	s0,16(sp)
    80004a30:	e426                	sd	s1,8(sp)
    80004a32:	e04a                	sd	s2,0(sp)
    80004a34:	1000                	addi	s0,sp,32
    80004a36:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a38:	00850913          	addi	s2,a0,8
    80004a3c:	854a                	mv	a0,s2
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	2b8080e7          	jalr	696(ra) # 80000cf6 <acquire>
  lk->locked = 0;
    80004a46:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a4a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a4e:	8526                	mv	a0,s1
    80004a50:	ffffe097          	auipc	ra,0xffffe
    80004a54:	93a080e7          	jalr	-1734(ra) # 8000238a <wakeup>
  release(&lk->lk);
    80004a58:	854a                	mv	a0,s2
    80004a5a:	ffffc097          	auipc	ra,0xffffc
    80004a5e:	350080e7          	jalr	848(ra) # 80000daa <release>
}
    80004a62:	60e2                	ld	ra,24(sp)
    80004a64:	6442                	ld	s0,16(sp)
    80004a66:	64a2                	ld	s1,8(sp)
    80004a68:	6902                	ld	s2,0(sp)
    80004a6a:	6105                	addi	sp,sp,32
    80004a6c:	8082                	ret

0000000080004a6e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a6e:	7179                	addi	sp,sp,-48
    80004a70:	f406                	sd	ra,40(sp)
    80004a72:	f022                	sd	s0,32(sp)
    80004a74:	ec26                	sd	s1,24(sp)
    80004a76:	e84a                	sd	s2,16(sp)
    80004a78:	e44e                	sd	s3,8(sp)
    80004a7a:	1800                	addi	s0,sp,48
    80004a7c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a7e:	00850913          	addi	s2,a0,8
    80004a82:	854a                	mv	a0,s2
    80004a84:	ffffc097          	auipc	ra,0xffffc
    80004a88:	272080e7          	jalr	626(ra) # 80000cf6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a8c:	409c                	lw	a5,0(s1)
    80004a8e:	ef99                	bnez	a5,80004aac <holdingsleep+0x3e>
    80004a90:	4481                	li	s1,0
  release(&lk->lk);
    80004a92:	854a                	mv	a0,s2
    80004a94:	ffffc097          	auipc	ra,0xffffc
    80004a98:	316080e7          	jalr	790(ra) # 80000daa <release>
  return r;
}
    80004a9c:	8526                	mv	a0,s1
    80004a9e:	70a2                	ld	ra,40(sp)
    80004aa0:	7402                	ld	s0,32(sp)
    80004aa2:	64e2                	ld	s1,24(sp)
    80004aa4:	6942                	ld	s2,16(sp)
    80004aa6:	69a2                	ld	s3,8(sp)
    80004aa8:	6145                	addi	sp,sp,48
    80004aaa:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004aac:	0284a983          	lw	s3,40(s1)
    80004ab0:	ffffd097          	auipc	ra,0xffffd
    80004ab4:	05e080e7          	jalr	94(ra) # 80001b0e <myproc>
    80004ab8:	5904                	lw	s1,48(a0)
    80004aba:	413484b3          	sub	s1,s1,s3
    80004abe:	0014b493          	seqz	s1,s1
    80004ac2:	bfc1                	j	80004a92 <holdingsleep+0x24>

0000000080004ac4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ac4:	1141                	addi	sp,sp,-16
    80004ac6:	e406                	sd	ra,8(sp)
    80004ac8:	e022                	sd	s0,0(sp)
    80004aca:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004acc:	00004597          	auipc	a1,0x4
    80004ad0:	c0458593          	addi	a1,a1,-1020 # 800086d0 <syscalls+0x250>
    80004ad4:	0023d517          	auipc	a0,0x23d
    80004ad8:	bdc50513          	addi	a0,a0,-1060 # 802416b0 <ftable>
    80004adc:	ffffc097          	auipc	ra,0xffffc
    80004ae0:	18a080e7          	jalr	394(ra) # 80000c66 <initlock>
}
    80004ae4:	60a2                	ld	ra,8(sp)
    80004ae6:	6402                	ld	s0,0(sp)
    80004ae8:	0141                	addi	sp,sp,16
    80004aea:	8082                	ret

0000000080004aec <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004aec:	1101                	addi	sp,sp,-32
    80004aee:	ec06                	sd	ra,24(sp)
    80004af0:	e822                	sd	s0,16(sp)
    80004af2:	e426                	sd	s1,8(sp)
    80004af4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004af6:	0023d517          	auipc	a0,0x23d
    80004afa:	bba50513          	addi	a0,a0,-1094 # 802416b0 <ftable>
    80004afe:	ffffc097          	auipc	ra,0xffffc
    80004b02:	1f8080e7          	jalr	504(ra) # 80000cf6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b06:	0023d497          	auipc	s1,0x23d
    80004b0a:	bc248493          	addi	s1,s1,-1086 # 802416c8 <ftable+0x18>
    80004b0e:	0023e717          	auipc	a4,0x23e
    80004b12:	b5a70713          	addi	a4,a4,-1190 # 80242668 <disk>
    if(f->ref == 0){
    80004b16:	40dc                	lw	a5,4(s1)
    80004b18:	cf99                	beqz	a5,80004b36 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b1a:	02848493          	addi	s1,s1,40
    80004b1e:	fee49ce3          	bne	s1,a4,80004b16 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b22:	0023d517          	auipc	a0,0x23d
    80004b26:	b8e50513          	addi	a0,a0,-1138 # 802416b0 <ftable>
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	280080e7          	jalr	640(ra) # 80000daa <release>
  return 0;
    80004b32:	4481                	li	s1,0
    80004b34:	a819                	j	80004b4a <filealloc+0x5e>
      f->ref = 1;
    80004b36:	4785                	li	a5,1
    80004b38:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b3a:	0023d517          	auipc	a0,0x23d
    80004b3e:	b7650513          	addi	a0,a0,-1162 # 802416b0 <ftable>
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	268080e7          	jalr	616(ra) # 80000daa <release>
}
    80004b4a:	8526                	mv	a0,s1
    80004b4c:	60e2                	ld	ra,24(sp)
    80004b4e:	6442                	ld	s0,16(sp)
    80004b50:	64a2                	ld	s1,8(sp)
    80004b52:	6105                	addi	sp,sp,32
    80004b54:	8082                	ret

0000000080004b56 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b56:	1101                	addi	sp,sp,-32
    80004b58:	ec06                	sd	ra,24(sp)
    80004b5a:	e822                	sd	s0,16(sp)
    80004b5c:	e426                	sd	s1,8(sp)
    80004b5e:	1000                	addi	s0,sp,32
    80004b60:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b62:	0023d517          	auipc	a0,0x23d
    80004b66:	b4e50513          	addi	a0,a0,-1202 # 802416b0 <ftable>
    80004b6a:	ffffc097          	auipc	ra,0xffffc
    80004b6e:	18c080e7          	jalr	396(ra) # 80000cf6 <acquire>
  if(f->ref < 1)
    80004b72:	40dc                	lw	a5,4(s1)
    80004b74:	02f05263          	blez	a5,80004b98 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b78:	2785                	addiw	a5,a5,1
    80004b7a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b7c:	0023d517          	auipc	a0,0x23d
    80004b80:	b3450513          	addi	a0,a0,-1228 # 802416b0 <ftable>
    80004b84:	ffffc097          	auipc	ra,0xffffc
    80004b88:	226080e7          	jalr	550(ra) # 80000daa <release>
  return f;
}
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	60e2                	ld	ra,24(sp)
    80004b90:	6442                	ld	s0,16(sp)
    80004b92:	64a2                	ld	s1,8(sp)
    80004b94:	6105                	addi	sp,sp,32
    80004b96:	8082                	ret
    panic("filedup");
    80004b98:	00004517          	auipc	a0,0x4
    80004b9c:	b4050513          	addi	a0,a0,-1216 # 800086d8 <syscalls+0x258>
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	99e080e7          	jalr	-1634(ra) # 8000053e <panic>

0000000080004ba8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ba8:	7139                	addi	sp,sp,-64
    80004baa:	fc06                	sd	ra,56(sp)
    80004bac:	f822                	sd	s0,48(sp)
    80004bae:	f426                	sd	s1,40(sp)
    80004bb0:	f04a                	sd	s2,32(sp)
    80004bb2:	ec4e                	sd	s3,24(sp)
    80004bb4:	e852                	sd	s4,16(sp)
    80004bb6:	e456                	sd	s5,8(sp)
    80004bb8:	0080                	addi	s0,sp,64
    80004bba:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004bbc:	0023d517          	auipc	a0,0x23d
    80004bc0:	af450513          	addi	a0,a0,-1292 # 802416b0 <ftable>
    80004bc4:	ffffc097          	auipc	ra,0xffffc
    80004bc8:	132080e7          	jalr	306(ra) # 80000cf6 <acquire>
  if(f->ref < 1)
    80004bcc:	40dc                	lw	a5,4(s1)
    80004bce:	06f05163          	blez	a5,80004c30 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004bd2:	37fd                	addiw	a5,a5,-1
    80004bd4:	0007871b          	sext.w	a4,a5
    80004bd8:	c0dc                	sw	a5,4(s1)
    80004bda:	06e04363          	bgtz	a4,80004c40 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bde:	0004a903          	lw	s2,0(s1)
    80004be2:	0094ca83          	lbu	s5,9(s1)
    80004be6:	0104ba03          	ld	s4,16(s1)
    80004bea:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004bee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bf2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bf6:	0023d517          	auipc	a0,0x23d
    80004bfa:	aba50513          	addi	a0,a0,-1350 # 802416b0 <ftable>
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	1ac080e7          	jalr	428(ra) # 80000daa <release>

  if(ff.type == FD_PIPE){
    80004c06:	4785                	li	a5,1
    80004c08:	04f90d63          	beq	s2,a5,80004c62 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c0c:	3979                	addiw	s2,s2,-2
    80004c0e:	4785                	li	a5,1
    80004c10:	0527e063          	bltu	a5,s2,80004c50 <fileclose+0xa8>
    begin_op();
    80004c14:	00000097          	auipc	ra,0x0
    80004c18:	ac8080e7          	jalr	-1336(ra) # 800046dc <begin_op>
    iput(ff.ip);
    80004c1c:	854e                	mv	a0,s3
    80004c1e:	fffff097          	auipc	ra,0xfffff
    80004c22:	2b6080e7          	jalr	694(ra) # 80003ed4 <iput>
    end_op();
    80004c26:	00000097          	auipc	ra,0x0
    80004c2a:	b36080e7          	jalr	-1226(ra) # 8000475c <end_op>
    80004c2e:	a00d                	j	80004c50 <fileclose+0xa8>
    panic("fileclose");
    80004c30:	00004517          	auipc	a0,0x4
    80004c34:	ab050513          	addi	a0,a0,-1360 # 800086e0 <syscalls+0x260>
    80004c38:	ffffc097          	auipc	ra,0xffffc
    80004c3c:	906080e7          	jalr	-1786(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004c40:	0023d517          	auipc	a0,0x23d
    80004c44:	a7050513          	addi	a0,a0,-1424 # 802416b0 <ftable>
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	162080e7          	jalr	354(ra) # 80000daa <release>
  }
}
    80004c50:	70e2                	ld	ra,56(sp)
    80004c52:	7442                	ld	s0,48(sp)
    80004c54:	74a2                	ld	s1,40(sp)
    80004c56:	7902                	ld	s2,32(sp)
    80004c58:	69e2                	ld	s3,24(sp)
    80004c5a:	6a42                	ld	s4,16(sp)
    80004c5c:	6aa2                	ld	s5,8(sp)
    80004c5e:	6121                	addi	sp,sp,64
    80004c60:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c62:	85d6                	mv	a1,s5
    80004c64:	8552                	mv	a0,s4
    80004c66:	00000097          	auipc	ra,0x0
    80004c6a:	34c080e7          	jalr	844(ra) # 80004fb2 <pipeclose>
    80004c6e:	b7cd                	j	80004c50 <fileclose+0xa8>

0000000080004c70 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c70:	715d                	addi	sp,sp,-80
    80004c72:	e486                	sd	ra,72(sp)
    80004c74:	e0a2                	sd	s0,64(sp)
    80004c76:	fc26                	sd	s1,56(sp)
    80004c78:	f84a                	sd	s2,48(sp)
    80004c7a:	f44e                	sd	s3,40(sp)
    80004c7c:	0880                	addi	s0,sp,80
    80004c7e:	84aa                	mv	s1,a0
    80004c80:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c82:	ffffd097          	auipc	ra,0xffffd
    80004c86:	e8c080e7          	jalr	-372(ra) # 80001b0e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c8a:	409c                	lw	a5,0(s1)
    80004c8c:	37f9                	addiw	a5,a5,-2
    80004c8e:	4705                	li	a4,1
    80004c90:	04f76763          	bltu	a4,a5,80004cde <filestat+0x6e>
    80004c94:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c96:	6c88                	ld	a0,24(s1)
    80004c98:	fffff097          	auipc	ra,0xfffff
    80004c9c:	082080e7          	jalr	130(ra) # 80003d1a <ilock>
    stati(f->ip, &st);
    80004ca0:	fb840593          	addi	a1,s0,-72
    80004ca4:	6c88                	ld	a0,24(s1)
    80004ca6:	fffff097          	auipc	ra,0xfffff
    80004caa:	2fe080e7          	jalr	766(ra) # 80003fa4 <stati>
    iunlock(f->ip);
    80004cae:	6c88                	ld	a0,24(s1)
    80004cb0:	fffff097          	auipc	ra,0xfffff
    80004cb4:	12c080e7          	jalr	300(ra) # 80003ddc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004cb8:	46e1                	li	a3,24
    80004cba:	fb840613          	addi	a2,s0,-72
    80004cbe:	85ce                	mv	a1,s3
    80004cc0:	05093503          	ld	a0,80(s2)
    80004cc4:	ffffd097          	auipc	ra,0xffffd
    80004cc8:	aca080e7          	jalr	-1334(ra) # 8000178e <copyout>
    80004ccc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004cd0:	60a6                	ld	ra,72(sp)
    80004cd2:	6406                	ld	s0,64(sp)
    80004cd4:	74e2                	ld	s1,56(sp)
    80004cd6:	7942                	ld	s2,48(sp)
    80004cd8:	79a2                	ld	s3,40(sp)
    80004cda:	6161                	addi	sp,sp,80
    80004cdc:	8082                	ret
  return -1;
    80004cde:	557d                	li	a0,-1
    80004ce0:	bfc5                	j	80004cd0 <filestat+0x60>

0000000080004ce2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ce2:	7179                	addi	sp,sp,-48
    80004ce4:	f406                	sd	ra,40(sp)
    80004ce6:	f022                	sd	s0,32(sp)
    80004ce8:	ec26                	sd	s1,24(sp)
    80004cea:	e84a                	sd	s2,16(sp)
    80004cec:	e44e                	sd	s3,8(sp)
    80004cee:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004cf0:	00854783          	lbu	a5,8(a0)
    80004cf4:	c3d5                	beqz	a5,80004d98 <fileread+0xb6>
    80004cf6:	84aa                	mv	s1,a0
    80004cf8:	89ae                	mv	s3,a1
    80004cfa:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cfc:	411c                	lw	a5,0(a0)
    80004cfe:	4705                	li	a4,1
    80004d00:	04e78963          	beq	a5,a4,80004d52 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d04:	470d                	li	a4,3
    80004d06:	04e78d63          	beq	a5,a4,80004d60 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d0a:	4709                	li	a4,2
    80004d0c:	06e79e63          	bne	a5,a4,80004d88 <fileread+0xa6>
    ilock(f->ip);
    80004d10:	6d08                	ld	a0,24(a0)
    80004d12:	fffff097          	auipc	ra,0xfffff
    80004d16:	008080e7          	jalr	8(ra) # 80003d1a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d1a:	874a                	mv	a4,s2
    80004d1c:	5094                	lw	a3,32(s1)
    80004d1e:	864e                	mv	a2,s3
    80004d20:	4585                	li	a1,1
    80004d22:	6c88                	ld	a0,24(s1)
    80004d24:	fffff097          	auipc	ra,0xfffff
    80004d28:	2aa080e7          	jalr	682(ra) # 80003fce <readi>
    80004d2c:	892a                	mv	s2,a0
    80004d2e:	00a05563          	blez	a0,80004d38 <fileread+0x56>
      f->off += r;
    80004d32:	509c                	lw	a5,32(s1)
    80004d34:	9fa9                	addw	a5,a5,a0
    80004d36:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d38:	6c88                	ld	a0,24(s1)
    80004d3a:	fffff097          	auipc	ra,0xfffff
    80004d3e:	0a2080e7          	jalr	162(ra) # 80003ddc <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d42:	854a                	mv	a0,s2
    80004d44:	70a2                	ld	ra,40(sp)
    80004d46:	7402                	ld	s0,32(sp)
    80004d48:	64e2                	ld	s1,24(sp)
    80004d4a:	6942                	ld	s2,16(sp)
    80004d4c:	69a2                	ld	s3,8(sp)
    80004d4e:	6145                	addi	sp,sp,48
    80004d50:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d52:	6908                	ld	a0,16(a0)
    80004d54:	00000097          	auipc	ra,0x0
    80004d58:	3c6080e7          	jalr	966(ra) # 8000511a <piperead>
    80004d5c:	892a                	mv	s2,a0
    80004d5e:	b7d5                	j	80004d42 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d60:	02451783          	lh	a5,36(a0)
    80004d64:	03079693          	slli	a3,a5,0x30
    80004d68:	92c1                	srli	a3,a3,0x30
    80004d6a:	4725                	li	a4,9
    80004d6c:	02d76863          	bltu	a4,a3,80004d9c <fileread+0xba>
    80004d70:	0792                	slli	a5,a5,0x4
    80004d72:	0023d717          	auipc	a4,0x23d
    80004d76:	89e70713          	addi	a4,a4,-1890 # 80241610 <devsw>
    80004d7a:	97ba                	add	a5,a5,a4
    80004d7c:	639c                	ld	a5,0(a5)
    80004d7e:	c38d                	beqz	a5,80004da0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d80:	4505                	li	a0,1
    80004d82:	9782                	jalr	a5
    80004d84:	892a                	mv	s2,a0
    80004d86:	bf75                	j	80004d42 <fileread+0x60>
    panic("fileread");
    80004d88:	00004517          	auipc	a0,0x4
    80004d8c:	96850513          	addi	a0,a0,-1688 # 800086f0 <syscalls+0x270>
    80004d90:	ffffb097          	auipc	ra,0xffffb
    80004d94:	7ae080e7          	jalr	1966(ra) # 8000053e <panic>
    return -1;
    80004d98:	597d                	li	s2,-1
    80004d9a:	b765                	j	80004d42 <fileread+0x60>
      return -1;
    80004d9c:	597d                	li	s2,-1
    80004d9e:	b755                	j	80004d42 <fileread+0x60>
    80004da0:	597d                	li	s2,-1
    80004da2:	b745                	j	80004d42 <fileread+0x60>

0000000080004da4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004da4:	715d                	addi	sp,sp,-80
    80004da6:	e486                	sd	ra,72(sp)
    80004da8:	e0a2                	sd	s0,64(sp)
    80004daa:	fc26                	sd	s1,56(sp)
    80004dac:	f84a                	sd	s2,48(sp)
    80004dae:	f44e                	sd	s3,40(sp)
    80004db0:	f052                	sd	s4,32(sp)
    80004db2:	ec56                	sd	s5,24(sp)
    80004db4:	e85a                	sd	s6,16(sp)
    80004db6:	e45e                	sd	s7,8(sp)
    80004db8:	e062                	sd	s8,0(sp)
    80004dba:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004dbc:	00954783          	lbu	a5,9(a0)
    80004dc0:	10078663          	beqz	a5,80004ecc <filewrite+0x128>
    80004dc4:	892a                	mv	s2,a0
    80004dc6:	8aae                	mv	s5,a1
    80004dc8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dca:	411c                	lw	a5,0(a0)
    80004dcc:	4705                	li	a4,1
    80004dce:	02e78263          	beq	a5,a4,80004df2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dd2:	470d                	li	a4,3
    80004dd4:	02e78663          	beq	a5,a4,80004e00 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dd8:	4709                	li	a4,2
    80004dda:	0ee79163          	bne	a5,a4,80004ebc <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dde:	0ac05d63          	blez	a2,80004e98 <filewrite+0xf4>
    int i = 0;
    80004de2:	4981                	li	s3,0
    80004de4:	6b05                	lui	s6,0x1
    80004de6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004dea:	6b85                	lui	s7,0x1
    80004dec:	c00b8b9b          	addiw	s7,s7,-1024
    80004df0:	a861                	j	80004e88 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004df2:	6908                	ld	a0,16(a0)
    80004df4:	00000097          	auipc	ra,0x0
    80004df8:	22e080e7          	jalr	558(ra) # 80005022 <pipewrite>
    80004dfc:	8a2a                	mv	s4,a0
    80004dfe:	a045                	j	80004e9e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e00:	02451783          	lh	a5,36(a0)
    80004e04:	03079693          	slli	a3,a5,0x30
    80004e08:	92c1                	srli	a3,a3,0x30
    80004e0a:	4725                	li	a4,9
    80004e0c:	0cd76263          	bltu	a4,a3,80004ed0 <filewrite+0x12c>
    80004e10:	0792                	slli	a5,a5,0x4
    80004e12:	0023c717          	auipc	a4,0x23c
    80004e16:	7fe70713          	addi	a4,a4,2046 # 80241610 <devsw>
    80004e1a:	97ba                	add	a5,a5,a4
    80004e1c:	679c                	ld	a5,8(a5)
    80004e1e:	cbdd                	beqz	a5,80004ed4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e20:	4505                	li	a0,1
    80004e22:	9782                	jalr	a5
    80004e24:	8a2a                	mv	s4,a0
    80004e26:	a8a5                	j	80004e9e <filewrite+0xfa>
    80004e28:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e2c:	00000097          	auipc	ra,0x0
    80004e30:	8b0080e7          	jalr	-1872(ra) # 800046dc <begin_op>
      ilock(f->ip);
    80004e34:	01893503          	ld	a0,24(s2)
    80004e38:	fffff097          	auipc	ra,0xfffff
    80004e3c:	ee2080e7          	jalr	-286(ra) # 80003d1a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e40:	8762                	mv	a4,s8
    80004e42:	02092683          	lw	a3,32(s2)
    80004e46:	01598633          	add	a2,s3,s5
    80004e4a:	4585                	li	a1,1
    80004e4c:	01893503          	ld	a0,24(s2)
    80004e50:	fffff097          	auipc	ra,0xfffff
    80004e54:	276080e7          	jalr	630(ra) # 800040c6 <writei>
    80004e58:	84aa                	mv	s1,a0
    80004e5a:	00a05763          	blez	a0,80004e68 <filewrite+0xc4>
        f->off += r;
    80004e5e:	02092783          	lw	a5,32(s2)
    80004e62:	9fa9                	addw	a5,a5,a0
    80004e64:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e68:	01893503          	ld	a0,24(s2)
    80004e6c:	fffff097          	auipc	ra,0xfffff
    80004e70:	f70080e7          	jalr	-144(ra) # 80003ddc <iunlock>
      end_op();
    80004e74:	00000097          	auipc	ra,0x0
    80004e78:	8e8080e7          	jalr	-1816(ra) # 8000475c <end_op>

      if(r != n1){
    80004e7c:	009c1f63          	bne	s8,s1,80004e9a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e80:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e84:	0149db63          	bge	s3,s4,80004e9a <filewrite+0xf6>
      int n1 = n - i;
    80004e88:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e8c:	84be                	mv	s1,a5
    80004e8e:	2781                	sext.w	a5,a5
    80004e90:	f8fb5ce3          	bge	s6,a5,80004e28 <filewrite+0x84>
    80004e94:	84de                	mv	s1,s7
    80004e96:	bf49                	j	80004e28 <filewrite+0x84>
    int i = 0;
    80004e98:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e9a:	013a1f63          	bne	s4,s3,80004eb8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e9e:	8552                	mv	a0,s4
    80004ea0:	60a6                	ld	ra,72(sp)
    80004ea2:	6406                	ld	s0,64(sp)
    80004ea4:	74e2                	ld	s1,56(sp)
    80004ea6:	7942                	ld	s2,48(sp)
    80004ea8:	79a2                	ld	s3,40(sp)
    80004eaa:	7a02                	ld	s4,32(sp)
    80004eac:	6ae2                	ld	s5,24(sp)
    80004eae:	6b42                	ld	s6,16(sp)
    80004eb0:	6ba2                	ld	s7,8(sp)
    80004eb2:	6c02                	ld	s8,0(sp)
    80004eb4:	6161                	addi	sp,sp,80
    80004eb6:	8082                	ret
    ret = (i == n ? n : -1);
    80004eb8:	5a7d                	li	s4,-1
    80004eba:	b7d5                	j	80004e9e <filewrite+0xfa>
    panic("filewrite");
    80004ebc:	00004517          	auipc	a0,0x4
    80004ec0:	84450513          	addi	a0,a0,-1980 # 80008700 <syscalls+0x280>
    80004ec4:	ffffb097          	auipc	ra,0xffffb
    80004ec8:	67a080e7          	jalr	1658(ra) # 8000053e <panic>
    return -1;
    80004ecc:	5a7d                	li	s4,-1
    80004ece:	bfc1                	j	80004e9e <filewrite+0xfa>
      return -1;
    80004ed0:	5a7d                	li	s4,-1
    80004ed2:	b7f1                	j	80004e9e <filewrite+0xfa>
    80004ed4:	5a7d                	li	s4,-1
    80004ed6:	b7e1                	j	80004e9e <filewrite+0xfa>

0000000080004ed8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ed8:	7179                	addi	sp,sp,-48
    80004eda:	f406                	sd	ra,40(sp)
    80004edc:	f022                	sd	s0,32(sp)
    80004ede:	ec26                	sd	s1,24(sp)
    80004ee0:	e84a                	sd	s2,16(sp)
    80004ee2:	e44e                	sd	s3,8(sp)
    80004ee4:	e052                	sd	s4,0(sp)
    80004ee6:	1800                	addi	s0,sp,48
    80004ee8:	84aa                	mv	s1,a0
    80004eea:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004eec:	0005b023          	sd	zero,0(a1)
    80004ef0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ef4:	00000097          	auipc	ra,0x0
    80004ef8:	bf8080e7          	jalr	-1032(ra) # 80004aec <filealloc>
    80004efc:	e088                	sd	a0,0(s1)
    80004efe:	c551                	beqz	a0,80004f8a <pipealloc+0xb2>
    80004f00:	00000097          	auipc	ra,0x0
    80004f04:	bec080e7          	jalr	-1044(ra) # 80004aec <filealloc>
    80004f08:	00aa3023          	sd	a0,0(s4)
    80004f0c:	c92d                	beqz	a0,80004f7e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f0e:	ffffc097          	auipc	ra,0xffffc
    80004f12:	b48080e7          	jalr	-1208(ra) # 80000a56 <kalloc>
    80004f16:	892a                	mv	s2,a0
    80004f18:	c125                	beqz	a0,80004f78 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f1a:	4985                	li	s3,1
    80004f1c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f20:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f24:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f28:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f2c:	00003597          	auipc	a1,0x3
    80004f30:	7e458593          	addi	a1,a1,2020 # 80008710 <syscalls+0x290>
    80004f34:	ffffc097          	auipc	ra,0xffffc
    80004f38:	d32080e7          	jalr	-718(ra) # 80000c66 <initlock>
  (*f0)->type = FD_PIPE;
    80004f3c:	609c                	ld	a5,0(s1)
    80004f3e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f42:	609c                	ld	a5,0(s1)
    80004f44:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f48:	609c                	ld	a5,0(s1)
    80004f4a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f4e:	609c                	ld	a5,0(s1)
    80004f50:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f54:	000a3783          	ld	a5,0(s4)
    80004f58:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f5c:	000a3783          	ld	a5,0(s4)
    80004f60:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f64:	000a3783          	ld	a5,0(s4)
    80004f68:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f6c:	000a3783          	ld	a5,0(s4)
    80004f70:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f74:	4501                	li	a0,0
    80004f76:	a025                	j	80004f9e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f78:	6088                	ld	a0,0(s1)
    80004f7a:	e501                	bnez	a0,80004f82 <pipealloc+0xaa>
    80004f7c:	a039                	j	80004f8a <pipealloc+0xb2>
    80004f7e:	6088                	ld	a0,0(s1)
    80004f80:	c51d                	beqz	a0,80004fae <pipealloc+0xd6>
    fileclose(*f0);
    80004f82:	00000097          	auipc	ra,0x0
    80004f86:	c26080e7          	jalr	-986(ra) # 80004ba8 <fileclose>
  if(*f1)
    80004f8a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f8e:	557d                	li	a0,-1
  if(*f1)
    80004f90:	c799                	beqz	a5,80004f9e <pipealloc+0xc6>
    fileclose(*f1);
    80004f92:	853e                	mv	a0,a5
    80004f94:	00000097          	auipc	ra,0x0
    80004f98:	c14080e7          	jalr	-1004(ra) # 80004ba8 <fileclose>
  return -1;
    80004f9c:	557d                	li	a0,-1
}
    80004f9e:	70a2                	ld	ra,40(sp)
    80004fa0:	7402                	ld	s0,32(sp)
    80004fa2:	64e2                	ld	s1,24(sp)
    80004fa4:	6942                	ld	s2,16(sp)
    80004fa6:	69a2                	ld	s3,8(sp)
    80004fa8:	6a02                	ld	s4,0(sp)
    80004faa:	6145                	addi	sp,sp,48
    80004fac:	8082                	ret
  return -1;
    80004fae:	557d                	li	a0,-1
    80004fb0:	b7fd                	j	80004f9e <pipealloc+0xc6>

0000000080004fb2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004fb2:	1101                	addi	sp,sp,-32
    80004fb4:	ec06                	sd	ra,24(sp)
    80004fb6:	e822                	sd	s0,16(sp)
    80004fb8:	e426                	sd	s1,8(sp)
    80004fba:	e04a                	sd	s2,0(sp)
    80004fbc:	1000                	addi	s0,sp,32
    80004fbe:	84aa                	mv	s1,a0
    80004fc0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fc2:	ffffc097          	auipc	ra,0xffffc
    80004fc6:	d34080e7          	jalr	-716(ra) # 80000cf6 <acquire>
  if(writable){
    80004fca:	02090d63          	beqz	s2,80005004 <pipeclose+0x52>
    pi->writeopen = 0;
    80004fce:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fd2:	21848513          	addi	a0,s1,536
    80004fd6:	ffffd097          	auipc	ra,0xffffd
    80004fda:	3b4080e7          	jalr	948(ra) # 8000238a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004fde:	2204b783          	ld	a5,544(s1)
    80004fe2:	eb95                	bnez	a5,80005016 <pipeclose+0x64>
    release(&pi->lock);
    80004fe4:	8526                	mv	a0,s1
    80004fe6:	ffffc097          	auipc	ra,0xffffc
    80004fea:	dc4080e7          	jalr	-572(ra) # 80000daa <release>
    kfree((char*)pi);
    80004fee:	8526                	mv	a0,s1
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	b5c080e7          	jalr	-1188(ra) # 80000b4c <kfree>
  } else
    release(&pi->lock);
}
    80004ff8:	60e2                	ld	ra,24(sp)
    80004ffa:	6442                	ld	s0,16(sp)
    80004ffc:	64a2                	ld	s1,8(sp)
    80004ffe:	6902                	ld	s2,0(sp)
    80005000:	6105                	addi	sp,sp,32
    80005002:	8082                	ret
    pi->readopen = 0;
    80005004:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005008:	21c48513          	addi	a0,s1,540
    8000500c:	ffffd097          	auipc	ra,0xffffd
    80005010:	37e080e7          	jalr	894(ra) # 8000238a <wakeup>
    80005014:	b7e9                	j	80004fde <pipeclose+0x2c>
    release(&pi->lock);
    80005016:	8526                	mv	a0,s1
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	d92080e7          	jalr	-622(ra) # 80000daa <release>
}
    80005020:	bfe1                	j	80004ff8 <pipeclose+0x46>

0000000080005022 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005022:	711d                	addi	sp,sp,-96
    80005024:	ec86                	sd	ra,88(sp)
    80005026:	e8a2                	sd	s0,80(sp)
    80005028:	e4a6                	sd	s1,72(sp)
    8000502a:	e0ca                	sd	s2,64(sp)
    8000502c:	fc4e                	sd	s3,56(sp)
    8000502e:	f852                	sd	s4,48(sp)
    80005030:	f456                	sd	s5,40(sp)
    80005032:	f05a                	sd	s6,32(sp)
    80005034:	ec5e                	sd	s7,24(sp)
    80005036:	e862                	sd	s8,16(sp)
    80005038:	1080                	addi	s0,sp,96
    8000503a:	84aa                	mv	s1,a0
    8000503c:	8aae                	mv	s5,a1
    8000503e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005040:	ffffd097          	auipc	ra,0xffffd
    80005044:	ace080e7          	jalr	-1330(ra) # 80001b0e <myproc>
    80005048:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000504a:	8526                	mv	a0,s1
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	caa080e7          	jalr	-854(ra) # 80000cf6 <acquire>
  while(i < n){
    80005054:	0b405663          	blez	s4,80005100 <pipewrite+0xde>
  int i = 0;
    80005058:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000505a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000505c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005060:	21c48b93          	addi	s7,s1,540
    80005064:	a089                	j	800050a6 <pipewrite+0x84>
      release(&pi->lock);
    80005066:	8526                	mv	a0,s1
    80005068:	ffffc097          	auipc	ra,0xffffc
    8000506c:	d42080e7          	jalr	-702(ra) # 80000daa <release>
      return -1;
    80005070:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005072:	854a                	mv	a0,s2
    80005074:	60e6                	ld	ra,88(sp)
    80005076:	6446                	ld	s0,80(sp)
    80005078:	64a6                	ld	s1,72(sp)
    8000507a:	6906                	ld	s2,64(sp)
    8000507c:	79e2                	ld	s3,56(sp)
    8000507e:	7a42                	ld	s4,48(sp)
    80005080:	7aa2                	ld	s5,40(sp)
    80005082:	7b02                	ld	s6,32(sp)
    80005084:	6be2                	ld	s7,24(sp)
    80005086:	6c42                	ld	s8,16(sp)
    80005088:	6125                	addi	sp,sp,96
    8000508a:	8082                	ret
      wakeup(&pi->nread);
    8000508c:	8562                	mv	a0,s8
    8000508e:	ffffd097          	auipc	ra,0xffffd
    80005092:	2fc080e7          	jalr	764(ra) # 8000238a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005096:	85a6                	mv	a1,s1
    80005098:	855e                	mv	a0,s7
    8000509a:	ffffd097          	auipc	ra,0xffffd
    8000509e:	28c080e7          	jalr	652(ra) # 80002326 <sleep>
  while(i < n){
    800050a2:	07495063          	bge	s2,s4,80005102 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800050a6:	2204a783          	lw	a5,544(s1)
    800050aa:	dfd5                	beqz	a5,80005066 <pipewrite+0x44>
    800050ac:	854e                	mv	a0,s3
    800050ae:	ffffd097          	auipc	ra,0xffffd
    800050b2:	52c080e7          	jalr	1324(ra) # 800025da <killed>
    800050b6:	f945                	bnez	a0,80005066 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050b8:	2184a783          	lw	a5,536(s1)
    800050bc:	21c4a703          	lw	a4,540(s1)
    800050c0:	2007879b          	addiw	a5,a5,512
    800050c4:	fcf704e3          	beq	a4,a5,8000508c <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050c8:	4685                	li	a3,1
    800050ca:	01590633          	add	a2,s2,s5
    800050ce:	faf40593          	addi	a1,s0,-81
    800050d2:	0509b503          	ld	a0,80(s3)
    800050d6:	ffffc097          	auipc	ra,0xffffc
    800050da:	780080e7          	jalr	1920(ra) # 80001856 <copyin>
    800050de:	03650263          	beq	a0,s6,80005102 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050e2:	21c4a783          	lw	a5,540(s1)
    800050e6:	0017871b          	addiw	a4,a5,1
    800050ea:	20e4ae23          	sw	a4,540(s1)
    800050ee:	1ff7f793          	andi	a5,a5,511
    800050f2:	97a6                	add	a5,a5,s1
    800050f4:	faf44703          	lbu	a4,-81(s0)
    800050f8:	00e78c23          	sb	a4,24(a5)
      i++;
    800050fc:	2905                	addiw	s2,s2,1
    800050fe:	b755                	j	800050a2 <pipewrite+0x80>
  int i = 0;
    80005100:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005102:	21848513          	addi	a0,s1,536
    80005106:	ffffd097          	auipc	ra,0xffffd
    8000510a:	284080e7          	jalr	644(ra) # 8000238a <wakeup>
  release(&pi->lock);
    8000510e:	8526                	mv	a0,s1
    80005110:	ffffc097          	auipc	ra,0xffffc
    80005114:	c9a080e7          	jalr	-870(ra) # 80000daa <release>
  return i;
    80005118:	bfa9                	j	80005072 <pipewrite+0x50>

000000008000511a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000511a:	715d                	addi	sp,sp,-80
    8000511c:	e486                	sd	ra,72(sp)
    8000511e:	e0a2                	sd	s0,64(sp)
    80005120:	fc26                	sd	s1,56(sp)
    80005122:	f84a                	sd	s2,48(sp)
    80005124:	f44e                	sd	s3,40(sp)
    80005126:	f052                	sd	s4,32(sp)
    80005128:	ec56                	sd	s5,24(sp)
    8000512a:	e85a                	sd	s6,16(sp)
    8000512c:	0880                	addi	s0,sp,80
    8000512e:	84aa                	mv	s1,a0
    80005130:	892e                	mv	s2,a1
    80005132:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005134:	ffffd097          	auipc	ra,0xffffd
    80005138:	9da080e7          	jalr	-1574(ra) # 80001b0e <myproc>
    8000513c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000513e:	8526                	mv	a0,s1
    80005140:	ffffc097          	auipc	ra,0xffffc
    80005144:	bb6080e7          	jalr	-1098(ra) # 80000cf6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005148:	2184a703          	lw	a4,536(s1)
    8000514c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005150:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005154:	02f71763          	bne	a4,a5,80005182 <piperead+0x68>
    80005158:	2244a783          	lw	a5,548(s1)
    8000515c:	c39d                	beqz	a5,80005182 <piperead+0x68>
    if(killed(pr)){
    8000515e:	8552                	mv	a0,s4
    80005160:	ffffd097          	auipc	ra,0xffffd
    80005164:	47a080e7          	jalr	1146(ra) # 800025da <killed>
    80005168:	e941                	bnez	a0,800051f8 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000516a:	85a6                	mv	a1,s1
    8000516c:	854e                	mv	a0,s3
    8000516e:	ffffd097          	auipc	ra,0xffffd
    80005172:	1b8080e7          	jalr	440(ra) # 80002326 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005176:	2184a703          	lw	a4,536(s1)
    8000517a:	21c4a783          	lw	a5,540(s1)
    8000517e:	fcf70de3          	beq	a4,a5,80005158 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005182:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005184:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005186:	05505363          	blez	s5,800051cc <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000518a:	2184a783          	lw	a5,536(s1)
    8000518e:	21c4a703          	lw	a4,540(s1)
    80005192:	02f70d63          	beq	a4,a5,800051cc <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005196:	0017871b          	addiw	a4,a5,1
    8000519a:	20e4ac23          	sw	a4,536(s1)
    8000519e:	1ff7f793          	andi	a5,a5,511
    800051a2:	97a6                	add	a5,a5,s1
    800051a4:	0187c783          	lbu	a5,24(a5)
    800051a8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051ac:	4685                	li	a3,1
    800051ae:	fbf40613          	addi	a2,s0,-65
    800051b2:	85ca                	mv	a1,s2
    800051b4:	050a3503          	ld	a0,80(s4)
    800051b8:	ffffc097          	auipc	ra,0xffffc
    800051bc:	5d6080e7          	jalr	1494(ra) # 8000178e <copyout>
    800051c0:	01650663          	beq	a0,s6,800051cc <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051c4:	2985                	addiw	s3,s3,1
    800051c6:	0905                	addi	s2,s2,1
    800051c8:	fd3a91e3          	bne	s5,s3,8000518a <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051cc:	21c48513          	addi	a0,s1,540
    800051d0:	ffffd097          	auipc	ra,0xffffd
    800051d4:	1ba080e7          	jalr	442(ra) # 8000238a <wakeup>
  release(&pi->lock);
    800051d8:	8526                	mv	a0,s1
    800051da:	ffffc097          	auipc	ra,0xffffc
    800051de:	bd0080e7          	jalr	-1072(ra) # 80000daa <release>
  return i;
}
    800051e2:	854e                	mv	a0,s3
    800051e4:	60a6                	ld	ra,72(sp)
    800051e6:	6406                	ld	s0,64(sp)
    800051e8:	74e2                	ld	s1,56(sp)
    800051ea:	7942                	ld	s2,48(sp)
    800051ec:	79a2                	ld	s3,40(sp)
    800051ee:	7a02                	ld	s4,32(sp)
    800051f0:	6ae2                	ld	s5,24(sp)
    800051f2:	6b42                	ld	s6,16(sp)
    800051f4:	6161                	addi	sp,sp,80
    800051f6:	8082                	ret
      release(&pi->lock);
    800051f8:	8526                	mv	a0,s1
    800051fa:	ffffc097          	auipc	ra,0xffffc
    800051fe:	bb0080e7          	jalr	-1104(ra) # 80000daa <release>
      return -1;
    80005202:	59fd                	li	s3,-1
    80005204:	bff9                	j	800051e2 <piperead+0xc8>

0000000080005206 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005206:	1141                	addi	sp,sp,-16
    80005208:	e422                	sd	s0,8(sp)
    8000520a:	0800                	addi	s0,sp,16
    8000520c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000520e:	8905                	andi	a0,a0,1
    80005210:	c111                	beqz	a0,80005214 <flags2perm+0xe>
      perm = PTE_X;
    80005212:	4521                	li	a0,8
    if(flags & 0x2)
    80005214:	8b89                	andi	a5,a5,2
    80005216:	c399                	beqz	a5,8000521c <flags2perm+0x16>
      perm |= PTE_W;
    80005218:	00456513          	ori	a0,a0,4
    return perm;
}
    8000521c:	6422                	ld	s0,8(sp)
    8000521e:	0141                	addi	sp,sp,16
    80005220:	8082                	ret

0000000080005222 <exec>:

int
exec(char *path, char **argv)
{
    80005222:	de010113          	addi	sp,sp,-544
    80005226:	20113c23          	sd	ra,536(sp)
    8000522a:	20813823          	sd	s0,528(sp)
    8000522e:	20913423          	sd	s1,520(sp)
    80005232:	21213023          	sd	s2,512(sp)
    80005236:	ffce                	sd	s3,504(sp)
    80005238:	fbd2                	sd	s4,496(sp)
    8000523a:	f7d6                	sd	s5,488(sp)
    8000523c:	f3da                	sd	s6,480(sp)
    8000523e:	efde                	sd	s7,472(sp)
    80005240:	ebe2                	sd	s8,464(sp)
    80005242:	e7e6                	sd	s9,456(sp)
    80005244:	e3ea                	sd	s10,448(sp)
    80005246:	ff6e                	sd	s11,440(sp)
    80005248:	1400                	addi	s0,sp,544
    8000524a:	892a                	mv	s2,a0
    8000524c:	dea43423          	sd	a0,-536(s0)
    80005250:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005254:	ffffd097          	auipc	ra,0xffffd
    80005258:	8ba080e7          	jalr	-1862(ra) # 80001b0e <myproc>
    8000525c:	84aa                	mv	s1,a0

  begin_op();
    8000525e:	fffff097          	auipc	ra,0xfffff
    80005262:	47e080e7          	jalr	1150(ra) # 800046dc <begin_op>

  if((ip = namei(path)) == 0){
    80005266:	854a                	mv	a0,s2
    80005268:	fffff097          	auipc	ra,0xfffff
    8000526c:	258080e7          	jalr	600(ra) # 800044c0 <namei>
    80005270:	c93d                	beqz	a0,800052e6 <exec+0xc4>
    80005272:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005274:	fffff097          	auipc	ra,0xfffff
    80005278:	aa6080e7          	jalr	-1370(ra) # 80003d1a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000527c:	04000713          	li	a4,64
    80005280:	4681                	li	a3,0
    80005282:	e5040613          	addi	a2,s0,-432
    80005286:	4581                	li	a1,0
    80005288:	8556                	mv	a0,s5
    8000528a:	fffff097          	auipc	ra,0xfffff
    8000528e:	d44080e7          	jalr	-700(ra) # 80003fce <readi>
    80005292:	04000793          	li	a5,64
    80005296:	00f51a63          	bne	a0,a5,800052aa <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000529a:	e5042703          	lw	a4,-432(s0)
    8000529e:	464c47b7          	lui	a5,0x464c4
    800052a2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052a6:	04f70663          	beq	a4,a5,800052f2 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800052aa:	8556                	mv	a0,s5
    800052ac:	fffff097          	auipc	ra,0xfffff
    800052b0:	cd0080e7          	jalr	-816(ra) # 80003f7c <iunlockput>
    end_op();
    800052b4:	fffff097          	auipc	ra,0xfffff
    800052b8:	4a8080e7          	jalr	1192(ra) # 8000475c <end_op>
  }
  return -1;
    800052bc:	557d                	li	a0,-1
}
    800052be:	21813083          	ld	ra,536(sp)
    800052c2:	21013403          	ld	s0,528(sp)
    800052c6:	20813483          	ld	s1,520(sp)
    800052ca:	20013903          	ld	s2,512(sp)
    800052ce:	79fe                	ld	s3,504(sp)
    800052d0:	7a5e                	ld	s4,496(sp)
    800052d2:	7abe                	ld	s5,488(sp)
    800052d4:	7b1e                	ld	s6,480(sp)
    800052d6:	6bfe                	ld	s7,472(sp)
    800052d8:	6c5e                	ld	s8,464(sp)
    800052da:	6cbe                	ld	s9,456(sp)
    800052dc:	6d1e                	ld	s10,448(sp)
    800052de:	7dfa                	ld	s11,440(sp)
    800052e0:	22010113          	addi	sp,sp,544
    800052e4:	8082                	ret
    end_op();
    800052e6:	fffff097          	auipc	ra,0xfffff
    800052ea:	476080e7          	jalr	1142(ra) # 8000475c <end_op>
    return -1;
    800052ee:	557d                	li	a0,-1
    800052f0:	b7f9                	j	800052be <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800052f2:	8526                	mv	a0,s1
    800052f4:	ffffd097          	auipc	ra,0xffffd
    800052f8:	8de080e7          	jalr	-1826(ra) # 80001bd2 <proc_pagetable>
    800052fc:	8b2a                	mv	s6,a0
    800052fe:	d555                	beqz	a0,800052aa <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005300:	e7042783          	lw	a5,-400(s0)
    80005304:	e8845703          	lhu	a4,-376(s0)
    80005308:	c735                	beqz	a4,80005374 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000530a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000530c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005310:	6a05                	lui	s4,0x1
    80005312:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005316:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000531a:	6d85                	lui	s11,0x1
    8000531c:	7d7d                	lui	s10,0xfffff
    8000531e:	a481                	j	8000555e <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005320:	00003517          	auipc	a0,0x3
    80005324:	3f850513          	addi	a0,a0,1016 # 80008718 <syscalls+0x298>
    80005328:	ffffb097          	auipc	ra,0xffffb
    8000532c:	216080e7          	jalr	534(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005330:	874a                	mv	a4,s2
    80005332:	009c86bb          	addw	a3,s9,s1
    80005336:	4581                	li	a1,0
    80005338:	8556                	mv	a0,s5
    8000533a:	fffff097          	auipc	ra,0xfffff
    8000533e:	c94080e7          	jalr	-876(ra) # 80003fce <readi>
    80005342:	2501                	sext.w	a0,a0
    80005344:	1aa91a63          	bne	s2,a0,800054f8 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80005348:	009d84bb          	addw	s1,s11,s1
    8000534c:	013d09bb          	addw	s3,s10,s3
    80005350:	1f74f763          	bgeu	s1,s7,8000553e <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80005354:	02049593          	slli	a1,s1,0x20
    80005358:	9181                	srli	a1,a1,0x20
    8000535a:	95e2                	add	a1,a1,s8
    8000535c:	855a                	mv	a0,s6
    8000535e:	ffffc097          	auipc	ra,0xffffc
    80005362:	e1e080e7          	jalr	-482(ra) # 8000117c <walkaddr>
    80005366:	862a                	mv	a2,a0
    if(pa == 0)
    80005368:	dd45                	beqz	a0,80005320 <exec+0xfe>
      n = PGSIZE;
    8000536a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000536c:	fd49f2e3          	bgeu	s3,s4,80005330 <exec+0x10e>
      n = sz - i;
    80005370:	894e                	mv	s2,s3
    80005372:	bf7d                	j	80005330 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005374:	4901                	li	s2,0
  iunlockput(ip);
    80005376:	8556                	mv	a0,s5
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	c04080e7          	jalr	-1020(ra) # 80003f7c <iunlockput>
  end_op();
    80005380:	fffff097          	auipc	ra,0xfffff
    80005384:	3dc080e7          	jalr	988(ra) # 8000475c <end_op>
  p = myproc();
    80005388:	ffffc097          	auipc	ra,0xffffc
    8000538c:	786080e7          	jalr	1926(ra) # 80001b0e <myproc>
    80005390:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005392:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005396:	6785                	lui	a5,0x1
    80005398:	17fd                	addi	a5,a5,-1
    8000539a:	993e                	add	s2,s2,a5
    8000539c:	77fd                	lui	a5,0xfffff
    8000539e:	00f977b3          	and	a5,s2,a5
    800053a2:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800053a6:	4691                	li	a3,4
    800053a8:	6609                	lui	a2,0x2
    800053aa:	963e                	add	a2,a2,a5
    800053ac:	85be                	mv	a1,a5
    800053ae:	855a                	mv	a0,s6
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	180080e7          	jalr	384(ra) # 80001530 <uvmalloc>
    800053b8:	8c2a                	mv	s8,a0
  ip = 0;
    800053ba:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800053bc:	12050e63          	beqz	a0,800054f8 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800053c0:	75f9                	lui	a1,0xffffe
    800053c2:	95aa                	add	a1,a1,a0
    800053c4:	855a                	mv	a0,s6
    800053c6:	ffffc097          	auipc	ra,0xffffc
    800053ca:	396080e7          	jalr	918(ra) # 8000175c <uvmclear>
  stackbase = sp - PGSIZE;
    800053ce:	7afd                	lui	s5,0xfffff
    800053d0:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800053d2:	df043783          	ld	a5,-528(s0)
    800053d6:	6388                	ld	a0,0(a5)
    800053d8:	c925                	beqz	a0,80005448 <exec+0x226>
    800053da:	e9040993          	addi	s3,s0,-368
    800053de:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800053e2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053e4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053e6:	ffffc097          	auipc	ra,0xffffc
    800053ea:	b88080e7          	jalr	-1144(ra) # 80000f6e <strlen>
    800053ee:	0015079b          	addiw	a5,a0,1
    800053f2:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053f6:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800053fa:	13596663          	bltu	s2,s5,80005526 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053fe:	df043d83          	ld	s11,-528(s0)
    80005402:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005406:	8552                	mv	a0,s4
    80005408:	ffffc097          	auipc	ra,0xffffc
    8000540c:	b66080e7          	jalr	-1178(ra) # 80000f6e <strlen>
    80005410:	0015069b          	addiw	a3,a0,1
    80005414:	8652                	mv	a2,s4
    80005416:	85ca                	mv	a1,s2
    80005418:	855a                	mv	a0,s6
    8000541a:	ffffc097          	auipc	ra,0xffffc
    8000541e:	374080e7          	jalr	884(ra) # 8000178e <copyout>
    80005422:	10054663          	bltz	a0,8000552e <exec+0x30c>
    ustack[argc] = sp;
    80005426:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000542a:	0485                	addi	s1,s1,1
    8000542c:	008d8793          	addi	a5,s11,8
    80005430:	def43823          	sd	a5,-528(s0)
    80005434:	008db503          	ld	a0,8(s11)
    80005438:	c911                	beqz	a0,8000544c <exec+0x22a>
    if(argc >= MAXARG)
    8000543a:	09a1                	addi	s3,s3,8
    8000543c:	fb3c95e3          	bne	s9,s3,800053e6 <exec+0x1c4>
  sz = sz1;
    80005440:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005444:	4a81                	li	s5,0
    80005446:	a84d                	j	800054f8 <exec+0x2d6>
  sp = sz;
    80005448:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000544a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000544c:	00349793          	slli	a5,s1,0x3
    80005450:	f9040713          	addi	a4,s0,-112
    80005454:	97ba                	add	a5,a5,a4
    80005456:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7fdbc758>
  sp -= (argc+1) * sizeof(uint64);
    8000545a:	00148693          	addi	a3,s1,1
    8000545e:	068e                	slli	a3,a3,0x3
    80005460:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005464:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005468:	01597663          	bgeu	s2,s5,80005474 <exec+0x252>
  sz = sz1;
    8000546c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005470:	4a81                	li	s5,0
    80005472:	a059                	j	800054f8 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005474:	e9040613          	addi	a2,s0,-368
    80005478:	85ca                	mv	a1,s2
    8000547a:	855a                	mv	a0,s6
    8000547c:	ffffc097          	auipc	ra,0xffffc
    80005480:	312080e7          	jalr	786(ra) # 8000178e <copyout>
    80005484:	0a054963          	bltz	a0,80005536 <exec+0x314>
  p->trapframe->a1 = sp;
    80005488:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    8000548c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005490:	de843783          	ld	a5,-536(s0)
    80005494:	0007c703          	lbu	a4,0(a5)
    80005498:	cf11                	beqz	a4,800054b4 <exec+0x292>
    8000549a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000549c:	02f00693          	li	a3,47
    800054a0:	a039                	j	800054ae <exec+0x28c>
      last = s+1;
    800054a2:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800054a6:	0785                	addi	a5,a5,1
    800054a8:	fff7c703          	lbu	a4,-1(a5)
    800054ac:	c701                	beqz	a4,800054b4 <exec+0x292>
    if(*s == '/')
    800054ae:	fed71ce3          	bne	a4,a3,800054a6 <exec+0x284>
    800054b2:	bfc5                	j	800054a2 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    800054b4:	4641                	li	a2,16
    800054b6:	de843583          	ld	a1,-536(s0)
    800054ba:	158b8513          	addi	a0,s7,344
    800054be:	ffffc097          	auipc	ra,0xffffc
    800054c2:	a7e080e7          	jalr	-1410(ra) # 80000f3c <safestrcpy>
  oldpagetable = p->pagetable;
    800054c6:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800054ca:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800054ce:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800054d2:	058bb783          	ld	a5,88(s7)
    800054d6:	e6843703          	ld	a4,-408(s0)
    800054da:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054dc:	058bb783          	ld	a5,88(s7)
    800054e0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054e4:	85ea                	mv	a1,s10
    800054e6:	ffffc097          	auipc	ra,0xffffc
    800054ea:	788080e7          	jalr	1928(ra) # 80001c6e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054ee:	0004851b          	sext.w	a0,s1
    800054f2:	b3f1                	j	800052be <exec+0x9c>
    800054f4:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800054f8:	df843583          	ld	a1,-520(s0)
    800054fc:	855a                	mv	a0,s6
    800054fe:	ffffc097          	auipc	ra,0xffffc
    80005502:	770080e7          	jalr	1904(ra) # 80001c6e <proc_freepagetable>
  if(ip){
    80005506:	da0a92e3          	bnez	s5,800052aa <exec+0x88>
  return -1;
    8000550a:	557d                	li	a0,-1
    8000550c:	bb4d                	j	800052be <exec+0x9c>
    8000550e:	df243c23          	sd	s2,-520(s0)
    80005512:	b7dd                	j	800054f8 <exec+0x2d6>
    80005514:	df243c23          	sd	s2,-520(s0)
    80005518:	b7c5                	j	800054f8 <exec+0x2d6>
    8000551a:	df243c23          	sd	s2,-520(s0)
    8000551e:	bfe9                	j	800054f8 <exec+0x2d6>
    80005520:	df243c23          	sd	s2,-520(s0)
    80005524:	bfd1                	j	800054f8 <exec+0x2d6>
  sz = sz1;
    80005526:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000552a:	4a81                	li	s5,0
    8000552c:	b7f1                	j	800054f8 <exec+0x2d6>
  sz = sz1;
    8000552e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005532:	4a81                	li	s5,0
    80005534:	b7d1                	j	800054f8 <exec+0x2d6>
  sz = sz1;
    80005536:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000553a:	4a81                	li	s5,0
    8000553c:	bf75                	j	800054f8 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000553e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005542:	e0843783          	ld	a5,-504(s0)
    80005546:	0017869b          	addiw	a3,a5,1
    8000554a:	e0d43423          	sd	a3,-504(s0)
    8000554e:	e0043783          	ld	a5,-512(s0)
    80005552:	0387879b          	addiw	a5,a5,56
    80005556:	e8845703          	lhu	a4,-376(s0)
    8000555a:	e0e6dee3          	bge	a3,a4,80005376 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000555e:	2781                	sext.w	a5,a5
    80005560:	e0f43023          	sd	a5,-512(s0)
    80005564:	03800713          	li	a4,56
    80005568:	86be                	mv	a3,a5
    8000556a:	e1840613          	addi	a2,s0,-488
    8000556e:	4581                	li	a1,0
    80005570:	8556                	mv	a0,s5
    80005572:	fffff097          	auipc	ra,0xfffff
    80005576:	a5c080e7          	jalr	-1444(ra) # 80003fce <readi>
    8000557a:	03800793          	li	a5,56
    8000557e:	f6f51be3          	bne	a0,a5,800054f4 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80005582:	e1842783          	lw	a5,-488(s0)
    80005586:	4705                	li	a4,1
    80005588:	fae79de3          	bne	a5,a4,80005542 <exec+0x320>
    if(ph.memsz < ph.filesz)
    8000558c:	e4043483          	ld	s1,-448(s0)
    80005590:	e3843783          	ld	a5,-456(s0)
    80005594:	f6f4ede3          	bltu	s1,a5,8000550e <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005598:	e2843783          	ld	a5,-472(s0)
    8000559c:	94be                	add	s1,s1,a5
    8000559e:	f6f4ebe3          	bltu	s1,a5,80005514 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    800055a2:	de043703          	ld	a4,-544(s0)
    800055a6:	8ff9                	and	a5,a5,a4
    800055a8:	fbad                	bnez	a5,8000551a <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055aa:	e1c42503          	lw	a0,-484(s0)
    800055ae:	00000097          	auipc	ra,0x0
    800055b2:	c58080e7          	jalr	-936(ra) # 80005206 <flags2perm>
    800055b6:	86aa                	mv	a3,a0
    800055b8:	8626                	mv	a2,s1
    800055ba:	85ca                	mv	a1,s2
    800055bc:	855a                	mv	a0,s6
    800055be:	ffffc097          	auipc	ra,0xffffc
    800055c2:	f72080e7          	jalr	-142(ra) # 80001530 <uvmalloc>
    800055c6:	dea43c23          	sd	a0,-520(s0)
    800055ca:	d939                	beqz	a0,80005520 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800055cc:	e2843c03          	ld	s8,-472(s0)
    800055d0:	e2042c83          	lw	s9,-480(s0)
    800055d4:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055d8:	f60b83e3          	beqz	s7,8000553e <exec+0x31c>
    800055dc:	89de                	mv	s3,s7
    800055de:	4481                	li	s1,0
    800055e0:	bb95                	j	80005354 <exec+0x132>

00000000800055e2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055e2:	7179                	addi	sp,sp,-48
    800055e4:	f406                	sd	ra,40(sp)
    800055e6:	f022                	sd	s0,32(sp)
    800055e8:	ec26                	sd	s1,24(sp)
    800055ea:	e84a                	sd	s2,16(sp)
    800055ec:	1800                	addi	s0,sp,48
    800055ee:	892e                	mv	s2,a1
    800055f0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800055f2:	fdc40593          	addi	a1,s0,-36
    800055f6:	ffffe097          	auipc	ra,0xffffe
    800055fa:	a96080e7          	jalr	-1386(ra) # 8000308c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055fe:	fdc42703          	lw	a4,-36(s0)
    80005602:	47bd                	li	a5,15
    80005604:	02e7eb63          	bltu	a5,a4,8000563a <argfd+0x58>
    80005608:	ffffc097          	auipc	ra,0xffffc
    8000560c:	506080e7          	jalr	1286(ra) # 80001b0e <myproc>
    80005610:	fdc42703          	lw	a4,-36(s0)
    80005614:	01a70793          	addi	a5,a4,26
    80005618:	078e                	slli	a5,a5,0x3
    8000561a:	953e                	add	a0,a0,a5
    8000561c:	611c                	ld	a5,0(a0)
    8000561e:	c385                	beqz	a5,8000563e <argfd+0x5c>
    return -1;
  if(pfd)
    80005620:	00090463          	beqz	s2,80005628 <argfd+0x46>
    *pfd = fd;
    80005624:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005628:	4501                	li	a0,0
  if(pf)
    8000562a:	c091                	beqz	s1,8000562e <argfd+0x4c>
    *pf = f;
    8000562c:	e09c                	sd	a5,0(s1)
}
    8000562e:	70a2                	ld	ra,40(sp)
    80005630:	7402                	ld	s0,32(sp)
    80005632:	64e2                	ld	s1,24(sp)
    80005634:	6942                	ld	s2,16(sp)
    80005636:	6145                	addi	sp,sp,48
    80005638:	8082                	ret
    return -1;
    8000563a:	557d                	li	a0,-1
    8000563c:	bfcd                	j	8000562e <argfd+0x4c>
    8000563e:	557d                	li	a0,-1
    80005640:	b7fd                	j	8000562e <argfd+0x4c>

0000000080005642 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005642:	1101                	addi	sp,sp,-32
    80005644:	ec06                	sd	ra,24(sp)
    80005646:	e822                	sd	s0,16(sp)
    80005648:	e426                	sd	s1,8(sp)
    8000564a:	1000                	addi	s0,sp,32
    8000564c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000564e:	ffffc097          	auipc	ra,0xffffc
    80005652:	4c0080e7          	jalr	1216(ra) # 80001b0e <myproc>
    80005656:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005658:	0d050793          	addi	a5,a0,208
    8000565c:	4501                	li	a0,0
    8000565e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005660:	6398                	ld	a4,0(a5)
    80005662:	cb19                	beqz	a4,80005678 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005664:	2505                	addiw	a0,a0,1
    80005666:	07a1                	addi	a5,a5,8
    80005668:	fed51ce3          	bne	a0,a3,80005660 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000566c:	557d                	li	a0,-1
}
    8000566e:	60e2                	ld	ra,24(sp)
    80005670:	6442                	ld	s0,16(sp)
    80005672:	64a2                	ld	s1,8(sp)
    80005674:	6105                	addi	sp,sp,32
    80005676:	8082                	ret
      p->ofile[fd] = f;
    80005678:	01a50793          	addi	a5,a0,26
    8000567c:	078e                	slli	a5,a5,0x3
    8000567e:	963e                	add	a2,a2,a5
    80005680:	e204                	sd	s1,0(a2)
      return fd;
    80005682:	b7f5                	j	8000566e <fdalloc+0x2c>

0000000080005684 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005684:	715d                	addi	sp,sp,-80
    80005686:	e486                	sd	ra,72(sp)
    80005688:	e0a2                	sd	s0,64(sp)
    8000568a:	fc26                	sd	s1,56(sp)
    8000568c:	f84a                	sd	s2,48(sp)
    8000568e:	f44e                	sd	s3,40(sp)
    80005690:	f052                	sd	s4,32(sp)
    80005692:	ec56                	sd	s5,24(sp)
    80005694:	e85a                	sd	s6,16(sp)
    80005696:	0880                	addi	s0,sp,80
    80005698:	8b2e                	mv	s6,a1
    8000569a:	89b2                	mv	s3,a2
    8000569c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000569e:	fb040593          	addi	a1,s0,-80
    800056a2:	fffff097          	auipc	ra,0xfffff
    800056a6:	e3c080e7          	jalr	-452(ra) # 800044de <nameiparent>
    800056aa:	84aa                	mv	s1,a0
    800056ac:	14050f63          	beqz	a0,8000580a <create+0x186>
    return 0;

  ilock(dp);
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	66a080e7          	jalr	1642(ra) # 80003d1a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056b8:	4601                	li	a2,0
    800056ba:	fb040593          	addi	a1,s0,-80
    800056be:	8526                	mv	a0,s1
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	b3e080e7          	jalr	-1218(ra) # 800041fe <dirlookup>
    800056c8:	8aaa                	mv	s5,a0
    800056ca:	c931                	beqz	a0,8000571e <create+0x9a>
    iunlockput(dp);
    800056cc:	8526                	mv	a0,s1
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	8ae080e7          	jalr	-1874(ra) # 80003f7c <iunlockput>
    ilock(ip);
    800056d6:	8556                	mv	a0,s5
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	642080e7          	jalr	1602(ra) # 80003d1a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056e0:	000b059b          	sext.w	a1,s6
    800056e4:	4789                	li	a5,2
    800056e6:	02f59563          	bne	a1,a5,80005710 <create+0x8c>
    800056ea:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fdbc89c>
    800056ee:	37f9                	addiw	a5,a5,-2
    800056f0:	17c2                	slli	a5,a5,0x30
    800056f2:	93c1                	srli	a5,a5,0x30
    800056f4:	4705                	li	a4,1
    800056f6:	00f76d63          	bltu	a4,a5,80005710 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800056fa:	8556                	mv	a0,s5
    800056fc:	60a6                	ld	ra,72(sp)
    800056fe:	6406                	ld	s0,64(sp)
    80005700:	74e2                	ld	s1,56(sp)
    80005702:	7942                	ld	s2,48(sp)
    80005704:	79a2                	ld	s3,40(sp)
    80005706:	7a02                	ld	s4,32(sp)
    80005708:	6ae2                	ld	s5,24(sp)
    8000570a:	6b42                	ld	s6,16(sp)
    8000570c:	6161                	addi	sp,sp,80
    8000570e:	8082                	ret
    iunlockput(ip);
    80005710:	8556                	mv	a0,s5
    80005712:	fffff097          	auipc	ra,0xfffff
    80005716:	86a080e7          	jalr	-1942(ra) # 80003f7c <iunlockput>
    return 0;
    8000571a:	4a81                	li	s5,0
    8000571c:	bff9                	j	800056fa <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000571e:	85da                	mv	a1,s6
    80005720:	4088                	lw	a0,0(s1)
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	45c080e7          	jalr	1116(ra) # 80003b7e <ialloc>
    8000572a:	8a2a                	mv	s4,a0
    8000572c:	c539                	beqz	a0,8000577a <create+0xf6>
  ilock(ip);
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	5ec080e7          	jalr	1516(ra) # 80003d1a <ilock>
  ip->major = major;
    80005736:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000573a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000573e:	4905                	li	s2,1
    80005740:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005744:	8552                	mv	a0,s4
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	50a080e7          	jalr	1290(ra) # 80003c50 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000574e:	000b059b          	sext.w	a1,s6
    80005752:	03258b63          	beq	a1,s2,80005788 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005756:	004a2603          	lw	a2,4(s4)
    8000575a:	fb040593          	addi	a1,s0,-80
    8000575e:	8526                	mv	a0,s1
    80005760:	fffff097          	auipc	ra,0xfffff
    80005764:	cae080e7          	jalr	-850(ra) # 8000440e <dirlink>
    80005768:	06054f63          	bltz	a0,800057e6 <create+0x162>
  iunlockput(dp);
    8000576c:	8526                	mv	a0,s1
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	80e080e7          	jalr	-2034(ra) # 80003f7c <iunlockput>
  return ip;
    80005776:	8ad2                	mv	s5,s4
    80005778:	b749                	j	800056fa <create+0x76>
    iunlockput(dp);
    8000577a:	8526                	mv	a0,s1
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	800080e7          	jalr	-2048(ra) # 80003f7c <iunlockput>
    return 0;
    80005784:	8ad2                	mv	s5,s4
    80005786:	bf95                	j	800056fa <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005788:	004a2603          	lw	a2,4(s4)
    8000578c:	00003597          	auipc	a1,0x3
    80005790:	fac58593          	addi	a1,a1,-84 # 80008738 <syscalls+0x2b8>
    80005794:	8552                	mv	a0,s4
    80005796:	fffff097          	auipc	ra,0xfffff
    8000579a:	c78080e7          	jalr	-904(ra) # 8000440e <dirlink>
    8000579e:	04054463          	bltz	a0,800057e6 <create+0x162>
    800057a2:	40d0                	lw	a2,4(s1)
    800057a4:	00003597          	auipc	a1,0x3
    800057a8:	f9c58593          	addi	a1,a1,-100 # 80008740 <syscalls+0x2c0>
    800057ac:	8552                	mv	a0,s4
    800057ae:	fffff097          	auipc	ra,0xfffff
    800057b2:	c60080e7          	jalr	-928(ra) # 8000440e <dirlink>
    800057b6:	02054863          	bltz	a0,800057e6 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800057ba:	004a2603          	lw	a2,4(s4)
    800057be:	fb040593          	addi	a1,s0,-80
    800057c2:	8526                	mv	a0,s1
    800057c4:	fffff097          	auipc	ra,0xfffff
    800057c8:	c4a080e7          	jalr	-950(ra) # 8000440e <dirlink>
    800057cc:	00054d63          	bltz	a0,800057e6 <create+0x162>
    dp->nlink++;  // for ".."
    800057d0:	04a4d783          	lhu	a5,74(s1)
    800057d4:	2785                	addiw	a5,a5,1
    800057d6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057da:	8526                	mv	a0,s1
    800057dc:	ffffe097          	auipc	ra,0xffffe
    800057e0:	474080e7          	jalr	1140(ra) # 80003c50 <iupdate>
    800057e4:	b761                	j	8000576c <create+0xe8>
  ip->nlink = 0;
    800057e6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800057ea:	8552                	mv	a0,s4
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	464080e7          	jalr	1124(ra) # 80003c50 <iupdate>
  iunlockput(ip);
    800057f4:	8552                	mv	a0,s4
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	786080e7          	jalr	1926(ra) # 80003f7c <iunlockput>
  iunlockput(dp);
    800057fe:	8526                	mv	a0,s1
    80005800:	ffffe097          	auipc	ra,0xffffe
    80005804:	77c080e7          	jalr	1916(ra) # 80003f7c <iunlockput>
  return 0;
    80005808:	bdcd                	j	800056fa <create+0x76>
    return 0;
    8000580a:	8aaa                	mv	s5,a0
    8000580c:	b5fd                	j	800056fa <create+0x76>

000000008000580e <sys_dup>:
{
    8000580e:	7179                	addi	sp,sp,-48
    80005810:	f406                	sd	ra,40(sp)
    80005812:	f022                	sd	s0,32(sp)
    80005814:	ec26                	sd	s1,24(sp)
    80005816:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005818:	fd840613          	addi	a2,s0,-40
    8000581c:	4581                	li	a1,0
    8000581e:	4501                	li	a0,0
    80005820:	00000097          	auipc	ra,0x0
    80005824:	dc2080e7          	jalr	-574(ra) # 800055e2 <argfd>
    return -1;
    80005828:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000582a:	02054363          	bltz	a0,80005850 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000582e:	fd843503          	ld	a0,-40(s0)
    80005832:	00000097          	auipc	ra,0x0
    80005836:	e10080e7          	jalr	-496(ra) # 80005642 <fdalloc>
    8000583a:	84aa                	mv	s1,a0
    return -1;
    8000583c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000583e:	00054963          	bltz	a0,80005850 <sys_dup+0x42>
  filedup(f);
    80005842:	fd843503          	ld	a0,-40(s0)
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	310080e7          	jalr	784(ra) # 80004b56 <filedup>
  return fd;
    8000584e:	87a6                	mv	a5,s1
}
    80005850:	853e                	mv	a0,a5
    80005852:	70a2                	ld	ra,40(sp)
    80005854:	7402                	ld	s0,32(sp)
    80005856:	64e2                	ld	s1,24(sp)
    80005858:	6145                	addi	sp,sp,48
    8000585a:	8082                	ret

000000008000585c <sys_getreadcount>:
{
    8000585c:	1141                	addi	sp,sp,-16
    8000585e:	e422                	sd	s0,8(sp)
    80005860:	0800                	addi	s0,sp,16
}
    80005862:	00003517          	auipc	a0,0x3
    80005866:	0b252503          	lw	a0,178(a0) # 80008914 <readCount>
    8000586a:	6422                	ld	s0,8(sp)
    8000586c:	0141                	addi	sp,sp,16
    8000586e:	8082                	ret

0000000080005870 <sys_read>:
{
    80005870:	7179                	addi	sp,sp,-48
    80005872:	f406                	sd	ra,40(sp)
    80005874:	f022                	sd	s0,32(sp)
    80005876:	1800                	addi	s0,sp,48
  readCount++;
    80005878:	00003717          	auipc	a4,0x3
    8000587c:	09c70713          	addi	a4,a4,156 # 80008914 <readCount>
    80005880:	431c                	lw	a5,0(a4)
    80005882:	2785                	addiw	a5,a5,1
    80005884:	c31c                	sw	a5,0(a4)
  argaddr(1, &p);
    80005886:	fd840593          	addi	a1,s0,-40
    8000588a:	4505                	li	a0,1
    8000588c:	ffffe097          	auipc	ra,0xffffe
    80005890:	820080e7          	jalr	-2016(ra) # 800030ac <argaddr>
  argint(2, &n);
    80005894:	fe440593          	addi	a1,s0,-28
    80005898:	4509                	li	a0,2
    8000589a:	ffffd097          	auipc	ra,0xffffd
    8000589e:	7f2080e7          	jalr	2034(ra) # 8000308c <argint>
  if(argfd(0, 0, &f) < 0)
    800058a2:	fe840613          	addi	a2,s0,-24
    800058a6:	4581                	li	a1,0
    800058a8:	4501                	li	a0,0
    800058aa:	00000097          	auipc	ra,0x0
    800058ae:	d38080e7          	jalr	-712(ra) # 800055e2 <argfd>
    800058b2:	87aa                	mv	a5,a0
    return -1;
    800058b4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058b6:	0007cc63          	bltz	a5,800058ce <sys_read+0x5e>
  return fileread(f, p, n);
    800058ba:	fe442603          	lw	a2,-28(s0)
    800058be:	fd843583          	ld	a1,-40(s0)
    800058c2:	fe843503          	ld	a0,-24(s0)
    800058c6:	fffff097          	auipc	ra,0xfffff
    800058ca:	41c080e7          	jalr	1052(ra) # 80004ce2 <fileread>
}
    800058ce:	70a2                	ld	ra,40(sp)
    800058d0:	7402                	ld	s0,32(sp)
    800058d2:	6145                	addi	sp,sp,48
    800058d4:	8082                	ret

00000000800058d6 <sys_write>:
{
    800058d6:	7179                	addi	sp,sp,-48
    800058d8:	f406                	sd	ra,40(sp)
    800058da:	f022                	sd	s0,32(sp)
    800058dc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800058de:	fd840593          	addi	a1,s0,-40
    800058e2:	4505                	li	a0,1
    800058e4:	ffffd097          	auipc	ra,0xffffd
    800058e8:	7c8080e7          	jalr	1992(ra) # 800030ac <argaddr>
  argint(2, &n);
    800058ec:	fe440593          	addi	a1,s0,-28
    800058f0:	4509                	li	a0,2
    800058f2:	ffffd097          	auipc	ra,0xffffd
    800058f6:	79a080e7          	jalr	1946(ra) # 8000308c <argint>
  if(argfd(0, 0, &f) < 0)
    800058fa:	fe840613          	addi	a2,s0,-24
    800058fe:	4581                	li	a1,0
    80005900:	4501                	li	a0,0
    80005902:	00000097          	auipc	ra,0x0
    80005906:	ce0080e7          	jalr	-800(ra) # 800055e2 <argfd>
    8000590a:	87aa                	mv	a5,a0
    return -1;
    8000590c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000590e:	0007cc63          	bltz	a5,80005926 <sys_write+0x50>
  return filewrite(f, p, n);
    80005912:	fe442603          	lw	a2,-28(s0)
    80005916:	fd843583          	ld	a1,-40(s0)
    8000591a:	fe843503          	ld	a0,-24(s0)
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	486080e7          	jalr	1158(ra) # 80004da4 <filewrite>
}
    80005926:	70a2                	ld	ra,40(sp)
    80005928:	7402                	ld	s0,32(sp)
    8000592a:	6145                	addi	sp,sp,48
    8000592c:	8082                	ret

000000008000592e <sys_close>:
{
    8000592e:	1101                	addi	sp,sp,-32
    80005930:	ec06                	sd	ra,24(sp)
    80005932:	e822                	sd	s0,16(sp)
    80005934:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005936:	fe040613          	addi	a2,s0,-32
    8000593a:	fec40593          	addi	a1,s0,-20
    8000593e:	4501                	li	a0,0
    80005940:	00000097          	auipc	ra,0x0
    80005944:	ca2080e7          	jalr	-862(ra) # 800055e2 <argfd>
    return -1;
    80005948:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000594a:	02054463          	bltz	a0,80005972 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000594e:	ffffc097          	auipc	ra,0xffffc
    80005952:	1c0080e7          	jalr	448(ra) # 80001b0e <myproc>
    80005956:	fec42783          	lw	a5,-20(s0)
    8000595a:	07e9                	addi	a5,a5,26
    8000595c:	078e                	slli	a5,a5,0x3
    8000595e:	97aa                	add	a5,a5,a0
    80005960:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005964:	fe043503          	ld	a0,-32(s0)
    80005968:	fffff097          	auipc	ra,0xfffff
    8000596c:	240080e7          	jalr	576(ra) # 80004ba8 <fileclose>
  return 0;
    80005970:	4781                	li	a5,0
}
    80005972:	853e                	mv	a0,a5
    80005974:	60e2                	ld	ra,24(sp)
    80005976:	6442                	ld	s0,16(sp)
    80005978:	6105                	addi	sp,sp,32
    8000597a:	8082                	ret

000000008000597c <sys_fstat>:
{
    8000597c:	1101                	addi	sp,sp,-32
    8000597e:	ec06                	sd	ra,24(sp)
    80005980:	e822                	sd	s0,16(sp)
    80005982:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005984:	fe040593          	addi	a1,s0,-32
    80005988:	4505                	li	a0,1
    8000598a:	ffffd097          	auipc	ra,0xffffd
    8000598e:	722080e7          	jalr	1826(ra) # 800030ac <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005992:	fe840613          	addi	a2,s0,-24
    80005996:	4581                	li	a1,0
    80005998:	4501                	li	a0,0
    8000599a:	00000097          	auipc	ra,0x0
    8000599e:	c48080e7          	jalr	-952(ra) # 800055e2 <argfd>
    800059a2:	87aa                	mv	a5,a0
    return -1;
    800059a4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800059a6:	0007ca63          	bltz	a5,800059ba <sys_fstat+0x3e>
  return filestat(f, st);
    800059aa:	fe043583          	ld	a1,-32(s0)
    800059ae:	fe843503          	ld	a0,-24(s0)
    800059b2:	fffff097          	auipc	ra,0xfffff
    800059b6:	2be080e7          	jalr	702(ra) # 80004c70 <filestat>
}
    800059ba:	60e2                	ld	ra,24(sp)
    800059bc:	6442                	ld	s0,16(sp)
    800059be:	6105                	addi	sp,sp,32
    800059c0:	8082                	ret

00000000800059c2 <sys_link>:
{
    800059c2:	7169                	addi	sp,sp,-304
    800059c4:	f606                	sd	ra,296(sp)
    800059c6:	f222                	sd	s0,288(sp)
    800059c8:	ee26                	sd	s1,280(sp)
    800059ca:	ea4a                	sd	s2,272(sp)
    800059cc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059ce:	08000613          	li	a2,128
    800059d2:	ed040593          	addi	a1,s0,-304
    800059d6:	4501                	li	a0,0
    800059d8:	ffffd097          	auipc	ra,0xffffd
    800059dc:	6f4080e7          	jalr	1780(ra) # 800030cc <argstr>
    return -1;
    800059e0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059e2:	10054e63          	bltz	a0,80005afe <sys_link+0x13c>
    800059e6:	08000613          	li	a2,128
    800059ea:	f5040593          	addi	a1,s0,-176
    800059ee:	4505                	li	a0,1
    800059f0:	ffffd097          	auipc	ra,0xffffd
    800059f4:	6dc080e7          	jalr	1756(ra) # 800030cc <argstr>
    return -1;
    800059f8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059fa:	10054263          	bltz	a0,80005afe <sys_link+0x13c>
  begin_op();
    800059fe:	fffff097          	auipc	ra,0xfffff
    80005a02:	cde080e7          	jalr	-802(ra) # 800046dc <begin_op>
  if((ip = namei(old)) == 0){
    80005a06:	ed040513          	addi	a0,s0,-304
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	ab6080e7          	jalr	-1354(ra) # 800044c0 <namei>
    80005a12:	84aa                	mv	s1,a0
    80005a14:	c551                	beqz	a0,80005aa0 <sys_link+0xde>
  ilock(ip);
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	304080e7          	jalr	772(ra) # 80003d1a <ilock>
  if(ip->type == T_DIR){
    80005a1e:	04449703          	lh	a4,68(s1)
    80005a22:	4785                	li	a5,1
    80005a24:	08f70463          	beq	a4,a5,80005aac <sys_link+0xea>
  ip->nlink++;
    80005a28:	04a4d783          	lhu	a5,74(s1)
    80005a2c:	2785                	addiw	a5,a5,1
    80005a2e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a32:	8526                	mv	a0,s1
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	21c080e7          	jalr	540(ra) # 80003c50 <iupdate>
  iunlock(ip);
    80005a3c:	8526                	mv	a0,s1
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	39e080e7          	jalr	926(ra) # 80003ddc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a46:	fd040593          	addi	a1,s0,-48
    80005a4a:	f5040513          	addi	a0,s0,-176
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	a90080e7          	jalr	-1392(ra) # 800044de <nameiparent>
    80005a56:	892a                	mv	s2,a0
    80005a58:	c935                	beqz	a0,80005acc <sys_link+0x10a>
  ilock(dp);
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	2c0080e7          	jalr	704(ra) # 80003d1a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a62:	00092703          	lw	a4,0(s2)
    80005a66:	409c                	lw	a5,0(s1)
    80005a68:	04f71d63          	bne	a4,a5,80005ac2 <sys_link+0x100>
    80005a6c:	40d0                	lw	a2,4(s1)
    80005a6e:	fd040593          	addi	a1,s0,-48
    80005a72:	854a                	mv	a0,s2
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	99a080e7          	jalr	-1638(ra) # 8000440e <dirlink>
    80005a7c:	04054363          	bltz	a0,80005ac2 <sys_link+0x100>
  iunlockput(dp);
    80005a80:	854a                	mv	a0,s2
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	4fa080e7          	jalr	1274(ra) # 80003f7c <iunlockput>
  iput(ip);
    80005a8a:	8526                	mv	a0,s1
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	448080e7          	jalr	1096(ra) # 80003ed4 <iput>
  end_op();
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	cc8080e7          	jalr	-824(ra) # 8000475c <end_op>
  return 0;
    80005a9c:	4781                	li	a5,0
    80005a9e:	a085                	j	80005afe <sys_link+0x13c>
    end_op();
    80005aa0:	fffff097          	auipc	ra,0xfffff
    80005aa4:	cbc080e7          	jalr	-836(ra) # 8000475c <end_op>
    return -1;
    80005aa8:	57fd                	li	a5,-1
    80005aaa:	a891                	j	80005afe <sys_link+0x13c>
    iunlockput(ip);
    80005aac:	8526                	mv	a0,s1
    80005aae:	ffffe097          	auipc	ra,0xffffe
    80005ab2:	4ce080e7          	jalr	1230(ra) # 80003f7c <iunlockput>
    end_op();
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	ca6080e7          	jalr	-858(ra) # 8000475c <end_op>
    return -1;
    80005abe:	57fd                	li	a5,-1
    80005ac0:	a83d                	j	80005afe <sys_link+0x13c>
    iunlockput(dp);
    80005ac2:	854a                	mv	a0,s2
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	4b8080e7          	jalr	1208(ra) # 80003f7c <iunlockput>
  ilock(ip);
    80005acc:	8526                	mv	a0,s1
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	24c080e7          	jalr	588(ra) # 80003d1a <ilock>
  ip->nlink--;
    80005ad6:	04a4d783          	lhu	a5,74(s1)
    80005ada:	37fd                	addiw	a5,a5,-1
    80005adc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ae0:	8526                	mv	a0,s1
    80005ae2:	ffffe097          	auipc	ra,0xffffe
    80005ae6:	16e080e7          	jalr	366(ra) # 80003c50 <iupdate>
  iunlockput(ip);
    80005aea:	8526                	mv	a0,s1
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	490080e7          	jalr	1168(ra) # 80003f7c <iunlockput>
  end_op();
    80005af4:	fffff097          	auipc	ra,0xfffff
    80005af8:	c68080e7          	jalr	-920(ra) # 8000475c <end_op>
  return -1;
    80005afc:	57fd                	li	a5,-1
}
    80005afe:	853e                	mv	a0,a5
    80005b00:	70b2                	ld	ra,296(sp)
    80005b02:	7412                	ld	s0,288(sp)
    80005b04:	64f2                	ld	s1,280(sp)
    80005b06:	6952                	ld	s2,272(sp)
    80005b08:	6155                	addi	sp,sp,304
    80005b0a:	8082                	ret

0000000080005b0c <sys_unlink>:
{
    80005b0c:	7151                	addi	sp,sp,-240
    80005b0e:	f586                	sd	ra,232(sp)
    80005b10:	f1a2                	sd	s0,224(sp)
    80005b12:	eda6                	sd	s1,216(sp)
    80005b14:	e9ca                	sd	s2,208(sp)
    80005b16:	e5ce                	sd	s3,200(sp)
    80005b18:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005b1a:	08000613          	li	a2,128
    80005b1e:	f3040593          	addi	a1,s0,-208
    80005b22:	4501                	li	a0,0
    80005b24:	ffffd097          	auipc	ra,0xffffd
    80005b28:	5a8080e7          	jalr	1448(ra) # 800030cc <argstr>
    80005b2c:	18054163          	bltz	a0,80005cae <sys_unlink+0x1a2>
  begin_op();
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	bac080e7          	jalr	-1108(ra) # 800046dc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b38:	fb040593          	addi	a1,s0,-80
    80005b3c:	f3040513          	addi	a0,s0,-208
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	99e080e7          	jalr	-1634(ra) # 800044de <nameiparent>
    80005b48:	84aa                	mv	s1,a0
    80005b4a:	c979                	beqz	a0,80005c20 <sys_unlink+0x114>
  ilock(dp);
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	1ce080e7          	jalr	462(ra) # 80003d1a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b54:	00003597          	auipc	a1,0x3
    80005b58:	be458593          	addi	a1,a1,-1052 # 80008738 <syscalls+0x2b8>
    80005b5c:	fb040513          	addi	a0,s0,-80
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	684080e7          	jalr	1668(ra) # 800041e4 <namecmp>
    80005b68:	14050a63          	beqz	a0,80005cbc <sys_unlink+0x1b0>
    80005b6c:	00003597          	auipc	a1,0x3
    80005b70:	bd458593          	addi	a1,a1,-1068 # 80008740 <syscalls+0x2c0>
    80005b74:	fb040513          	addi	a0,s0,-80
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	66c080e7          	jalr	1644(ra) # 800041e4 <namecmp>
    80005b80:	12050e63          	beqz	a0,80005cbc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b84:	f2c40613          	addi	a2,s0,-212
    80005b88:	fb040593          	addi	a1,s0,-80
    80005b8c:	8526                	mv	a0,s1
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	670080e7          	jalr	1648(ra) # 800041fe <dirlookup>
    80005b96:	892a                	mv	s2,a0
    80005b98:	12050263          	beqz	a0,80005cbc <sys_unlink+0x1b0>
  ilock(ip);
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	17e080e7          	jalr	382(ra) # 80003d1a <ilock>
  if(ip->nlink < 1)
    80005ba4:	04a91783          	lh	a5,74(s2)
    80005ba8:	08f05263          	blez	a5,80005c2c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005bac:	04491703          	lh	a4,68(s2)
    80005bb0:	4785                	li	a5,1
    80005bb2:	08f70563          	beq	a4,a5,80005c3c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005bb6:	4641                	li	a2,16
    80005bb8:	4581                	li	a1,0
    80005bba:	fc040513          	addi	a0,s0,-64
    80005bbe:	ffffb097          	auipc	ra,0xffffb
    80005bc2:	234080e7          	jalr	564(ra) # 80000df2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bc6:	4741                	li	a4,16
    80005bc8:	f2c42683          	lw	a3,-212(s0)
    80005bcc:	fc040613          	addi	a2,s0,-64
    80005bd0:	4581                	li	a1,0
    80005bd2:	8526                	mv	a0,s1
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	4f2080e7          	jalr	1266(ra) # 800040c6 <writei>
    80005bdc:	47c1                	li	a5,16
    80005bde:	0af51563          	bne	a0,a5,80005c88 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005be2:	04491703          	lh	a4,68(s2)
    80005be6:	4785                	li	a5,1
    80005be8:	0af70863          	beq	a4,a5,80005c98 <sys_unlink+0x18c>
  iunlockput(dp);
    80005bec:	8526                	mv	a0,s1
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	38e080e7          	jalr	910(ra) # 80003f7c <iunlockput>
  ip->nlink--;
    80005bf6:	04a95783          	lhu	a5,74(s2)
    80005bfa:	37fd                	addiw	a5,a5,-1
    80005bfc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c00:	854a                	mv	a0,s2
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	04e080e7          	jalr	78(ra) # 80003c50 <iupdate>
  iunlockput(ip);
    80005c0a:	854a                	mv	a0,s2
    80005c0c:	ffffe097          	auipc	ra,0xffffe
    80005c10:	370080e7          	jalr	880(ra) # 80003f7c <iunlockput>
  end_op();
    80005c14:	fffff097          	auipc	ra,0xfffff
    80005c18:	b48080e7          	jalr	-1208(ra) # 8000475c <end_op>
  return 0;
    80005c1c:	4501                	li	a0,0
    80005c1e:	a84d                	j	80005cd0 <sys_unlink+0x1c4>
    end_op();
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	b3c080e7          	jalr	-1220(ra) # 8000475c <end_op>
    return -1;
    80005c28:	557d                	li	a0,-1
    80005c2a:	a05d                	j	80005cd0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005c2c:	00003517          	auipc	a0,0x3
    80005c30:	b1c50513          	addi	a0,a0,-1252 # 80008748 <syscalls+0x2c8>
    80005c34:	ffffb097          	auipc	ra,0xffffb
    80005c38:	90a080e7          	jalr	-1782(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c3c:	04c92703          	lw	a4,76(s2)
    80005c40:	02000793          	li	a5,32
    80005c44:	f6e7f9e3          	bgeu	a5,a4,80005bb6 <sys_unlink+0xaa>
    80005c48:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c4c:	4741                	li	a4,16
    80005c4e:	86ce                	mv	a3,s3
    80005c50:	f1840613          	addi	a2,s0,-232
    80005c54:	4581                	li	a1,0
    80005c56:	854a                	mv	a0,s2
    80005c58:	ffffe097          	auipc	ra,0xffffe
    80005c5c:	376080e7          	jalr	886(ra) # 80003fce <readi>
    80005c60:	47c1                	li	a5,16
    80005c62:	00f51b63          	bne	a0,a5,80005c78 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005c66:	f1845783          	lhu	a5,-232(s0)
    80005c6a:	e7a1                	bnez	a5,80005cb2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c6c:	29c1                	addiw	s3,s3,16
    80005c6e:	04c92783          	lw	a5,76(s2)
    80005c72:	fcf9ede3          	bltu	s3,a5,80005c4c <sys_unlink+0x140>
    80005c76:	b781                	j	80005bb6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c78:	00003517          	auipc	a0,0x3
    80005c7c:	ae850513          	addi	a0,a0,-1304 # 80008760 <syscalls+0x2e0>
    80005c80:	ffffb097          	auipc	ra,0xffffb
    80005c84:	8be080e7          	jalr	-1858(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005c88:	00003517          	auipc	a0,0x3
    80005c8c:	af050513          	addi	a0,a0,-1296 # 80008778 <syscalls+0x2f8>
    80005c90:	ffffb097          	auipc	ra,0xffffb
    80005c94:	8ae080e7          	jalr	-1874(ra) # 8000053e <panic>
    dp->nlink--;
    80005c98:	04a4d783          	lhu	a5,74(s1)
    80005c9c:	37fd                	addiw	a5,a5,-1
    80005c9e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ca2:	8526                	mv	a0,s1
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	fac080e7          	jalr	-84(ra) # 80003c50 <iupdate>
    80005cac:	b781                	j	80005bec <sys_unlink+0xe0>
    return -1;
    80005cae:	557d                	li	a0,-1
    80005cb0:	a005                	j	80005cd0 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005cb2:	854a                	mv	a0,s2
    80005cb4:	ffffe097          	auipc	ra,0xffffe
    80005cb8:	2c8080e7          	jalr	712(ra) # 80003f7c <iunlockput>
  iunlockput(dp);
    80005cbc:	8526                	mv	a0,s1
    80005cbe:	ffffe097          	auipc	ra,0xffffe
    80005cc2:	2be080e7          	jalr	702(ra) # 80003f7c <iunlockput>
  end_op();
    80005cc6:	fffff097          	auipc	ra,0xfffff
    80005cca:	a96080e7          	jalr	-1386(ra) # 8000475c <end_op>
  return -1;
    80005cce:	557d                	li	a0,-1
}
    80005cd0:	70ae                	ld	ra,232(sp)
    80005cd2:	740e                	ld	s0,224(sp)
    80005cd4:	64ee                	ld	s1,216(sp)
    80005cd6:	694e                	ld	s2,208(sp)
    80005cd8:	69ae                	ld	s3,200(sp)
    80005cda:	616d                	addi	sp,sp,240
    80005cdc:	8082                	ret

0000000080005cde <sys_open>:

uint64
sys_open(void)
{
    80005cde:	7131                	addi	sp,sp,-192
    80005ce0:	fd06                	sd	ra,184(sp)
    80005ce2:	f922                	sd	s0,176(sp)
    80005ce4:	f526                	sd	s1,168(sp)
    80005ce6:	f14a                	sd	s2,160(sp)
    80005ce8:	ed4e                	sd	s3,152(sp)
    80005cea:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005cec:	f4c40593          	addi	a1,s0,-180
    80005cf0:	4505                	li	a0,1
    80005cf2:	ffffd097          	auipc	ra,0xffffd
    80005cf6:	39a080e7          	jalr	922(ra) # 8000308c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005cfa:	08000613          	li	a2,128
    80005cfe:	f5040593          	addi	a1,s0,-176
    80005d02:	4501                	li	a0,0
    80005d04:	ffffd097          	auipc	ra,0xffffd
    80005d08:	3c8080e7          	jalr	968(ra) # 800030cc <argstr>
    80005d0c:	87aa                	mv	a5,a0
    return -1;
    80005d0e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005d10:	0a07c963          	bltz	a5,80005dc2 <sys_open+0xe4>

  begin_op();
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	9c8080e7          	jalr	-1592(ra) # 800046dc <begin_op>

  if(omode & O_CREATE){
    80005d1c:	f4c42783          	lw	a5,-180(s0)
    80005d20:	2007f793          	andi	a5,a5,512
    80005d24:	cfc5                	beqz	a5,80005ddc <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005d26:	4681                	li	a3,0
    80005d28:	4601                	li	a2,0
    80005d2a:	4589                	li	a1,2
    80005d2c:	f5040513          	addi	a0,s0,-176
    80005d30:	00000097          	auipc	ra,0x0
    80005d34:	954080e7          	jalr	-1708(ra) # 80005684 <create>
    80005d38:	84aa                	mv	s1,a0
    if(ip == 0){
    80005d3a:	c959                	beqz	a0,80005dd0 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d3c:	04449703          	lh	a4,68(s1)
    80005d40:	478d                	li	a5,3
    80005d42:	00f71763          	bne	a4,a5,80005d50 <sys_open+0x72>
    80005d46:	0464d703          	lhu	a4,70(s1)
    80005d4a:	47a5                	li	a5,9
    80005d4c:	0ce7ed63          	bltu	a5,a4,80005e26 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d50:	fffff097          	auipc	ra,0xfffff
    80005d54:	d9c080e7          	jalr	-612(ra) # 80004aec <filealloc>
    80005d58:	89aa                	mv	s3,a0
    80005d5a:	10050363          	beqz	a0,80005e60 <sys_open+0x182>
    80005d5e:	00000097          	auipc	ra,0x0
    80005d62:	8e4080e7          	jalr	-1820(ra) # 80005642 <fdalloc>
    80005d66:	892a                	mv	s2,a0
    80005d68:	0e054763          	bltz	a0,80005e56 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d6c:	04449703          	lh	a4,68(s1)
    80005d70:	478d                	li	a5,3
    80005d72:	0cf70563          	beq	a4,a5,80005e3c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d76:	4789                	li	a5,2
    80005d78:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d7c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d80:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d84:	f4c42783          	lw	a5,-180(s0)
    80005d88:	0017c713          	xori	a4,a5,1
    80005d8c:	8b05                	andi	a4,a4,1
    80005d8e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d92:	0037f713          	andi	a4,a5,3
    80005d96:	00e03733          	snez	a4,a4
    80005d9a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d9e:	4007f793          	andi	a5,a5,1024
    80005da2:	c791                	beqz	a5,80005dae <sys_open+0xd0>
    80005da4:	04449703          	lh	a4,68(s1)
    80005da8:	4789                	li	a5,2
    80005daa:	0af70063          	beq	a4,a5,80005e4a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005dae:	8526                	mv	a0,s1
    80005db0:	ffffe097          	auipc	ra,0xffffe
    80005db4:	02c080e7          	jalr	44(ra) # 80003ddc <iunlock>
  end_op();
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	9a4080e7          	jalr	-1628(ra) # 8000475c <end_op>

  return fd;
    80005dc0:	854a                	mv	a0,s2
}
    80005dc2:	70ea                	ld	ra,184(sp)
    80005dc4:	744a                	ld	s0,176(sp)
    80005dc6:	74aa                	ld	s1,168(sp)
    80005dc8:	790a                	ld	s2,160(sp)
    80005dca:	69ea                	ld	s3,152(sp)
    80005dcc:	6129                	addi	sp,sp,192
    80005dce:	8082                	ret
      end_op();
    80005dd0:	fffff097          	auipc	ra,0xfffff
    80005dd4:	98c080e7          	jalr	-1652(ra) # 8000475c <end_op>
      return -1;
    80005dd8:	557d                	li	a0,-1
    80005dda:	b7e5                	j	80005dc2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005ddc:	f5040513          	addi	a0,s0,-176
    80005de0:	ffffe097          	auipc	ra,0xffffe
    80005de4:	6e0080e7          	jalr	1760(ra) # 800044c0 <namei>
    80005de8:	84aa                	mv	s1,a0
    80005dea:	c905                	beqz	a0,80005e1a <sys_open+0x13c>
    ilock(ip);
    80005dec:	ffffe097          	auipc	ra,0xffffe
    80005df0:	f2e080e7          	jalr	-210(ra) # 80003d1a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005df4:	04449703          	lh	a4,68(s1)
    80005df8:	4785                	li	a5,1
    80005dfa:	f4f711e3          	bne	a4,a5,80005d3c <sys_open+0x5e>
    80005dfe:	f4c42783          	lw	a5,-180(s0)
    80005e02:	d7b9                	beqz	a5,80005d50 <sys_open+0x72>
      iunlockput(ip);
    80005e04:	8526                	mv	a0,s1
    80005e06:	ffffe097          	auipc	ra,0xffffe
    80005e0a:	176080e7          	jalr	374(ra) # 80003f7c <iunlockput>
      end_op();
    80005e0e:	fffff097          	auipc	ra,0xfffff
    80005e12:	94e080e7          	jalr	-1714(ra) # 8000475c <end_op>
      return -1;
    80005e16:	557d                	li	a0,-1
    80005e18:	b76d                	j	80005dc2 <sys_open+0xe4>
      end_op();
    80005e1a:	fffff097          	auipc	ra,0xfffff
    80005e1e:	942080e7          	jalr	-1726(ra) # 8000475c <end_op>
      return -1;
    80005e22:	557d                	li	a0,-1
    80005e24:	bf79                	j	80005dc2 <sys_open+0xe4>
    iunlockput(ip);
    80005e26:	8526                	mv	a0,s1
    80005e28:	ffffe097          	auipc	ra,0xffffe
    80005e2c:	154080e7          	jalr	340(ra) # 80003f7c <iunlockput>
    end_op();
    80005e30:	fffff097          	auipc	ra,0xfffff
    80005e34:	92c080e7          	jalr	-1748(ra) # 8000475c <end_op>
    return -1;
    80005e38:	557d                	li	a0,-1
    80005e3a:	b761                	j	80005dc2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005e3c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005e40:	04649783          	lh	a5,70(s1)
    80005e44:	02f99223          	sh	a5,36(s3)
    80005e48:	bf25                	j	80005d80 <sys_open+0xa2>
    itrunc(ip);
    80005e4a:	8526                	mv	a0,s1
    80005e4c:	ffffe097          	auipc	ra,0xffffe
    80005e50:	fdc080e7          	jalr	-36(ra) # 80003e28 <itrunc>
    80005e54:	bfa9                	j	80005dae <sys_open+0xd0>
      fileclose(f);
    80005e56:	854e                	mv	a0,s3
    80005e58:	fffff097          	auipc	ra,0xfffff
    80005e5c:	d50080e7          	jalr	-688(ra) # 80004ba8 <fileclose>
    iunlockput(ip);
    80005e60:	8526                	mv	a0,s1
    80005e62:	ffffe097          	auipc	ra,0xffffe
    80005e66:	11a080e7          	jalr	282(ra) # 80003f7c <iunlockput>
    end_op();
    80005e6a:	fffff097          	auipc	ra,0xfffff
    80005e6e:	8f2080e7          	jalr	-1806(ra) # 8000475c <end_op>
    return -1;
    80005e72:	557d                	li	a0,-1
    80005e74:	b7b9                	j	80005dc2 <sys_open+0xe4>

0000000080005e76 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e76:	7175                	addi	sp,sp,-144
    80005e78:	e506                	sd	ra,136(sp)
    80005e7a:	e122                	sd	s0,128(sp)
    80005e7c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e7e:	fffff097          	auipc	ra,0xfffff
    80005e82:	85e080e7          	jalr	-1954(ra) # 800046dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e86:	08000613          	li	a2,128
    80005e8a:	f7040593          	addi	a1,s0,-144
    80005e8e:	4501                	li	a0,0
    80005e90:	ffffd097          	auipc	ra,0xffffd
    80005e94:	23c080e7          	jalr	572(ra) # 800030cc <argstr>
    80005e98:	02054963          	bltz	a0,80005eca <sys_mkdir+0x54>
    80005e9c:	4681                	li	a3,0
    80005e9e:	4601                	li	a2,0
    80005ea0:	4585                	li	a1,1
    80005ea2:	f7040513          	addi	a0,s0,-144
    80005ea6:	fffff097          	auipc	ra,0xfffff
    80005eaa:	7de080e7          	jalr	2014(ra) # 80005684 <create>
    80005eae:	cd11                	beqz	a0,80005eca <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005eb0:	ffffe097          	auipc	ra,0xffffe
    80005eb4:	0cc080e7          	jalr	204(ra) # 80003f7c <iunlockput>
  end_op();
    80005eb8:	fffff097          	auipc	ra,0xfffff
    80005ebc:	8a4080e7          	jalr	-1884(ra) # 8000475c <end_op>
  return 0;
    80005ec0:	4501                	li	a0,0
}
    80005ec2:	60aa                	ld	ra,136(sp)
    80005ec4:	640a                	ld	s0,128(sp)
    80005ec6:	6149                	addi	sp,sp,144
    80005ec8:	8082                	ret
    end_op();
    80005eca:	fffff097          	auipc	ra,0xfffff
    80005ece:	892080e7          	jalr	-1902(ra) # 8000475c <end_op>
    return -1;
    80005ed2:	557d                	li	a0,-1
    80005ed4:	b7fd                	j	80005ec2 <sys_mkdir+0x4c>

0000000080005ed6 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ed6:	7135                	addi	sp,sp,-160
    80005ed8:	ed06                	sd	ra,152(sp)
    80005eda:	e922                	sd	s0,144(sp)
    80005edc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	7fe080e7          	jalr	2046(ra) # 800046dc <begin_op>
  argint(1, &major);
    80005ee6:	f6c40593          	addi	a1,s0,-148
    80005eea:	4505                	li	a0,1
    80005eec:	ffffd097          	auipc	ra,0xffffd
    80005ef0:	1a0080e7          	jalr	416(ra) # 8000308c <argint>
  argint(2, &minor);
    80005ef4:	f6840593          	addi	a1,s0,-152
    80005ef8:	4509                	li	a0,2
    80005efa:	ffffd097          	auipc	ra,0xffffd
    80005efe:	192080e7          	jalr	402(ra) # 8000308c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f02:	08000613          	li	a2,128
    80005f06:	f7040593          	addi	a1,s0,-144
    80005f0a:	4501                	li	a0,0
    80005f0c:	ffffd097          	auipc	ra,0xffffd
    80005f10:	1c0080e7          	jalr	448(ra) # 800030cc <argstr>
    80005f14:	02054b63          	bltz	a0,80005f4a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f18:	f6841683          	lh	a3,-152(s0)
    80005f1c:	f6c41603          	lh	a2,-148(s0)
    80005f20:	458d                	li	a1,3
    80005f22:	f7040513          	addi	a0,s0,-144
    80005f26:	fffff097          	auipc	ra,0xfffff
    80005f2a:	75e080e7          	jalr	1886(ra) # 80005684 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f2e:	cd11                	beqz	a0,80005f4a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f30:	ffffe097          	auipc	ra,0xffffe
    80005f34:	04c080e7          	jalr	76(ra) # 80003f7c <iunlockput>
  end_op();
    80005f38:	fffff097          	auipc	ra,0xfffff
    80005f3c:	824080e7          	jalr	-2012(ra) # 8000475c <end_op>
  return 0;
    80005f40:	4501                	li	a0,0
}
    80005f42:	60ea                	ld	ra,152(sp)
    80005f44:	644a                	ld	s0,144(sp)
    80005f46:	610d                	addi	sp,sp,160
    80005f48:	8082                	ret
    end_op();
    80005f4a:	fffff097          	auipc	ra,0xfffff
    80005f4e:	812080e7          	jalr	-2030(ra) # 8000475c <end_op>
    return -1;
    80005f52:	557d                	li	a0,-1
    80005f54:	b7fd                	j	80005f42 <sys_mknod+0x6c>

0000000080005f56 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f56:	7135                	addi	sp,sp,-160
    80005f58:	ed06                	sd	ra,152(sp)
    80005f5a:	e922                	sd	s0,144(sp)
    80005f5c:	e526                	sd	s1,136(sp)
    80005f5e:	e14a                	sd	s2,128(sp)
    80005f60:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f62:	ffffc097          	auipc	ra,0xffffc
    80005f66:	bac080e7          	jalr	-1108(ra) # 80001b0e <myproc>
    80005f6a:	892a                	mv	s2,a0
  
  begin_op();
    80005f6c:	ffffe097          	auipc	ra,0xffffe
    80005f70:	770080e7          	jalr	1904(ra) # 800046dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f74:	08000613          	li	a2,128
    80005f78:	f6040593          	addi	a1,s0,-160
    80005f7c:	4501                	li	a0,0
    80005f7e:	ffffd097          	auipc	ra,0xffffd
    80005f82:	14e080e7          	jalr	334(ra) # 800030cc <argstr>
    80005f86:	04054b63          	bltz	a0,80005fdc <sys_chdir+0x86>
    80005f8a:	f6040513          	addi	a0,s0,-160
    80005f8e:	ffffe097          	auipc	ra,0xffffe
    80005f92:	532080e7          	jalr	1330(ra) # 800044c0 <namei>
    80005f96:	84aa                	mv	s1,a0
    80005f98:	c131                	beqz	a0,80005fdc <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f9a:	ffffe097          	auipc	ra,0xffffe
    80005f9e:	d80080e7          	jalr	-640(ra) # 80003d1a <ilock>
  if(ip->type != T_DIR){
    80005fa2:	04449703          	lh	a4,68(s1)
    80005fa6:	4785                	li	a5,1
    80005fa8:	04f71063          	bne	a4,a5,80005fe8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005fac:	8526                	mv	a0,s1
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	e2e080e7          	jalr	-466(ra) # 80003ddc <iunlock>
  iput(p->cwd);
    80005fb6:	15093503          	ld	a0,336(s2)
    80005fba:	ffffe097          	auipc	ra,0xffffe
    80005fbe:	f1a080e7          	jalr	-230(ra) # 80003ed4 <iput>
  end_op();
    80005fc2:	ffffe097          	auipc	ra,0xffffe
    80005fc6:	79a080e7          	jalr	1946(ra) # 8000475c <end_op>
  p->cwd = ip;
    80005fca:	14993823          	sd	s1,336(s2)
  return 0;
    80005fce:	4501                	li	a0,0
}
    80005fd0:	60ea                	ld	ra,152(sp)
    80005fd2:	644a                	ld	s0,144(sp)
    80005fd4:	64aa                	ld	s1,136(sp)
    80005fd6:	690a                	ld	s2,128(sp)
    80005fd8:	610d                	addi	sp,sp,160
    80005fda:	8082                	ret
    end_op();
    80005fdc:	ffffe097          	auipc	ra,0xffffe
    80005fe0:	780080e7          	jalr	1920(ra) # 8000475c <end_op>
    return -1;
    80005fe4:	557d                	li	a0,-1
    80005fe6:	b7ed                	j	80005fd0 <sys_chdir+0x7a>
    iunlockput(ip);
    80005fe8:	8526                	mv	a0,s1
    80005fea:	ffffe097          	auipc	ra,0xffffe
    80005fee:	f92080e7          	jalr	-110(ra) # 80003f7c <iunlockput>
    end_op();
    80005ff2:	ffffe097          	auipc	ra,0xffffe
    80005ff6:	76a080e7          	jalr	1898(ra) # 8000475c <end_op>
    return -1;
    80005ffa:	557d                	li	a0,-1
    80005ffc:	bfd1                	j	80005fd0 <sys_chdir+0x7a>

0000000080005ffe <sys_exec>:

uint64
sys_exec(void)
{
    80005ffe:	7145                	addi	sp,sp,-464
    80006000:	e786                	sd	ra,456(sp)
    80006002:	e3a2                	sd	s0,448(sp)
    80006004:	ff26                	sd	s1,440(sp)
    80006006:	fb4a                	sd	s2,432(sp)
    80006008:	f74e                	sd	s3,424(sp)
    8000600a:	f352                	sd	s4,416(sp)
    8000600c:	ef56                	sd	s5,408(sp)
    8000600e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006010:	e3840593          	addi	a1,s0,-456
    80006014:	4505                	li	a0,1
    80006016:	ffffd097          	auipc	ra,0xffffd
    8000601a:	096080e7          	jalr	150(ra) # 800030ac <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000601e:	08000613          	li	a2,128
    80006022:	f4040593          	addi	a1,s0,-192
    80006026:	4501                	li	a0,0
    80006028:	ffffd097          	auipc	ra,0xffffd
    8000602c:	0a4080e7          	jalr	164(ra) # 800030cc <argstr>
    80006030:	87aa                	mv	a5,a0
    return -1;
    80006032:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006034:	0c07c263          	bltz	a5,800060f8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006038:	10000613          	li	a2,256
    8000603c:	4581                	li	a1,0
    8000603e:	e4040513          	addi	a0,s0,-448
    80006042:	ffffb097          	auipc	ra,0xffffb
    80006046:	db0080e7          	jalr	-592(ra) # 80000df2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000604a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000604e:	89a6                	mv	s3,s1
    80006050:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006052:	02000a13          	li	s4,32
    80006056:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000605a:	00391793          	slli	a5,s2,0x3
    8000605e:	e3040593          	addi	a1,s0,-464
    80006062:	e3843503          	ld	a0,-456(s0)
    80006066:	953e                	add	a0,a0,a5
    80006068:	ffffd097          	auipc	ra,0xffffd
    8000606c:	f86080e7          	jalr	-122(ra) # 80002fee <fetchaddr>
    80006070:	02054a63          	bltz	a0,800060a4 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80006074:	e3043783          	ld	a5,-464(s0)
    80006078:	c3b9                	beqz	a5,800060be <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000607a:	ffffb097          	auipc	ra,0xffffb
    8000607e:	9dc080e7          	jalr	-1572(ra) # 80000a56 <kalloc>
    80006082:	85aa                	mv	a1,a0
    80006084:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006088:	cd11                	beqz	a0,800060a4 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000608a:	6605                	lui	a2,0x1
    8000608c:	e3043503          	ld	a0,-464(s0)
    80006090:	ffffd097          	auipc	ra,0xffffd
    80006094:	fb0080e7          	jalr	-80(ra) # 80003040 <fetchstr>
    80006098:	00054663          	bltz	a0,800060a4 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    8000609c:	0905                	addi	s2,s2,1
    8000609e:	09a1                	addi	s3,s3,8
    800060a0:	fb491be3          	bne	s2,s4,80006056 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060a4:	10048913          	addi	s2,s1,256
    800060a8:	6088                	ld	a0,0(s1)
    800060aa:	c531                	beqz	a0,800060f6 <sys_exec+0xf8>
    kfree(argv[i]);
    800060ac:	ffffb097          	auipc	ra,0xffffb
    800060b0:	aa0080e7          	jalr	-1376(ra) # 80000b4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060b4:	04a1                	addi	s1,s1,8
    800060b6:	ff2499e3          	bne	s1,s2,800060a8 <sys_exec+0xaa>
  return -1;
    800060ba:	557d                	li	a0,-1
    800060bc:	a835                	j	800060f8 <sys_exec+0xfa>
      argv[i] = 0;
    800060be:	0a8e                	slli	s5,s5,0x3
    800060c0:	fc040793          	addi	a5,s0,-64
    800060c4:	9abe                	add	s5,s5,a5
    800060c6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800060ca:	e4040593          	addi	a1,s0,-448
    800060ce:	f4040513          	addi	a0,s0,-192
    800060d2:	fffff097          	auipc	ra,0xfffff
    800060d6:	150080e7          	jalr	336(ra) # 80005222 <exec>
    800060da:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060dc:	10048993          	addi	s3,s1,256
    800060e0:	6088                	ld	a0,0(s1)
    800060e2:	c901                	beqz	a0,800060f2 <sys_exec+0xf4>
    kfree(argv[i]);
    800060e4:	ffffb097          	auipc	ra,0xffffb
    800060e8:	a68080e7          	jalr	-1432(ra) # 80000b4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060ec:	04a1                	addi	s1,s1,8
    800060ee:	ff3499e3          	bne	s1,s3,800060e0 <sys_exec+0xe2>
  return ret;
    800060f2:	854a                	mv	a0,s2
    800060f4:	a011                	j	800060f8 <sys_exec+0xfa>
  return -1;
    800060f6:	557d                	li	a0,-1
}
    800060f8:	60be                	ld	ra,456(sp)
    800060fa:	641e                	ld	s0,448(sp)
    800060fc:	74fa                	ld	s1,440(sp)
    800060fe:	795a                	ld	s2,432(sp)
    80006100:	79ba                	ld	s3,424(sp)
    80006102:	7a1a                	ld	s4,416(sp)
    80006104:	6afa                	ld	s5,408(sp)
    80006106:	6179                	addi	sp,sp,464
    80006108:	8082                	ret

000000008000610a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000610a:	7139                	addi	sp,sp,-64
    8000610c:	fc06                	sd	ra,56(sp)
    8000610e:	f822                	sd	s0,48(sp)
    80006110:	f426                	sd	s1,40(sp)
    80006112:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006114:	ffffc097          	auipc	ra,0xffffc
    80006118:	9fa080e7          	jalr	-1542(ra) # 80001b0e <myproc>
    8000611c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000611e:	fd840593          	addi	a1,s0,-40
    80006122:	4501                	li	a0,0
    80006124:	ffffd097          	auipc	ra,0xffffd
    80006128:	f88080e7          	jalr	-120(ra) # 800030ac <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000612c:	fc840593          	addi	a1,s0,-56
    80006130:	fd040513          	addi	a0,s0,-48
    80006134:	fffff097          	auipc	ra,0xfffff
    80006138:	da4080e7          	jalr	-604(ra) # 80004ed8 <pipealloc>
    return -1;
    8000613c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000613e:	0c054463          	bltz	a0,80006206 <sys_pipe+0xfc>
  fd0 = -1;
    80006142:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006146:	fd043503          	ld	a0,-48(s0)
    8000614a:	fffff097          	auipc	ra,0xfffff
    8000614e:	4f8080e7          	jalr	1272(ra) # 80005642 <fdalloc>
    80006152:	fca42223          	sw	a0,-60(s0)
    80006156:	08054b63          	bltz	a0,800061ec <sys_pipe+0xe2>
    8000615a:	fc843503          	ld	a0,-56(s0)
    8000615e:	fffff097          	auipc	ra,0xfffff
    80006162:	4e4080e7          	jalr	1252(ra) # 80005642 <fdalloc>
    80006166:	fca42023          	sw	a0,-64(s0)
    8000616a:	06054863          	bltz	a0,800061da <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000616e:	4691                	li	a3,4
    80006170:	fc440613          	addi	a2,s0,-60
    80006174:	fd843583          	ld	a1,-40(s0)
    80006178:	68a8                	ld	a0,80(s1)
    8000617a:	ffffb097          	auipc	ra,0xffffb
    8000617e:	614080e7          	jalr	1556(ra) # 8000178e <copyout>
    80006182:	02054063          	bltz	a0,800061a2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006186:	4691                	li	a3,4
    80006188:	fc040613          	addi	a2,s0,-64
    8000618c:	fd843583          	ld	a1,-40(s0)
    80006190:	0591                	addi	a1,a1,4
    80006192:	68a8                	ld	a0,80(s1)
    80006194:	ffffb097          	auipc	ra,0xffffb
    80006198:	5fa080e7          	jalr	1530(ra) # 8000178e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000619c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000619e:	06055463          	bgez	a0,80006206 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800061a2:	fc442783          	lw	a5,-60(s0)
    800061a6:	07e9                	addi	a5,a5,26
    800061a8:	078e                	slli	a5,a5,0x3
    800061aa:	97a6                	add	a5,a5,s1
    800061ac:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800061b0:	fc042503          	lw	a0,-64(s0)
    800061b4:	0569                	addi	a0,a0,26
    800061b6:	050e                	slli	a0,a0,0x3
    800061b8:	94aa                	add	s1,s1,a0
    800061ba:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800061be:	fd043503          	ld	a0,-48(s0)
    800061c2:	fffff097          	auipc	ra,0xfffff
    800061c6:	9e6080e7          	jalr	-1562(ra) # 80004ba8 <fileclose>
    fileclose(wf);
    800061ca:	fc843503          	ld	a0,-56(s0)
    800061ce:	fffff097          	auipc	ra,0xfffff
    800061d2:	9da080e7          	jalr	-1574(ra) # 80004ba8 <fileclose>
    return -1;
    800061d6:	57fd                	li	a5,-1
    800061d8:	a03d                	j	80006206 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800061da:	fc442783          	lw	a5,-60(s0)
    800061de:	0007c763          	bltz	a5,800061ec <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800061e2:	07e9                	addi	a5,a5,26
    800061e4:	078e                	slli	a5,a5,0x3
    800061e6:	94be                	add	s1,s1,a5
    800061e8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800061ec:	fd043503          	ld	a0,-48(s0)
    800061f0:	fffff097          	auipc	ra,0xfffff
    800061f4:	9b8080e7          	jalr	-1608(ra) # 80004ba8 <fileclose>
    fileclose(wf);
    800061f8:	fc843503          	ld	a0,-56(s0)
    800061fc:	fffff097          	auipc	ra,0xfffff
    80006200:	9ac080e7          	jalr	-1620(ra) # 80004ba8 <fileclose>
    return -1;
    80006204:	57fd                	li	a5,-1
}
    80006206:	853e                	mv	a0,a5
    80006208:	70e2                	ld	ra,56(sp)
    8000620a:	7442                	ld	s0,48(sp)
    8000620c:	74a2                	ld	s1,40(sp)
    8000620e:	6121                	addi	sp,sp,64
    80006210:	8082                	ret
	...

0000000080006220 <kernelvec>:
    80006220:	7111                	addi	sp,sp,-256
    80006222:	e006                	sd	ra,0(sp)
    80006224:	e40a                	sd	sp,8(sp)
    80006226:	e80e                	sd	gp,16(sp)
    80006228:	ec12                	sd	tp,24(sp)
    8000622a:	f016                	sd	t0,32(sp)
    8000622c:	f41a                	sd	t1,40(sp)
    8000622e:	f81e                	sd	t2,48(sp)
    80006230:	fc22                	sd	s0,56(sp)
    80006232:	e0a6                	sd	s1,64(sp)
    80006234:	e4aa                	sd	a0,72(sp)
    80006236:	e8ae                	sd	a1,80(sp)
    80006238:	ecb2                	sd	a2,88(sp)
    8000623a:	f0b6                	sd	a3,96(sp)
    8000623c:	f4ba                	sd	a4,104(sp)
    8000623e:	f8be                	sd	a5,112(sp)
    80006240:	fcc2                	sd	a6,120(sp)
    80006242:	e146                	sd	a7,128(sp)
    80006244:	e54a                	sd	s2,136(sp)
    80006246:	e94e                	sd	s3,144(sp)
    80006248:	ed52                	sd	s4,152(sp)
    8000624a:	f156                	sd	s5,160(sp)
    8000624c:	f55a                	sd	s6,168(sp)
    8000624e:	f95e                	sd	s7,176(sp)
    80006250:	fd62                	sd	s8,184(sp)
    80006252:	e1e6                	sd	s9,192(sp)
    80006254:	e5ea                	sd	s10,200(sp)
    80006256:	e9ee                	sd	s11,208(sp)
    80006258:	edf2                	sd	t3,216(sp)
    8000625a:	f1f6                	sd	t4,224(sp)
    8000625c:	f5fa                	sd	t5,232(sp)
    8000625e:	f9fe                	sd	t6,240(sp)
    80006260:	a49fc0ef          	jal	ra,80002ca8 <kerneltrap>
    80006264:	6082                	ld	ra,0(sp)
    80006266:	6122                	ld	sp,8(sp)
    80006268:	61c2                	ld	gp,16(sp)
    8000626a:	7282                	ld	t0,32(sp)
    8000626c:	7322                	ld	t1,40(sp)
    8000626e:	73c2                	ld	t2,48(sp)
    80006270:	7462                	ld	s0,56(sp)
    80006272:	6486                	ld	s1,64(sp)
    80006274:	6526                	ld	a0,72(sp)
    80006276:	65c6                	ld	a1,80(sp)
    80006278:	6666                	ld	a2,88(sp)
    8000627a:	7686                	ld	a3,96(sp)
    8000627c:	7726                	ld	a4,104(sp)
    8000627e:	77c6                	ld	a5,112(sp)
    80006280:	7866                	ld	a6,120(sp)
    80006282:	688a                	ld	a7,128(sp)
    80006284:	692a                	ld	s2,136(sp)
    80006286:	69ca                	ld	s3,144(sp)
    80006288:	6a6a                	ld	s4,152(sp)
    8000628a:	7a8a                	ld	s5,160(sp)
    8000628c:	7b2a                	ld	s6,168(sp)
    8000628e:	7bca                	ld	s7,176(sp)
    80006290:	7c6a                	ld	s8,184(sp)
    80006292:	6c8e                	ld	s9,192(sp)
    80006294:	6d2e                	ld	s10,200(sp)
    80006296:	6dce                	ld	s11,208(sp)
    80006298:	6e6e                	ld	t3,216(sp)
    8000629a:	7e8e                	ld	t4,224(sp)
    8000629c:	7f2e                	ld	t5,232(sp)
    8000629e:	7fce                	ld	t6,240(sp)
    800062a0:	6111                	addi	sp,sp,256
    800062a2:	10200073          	sret
    800062a6:	00000013          	nop
    800062aa:	00000013          	nop
    800062ae:	0001                	nop

00000000800062b0 <timervec>:
    800062b0:	34051573          	csrrw	a0,mscratch,a0
    800062b4:	e10c                	sd	a1,0(a0)
    800062b6:	e510                	sd	a2,8(a0)
    800062b8:	e914                	sd	a3,16(a0)
    800062ba:	6d0c                	ld	a1,24(a0)
    800062bc:	7110                	ld	a2,32(a0)
    800062be:	6194                	ld	a3,0(a1)
    800062c0:	96b2                	add	a3,a3,a2
    800062c2:	e194                	sd	a3,0(a1)
    800062c4:	4589                	li	a1,2
    800062c6:	14459073          	csrw	sip,a1
    800062ca:	6914                	ld	a3,16(a0)
    800062cc:	6510                	ld	a2,8(a0)
    800062ce:	610c                	ld	a1,0(a0)
    800062d0:	34051573          	csrrw	a0,mscratch,a0
    800062d4:	30200073          	mret
	...

00000000800062da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800062da:	1141                	addi	sp,sp,-16
    800062dc:	e422                	sd	s0,8(sp)
    800062de:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800062e0:	0c0007b7          	lui	a5,0xc000
    800062e4:	4705                	li	a4,1
    800062e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800062e8:	c3d8                	sw	a4,4(a5)
}
    800062ea:	6422                	ld	s0,8(sp)
    800062ec:	0141                	addi	sp,sp,16
    800062ee:	8082                	ret

00000000800062f0 <plicinithart>:

void
plicinithart(void)
{
    800062f0:	1141                	addi	sp,sp,-16
    800062f2:	e406                	sd	ra,8(sp)
    800062f4:	e022                	sd	s0,0(sp)
    800062f6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062f8:	ffffb097          	auipc	ra,0xffffb
    800062fc:	7ea080e7          	jalr	2026(ra) # 80001ae2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006300:	0085171b          	slliw	a4,a0,0x8
    80006304:	0c0027b7          	lui	a5,0xc002
    80006308:	97ba                	add	a5,a5,a4
    8000630a:	40200713          	li	a4,1026
    8000630e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006312:	00d5151b          	slliw	a0,a0,0xd
    80006316:	0c2017b7          	lui	a5,0xc201
    8000631a:	953e                	add	a0,a0,a5
    8000631c:	00052023          	sw	zero,0(a0)
}
    80006320:	60a2                	ld	ra,8(sp)
    80006322:	6402                	ld	s0,0(sp)
    80006324:	0141                	addi	sp,sp,16
    80006326:	8082                	ret

0000000080006328 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006328:	1141                	addi	sp,sp,-16
    8000632a:	e406                	sd	ra,8(sp)
    8000632c:	e022                	sd	s0,0(sp)
    8000632e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006330:	ffffb097          	auipc	ra,0xffffb
    80006334:	7b2080e7          	jalr	1970(ra) # 80001ae2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006338:	00d5179b          	slliw	a5,a0,0xd
    8000633c:	0c201537          	lui	a0,0xc201
    80006340:	953e                	add	a0,a0,a5
  return irq;
}
    80006342:	4148                	lw	a0,4(a0)
    80006344:	60a2                	ld	ra,8(sp)
    80006346:	6402                	ld	s0,0(sp)
    80006348:	0141                	addi	sp,sp,16
    8000634a:	8082                	ret

000000008000634c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000634c:	1101                	addi	sp,sp,-32
    8000634e:	ec06                	sd	ra,24(sp)
    80006350:	e822                	sd	s0,16(sp)
    80006352:	e426                	sd	s1,8(sp)
    80006354:	1000                	addi	s0,sp,32
    80006356:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006358:	ffffb097          	auipc	ra,0xffffb
    8000635c:	78a080e7          	jalr	1930(ra) # 80001ae2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006360:	00d5151b          	slliw	a0,a0,0xd
    80006364:	0c2017b7          	lui	a5,0xc201
    80006368:	97aa                	add	a5,a5,a0
    8000636a:	c3c4                	sw	s1,4(a5)
}
    8000636c:	60e2                	ld	ra,24(sp)
    8000636e:	6442                	ld	s0,16(sp)
    80006370:	64a2                	ld	s1,8(sp)
    80006372:	6105                	addi	sp,sp,32
    80006374:	8082                	ret

0000000080006376 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006376:	1141                	addi	sp,sp,-16
    80006378:	e406                	sd	ra,8(sp)
    8000637a:	e022                	sd	s0,0(sp)
    8000637c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000637e:	479d                	li	a5,7
    80006380:	04a7cc63          	blt	a5,a0,800063d8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006384:	0023c797          	auipc	a5,0x23c
    80006388:	2e478793          	addi	a5,a5,740 # 80242668 <disk>
    8000638c:	97aa                	add	a5,a5,a0
    8000638e:	0187c783          	lbu	a5,24(a5)
    80006392:	ebb9                	bnez	a5,800063e8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006394:	00451613          	slli	a2,a0,0x4
    80006398:	0023c797          	auipc	a5,0x23c
    8000639c:	2d078793          	addi	a5,a5,720 # 80242668 <disk>
    800063a0:	6394                	ld	a3,0(a5)
    800063a2:	96b2                	add	a3,a3,a2
    800063a4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800063a8:	6398                	ld	a4,0(a5)
    800063aa:	9732                	add	a4,a4,a2
    800063ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800063b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800063b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800063b8:	953e                	add	a0,a0,a5
    800063ba:	4785                	li	a5,1
    800063bc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800063c0:	0023c517          	auipc	a0,0x23c
    800063c4:	2c050513          	addi	a0,a0,704 # 80242680 <disk+0x18>
    800063c8:	ffffc097          	auipc	ra,0xffffc
    800063cc:	fc2080e7          	jalr	-62(ra) # 8000238a <wakeup>
}
    800063d0:	60a2                	ld	ra,8(sp)
    800063d2:	6402                	ld	s0,0(sp)
    800063d4:	0141                	addi	sp,sp,16
    800063d6:	8082                	ret
    panic("free_desc 1");
    800063d8:	00002517          	auipc	a0,0x2
    800063dc:	3b050513          	addi	a0,a0,944 # 80008788 <syscalls+0x308>
    800063e0:	ffffa097          	auipc	ra,0xffffa
    800063e4:	15e080e7          	jalr	350(ra) # 8000053e <panic>
    panic("free_desc 2");
    800063e8:	00002517          	auipc	a0,0x2
    800063ec:	3b050513          	addi	a0,a0,944 # 80008798 <syscalls+0x318>
    800063f0:	ffffa097          	auipc	ra,0xffffa
    800063f4:	14e080e7          	jalr	334(ra) # 8000053e <panic>

00000000800063f8 <virtio_disk_init>:
{
    800063f8:	1101                	addi	sp,sp,-32
    800063fa:	ec06                	sd	ra,24(sp)
    800063fc:	e822                	sd	s0,16(sp)
    800063fe:	e426                	sd	s1,8(sp)
    80006400:	e04a                	sd	s2,0(sp)
    80006402:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006404:	00002597          	auipc	a1,0x2
    80006408:	3a458593          	addi	a1,a1,932 # 800087a8 <syscalls+0x328>
    8000640c:	0023c517          	auipc	a0,0x23c
    80006410:	38450513          	addi	a0,a0,900 # 80242790 <disk+0x128>
    80006414:	ffffb097          	auipc	ra,0xffffb
    80006418:	852080e7          	jalr	-1966(ra) # 80000c66 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000641c:	100017b7          	lui	a5,0x10001
    80006420:	4398                	lw	a4,0(a5)
    80006422:	2701                	sext.w	a4,a4
    80006424:	747277b7          	lui	a5,0x74727
    80006428:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000642c:	14f71c63          	bne	a4,a5,80006584 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006430:	100017b7          	lui	a5,0x10001
    80006434:	43dc                	lw	a5,4(a5)
    80006436:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006438:	4709                	li	a4,2
    8000643a:	14e79563          	bne	a5,a4,80006584 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000643e:	100017b7          	lui	a5,0x10001
    80006442:	479c                	lw	a5,8(a5)
    80006444:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006446:	12e79f63          	bne	a5,a4,80006584 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000644a:	100017b7          	lui	a5,0x10001
    8000644e:	47d8                	lw	a4,12(a5)
    80006450:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006452:	554d47b7          	lui	a5,0x554d4
    80006456:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000645a:	12f71563          	bne	a4,a5,80006584 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000645e:	100017b7          	lui	a5,0x10001
    80006462:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006466:	4705                	li	a4,1
    80006468:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000646a:	470d                	li	a4,3
    8000646c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000646e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006470:	c7ffe737          	lui	a4,0xc7ffe
    80006474:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47dbbfb7>
    80006478:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000647a:	2701                	sext.w	a4,a4
    8000647c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000647e:	472d                	li	a4,11
    80006480:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006482:	5bbc                	lw	a5,112(a5)
    80006484:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006488:	8ba1                	andi	a5,a5,8
    8000648a:	10078563          	beqz	a5,80006594 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000648e:	100017b7          	lui	a5,0x10001
    80006492:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006496:	43fc                	lw	a5,68(a5)
    80006498:	2781                	sext.w	a5,a5
    8000649a:	10079563          	bnez	a5,800065a4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000649e:	100017b7          	lui	a5,0x10001
    800064a2:	5bdc                	lw	a5,52(a5)
    800064a4:	2781                	sext.w	a5,a5
  if(max == 0)
    800064a6:	10078763          	beqz	a5,800065b4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800064aa:	471d                	li	a4,7
    800064ac:	10f77c63          	bgeu	a4,a5,800065c4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800064b0:	ffffa097          	auipc	ra,0xffffa
    800064b4:	5a6080e7          	jalr	1446(ra) # 80000a56 <kalloc>
    800064b8:	0023c497          	auipc	s1,0x23c
    800064bc:	1b048493          	addi	s1,s1,432 # 80242668 <disk>
    800064c0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800064c2:	ffffa097          	auipc	ra,0xffffa
    800064c6:	594080e7          	jalr	1428(ra) # 80000a56 <kalloc>
    800064ca:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800064cc:	ffffa097          	auipc	ra,0xffffa
    800064d0:	58a080e7          	jalr	1418(ra) # 80000a56 <kalloc>
    800064d4:	87aa                	mv	a5,a0
    800064d6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800064d8:	6088                	ld	a0,0(s1)
    800064da:	cd6d                	beqz	a0,800065d4 <virtio_disk_init+0x1dc>
    800064dc:	0023c717          	auipc	a4,0x23c
    800064e0:	19473703          	ld	a4,404(a4) # 80242670 <disk+0x8>
    800064e4:	cb65                	beqz	a4,800065d4 <virtio_disk_init+0x1dc>
    800064e6:	c7fd                	beqz	a5,800065d4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800064e8:	6605                	lui	a2,0x1
    800064ea:	4581                	li	a1,0
    800064ec:	ffffb097          	auipc	ra,0xffffb
    800064f0:	906080e7          	jalr	-1786(ra) # 80000df2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800064f4:	0023c497          	auipc	s1,0x23c
    800064f8:	17448493          	addi	s1,s1,372 # 80242668 <disk>
    800064fc:	6605                	lui	a2,0x1
    800064fe:	4581                	li	a1,0
    80006500:	6488                	ld	a0,8(s1)
    80006502:	ffffb097          	auipc	ra,0xffffb
    80006506:	8f0080e7          	jalr	-1808(ra) # 80000df2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000650a:	6605                	lui	a2,0x1
    8000650c:	4581                	li	a1,0
    8000650e:	6888                	ld	a0,16(s1)
    80006510:	ffffb097          	auipc	ra,0xffffb
    80006514:	8e2080e7          	jalr	-1822(ra) # 80000df2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006518:	100017b7          	lui	a5,0x10001
    8000651c:	4721                	li	a4,8
    8000651e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006520:	4098                	lw	a4,0(s1)
    80006522:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006526:	40d8                	lw	a4,4(s1)
    80006528:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000652c:	6498                	ld	a4,8(s1)
    8000652e:	0007069b          	sext.w	a3,a4
    80006532:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006536:	9701                	srai	a4,a4,0x20
    80006538:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000653c:	6898                	ld	a4,16(s1)
    8000653e:	0007069b          	sext.w	a3,a4
    80006542:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006546:	9701                	srai	a4,a4,0x20
    80006548:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000654c:	4705                	li	a4,1
    8000654e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006550:	00e48c23          	sb	a4,24(s1)
    80006554:	00e48ca3          	sb	a4,25(s1)
    80006558:	00e48d23          	sb	a4,26(s1)
    8000655c:	00e48da3          	sb	a4,27(s1)
    80006560:	00e48e23          	sb	a4,28(s1)
    80006564:	00e48ea3          	sb	a4,29(s1)
    80006568:	00e48f23          	sb	a4,30(s1)
    8000656c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006570:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006574:	0727a823          	sw	s2,112(a5)
}
    80006578:	60e2                	ld	ra,24(sp)
    8000657a:	6442                	ld	s0,16(sp)
    8000657c:	64a2                	ld	s1,8(sp)
    8000657e:	6902                	ld	s2,0(sp)
    80006580:	6105                	addi	sp,sp,32
    80006582:	8082                	ret
    panic("could not find virtio disk");
    80006584:	00002517          	auipc	a0,0x2
    80006588:	23450513          	addi	a0,a0,564 # 800087b8 <syscalls+0x338>
    8000658c:	ffffa097          	auipc	ra,0xffffa
    80006590:	fb2080e7          	jalr	-78(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006594:	00002517          	auipc	a0,0x2
    80006598:	24450513          	addi	a0,a0,580 # 800087d8 <syscalls+0x358>
    8000659c:	ffffa097          	auipc	ra,0xffffa
    800065a0:	fa2080e7          	jalr	-94(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800065a4:	00002517          	auipc	a0,0x2
    800065a8:	25450513          	addi	a0,a0,596 # 800087f8 <syscalls+0x378>
    800065ac:	ffffa097          	auipc	ra,0xffffa
    800065b0:	f92080e7          	jalr	-110(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800065b4:	00002517          	auipc	a0,0x2
    800065b8:	26450513          	addi	a0,a0,612 # 80008818 <syscalls+0x398>
    800065bc:	ffffa097          	auipc	ra,0xffffa
    800065c0:	f82080e7          	jalr	-126(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800065c4:	00002517          	auipc	a0,0x2
    800065c8:	27450513          	addi	a0,a0,628 # 80008838 <syscalls+0x3b8>
    800065cc:	ffffa097          	auipc	ra,0xffffa
    800065d0:	f72080e7          	jalr	-142(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800065d4:	00002517          	auipc	a0,0x2
    800065d8:	28450513          	addi	a0,a0,644 # 80008858 <syscalls+0x3d8>
    800065dc:	ffffa097          	auipc	ra,0xffffa
    800065e0:	f62080e7          	jalr	-158(ra) # 8000053e <panic>

00000000800065e4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800065e4:	7119                	addi	sp,sp,-128
    800065e6:	fc86                	sd	ra,120(sp)
    800065e8:	f8a2                	sd	s0,112(sp)
    800065ea:	f4a6                	sd	s1,104(sp)
    800065ec:	f0ca                	sd	s2,96(sp)
    800065ee:	ecce                	sd	s3,88(sp)
    800065f0:	e8d2                	sd	s4,80(sp)
    800065f2:	e4d6                	sd	s5,72(sp)
    800065f4:	e0da                	sd	s6,64(sp)
    800065f6:	fc5e                	sd	s7,56(sp)
    800065f8:	f862                	sd	s8,48(sp)
    800065fa:	f466                	sd	s9,40(sp)
    800065fc:	f06a                	sd	s10,32(sp)
    800065fe:	ec6e                	sd	s11,24(sp)
    80006600:	0100                	addi	s0,sp,128
    80006602:	8aaa                	mv	s5,a0
    80006604:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006606:	00c52d03          	lw	s10,12(a0)
    8000660a:	001d1d1b          	slliw	s10,s10,0x1
    8000660e:	1d02                	slli	s10,s10,0x20
    80006610:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006614:	0023c517          	auipc	a0,0x23c
    80006618:	17c50513          	addi	a0,a0,380 # 80242790 <disk+0x128>
    8000661c:	ffffa097          	auipc	ra,0xffffa
    80006620:	6da080e7          	jalr	1754(ra) # 80000cf6 <acquire>
  for(int i = 0; i < 3; i++){
    80006624:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006626:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006628:	0023cb97          	auipc	s7,0x23c
    8000662c:	040b8b93          	addi	s7,s7,64 # 80242668 <disk>
  for(int i = 0; i < 3; i++){
    80006630:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006632:	0023cc97          	auipc	s9,0x23c
    80006636:	15ec8c93          	addi	s9,s9,350 # 80242790 <disk+0x128>
    8000663a:	a08d                	j	8000669c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000663c:	00fb8733          	add	a4,s7,a5
    80006640:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006644:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006646:	0207c563          	bltz	a5,80006670 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000664a:	2905                	addiw	s2,s2,1
    8000664c:	0611                	addi	a2,a2,4
    8000664e:	05690c63          	beq	s2,s6,800066a6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006652:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006654:	0023c717          	auipc	a4,0x23c
    80006658:	01470713          	addi	a4,a4,20 # 80242668 <disk>
    8000665c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000665e:	01874683          	lbu	a3,24(a4)
    80006662:	fee9                	bnez	a3,8000663c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006664:	2785                	addiw	a5,a5,1
    80006666:	0705                	addi	a4,a4,1
    80006668:	fe979be3          	bne	a5,s1,8000665e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000666c:	57fd                	li	a5,-1
    8000666e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006670:	01205d63          	blez	s2,8000668a <virtio_disk_rw+0xa6>
    80006674:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006676:	000a2503          	lw	a0,0(s4)
    8000667a:	00000097          	auipc	ra,0x0
    8000667e:	cfc080e7          	jalr	-772(ra) # 80006376 <free_desc>
      for(int j = 0; j < i; j++)
    80006682:	2d85                	addiw	s11,s11,1
    80006684:	0a11                	addi	s4,s4,4
    80006686:	ffb918e3          	bne	s2,s11,80006676 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000668a:	85e6                	mv	a1,s9
    8000668c:	0023c517          	auipc	a0,0x23c
    80006690:	ff450513          	addi	a0,a0,-12 # 80242680 <disk+0x18>
    80006694:	ffffc097          	auipc	ra,0xffffc
    80006698:	c92080e7          	jalr	-878(ra) # 80002326 <sleep>
  for(int i = 0; i < 3; i++){
    8000669c:	f8040a13          	addi	s4,s0,-128
{
    800066a0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800066a2:	894e                	mv	s2,s3
    800066a4:	b77d                	j	80006652 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066a6:	f8042583          	lw	a1,-128(s0)
    800066aa:	00a58793          	addi	a5,a1,10
    800066ae:	0792                	slli	a5,a5,0x4

  if(write)
    800066b0:	0023c617          	auipc	a2,0x23c
    800066b4:	fb860613          	addi	a2,a2,-72 # 80242668 <disk>
    800066b8:	00f60733          	add	a4,a2,a5
    800066bc:	018036b3          	snez	a3,s8
    800066c0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800066c2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800066c6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800066ca:	f6078693          	addi	a3,a5,-160
    800066ce:	6218                	ld	a4,0(a2)
    800066d0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066d2:	00878513          	addi	a0,a5,8
    800066d6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066d8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066da:	6208                	ld	a0,0(a2)
    800066dc:	96aa                	add	a3,a3,a0
    800066de:	4741                	li	a4,16
    800066e0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066e2:	4705                	li	a4,1
    800066e4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800066e8:	f8442703          	lw	a4,-124(s0)
    800066ec:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800066f0:	0712                	slli	a4,a4,0x4
    800066f2:	953a                	add	a0,a0,a4
    800066f4:	058a8693          	addi	a3,s5,88
    800066f8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800066fa:	6208                	ld	a0,0(a2)
    800066fc:	972a                	add	a4,a4,a0
    800066fe:	40000693          	li	a3,1024
    80006702:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006704:	001c3c13          	seqz	s8,s8
    80006708:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000670a:	001c6c13          	ori	s8,s8,1
    8000670e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006712:	f8842603          	lw	a2,-120(s0)
    80006716:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000671a:	0023c697          	auipc	a3,0x23c
    8000671e:	f4e68693          	addi	a3,a3,-178 # 80242668 <disk>
    80006722:	00258713          	addi	a4,a1,2
    80006726:	0712                	slli	a4,a4,0x4
    80006728:	9736                	add	a4,a4,a3
    8000672a:	587d                	li	a6,-1
    8000672c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006730:	0612                	slli	a2,a2,0x4
    80006732:	9532                	add	a0,a0,a2
    80006734:	f9078793          	addi	a5,a5,-112
    80006738:	97b6                	add	a5,a5,a3
    8000673a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000673c:	629c                	ld	a5,0(a3)
    8000673e:	97b2                	add	a5,a5,a2
    80006740:	4605                	li	a2,1
    80006742:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006744:	4509                	li	a0,2
    80006746:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000674a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000674e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006752:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006756:	6698                	ld	a4,8(a3)
    80006758:	00275783          	lhu	a5,2(a4)
    8000675c:	8b9d                	andi	a5,a5,7
    8000675e:	0786                	slli	a5,a5,0x1
    80006760:	97ba                	add	a5,a5,a4
    80006762:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006766:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000676a:	6698                	ld	a4,8(a3)
    8000676c:	00275783          	lhu	a5,2(a4)
    80006770:	2785                	addiw	a5,a5,1
    80006772:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006776:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000677a:	100017b7          	lui	a5,0x10001
    8000677e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006782:	004aa783          	lw	a5,4(s5)
    80006786:	02c79163          	bne	a5,a2,800067a8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000678a:	0023c917          	auipc	s2,0x23c
    8000678e:	00690913          	addi	s2,s2,6 # 80242790 <disk+0x128>
  while(b->disk == 1) {
    80006792:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006794:	85ca                	mv	a1,s2
    80006796:	8556                	mv	a0,s5
    80006798:	ffffc097          	auipc	ra,0xffffc
    8000679c:	b8e080e7          	jalr	-1138(ra) # 80002326 <sleep>
  while(b->disk == 1) {
    800067a0:	004aa783          	lw	a5,4(s5)
    800067a4:	fe9788e3          	beq	a5,s1,80006794 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800067a8:	f8042903          	lw	s2,-128(s0)
    800067ac:	00290793          	addi	a5,s2,2
    800067b0:	00479713          	slli	a4,a5,0x4
    800067b4:	0023c797          	auipc	a5,0x23c
    800067b8:	eb478793          	addi	a5,a5,-332 # 80242668 <disk>
    800067bc:	97ba                	add	a5,a5,a4
    800067be:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800067c2:	0023c997          	auipc	s3,0x23c
    800067c6:	ea698993          	addi	s3,s3,-346 # 80242668 <disk>
    800067ca:	00491713          	slli	a4,s2,0x4
    800067ce:	0009b783          	ld	a5,0(s3)
    800067d2:	97ba                	add	a5,a5,a4
    800067d4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800067d8:	854a                	mv	a0,s2
    800067da:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800067de:	00000097          	auipc	ra,0x0
    800067e2:	b98080e7          	jalr	-1128(ra) # 80006376 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800067e6:	8885                	andi	s1,s1,1
    800067e8:	f0ed                	bnez	s1,800067ca <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800067ea:	0023c517          	auipc	a0,0x23c
    800067ee:	fa650513          	addi	a0,a0,-90 # 80242790 <disk+0x128>
    800067f2:	ffffa097          	auipc	ra,0xffffa
    800067f6:	5b8080e7          	jalr	1464(ra) # 80000daa <release>
}
    800067fa:	70e6                	ld	ra,120(sp)
    800067fc:	7446                	ld	s0,112(sp)
    800067fe:	74a6                	ld	s1,104(sp)
    80006800:	7906                	ld	s2,96(sp)
    80006802:	69e6                	ld	s3,88(sp)
    80006804:	6a46                	ld	s4,80(sp)
    80006806:	6aa6                	ld	s5,72(sp)
    80006808:	6b06                	ld	s6,64(sp)
    8000680a:	7be2                	ld	s7,56(sp)
    8000680c:	7c42                	ld	s8,48(sp)
    8000680e:	7ca2                	ld	s9,40(sp)
    80006810:	7d02                	ld	s10,32(sp)
    80006812:	6de2                	ld	s11,24(sp)
    80006814:	6109                	addi	sp,sp,128
    80006816:	8082                	ret

0000000080006818 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006818:	1101                	addi	sp,sp,-32
    8000681a:	ec06                	sd	ra,24(sp)
    8000681c:	e822                	sd	s0,16(sp)
    8000681e:	e426                	sd	s1,8(sp)
    80006820:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006822:	0023c497          	auipc	s1,0x23c
    80006826:	e4648493          	addi	s1,s1,-442 # 80242668 <disk>
    8000682a:	0023c517          	auipc	a0,0x23c
    8000682e:	f6650513          	addi	a0,a0,-154 # 80242790 <disk+0x128>
    80006832:	ffffa097          	auipc	ra,0xffffa
    80006836:	4c4080e7          	jalr	1220(ra) # 80000cf6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000683a:	10001737          	lui	a4,0x10001
    8000683e:	533c                	lw	a5,96(a4)
    80006840:	8b8d                	andi	a5,a5,3
    80006842:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006844:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006848:	689c                	ld	a5,16(s1)
    8000684a:	0204d703          	lhu	a4,32(s1)
    8000684e:	0027d783          	lhu	a5,2(a5)
    80006852:	04f70863          	beq	a4,a5,800068a2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006856:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000685a:	6898                	ld	a4,16(s1)
    8000685c:	0204d783          	lhu	a5,32(s1)
    80006860:	8b9d                	andi	a5,a5,7
    80006862:	078e                	slli	a5,a5,0x3
    80006864:	97ba                	add	a5,a5,a4
    80006866:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006868:	00278713          	addi	a4,a5,2
    8000686c:	0712                	slli	a4,a4,0x4
    8000686e:	9726                	add	a4,a4,s1
    80006870:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006874:	e721                	bnez	a4,800068bc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006876:	0789                	addi	a5,a5,2
    80006878:	0792                	slli	a5,a5,0x4
    8000687a:	97a6                	add	a5,a5,s1
    8000687c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000687e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006882:	ffffc097          	auipc	ra,0xffffc
    80006886:	b08080e7          	jalr	-1272(ra) # 8000238a <wakeup>

    disk.used_idx += 1;
    8000688a:	0204d783          	lhu	a5,32(s1)
    8000688e:	2785                	addiw	a5,a5,1
    80006890:	17c2                	slli	a5,a5,0x30
    80006892:	93c1                	srli	a5,a5,0x30
    80006894:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006898:	6898                	ld	a4,16(s1)
    8000689a:	00275703          	lhu	a4,2(a4)
    8000689e:	faf71ce3          	bne	a4,a5,80006856 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800068a2:	0023c517          	auipc	a0,0x23c
    800068a6:	eee50513          	addi	a0,a0,-274 # 80242790 <disk+0x128>
    800068aa:	ffffa097          	auipc	ra,0xffffa
    800068ae:	500080e7          	jalr	1280(ra) # 80000daa <release>
}
    800068b2:	60e2                	ld	ra,24(sp)
    800068b4:	6442                	ld	s0,16(sp)
    800068b6:	64a2                	ld	s1,8(sp)
    800068b8:	6105                	addi	sp,sp,32
    800068ba:	8082                	ret
      panic("virtio_disk_intr status");
    800068bc:	00002517          	auipc	a0,0x2
    800068c0:	fb450513          	addi	a0,a0,-76 # 80008870 <syscalls+0x3f0>
    800068c4:	ffffa097          	auipc	ra,0xffffa
    800068c8:	c7a080e7          	jalr	-902(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
