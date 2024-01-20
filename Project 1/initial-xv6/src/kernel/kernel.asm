
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a3010113          	addi	sp,sp,-1488 # 80008a30 <stack0>
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
    80000056:	89e70713          	addi	a4,a4,-1890 # 800088f0 <timer_scratch>
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
    80000068:	fac78793          	addi	a5,a5,-84 # 80006010 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb88f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
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
    80000130:	3f0080e7          	jalr	1008(ra) # 8000251c <either_copyin>
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
    8000018e:	8a650513          	addi	a0,a0,-1882 # 80010a30 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	89648493          	addi	s1,s1,-1898 # 80010a30 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	92690913          	addi	s2,s2,-1754 # 80010ac8 <cons+0x98>
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
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	19e080e7          	jalr	414(ra) # 80002366 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	edc080e7          	jalr	-292(ra) # 800020b2 <sleep>
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
    80000216:	2b4080e7          	jalr	692(ra) # 800024c6 <either_copyout>
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
    8000022a:	80a50513          	addi	a0,a0,-2038 # 80010a30 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00010517          	auipc	a0,0x10
    80000240:	7f450513          	addi	a0,a0,2036 # 80010a30 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
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
    80000276:	84f72b23          	sw	a5,-1962(a4) # 80010ac8 <cons+0x98>
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
    800002d0:	76450513          	addi	a0,a0,1892 # 80010a30 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

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
    800002f6:	280080e7          	jalr	640(ra) # 80002572 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	73650513          	addi	a0,a0,1846 # 80010a30 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
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
    80000322:	71270713          	addi	a4,a4,1810 # 80010a30 <cons>
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
    8000034c:	6e878793          	addi	a5,a5,1768 # 80010a30 <cons>
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
    8000037a:	7527a783          	lw	a5,1874(a5) # 80010ac8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6a670713          	addi	a4,a4,1702 # 80010a30 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	69648493          	addi	s1,s1,1686 # 80010a30 <cons>
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
    800003da:	65a70713          	addi	a4,a4,1626 # 80010a30 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6ef72223          	sw	a5,1764(a4) # 80010ad0 <cons+0xa0>
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
    80000416:	61e78793          	addi	a5,a5,1566 # 80010a30 <cons>
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
    8000043a:	68c7ab23          	sw	a2,1686(a5) # 80010acc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	68a50513          	addi	a0,a0,1674 # 80010ac8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	cd0080e7          	jalr	-816(ra) # 80002116 <wakeup>
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
    80000464:	5d050513          	addi	a0,a0,1488 # 80010a30 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	96078793          	addi	a5,a5,-1696 # 80021dd8 <devsw>
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
    8000054e:	5a07a323          	sw	zero,1446(a5) # 80010af0 <pr+0x18>
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
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	32f72923          	sw	a5,818(a4) # 800088b0 <panicked>
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
    800005be:	536dad83          	lw	s11,1334(s11) # 80010af0 <pr+0x18>
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
    800005fc:	4e050513          	addi	a0,a0,1248 # 80010ad8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
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
    8000075a:	38250513          	addi	a0,a0,898 # 80010ad8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
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
    80000776:	36648493          	addi	s1,s1,870 # 80010ad8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
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
    800007d6:	32650513          	addi	a0,a0,806 # 80010af8 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
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
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0b27a783          	lw	a5,178(a5) # 800088b0 <panicked>
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
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
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
    8000083a:	0827b783          	ld	a5,130(a5) # 800088b8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	08273703          	ld	a4,130(a4) # 800088c0 <uart_tx_w>
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
    80000864:	298a0a13          	addi	s4,s4,664 # 80010af8 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	05048493          	addi	s1,s1,80 # 800088b8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	05098993          	addi	s3,s3,80 # 800088c0 <uart_tx_w>
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
    80000896:	884080e7          	jalr	-1916(ra) # 80002116 <wakeup>
    
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
    800008d2:	22a50513          	addi	a0,a0,554 # 80010af8 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	fd27a783          	lw	a5,-46(a5) # 800088b0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fd873703          	ld	a4,-40(a4) # 800088c0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fc87b783          	ld	a5,-56(a5) # 800088b8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	1fc98993          	addi	s3,s3,508 # 80010af8 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fb448493          	addi	s1,s1,-76 # 800088b8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fb490913          	addi	s2,s2,-76 # 800088c0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	796080e7          	jalr	1942(ra) # 800020b2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1c648493          	addi	s1,s1,454 # 80010af8 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f6e7bd23          	sd	a4,-134(a5) # 800088c0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
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
    800009c0:	13c48493          	addi	s1,s1,316 # 80010af8 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00022797          	auipc	a5,0x22
    80000a02:	57278793          	addi	a5,a5,1394 # 80022f70 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	11290913          	addi	s2,s2,274 # 80010b30 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	07650513          	addi	a0,a0,118 # 80010b30 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	4a250513          	addi	a0,a0,1186 # 80022f70 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	04048493          	addi	s1,s1,64 # 80010b30 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	02850513          	addi	a0,a0,40 # 80010b30 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	ffc50513          	addi	a0,a0,-4 # 80010b30 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a4070713          	addi	a4,a4,-1472 # 800088c8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	a1a080e7          	jalr	-1510(ra) # 800028d8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	18a080e7          	jalr	394(ra) # 80006050 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	032080e7          	jalr	50(ra) # 80001f00 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	97a080e7          	jalr	-1670(ra) # 800028b0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	99a080e7          	jalr	-1638(ra) # 800028d8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	0f4080e7          	jalr	244(ra) # 8000603a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	102080e7          	jalr	258(ra) # 80006050 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	2a4080e7          	jalr	676(ra) # 800031fa <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	948080e7          	jalr	-1720(ra) # 800038a6 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	8e6080e7          	jalr	-1818(ra) # 8000484c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	1ea080e7          	jalr	490(ra) # 80006158 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d40080e7          	jalr	-704(ra) # 80001cb6 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	94f72223          	sw	a5,-1724(a4) # 800088c8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9387b783          	ld	a5,-1736(a5) # 800088d0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	66a7be23          	sd	a0,1660(a5) # 800088d0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	74448493          	addi	s1,s1,1860 # 80010f90 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1
    80001864:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001866:	00016a17          	auipc	s4,0x16
    8000186a:	32aa0a13          	addi	s4,s4,810 # 80017b90 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if (pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	8591                	srai	a1,a1,0x4
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018a0:	1b048493          	addi	s1,s1,432
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7a080e7          	jalr	-902(ra) # 8000053e <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	26850513          	addi	a0,a0,616 # 80010b50 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	26850513          	addi	a0,a0,616 # 80010b68 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	68048493          	addi	s1,s1,1664 # 80010f90 <proc>
  {
    initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1
    80001930:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001932:	00016997          	auipc	s3,0x16
    80001936:	25e98993          	addi	s3,s3,606 # 80017b90 <tickslock>
    initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	8791                	srai	a5,a5,0x4
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	fcbc                	sd	a5,120(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001964:	1b048493          	addi	s1,s1,432
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	1e450513          	addi	a0,a0,484 # 80010b80 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	18c70713          	addi	a4,a4,396 # 80010b50 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first)
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	e647a783          	lw	a5,-412(a5) # 80008860 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	eea080e7          	jalr	-278(ra) # 800028f0 <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e407a523          	sw	zero,-438(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	e06080e7          	jalr	-506(ra) # 80003826 <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	11a90913          	addi	s2,s2,282 # 80010b50 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e1c78793          	addi	a5,a5,-484 # 80008864 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	09093683          	ld	a3,144(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a52080e7          	jalr	-1454(ra) # 8000152c <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2c080e7          	jalr	-1492(ra) # 8000152c <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e2080e7          	jalr	-1566(ra) # 8000152c <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b6a:	6948                	ld	a0,144(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7c080e7          	jalr	-388(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b76:	0804b823          	sd	zero,144(s1)
  if (p->pagetable)
    80001b7a:	64c8                	ld	a0,136(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	60cc                	ld	a1,128(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0804b423          	sd	zero,136(s1)
  p->sz = 0;
    80001b8c:	0804b023          	sd	zero,128(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0604b823          	sd	zero,112(s1)
  p->name[0] = 0;
    80001b98:	18048823          	sb	zero,400(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	3ce48493          	addi	s1,s1,974 # 80010f90 <proc>
    80001bca:	00016917          	auipc	s2,0x16
    80001bce:	fc690913          	addi	s2,s2,-58 # 80017b90 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001bea:	1b048493          	addi	s1,s1,432
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a051                	j	80001c78 <allocproc+0xc2>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  p->read_count = 0;
    80001c04:	0204aa23          	sw	zero,52(s1)
  p->cur_ticks = 0;
    80001c08:	0404a223          	sw	zero,68(s1)
  p->arrival_time = ticks;
    80001c0c:	00007797          	auipc	a5,0x7
    80001c10:	cd47a783          	lw	a5,-812(a5) # 800088e0 <ticks>
    80001c14:	c8fc                	sw	a5,84(s1)
  p->wait_time = 0;
    80001c16:	0404ae23          	sw	zero,92(s1)
  p->tstp_curr = 0;
    80001c1a:	0604a223          	sw	zero,100(s1)
  p->tsleep = 0;
    80001c1e:	0604a423          	sw	zero,104(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	ec4080e7          	jalr	-316(ra) # 80000ae6 <kalloc>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	e8c8                	sd	a0,144(s1)
    80001c2e:	cd21                	beqz	a0,80001c86 <allocproc+0xd0>
  p->pagetable = proc_pagetable(p);
    80001c30:	8526                	mv	a0,s1
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	e3e080e7          	jalr	-450(ra) # 80001a70 <proc_pagetable>
    80001c3a:	892a                	mv	s2,a0
    80001c3c:	e4c8                	sd	a0,136(s1)
  if (p->pagetable == 0)
    80001c3e:	c125                	beqz	a0,80001c9e <allocproc+0xe8>
  memset(&p->context, 0, sizeof(p->context));
    80001c40:	07000613          	li	a2,112
    80001c44:	4581                	li	a1,0
    80001c46:	09848513          	addi	a0,s1,152
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	088080e7          	jalr	136(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c52:	00000797          	auipc	a5,0x0
    80001c56:	d9278793          	addi	a5,a5,-622 # 800019e4 <forkret>
    80001c5a:	ecdc                	sd	a5,152(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c5c:	7cbc                	ld	a5,120(s1)
    80001c5e:	6705                	lui	a4,0x1
    80001c60:	97ba                	add	a5,a5,a4
    80001c62:	f0dc                	sd	a5,160(s1)
  p->rtime = 0;
    80001c64:	1a04a023          	sw	zero,416(s1)
  p->etime = 0;
    80001c68:	1a04a423          	sw	zero,424(s1)
  p->ctime = ticks;
    80001c6c:	00007797          	auipc	a5,0x7
    80001c70:	c747a783          	lw	a5,-908(a5) # 800088e0 <ticks>
    80001c74:	1af4a223          	sw	a5,420(s1)
}
    80001c78:	8526                	mv	a0,s1
    80001c7a:	60e2                	ld	ra,24(sp)
    80001c7c:	6442                	ld	s0,16(sp)
    80001c7e:	64a2                	ld	s1,8(sp)
    80001c80:	6902                	ld	s2,0(sp)
    80001c82:	6105                	addi	sp,sp,32
    80001c84:	8082                	ret
    freeproc(p);
    80001c86:	8526                	mv	a0,s1
    80001c88:	00000097          	auipc	ra,0x0
    80001c8c:	ed6080e7          	jalr	-298(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c90:	8526                	mv	a0,s1
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	ff8080e7          	jalr	-8(ra) # 80000c8a <release>
    return 0;
    80001c9a:	84ca                	mv	s1,s2
    80001c9c:	bff1                	j	80001c78 <allocproc+0xc2>
    freeproc(p);
    80001c9e:	8526                	mv	a0,s1
    80001ca0:	00000097          	auipc	ra,0x0
    80001ca4:	ebe080e7          	jalr	-322(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	fe0080e7          	jalr	-32(ra) # 80000c8a <release>
    return 0;
    80001cb2:	84ca                	mv	s1,s2
    80001cb4:	b7d1                	j	80001c78 <allocproc+0xc2>

0000000080001cb6 <userinit>:
{
    80001cb6:	1101                	addi	sp,sp,-32
    80001cb8:	ec06                	sd	ra,24(sp)
    80001cba:	e822                	sd	s0,16(sp)
    80001cbc:	e426                	sd	s1,8(sp)
    80001cbe:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cc0:	00000097          	auipc	ra,0x0
    80001cc4:	ef6080e7          	jalr	-266(ra) # 80001bb6 <allocproc>
    80001cc8:	84aa                	mv	s1,a0
  initproc = p;
    80001cca:	00007797          	auipc	a5,0x7
    80001cce:	c0a7b723          	sd	a0,-1010(a5) # 800088d8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cd2:	03400613          	li	a2,52
    80001cd6:	00007597          	auipc	a1,0x7
    80001cda:	b9a58593          	addi	a1,a1,-1126 # 80008870 <initcode>
    80001cde:	6548                	ld	a0,136(a0)
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	676080e7          	jalr	1654(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001ce8:	6785                	lui	a5,0x1
    80001cea:	e0dc                	sd	a5,128(s1)
  p->trapframe->epc = 0;     // user program counter
    80001cec:	68d8                	ld	a4,144(s1)
    80001cee:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001cf2:	68d8                	ld	a4,144(s1)
    80001cf4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cf6:	4641                	li	a2,16
    80001cf8:	00006597          	auipc	a1,0x6
    80001cfc:	50858593          	addi	a1,a1,1288 # 80008200 <digits+0x1c0>
    80001d00:	19048513          	addi	a0,s1,400
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	118080e7          	jalr	280(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d0c:	00006517          	auipc	a0,0x6
    80001d10:	50450513          	addi	a0,a0,1284 # 80008210 <digits+0x1d0>
    80001d14:	00002097          	auipc	ra,0x2
    80001d18:	534080e7          	jalr	1332(ra) # 80004248 <namei>
    80001d1c:	18a4b423          	sd	a0,392(s1)
  p->state = RUNNABLE;
    80001d20:	478d                	li	a5,3
    80001d22:	cc9c                	sw	a5,24(s1)
  p->q_no = 0;
    80001d24:	0404ac23          	sw	zero,88(s1)
  qcount[0]++;
    80001d28:	0000f717          	auipc	a4,0xf
    80001d2c:	e2870713          	addi	a4,a4,-472 # 80010b50 <pid_lock>
    80001d30:	43072783          	lw	a5,1072(a4)
    80001d34:	2785                	addiw	a5,a5,1
    80001d36:	42f72823          	sw	a5,1072(a4)
  release(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	f4e080e7          	jalr	-178(ra) # 80000c8a <release>
}
    80001d44:	60e2                	ld	ra,24(sp)
    80001d46:	6442                	ld	s0,16(sp)
    80001d48:	64a2                	ld	s1,8(sp)
    80001d4a:	6105                	addi	sp,sp,32
    80001d4c:	8082                	ret

0000000080001d4e <growproc>:
{
    80001d4e:	1101                	addi	sp,sp,-32
    80001d50:	ec06                	sd	ra,24(sp)
    80001d52:	e822                	sd	s0,16(sp)
    80001d54:	e426                	sd	s1,8(sp)
    80001d56:	e04a                	sd	s2,0(sp)
    80001d58:	1000                	addi	s0,sp,32
    80001d5a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d5c:	00000097          	auipc	ra,0x0
    80001d60:	c50080e7          	jalr	-944(ra) # 800019ac <myproc>
    80001d64:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d66:	614c                	ld	a1,128(a0)
  if (n > 0)
    80001d68:	01204c63          	bgtz	s2,80001d80 <growproc+0x32>
  else if (n < 0)
    80001d6c:	02094663          	bltz	s2,80001d98 <growproc+0x4a>
  p->sz = sz;
    80001d70:	e0cc                	sd	a1,128(s1)
  return 0;
    80001d72:	4501                	li	a0,0
}
    80001d74:	60e2                	ld	ra,24(sp)
    80001d76:	6442                	ld	s0,16(sp)
    80001d78:	64a2                	ld	s1,8(sp)
    80001d7a:	6902                	ld	s2,0(sp)
    80001d7c:	6105                	addi	sp,sp,32
    80001d7e:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001d80:	4691                	li	a3,4
    80001d82:	00b90633          	add	a2,s2,a1
    80001d86:	6548                	ld	a0,136(a0)
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	688080e7          	jalr	1672(ra) # 80001410 <uvmalloc>
    80001d90:	85aa                	mv	a1,a0
    80001d92:	fd79                	bnez	a0,80001d70 <growproc+0x22>
      return -1;
    80001d94:	557d                	li	a0,-1
    80001d96:	bff9                	j	80001d74 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d98:	00b90633          	add	a2,s2,a1
    80001d9c:	6548                	ld	a0,136(a0)
    80001d9e:	fffff097          	auipc	ra,0xfffff
    80001da2:	62a080e7          	jalr	1578(ra) # 800013c8 <uvmdealloc>
    80001da6:	85aa                	mv	a1,a0
    80001da8:	b7e1                	j	80001d70 <growproc+0x22>

0000000080001daa <fork>:
{
    80001daa:	7139                	addi	sp,sp,-64
    80001dac:	fc06                	sd	ra,56(sp)
    80001dae:	f822                	sd	s0,48(sp)
    80001db0:	f426                	sd	s1,40(sp)
    80001db2:	f04a                	sd	s2,32(sp)
    80001db4:	ec4e                	sd	s3,24(sp)
    80001db6:	e852                	sd	s4,16(sp)
    80001db8:	e456                	sd	s5,8(sp)
    80001dba:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	bf0080e7          	jalr	-1040(ra) # 800019ac <myproc>
    80001dc4:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001dc6:	00000097          	auipc	ra,0x0
    80001dca:	df0080e7          	jalr	-528(ra) # 80001bb6 <allocproc>
    80001dce:	12050763          	beqz	a0,80001efc <fork+0x152>
    80001dd2:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001dd4:	080ab603          	ld	a2,128(s5)
    80001dd8:	654c                	ld	a1,136(a0)
    80001dda:	088ab503          	ld	a0,136(s5)
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	786080e7          	jalr	1926(ra) # 80001564 <uvmcopy>
    80001de6:	04054863          	bltz	a0,80001e36 <fork+0x8c>
  np->sz = p->sz;
    80001dea:	080ab783          	ld	a5,128(s5)
    80001dee:	08fa3023          	sd	a5,128(s4)
  *(np->trapframe) = *(p->trapframe);
    80001df2:	090ab683          	ld	a3,144(s5)
    80001df6:	87b6                	mv	a5,a3
    80001df8:	090a3703          	ld	a4,144(s4)
    80001dfc:	12068693          	addi	a3,a3,288
    80001e00:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e04:	6788                	ld	a0,8(a5)
    80001e06:	6b8c                	ld	a1,16(a5)
    80001e08:	6f90                	ld	a2,24(a5)
    80001e0a:	01073023          	sd	a6,0(a4)
    80001e0e:	e708                	sd	a0,8(a4)
    80001e10:	eb0c                	sd	a1,16(a4)
    80001e12:	ef10                	sd	a2,24(a4)
    80001e14:	02078793          	addi	a5,a5,32
    80001e18:	02070713          	addi	a4,a4,32
    80001e1c:	fed792e3          	bne	a5,a3,80001e00 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e20:	090a3783          	ld	a5,144(s4)
    80001e24:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e28:	108a8493          	addi	s1,s5,264
    80001e2c:	108a0913          	addi	s2,s4,264
    80001e30:	188a8993          	addi	s3,s5,392
    80001e34:	a00d                	j	80001e56 <fork+0xac>
    freeproc(np);
    80001e36:	8552                	mv	a0,s4
    80001e38:	00000097          	auipc	ra,0x0
    80001e3c:	d26080e7          	jalr	-730(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e40:	8552                	mv	a0,s4
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	e48080e7          	jalr	-440(ra) # 80000c8a <release>
    return -1;
    80001e4a:	59fd                	li	s3,-1
    80001e4c:	a871                	j	80001ee8 <fork+0x13e>
  for (i = 0; i < NOFILE; i++)
    80001e4e:	04a1                	addi	s1,s1,8
    80001e50:	0921                	addi	s2,s2,8
    80001e52:	01348b63          	beq	s1,s3,80001e68 <fork+0xbe>
    if (p->ofile[i])
    80001e56:	6088                	ld	a0,0(s1)
    80001e58:	d97d                	beqz	a0,80001e4e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e5a:	00003097          	auipc	ra,0x3
    80001e5e:	a84080e7          	jalr	-1404(ra) # 800048de <filedup>
    80001e62:	00a93023          	sd	a0,0(s2)
    80001e66:	b7e5                	j	80001e4e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e68:	188ab503          	ld	a0,392(s5)
    80001e6c:	00002097          	auipc	ra,0x2
    80001e70:	bf8080e7          	jalr	-1032(ra) # 80003a64 <idup>
    80001e74:	18aa3423          	sd	a0,392(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e78:	4641                	li	a2,16
    80001e7a:	190a8593          	addi	a1,s5,400
    80001e7e:	190a0513          	addi	a0,s4,400
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	f9a080e7          	jalr	-102(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e8a:	030a2983          	lw	s3,48(s4)
  release(&np->lock);
    80001e8e:	8552                	mv	a0,s4
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	dfa080e7          	jalr	-518(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e98:	0000f497          	auipc	s1,0xf
    80001e9c:	cb848493          	addi	s1,s1,-840 # 80010b50 <pid_lock>
    80001ea0:	0000f917          	auipc	s2,0xf
    80001ea4:	cc890913          	addi	s2,s2,-824 # 80010b68 <wait_lock>
    80001ea8:	854a                	mv	a0,s2
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	d2c080e7          	jalr	-724(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001eb2:	075a3823          	sd	s5,112(s4)
  release(&wait_lock);
    80001eb6:	854a                	mv	a0,s2
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	dd2080e7          	jalr	-558(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ec0:	8552                	mv	a0,s4
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	d14080e7          	jalr	-748(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001eca:	478d                	li	a5,3
    80001ecc:	00fa2c23          	sw	a5,24(s4)
  p->q_no = 0;
    80001ed0:	040aac23          	sw	zero,88(s5)
  qcount[0]++;
    80001ed4:	4304a783          	lw	a5,1072(s1)
    80001ed8:	2785                	addiw	a5,a5,1
    80001eda:	42f4a823          	sw	a5,1072(s1)
  release(&np->lock);
    80001ede:	8552                	mv	a0,s4
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	daa080e7          	jalr	-598(ra) # 80000c8a <release>
}
    80001ee8:	854e                	mv	a0,s3
    80001eea:	70e2                	ld	ra,56(sp)
    80001eec:	7442                	ld	s0,48(sp)
    80001eee:	74a2                	ld	s1,40(sp)
    80001ef0:	7902                	ld	s2,32(sp)
    80001ef2:	69e2                	ld	s3,24(sp)
    80001ef4:	6a42                	ld	s4,16(sp)
    80001ef6:	6aa2                	ld	s5,8(sp)
    80001ef8:	6121                	addi	sp,sp,64
    80001efa:	8082                	ret
    return -1;
    80001efc:	59fd                	li	s3,-1
    80001efe:	b7ed                	j	80001ee8 <fork+0x13e>

0000000080001f00 <scheduler>:
{
    80001f00:	7139                	addi	sp,sp,-64
    80001f02:	fc06                	sd	ra,56(sp)
    80001f04:	f822                	sd	s0,48(sp)
    80001f06:	f426                	sd	s1,40(sp)
    80001f08:	f04a                	sd	s2,32(sp)
    80001f0a:	ec4e                	sd	s3,24(sp)
    80001f0c:	e852                	sd	s4,16(sp)
    80001f0e:	e456                	sd	s5,8(sp)
    80001f10:	e05a                	sd	s6,0(sp)
    80001f12:	0080                	addi	s0,sp,64
    80001f14:	8792                	mv	a5,tp
  int id = r_tp();
    80001f16:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f18:	00779a93          	slli	s5,a5,0x7
    80001f1c:	0000f717          	auipc	a4,0xf
    80001f20:	c3470713          	addi	a4,a4,-972 # 80010b50 <pid_lock>
    80001f24:	9756                	add	a4,a4,s5
    80001f26:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f2a:	0000f717          	auipc	a4,0xf
    80001f2e:	c5e70713          	addi	a4,a4,-930 # 80010b88 <cpus+0x8>
    80001f32:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001f34:	498d                	li	s3,3
        p->state = RUNNING;
    80001f36:	4b11                	li	s6,4
        c->proc = p;
    80001f38:	079e                	slli	a5,a5,0x7
    80001f3a:	0000fa17          	auipc	s4,0xf
    80001f3e:	c16a0a13          	addi	s4,s4,-1002 # 80010b50 <pid_lock>
    80001f42:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001f44:	00016917          	auipc	s2,0x16
    80001f48:	c4c90913          	addi	s2,s2,-948 # 80017b90 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f4c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f50:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f54:	10079073          	csrw	sstatus,a5
    80001f58:	0000f497          	auipc	s1,0xf
    80001f5c:	03848493          	addi	s1,s1,56 # 80010f90 <proc>
    80001f60:	a811                	j	80001f74 <scheduler+0x74>
      release(&p->lock);
    80001f62:	8526                	mv	a0,s1
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	d26080e7          	jalr	-730(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f6c:	1b048493          	addi	s1,s1,432
    80001f70:	fd248ee3          	beq	s1,s2,80001f4c <scheduler+0x4c>
      acquire(&p->lock);
    80001f74:	8526                	mv	a0,s1
    80001f76:	fffff097          	auipc	ra,0xfffff
    80001f7a:	c60080e7          	jalr	-928(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80001f7e:	4c9c                	lw	a5,24(s1)
    80001f80:	ff3791e3          	bne	a5,s3,80001f62 <scheduler+0x62>
        p->state = RUNNING;
    80001f84:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f88:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f8c:	09848593          	addi	a1,s1,152
    80001f90:	8556                	mv	a0,s5
    80001f92:	00001097          	auipc	ra,0x1
    80001f96:	8b4080e7          	jalr	-1868(ra) # 80002846 <swtch>
        c->proc = 0;
    80001f9a:	020a3823          	sd	zero,48(s4)
    80001f9e:	b7d1                	j	80001f62 <scheduler+0x62>

0000000080001fa0 <sched>:
{
    80001fa0:	7179                	addi	sp,sp,-48
    80001fa2:	f406                	sd	ra,40(sp)
    80001fa4:	f022                	sd	s0,32(sp)
    80001fa6:	ec26                	sd	s1,24(sp)
    80001fa8:	e84a                	sd	s2,16(sp)
    80001faa:	e44e                	sd	s3,8(sp)
    80001fac:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fae:	00000097          	auipc	ra,0x0
    80001fb2:	9fe080e7          	jalr	-1538(ra) # 800019ac <myproc>
    80001fb6:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	ba4080e7          	jalr	-1116(ra) # 80000b5c <holding>
    80001fc0:	c93d                	beqz	a0,80002036 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fc2:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001fc4:	2781                	sext.w	a5,a5
    80001fc6:	079e                	slli	a5,a5,0x7
    80001fc8:	0000f717          	auipc	a4,0xf
    80001fcc:	b8870713          	addi	a4,a4,-1144 # 80010b50 <pid_lock>
    80001fd0:	97ba                	add	a5,a5,a4
    80001fd2:	0a87a703          	lw	a4,168(a5)
    80001fd6:	4785                	li	a5,1
    80001fd8:	06f71763          	bne	a4,a5,80002046 <sched+0xa6>
  if (p->state == RUNNING)
    80001fdc:	4c98                	lw	a4,24(s1)
    80001fde:	4791                	li	a5,4
    80001fe0:	06f70b63          	beq	a4,a5,80002056 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fe4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fe8:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001fea:	efb5                	bnez	a5,80002066 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fec:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fee:	0000f917          	auipc	s2,0xf
    80001ff2:	b6290913          	addi	s2,s2,-1182 # 80010b50 <pid_lock>
    80001ff6:	2781                	sext.w	a5,a5
    80001ff8:	079e                	slli	a5,a5,0x7
    80001ffa:	97ca                	add	a5,a5,s2
    80001ffc:	0ac7a983          	lw	s3,172(a5)
    80002000:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002002:	2781                	sext.w	a5,a5
    80002004:	079e                	slli	a5,a5,0x7
    80002006:	0000f597          	auipc	a1,0xf
    8000200a:	b8258593          	addi	a1,a1,-1150 # 80010b88 <cpus+0x8>
    8000200e:	95be                	add	a1,a1,a5
    80002010:	09848513          	addi	a0,s1,152
    80002014:	00001097          	auipc	ra,0x1
    80002018:	832080e7          	jalr	-1998(ra) # 80002846 <swtch>
    8000201c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000201e:	2781                	sext.w	a5,a5
    80002020:	079e                	slli	a5,a5,0x7
    80002022:	97ca                	add	a5,a5,s2
    80002024:	0b37a623          	sw	s3,172(a5)
}
    80002028:	70a2                	ld	ra,40(sp)
    8000202a:	7402                	ld	s0,32(sp)
    8000202c:	64e2                	ld	s1,24(sp)
    8000202e:	6942                	ld	s2,16(sp)
    80002030:	69a2                	ld	s3,8(sp)
    80002032:	6145                	addi	sp,sp,48
    80002034:	8082                	ret
    panic("sched p->lock");
    80002036:	00006517          	auipc	a0,0x6
    8000203a:	1e250513          	addi	a0,a0,482 # 80008218 <digits+0x1d8>
    8000203e:	ffffe097          	auipc	ra,0xffffe
    80002042:	500080e7          	jalr	1280(ra) # 8000053e <panic>
    panic("sched locks");
    80002046:	00006517          	auipc	a0,0x6
    8000204a:	1e250513          	addi	a0,a0,482 # 80008228 <digits+0x1e8>
    8000204e:	ffffe097          	auipc	ra,0xffffe
    80002052:	4f0080e7          	jalr	1264(ra) # 8000053e <panic>
    panic("sched running");
    80002056:	00006517          	auipc	a0,0x6
    8000205a:	1e250513          	addi	a0,a0,482 # 80008238 <digits+0x1f8>
    8000205e:	ffffe097          	auipc	ra,0xffffe
    80002062:	4e0080e7          	jalr	1248(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002066:	00006517          	auipc	a0,0x6
    8000206a:	1e250513          	addi	a0,a0,482 # 80008248 <digits+0x208>
    8000206e:	ffffe097          	auipc	ra,0xffffe
    80002072:	4d0080e7          	jalr	1232(ra) # 8000053e <panic>

0000000080002076 <yield>:
{
    80002076:	1101                	addi	sp,sp,-32
    80002078:	ec06                	sd	ra,24(sp)
    8000207a:	e822                	sd	s0,16(sp)
    8000207c:	e426                	sd	s1,8(sp)
    8000207e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002080:	00000097          	auipc	ra,0x0
    80002084:	92c080e7          	jalr	-1748(ra) # 800019ac <myproc>
    80002088:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000208a:	fffff097          	auipc	ra,0xfffff
    8000208e:	b4c080e7          	jalr	-1204(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002092:	478d                	li	a5,3
    80002094:	cc9c                	sw	a5,24(s1)
  sched();
    80002096:	00000097          	auipc	ra,0x0
    8000209a:	f0a080e7          	jalr	-246(ra) # 80001fa0 <sched>
  release(&p->lock);
    8000209e:	8526                	mv	a0,s1
    800020a0:	fffff097          	auipc	ra,0xfffff
    800020a4:	bea080e7          	jalr	-1046(ra) # 80000c8a <release>
}
    800020a8:	60e2                	ld	ra,24(sp)
    800020aa:	6442                	ld	s0,16(sp)
    800020ac:	64a2                	ld	s1,8(sp)
    800020ae:	6105                	addi	sp,sp,32
    800020b0:	8082                	ret

00000000800020b2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800020b2:	7179                	addi	sp,sp,-48
    800020b4:	f406                	sd	ra,40(sp)
    800020b6:	f022                	sd	s0,32(sp)
    800020b8:	ec26                	sd	s1,24(sp)
    800020ba:	e84a                	sd	s2,16(sp)
    800020bc:	e44e                	sd	s3,8(sp)
    800020be:	1800                	addi	s0,sp,48
    800020c0:	89aa                	mv	s3,a0
    800020c2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020c4:	00000097          	auipc	ra,0x0
    800020c8:	8e8080e7          	jalr	-1816(ra) # 800019ac <myproc>
    800020cc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	b08080e7          	jalr	-1272(ra) # 80000bd6 <acquire>
  release(lk);
    800020d6:	854a                	mv	a0,s2
    800020d8:	fffff097          	auipc	ra,0xfffff
    800020dc:	bb2080e7          	jalr	-1102(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800020e0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020e4:	4789                	li	a5,2
    800020e6:	cc9c                	sw	a5,24(s1)

  sched();
    800020e8:	00000097          	auipc	ra,0x0
    800020ec:	eb8080e7          	jalr	-328(ra) # 80001fa0 <sched>

  // Tidy up.
  p->chan = 0;
    800020f0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020f4:	8526                	mv	a0,s1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	b94080e7          	jalr	-1132(ra) # 80000c8a <release>
  acquire(lk);
    800020fe:	854a                	mv	a0,s2
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	ad6080e7          	jalr	-1322(ra) # 80000bd6 <acquire>
}
    80002108:	70a2                	ld	ra,40(sp)
    8000210a:	7402                	ld	s0,32(sp)
    8000210c:	64e2                	ld	s1,24(sp)
    8000210e:	6942                	ld	s2,16(sp)
    80002110:	69a2                	ld	s3,8(sp)
    80002112:	6145                	addi	sp,sp,48
    80002114:	8082                	ret

0000000080002116 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002116:	7139                	addi	sp,sp,-64
    80002118:	fc06                	sd	ra,56(sp)
    8000211a:	f822                	sd	s0,48(sp)
    8000211c:	f426                	sd	s1,40(sp)
    8000211e:	f04a                	sd	s2,32(sp)
    80002120:	ec4e                	sd	s3,24(sp)
    80002122:	e852                	sd	s4,16(sp)
    80002124:	e456                	sd	s5,8(sp)
    80002126:	0080                	addi	s0,sp,64
    80002128:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000212a:	0000f497          	auipc	s1,0xf
    8000212e:	e6648493          	addi	s1,s1,-410 # 80010f90 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002132:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002134:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002136:	00016917          	auipc	s2,0x16
    8000213a:	a5a90913          	addi	s2,s2,-1446 # 80017b90 <tickslock>
    8000213e:	a811                	j	80002152 <wakeup+0x3c>
      }
      release(&p->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	b48080e7          	jalr	-1208(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000214a:	1b048493          	addi	s1,s1,432
    8000214e:	03248663          	beq	s1,s2,8000217a <wakeup+0x64>
    if (p != myproc())
    80002152:	00000097          	auipc	ra,0x0
    80002156:	85a080e7          	jalr	-1958(ra) # 800019ac <myproc>
    8000215a:	fea488e3          	beq	s1,a0,8000214a <wakeup+0x34>
      acquire(&p->lock);
    8000215e:	8526                	mv	a0,s1
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	a76080e7          	jalr	-1418(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002168:	4c9c                	lw	a5,24(s1)
    8000216a:	fd379be3          	bne	a5,s3,80002140 <wakeup+0x2a>
    8000216e:	709c                	ld	a5,32(s1)
    80002170:	fd4798e3          	bne	a5,s4,80002140 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002174:	0154ac23          	sw	s5,24(s1)
    80002178:	b7e1                	j	80002140 <wakeup+0x2a>
    }
  }
}
    8000217a:	70e2                	ld	ra,56(sp)
    8000217c:	7442                	ld	s0,48(sp)
    8000217e:	74a2                	ld	s1,40(sp)
    80002180:	7902                	ld	s2,32(sp)
    80002182:	69e2                	ld	s3,24(sp)
    80002184:	6a42                	ld	s4,16(sp)
    80002186:	6aa2                	ld	s5,8(sp)
    80002188:	6121                	addi	sp,sp,64
    8000218a:	8082                	ret

000000008000218c <reparent>:
{
    8000218c:	7179                	addi	sp,sp,-48
    8000218e:	f406                	sd	ra,40(sp)
    80002190:	f022                	sd	s0,32(sp)
    80002192:	ec26                	sd	s1,24(sp)
    80002194:	e84a                	sd	s2,16(sp)
    80002196:	e44e                	sd	s3,8(sp)
    80002198:	e052                	sd	s4,0(sp)
    8000219a:	1800                	addi	s0,sp,48
    8000219c:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000219e:	0000f497          	auipc	s1,0xf
    800021a2:	df248493          	addi	s1,s1,-526 # 80010f90 <proc>
      pp->parent = initproc;
    800021a6:	00006a17          	auipc	s4,0x6
    800021aa:	732a0a13          	addi	s4,s4,1842 # 800088d8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021ae:	00016997          	auipc	s3,0x16
    800021b2:	9e298993          	addi	s3,s3,-1566 # 80017b90 <tickslock>
    800021b6:	a029                	j	800021c0 <reparent+0x34>
    800021b8:	1b048493          	addi	s1,s1,432
    800021bc:	01348d63          	beq	s1,s3,800021d6 <reparent+0x4a>
    if (pp->parent == p)
    800021c0:	78bc                	ld	a5,112(s1)
    800021c2:	ff279be3          	bne	a5,s2,800021b8 <reparent+0x2c>
      pp->parent = initproc;
    800021c6:	000a3503          	ld	a0,0(s4)
    800021ca:	f8a8                	sd	a0,112(s1)
      wakeup(initproc);
    800021cc:	00000097          	auipc	ra,0x0
    800021d0:	f4a080e7          	jalr	-182(ra) # 80002116 <wakeup>
    800021d4:	b7d5                	j	800021b8 <reparent+0x2c>
}
    800021d6:	70a2                	ld	ra,40(sp)
    800021d8:	7402                	ld	s0,32(sp)
    800021da:	64e2                	ld	s1,24(sp)
    800021dc:	6942                	ld	s2,16(sp)
    800021de:	69a2                	ld	s3,8(sp)
    800021e0:	6a02                	ld	s4,0(sp)
    800021e2:	6145                	addi	sp,sp,48
    800021e4:	8082                	ret

00000000800021e6 <exit>:
{
    800021e6:	7179                	addi	sp,sp,-48
    800021e8:	f406                	sd	ra,40(sp)
    800021ea:	f022                	sd	s0,32(sp)
    800021ec:	ec26                	sd	s1,24(sp)
    800021ee:	e84a                	sd	s2,16(sp)
    800021f0:	e44e                	sd	s3,8(sp)
    800021f2:	e052                	sd	s4,0(sp)
    800021f4:	1800                	addi	s0,sp,48
    800021f6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	7b4080e7          	jalr	1972(ra) # 800019ac <myproc>
    80002200:	89aa                	mv	s3,a0
  if (p == initproc)
    80002202:	00006797          	auipc	a5,0x6
    80002206:	6d67b783          	ld	a5,1750(a5) # 800088d8 <initproc>
    8000220a:	10850493          	addi	s1,a0,264
    8000220e:	18850913          	addi	s2,a0,392
    80002212:	02a79363          	bne	a5,a0,80002238 <exit+0x52>
    panic("init exiting");
    80002216:	00006517          	auipc	a0,0x6
    8000221a:	04a50513          	addi	a0,a0,74 # 80008260 <digits+0x220>
    8000221e:	ffffe097          	auipc	ra,0xffffe
    80002222:	320080e7          	jalr	800(ra) # 8000053e <panic>
      fileclose(f);
    80002226:	00002097          	auipc	ra,0x2
    8000222a:	70a080e7          	jalr	1802(ra) # 80004930 <fileclose>
      p->ofile[fd] = 0;
    8000222e:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002232:	04a1                	addi	s1,s1,8
    80002234:	01248563          	beq	s1,s2,8000223e <exit+0x58>
    if (p->ofile[fd])
    80002238:	6088                	ld	a0,0(s1)
    8000223a:	f575                	bnez	a0,80002226 <exit+0x40>
    8000223c:	bfdd                	j	80002232 <exit+0x4c>
  begin_op();
    8000223e:	00002097          	auipc	ra,0x2
    80002242:	226080e7          	jalr	550(ra) # 80004464 <begin_op>
  iput(p->cwd);
    80002246:	1889b503          	ld	a0,392(s3)
    8000224a:	00002097          	auipc	ra,0x2
    8000224e:	a12080e7          	jalr	-1518(ra) # 80003c5c <iput>
  end_op();
    80002252:	00002097          	auipc	ra,0x2
    80002256:	292080e7          	jalr	658(ra) # 800044e4 <end_op>
  p->cwd = 0;
    8000225a:	1809b423          	sd	zero,392(s3)
  acquire(&wait_lock);
    8000225e:	0000f497          	auipc	s1,0xf
    80002262:	90a48493          	addi	s1,s1,-1782 # 80010b68 <wait_lock>
    80002266:	8526                	mv	a0,s1
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	96e080e7          	jalr	-1682(ra) # 80000bd6 <acquire>
  reparent(p);
    80002270:	854e                	mv	a0,s3
    80002272:	00000097          	auipc	ra,0x0
    80002276:	f1a080e7          	jalr	-230(ra) # 8000218c <reparent>
  wakeup(p->parent);
    8000227a:	0709b503          	ld	a0,112(s3)
    8000227e:	00000097          	auipc	ra,0x0
    80002282:	e98080e7          	jalr	-360(ra) # 80002116 <wakeup>
  acquire(&p->lock);
    80002286:	854e                	mv	a0,s3
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	94e080e7          	jalr	-1714(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002290:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002294:	4795                	li	a5,5
    80002296:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000229a:	00006797          	auipc	a5,0x6
    8000229e:	6467a783          	lw	a5,1606(a5) # 800088e0 <ticks>
    800022a2:	1af9a423          	sw	a5,424(s3)
  release(&wait_lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	9e2080e7          	jalr	-1566(ra) # 80000c8a <release>
  sched();
    800022b0:	00000097          	auipc	ra,0x0
    800022b4:	cf0080e7          	jalr	-784(ra) # 80001fa0 <sched>
  panic("zombie exit");
    800022b8:	00006517          	auipc	a0,0x6
    800022bc:	fb850513          	addi	a0,a0,-72 # 80008270 <digits+0x230>
    800022c0:	ffffe097          	auipc	ra,0xffffe
    800022c4:	27e080e7          	jalr	638(ra) # 8000053e <panic>

00000000800022c8 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800022c8:	7179                	addi	sp,sp,-48
    800022ca:	f406                	sd	ra,40(sp)
    800022cc:	f022                	sd	s0,32(sp)
    800022ce:	ec26                	sd	s1,24(sp)
    800022d0:	e84a                	sd	s2,16(sp)
    800022d2:	e44e                	sd	s3,8(sp)
    800022d4:	1800                	addi	s0,sp,48
    800022d6:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800022d8:	0000f497          	auipc	s1,0xf
    800022dc:	cb848493          	addi	s1,s1,-840 # 80010f90 <proc>
    800022e0:	00016997          	auipc	s3,0x16
    800022e4:	8b098993          	addi	s3,s3,-1872 # 80017b90 <tickslock>
  {
    acquire(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	8ec080e7          	jalr	-1812(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    800022f2:	589c                	lw	a5,48(s1)
    800022f4:	01278d63          	beq	a5,s2,8000230e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022f8:	8526                	mv	a0,s1
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	990080e7          	jalr	-1648(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002302:	1b048493          	addi	s1,s1,432
    80002306:	ff3491e3          	bne	s1,s3,800022e8 <kill+0x20>
  }
  return -1;
    8000230a:	557d                	li	a0,-1
    8000230c:	a829                	j	80002326 <kill+0x5e>
      p->killed = 1;
    8000230e:	4785                	li	a5,1
    80002310:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002312:	4c98                	lw	a4,24(s1)
    80002314:	4789                	li	a5,2
    80002316:	00f70f63          	beq	a4,a5,80002334 <kill+0x6c>
      release(&p->lock);
    8000231a:	8526                	mv	a0,s1
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	96e080e7          	jalr	-1682(ra) # 80000c8a <release>
      return 0;
    80002324:	4501                	li	a0,0
}
    80002326:	70a2                	ld	ra,40(sp)
    80002328:	7402                	ld	s0,32(sp)
    8000232a:	64e2                	ld	s1,24(sp)
    8000232c:	6942                	ld	s2,16(sp)
    8000232e:	69a2                	ld	s3,8(sp)
    80002330:	6145                	addi	sp,sp,48
    80002332:	8082                	ret
        p->state = RUNNABLE;
    80002334:	478d                	li	a5,3
    80002336:	cc9c                	sw	a5,24(s1)
    80002338:	b7cd                	j	8000231a <kill+0x52>

000000008000233a <setkilled>:

void setkilled(struct proc *p)
{
    8000233a:	1101                	addi	sp,sp,-32
    8000233c:	ec06                	sd	ra,24(sp)
    8000233e:	e822                	sd	s0,16(sp)
    80002340:	e426                	sd	s1,8(sp)
    80002342:	1000                	addi	s0,sp,32
    80002344:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	890080e7          	jalr	-1904(ra) # 80000bd6 <acquire>
  p->killed = 1;
    8000234e:	4785                	li	a5,1
    80002350:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002352:	8526                	mv	a0,s1
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	936080e7          	jalr	-1738(ra) # 80000c8a <release>
}
    8000235c:	60e2                	ld	ra,24(sp)
    8000235e:	6442                	ld	s0,16(sp)
    80002360:	64a2                	ld	s1,8(sp)
    80002362:	6105                	addi	sp,sp,32
    80002364:	8082                	ret

0000000080002366 <killed>:

int killed(struct proc *p)
{
    80002366:	1101                	addi	sp,sp,-32
    80002368:	ec06                	sd	ra,24(sp)
    8000236a:	e822                	sd	s0,16(sp)
    8000236c:	e426                	sd	s1,8(sp)
    8000236e:	e04a                	sd	s2,0(sp)
    80002370:	1000                	addi	s0,sp,32
    80002372:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	862080e7          	jalr	-1950(ra) # 80000bd6 <acquire>
  k = p->killed;
    8000237c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002380:	8526                	mv	a0,s1
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	908080e7          	jalr	-1784(ra) # 80000c8a <release>
  return k;
}
    8000238a:	854a                	mv	a0,s2
    8000238c:	60e2                	ld	ra,24(sp)
    8000238e:	6442                	ld	s0,16(sp)
    80002390:	64a2                	ld	s1,8(sp)
    80002392:	6902                	ld	s2,0(sp)
    80002394:	6105                	addi	sp,sp,32
    80002396:	8082                	ret

0000000080002398 <wait>:
{
    80002398:	715d                	addi	sp,sp,-80
    8000239a:	e486                	sd	ra,72(sp)
    8000239c:	e0a2                	sd	s0,64(sp)
    8000239e:	fc26                	sd	s1,56(sp)
    800023a0:	f84a                	sd	s2,48(sp)
    800023a2:	f44e                	sd	s3,40(sp)
    800023a4:	f052                	sd	s4,32(sp)
    800023a6:	ec56                	sd	s5,24(sp)
    800023a8:	e85a                	sd	s6,16(sp)
    800023aa:	e45e                	sd	s7,8(sp)
    800023ac:	e062                	sd	s8,0(sp)
    800023ae:	0880                	addi	s0,sp,80
    800023b0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	5fa080e7          	jalr	1530(ra) # 800019ac <myproc>
    800023ba:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023bc:	0000e517          	auipc	a0,0xe
    800023c0:	7ac50513          	addi	a0,a0,1964 # 80010b68 <wait_lock>
    800023c4:	fffff097          	auipc	ra,0xfffff
    800023c8:	812080e7          	jalr	-2030(ra) # 80000bd6 <acquire>
    havekids = 0;
    800023cc:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800023ce:	4a15                	li	s4,5
        havekids = 1;
    800023d0:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023d2:	00015997          	auipc	s3,0x15
    800023d6:	7be98993          	addi	s3,s3,1982 # 80017b90 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800023da:	0000ec17          	auipc	s8,0xe
    800023de:	78ec0c13          	addi	s8,s8,1934 # 80010b68 <wait_lock>
    havekids = 0;
    800023e2:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023e4:	0000f497          	auipc	s1,0xf
    800023e8:	bac48493          	addi	s1,s1,-1108 # 80010f90 <proc>
    800023ec:	a0bd                	j	8000245a <wait+0xc2>
          pid = pp->pid;
    800023ee:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023f2:	000b0e63          	beqz	s6,8000240e <wait+0x76>
    800023f6:	4691                	li	a3,4
    800023f8:	02c48613          	addi	a2,s1,44
    800023fc:	85da                	mv	a1,s6
    800023fe:	08893503          	ld	a0,136(s2)
    80002402:	fffff097          	auipc	ra,0xfffff
    80002406:	266080e7          	jalr	614(ra) # 80001668 <copyout>
    8000240a:	02054563          	bltz	a0,80002434 <wait+0x9c>
          freeproc(pp);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	74e080e7          	jalr	1870(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    80002418:	8526                	mv	a0,s1
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	870080e7          	jalr	-1936(ra) # 80000c8a <release>
          release(&wait_lock);
    80002422:	0000e517          	auipc	a0,0xe
    80002426:	74650513          	addi	a0,a0,1862 # 80010b68 <wait_lock>
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	860080e7          	jalr	-1952(ra) # 80000c8a <release>
          return pid;
    80002432:	a0b5                	j	8000249e <wait+0x106>
            release(&pp->lock);
    80002434:	8526                	mv	a0,s1
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	854080e7          	jalr	-1964(ra) # 80000c8a <release>
            release(&wait_lock);
    8000243e:	0000e517          	auipc	a0,0xe
    80002442:	72a50513          	addi	a0,a0,1834 # 80010b68 <wait_lock>
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	844080e7          	jalr	-1980(ra) # 80000c8a <release>
            return -1;
    8000244e:	59fd                	li	s3,-1
    80002450:	a0b9                	j	8000249e <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002452:	1b048493          	addi	s1,s1,432
    80002456:	03348463          	beq	s1,s3,8000247e <wait+0xe6>
      if (pp->parent == p)
    8000245a:	78bc                	ld	a5,112(s1)
    8000245c:	ff279be3          	bne	a5,s2,80002452 <wait+0xba>
        acquire(&pp->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	774080e7          	jalr	1908(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    8000246a:	4c9c                	lw	a5,24(s1)
    8000246c:	f94781e3          	beq	a5,s4,800023ee <wait+0x56>
        release(&pp->lock);
    80002470:	8526                	mv	a0,s1
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	818080e7          	jalr	-2024(ra) # 80000c8a <release>
        havekids = 1;
    8000247a:	8756                	mv	a4,s5
    8000247c:	bfd9                	j	80002452 <wait+0xba>
    if (!havekids || killed(p))
    8000247e:	c719                	beqz	a4,8000248c <wait+0xf4>
    80002480:	854a                	mv	a0,s2
    80002482:	00000097          	auipc	ra,0x0
    80002486:	ee4080e7          	jalr	-284(ra) # 80002366 <killed>
    8000248a:	c51d                	beqz	a0,800024b8 <wait+0x120>
      release(&wait_lock);
    8000248c:	0000e517          	auipc	a0,0xe
    80002490:	6dc50513          	addi	a0,a0,1756 # 80010b68 <wait_lock>
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	7f6080e7          	jalr	2038(ra) # 80000c8a <release>
      return -1;
    8000249c:	59fd                	li	s3,-1
}
    8000249e:	854e                	mv	a0,s3
    800024a0:	60a6                	ld	ra,72(sp)
    800024a2:	6406                	ld	s0,64(sp)
    800024a4:	74e2                	ld	s1,56(sp)
    800024a6:	7942                	ld	s2,48(sp)
    800024a8:	79a2                	ld	s3,40(sp)
    800024aa:	7a02                	ld	s4,32(sp)
    800024ac:	6ae2                	ld	s5,24(sp)
    800024ae:	6b42                	ld	s6,16(sp)
    800024b0:	6ba2                	ld	s7,8(sp)
    800024b2:	6c02                	ld	s8,0(sp)
    800024b4:	6161                	addi	sp,sp,80
    800024b6:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024b8:	85e2                	mv	a1,s8
    800024ba:	854a                	mv	a0,s2
    800024bc:	00000097          	auipc	ra,0x0
    800024c0:	bf6080e7          	jalr	-1034(ra) # 800020b2 <sleep>
    havekids = 0;
    800024c4:	bf39                	j	800023e2 <wait+0x4a>

00000000800024c6 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024c6:	7179                	addi	sp,sp,-48
    800024c8:	f406                	sd	ra,40(sp)
    800024ca:	f022                	sd	s0,32(sp)
    800024cc:	ec26                	sd	s1,24(sp)
    800024ce:	e84a                	sd	s2,16(sp)
    800024d0:	e44e                	sd	s3,8(sp)
    800024d2:	e052                	sd	s4,0(sp)
    800024d4:	1800                	addi	s0,sp,48
    800024d6:	84aa                	mv	s1,a0
    800024d8:	892e                	mv	s2,a1
    800024da:	89b2                	mv	s3,a2
    800024dc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024de:	fffff097          	auipc	ra,0xfffff
    800024e2:	4ce080e7          	jalr	1230(ra) # 800019ac <myproc>
  if (user_dst)
    800024e6:	c08d                	beqz	s1,80002508 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800024e8:	86d2                	mv	a3,s4
    800024ea:	864e                	mv	a2,s3
    800024ec:	85ca                	mv	a1,s2
    800024ee:	6548                	ld	a0,136(a0)
    800024f0:	fffff097          	auipc	ra,0xfffff
    800024f4:	178080e7          	jalr	376(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024f8:	70a2                	ld	ra,40(sp)
    800024fa:	7402                	ld	s0,32(sp)
    800024fc:	64e2                	ld	s1,24(sp)
    800024fe:	6942                	ld	s2,16(sp)
    80002500:	69a2                	ld	s3,8(sp)
    80002502:	6a02                	ld	s4,0(sp)
    80002504:	6145                	addi	sp,sp,48
    80002506:	8082                	ret
    memmove((char *)dst, src, len);
    80002508:	000a061b          	sext.w	a2,s4
    8000250c:	85ce                	mv	a1,s3
    8000250e:	854a                	mv	a0,s2
    80002510:	fffff097          	auipc	ra,0xfffff
    80002514:	81e080e7          	jalr	-2018(ra) # 80000d2e <memmove>
    return 0;
    80002518:	8526                	mv	a0,s1
    8000251a:	bff9                	j	800024f8 <either_copyout+0x32>

000000008000251c <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000251c:	7179                	addi	sp,sp,-48
    8000251e:	f406                	sd	ra,40(sp)
    80002520:	f022                	sd	s0,32(sp)
    80002522:	ec26                	sd	s1,24(sp)
    80002524:	e84a                	sd	s2,16(sp)
    80002526:	e44e                	sd	s3,8(sp)
    80002528:	e052                	sd	s4,0(sp)
    8000252a:	1800                	addi	s0,sp,48
    8000252c:	892a                	mv	s2,a0
    8000252e:	84ae                	mv	s1,a1
    80002530:	89b2                	mv	s3,a2
    80002532:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002534:	fffff097          	auipc	ra,0xfffff
    80002538:	478080e7          	jalr	1144(ra) # 800019ac <myproc>
  if (user_src)
    8000253c:	c08d                	beqz	s1,8000255e <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    8000253e:	86d2                	mv	a3,s4
    80002540:	864e                	mv	a2,s3
    80002542:	85ca                	mv	a1,s2
    80002544:	6548                	ld	a0,136(a0)
    80002546:	fffff097          	auipc	ra,0xfffff
    8000254a:	1ae080e7          	jalr	430(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000254e:	70a2                	ld	ra,40(sp)
    80002550:	7402                	ld	s0,32(sp)
    80002552:	64e2                	ld	s1,24(sp)
    80002554:	6942                	ld	s2,16(sp)
    80002556:	69a2                	ld	s3,8(sp)
    80002558:	6a02                	ld	s4,0(sp)
    8000255a:	6145                	addi	sp,sp,48
    8000255c:	8082                	ret
    memmove(dst, (char *)src, len);
    8000255e:	000a061b          	sext.w	a2,s4
    80002562:	85ce                	mv	a1,s3
    80002564:	854a                	mv	a0,s2
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	7c8080e7          	jalr	1992(ra) # 80000d2e <memmove>
    return 0;
    8000256e:	8526                	mv	a0,s1
    80002570:	bff9                	j	8000254e <either_copyin+0x32>

0000000080002572 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002572:	715d                	addi	sp,sp,-80
    80002574:	e486                	sd	ra,72(sp)
    80002576:	e0a2                	sd	s0,64(sp)
    80002578:	fc26                	sd	s1,56(sp)
    8000257a:	f84a                	sd	s2,48(sp)
    8000257c:	f44e                	sd	s3,40(sp)
    8000257e:	f052                	sd	s4,32(sp)
    80002580:	ec56                	sd	s5,24(sp)
    80002582:	e85a                	sd	s6,16(sp)
    80002584:	e45e                	sd	s7,8(sp)
    80002586:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002588:	00006517          	auipc	a0,0x6
    8000258c:	b4050513          	addi	a0,a0,-1216 # 800080c8 <digits+0x88>
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	ff8080e7          	jalr	-8(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002598:	0000f497          	auipc	s1,0xf
    8000259c:	b8848493          	addi	s1,s1,-1144 # 80011120 <proc+0x190>
    800025a0:	00015917          	auipc	s2,0x15
    800025a4:	78090913          	addi	s2,s2,1920 # 80017d20 <bcache+0x178>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025aa:	00006997          	auipc	s3,0x6
    800025ae:	cd698993          	addi	s3,s3,-810 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025b2:	00006a97          	auipc	s5,0x6
    800025b6:	cd6a8a93          	addi	s5,s5,-810 # 80008288 <digits+0x248>
    printf("\n");
    800025ba:	00006a17          	auipc	s4,0x6
    800025be:	b0ea0a13          	addi	s4,s4,-1266 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025c2:	00006b97          	auipc	s7,0x6
    800025c6:	d06b8b93          	addi	s7,s7,-762 # 800082c8 <states.0>
    800025ca:	a00d                	j	800025ec <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025cc:	ea06a583          	lw	a1,-352(a3)
    800025d0:	8556                	mv	a0,s5
    800025d2:	ffffe097          	auipc	ra,0xffffe
    800025d6:	fb6080e7          	jalr	-74(ra) # 80000588 <printf>
    printf("\n");
    800025da:	8552                	mv	a0,s4
    800025dc:	ffffe097          	auipc	ra,0xffffe
    800025e0:	fac080e7          	jalr	-84(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800025e4:	1b048493          	addi	s1,s1,432
    800025e8:	03248163          	beq	s1,s2,8000260a <procdump+0x98>
    if (p->state == UNUSED)
    800025ec:	86a6                	mv	a3,s1
    800025ee:	e884a783          	lw	a5,-376(s1)
    800025f2:	dbed                	beqz	a5,800025e4 <procdump+0x72>
      state = "???";
    800025f4:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f6:	fcfb6be3          	bltu	s6,a5,800025cc <procdump+0x5a>
    800025fa:	1782                	slli	a5,a5,0x20
    800025fc:	9381                	srli	a5,a5,0x20
    800025fe:	078e                	slli	a5,a5,0x3
    80002600:	97de                	add	a5,a5,s7
    80002602:	6390                	ld	a2,0(a5)
    80002604:	f661                	bnez	a2,800025cc <procdump+0x5a>
      state = "???";
    80002606:	864e                	mv	a2,s3
    80002608:	b7d1                	j	800025cc <procdump+0x5a>
  }
}
    8000260a:	60a6                	ld	ra,72(sp)
    8000260c:	6406                	ld	s0,64(sp)
    8000260e:	74e2                	ld	s1,56(sp)
    80002610:	7942                	ld	s2,48(sp)
    80002612:	79a2                	ld	s3,40(sp)
    80002614:	7a02                	ld	s4,32(sp)
    80002616:	6ae2                	ld	s5,24(sp)
    80002618:	6b42                	ld	s6,16(sp)
    8000261a:	6ba2                	ld	s7,8(sp)
    8000261c:	6161                	addi	sp,sp,80
    8000261e:	8082                	ret

0000000080002620 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002620:	711d                	addi	sp,sp,-96
    80002622:	ec86                	sd	ra,88(sp)
    80002624:	e8a2                	sd	s0,80(sp)
    80002626:	e4a6                	sd	s1,72(sp)
    80002628:	e0ca                	sd	s2,64(sp)
    8000262a:	fc4e                	sd	s3,56(sp)
    8000262c:	f852                	sd	s4,48(sp)
    8000262e:	f456                	sd	s5,40(sp)
    80002630:	f05a                	sd	s6,32(sp)
    80002632:	ec5e                	sd	s7,24(sp)
    80002634:	e862                	sd	s8,16(sp)
    80002636:	e466                	sd	s9,8(sp)
    80002638:	e06a                	sd	s10,0(sp)
    8000263a:	1080                	addi	s0,sp,96
    8000263c:	8b2a                	mv	s6,a0
    8000263e:	8bae                	mv	s7,a1
    80002640:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002642:	fffff097          	auipc	ra,0xfffff
    80002646:	36a080e7          	jalr	874(ra) # 800019ac <myproc>
    8000264a:	892a                	mv	s2,a0

  acquire(&wait_lock);
    8000264c:	0000e517          	auipc	a0,0xe
    80002650:	51c50513          	addi	a0,a0,1308 # 80010b68 <wait_lock>
    80002654:	ffffe097          	auipc	ra,0xffffe
    80002658:	582080e7          	jalr	1410(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    8000265c:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    8000265e:	4a15                	li	s4,5
        havekids = 1;
    80002660:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002662:	00015997          	auipc	s3,0x15
    80002666:	52e98993          	addi	s3,s3,1326 # 80017b90 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000266a:	0000ed17          	auipc	s10,0xe
    8000266e:	4fed0d13          	addi	s10,s10,1278 # 80010b68 <wait_lock>
    havekids = 0;
    80002672:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002674:	0000f497          	auipc	s1,0xf
    80002678:	91c48493          	addi	s1,s1,-1764 # 80010f90 <proc>
    8000267c:	a059                	j	80002702 <waitx+0xe2>
          pid = np->pid;
    8000267e:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002682:	1a04a703          	lw	a4,416(s1)
    80002686:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    8000268a:	1a44a783          	lw	a5,420(s1)
    8000268e:	9f3d                	addw	a4,a4,a5
    80002690:	1a84a783          	lw	a5,424(s1)
    80002694:	9f99                	subw	a5,a5,a4
    80002696:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000269a:	000b0e63          	beqz	s6,800026b6 <waitx+0x96>
    8000269e:	4691                	li	a3,4
    800026a0:	02c48613          	addi	a2,s1,44
    800026a4:	85da                	mv	a1,s6
    800026a6:	08893503          	ld	a0,136(s2)
    800026aa:	fffff097          	auipc	ra,0xfffff
    800026ae:	fbe080e7          	jalr	-66(ra) # 80001668 <copyout>
    800026b2:	02054563          	bltz	a0,800026dc <waitx+0xbc>
          freeproc(np);
    800026b6:	8526                	mv	a0,s1
    800026b8:	fffff097          	auipc	ra,0xfffff
    800026bc:	4a6080e7          	jalr	1190(ra) # 80001b5e <freeproc>
          release(&np->lock);
    800026c0:	8526                	mv	a0,s1
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	5c8080e7          	jalr	1480(ra) # 80000c8a <release>
          release(&wait_lock);
    800026ca:	0000e517          	auipc	a0,0xe
    800026ce:	49e50513          	addi	a0,a0,1182 # 80010b68 <wait_lock>
    800026d2:	ffffe097          	auipc	ra,0xffffe
    800026d6:	5b8080e7          	jalr	1464(ra) # 80000c8a <release>
          return pid;
    800026da:	a09d                	j	80002740 <waitx+0x120>
            release(&np->lock);
    800026dc:	8526                	mv	a0,s1
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	5ac080e7          	jalr	1452(ra) # 80000c8a <release>
            release(&wait_lock);
    800026e6:	0000e517          	auipc	a0,0xe
    800026ea:	48250513          	addi	a0,a0,1154 # 80010b68 <wait_lock>
    800026ee:	ffffe097          	auipc	ra,0xffffe
    800026f2:	59c080e7          	jalr	1436(ra) # 80000c8a <release>
            return -1;
    800026f6:	59fd                	li	s3,-1
    800026f8:	a0a1                	j	80002740 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    800026fa:	1b048493          	addi	s1,s1,432
    800026fe:	03348463          	beq	s1,s3,80002726 <waitx+0x106>
      if (np->parent == p)
    80002702:	78bc                	ld	a5,112(s1)
    80002704:	ff279be3          	bne	a5,s2,800026fa <waitx+0xda>
        acquire(&np->lock);
    80002708:	8526                	mv	a0,s1
    8000270a:	ffffe097          	auipc	ra,0xffffe
    8000270e:	4cc080e7          	jalr	1228(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    80002712:	4c9c                	lw	a5,24(s1)
    80002714:	f74785e3          	beq	a5,s4,8000267e <waitx+0x5e>
        release(&np->lock);
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	570080e7          	jalr	1392(ra) # 80000c8a <release>
        havekids = 1;
    80002722:	8756                	mv	a4,s5
    80002724:	bfd9                	j	800026fa <waitx+0xda>
    if (!havekids || p->killed)
    80002726:	c701                	beqz	a4,8000272e <waitx+0x10e>
    80002728:	02892783          	lw	a5,40(s2)
    8000272c:	cb8d                	beqz	a5,8000275e <waitx+0x13e>
      release(&wait_lock);
    8000272e:	0000e517          	auipc	a0,0xe
    80002732:	43a50513          	addi	a0,a0,1082 # 80010b68 <wait_lock>
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	554080e7          	jalr	1364(ra) # 80000c8a <release>
      return -1;
    8000273e:	59fd                	li	s3,-1
  }
}
    80002740:	854e                	mv	a0,s3
    80002742:	60e6                	ld	ra,88(sp)
    80002744:	6446                	ld	s0,80(sp)
    80002746:	64a6                	ld	s1,72(sp)
    80002748:	6906                	ld	s2,64(sp)
    8000274a:	79e2                	ld	s3,56(sp)
    8000274c:	7a42                	ld	s4,48(sp)
    8000274e:	7aa2                	ld	s5,40(sp)
    80002750:	7b02                	ld	s6,32(sp)
    80002752:	6be2                	ld	s7,24(sp)
    80002754:	6c42                	ld	s8,16(sp)
    80002756:	6ca2                	ld	s9,8(sp)
    80002758:	6d02                	ld	s10,0(sp)
    8000275a:	6125                	addi	sp,sp,96
    8000275c:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000275e:	85ea                	mv	a1,s10
    80002760:	854a                	mv	a0,s2
    80002762:	00000097          	auipc	ra,0x0
    80002766:	950080e7          	jalr	-1712(ra) # 800020b2 <sleep>
    havekids = 0;
    8000276a:	b721                	j	80002672 <waitx+0x52>

000000008000276c <update_time>:

void update_time()
{
    8000276c:	715d                	addi	sp,sp,-80
    8000276e:	e486                	sd	ra,72(sp)
    80002770:	e0a2                	sd	s0,64(sp)
    80002772:	fc26                	sd	s1,56(sp)
    80002774:	f84a                	sd	s2,48(sp)
    80002776:	f44e                	sd	s3,40(sp)
    80002778:	f052                	sd	s4,32(sp)
    8000277a:	ec56                	sd	s5,24(sp)
    8000277c:	e85a                	sd	s6,16(sp)
    8000277e:	e45e                	sd	s7,8(sp)
    80002780:	e062                	sd	s8,0(sp)
    80002782:	0880                	addi	s0,sp,80
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002784:	0000f497          	auipc	s1,0xf
    80002788:	80c48493          	addi	s1,s1,-2036 # 80010f90 <proc>
  {
    if (p->state == RUNNING)
    8000278c:	4991                	li	s3,4
    {
      p->rtime++;
      p->cur_ticks++;
      // printf("Hi\n");
    }
    else if(p->state == RUNNABLE)
    8000278e:	4a0d                	li	s4,3
          p->arrival_time = ticks;
          p->wait_time = 0;
        }
      }
    }
    else if (p->state == SLEEPING)
    80002790:	4a89                	li	s5,2
        if(p->q_no != 0 && p->wait_time > 30)
    80002792:	4bf9                	li	s7,30
          qcount[p->q_no]--;
    80002794:	0000eb17          	auipc	s6,0xe
    80002798:	3bcb0b13          	addi	s6,s6,956 # 80010b50 <pid_lock>
          p->arrival_time = ticks;
    8000279c:	00006c17          	auipc	s8,0x6
    800027a0:	144c0c13          	addi	s8,s8,324 # 800088e0 <ticks>
  for (p = proc; p < &proc[NPROC]; p++)
    800027a4:	00015917          	auipc	s2,0x15
    800027a8:	3ec90913          	addi	s2,s2,1004 # 80017b90 <tickslock>
    800027ac:	a829                	j	800027c6 <update_time+0x5a>
      p->rtime++;
    800027ae:	1a04a783          	lw	a5,416(s1)
    800027b2:	2785                	addiw	a5,a5,1
    800027b4:	1af4a023          	sw	a5,416(s1)
      p->cur_ticks++;
    800027b8:	40fc                	lw	a5,68(s1)
    800027ba:	2785                	addiw	a5,a5,1
    800027bc:	c0fc                	sw	a5,68(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    800027be:	1b048493          	addi	s1,s1,432
    800027c2:	07248663          	beq	s1,s2,8000282e <update_time+0xc2>
    if (p->state == RUNNING)
    800027c6:	4c9c                	lw	a5,24(s1)
    800027c8:	ff3783e3          	beq	a5,s3,800027ae <update_time+0x42>
    else if(p->state == RUNNABLE)
    800027cc:	01478863          	beq	a5,s4,800027dc <update_time+0x70>
    else if (p->state == SLEEPING)
    800027d0:	ff5797e3          	bne	a5,s5,800027be <update_time+0x52>
    {
      p->tsleep++;
    800027d4:	54bc                	lw	a5,104(s1)
    800027d6:	2785                	addiw	a5,a5,1
    800027d8:	d4bc                	sw	a5,104(s1)
    800027da:	b7d5                	j	800027be <update_time+0x52>
      if(p != myproc())
    800027dc:	fffff097          	auipc	ra,0xfffff
    800027e0:	1d0080e7          	jalr	464(ra) # 800019ac <myproc>
    800027e4:	fca48de3          	beq	s1,a0,800027be <update_time+0x52>
        p->wait_time++;
    800027e8:	4cfc                	lw	a5,92(s1)
    800027ea:	2785                	addiw	a5,a5,1
    800027ec:	0007871b          	sext.w	a4,a5
    800027f0:	ccfc                	sw	a5,92(s1)
        if(p->q_no != 0 && p->wait_time > 30)
    800027f2:	4cbc                	lw	a5,88(s1)
    800027f4:	d7e9                	beqz	a5,800027be <update_time+0x52>
    800027f6:	fcebd4e3          	bge	s7,a4,800027be <update_time+0x52>
          qcount[p->q_no]--;
    800027fa:	00279713          	slli	a4,a5,0x2
    800027fe:	975a                	add	a4,a4,s6
    80002800:	43072683          	lw	a3,1072(a4)
    80002804:	36fd                	addiw	a3,a3,-1
    80002806:	42d72823          	sw	a3,1072(a4)
          p->q_no--;
    8000280a:	37fd                	addiw	a5,a5,-1
    8000280c:	0007871b          	sext.w	a4,a5
    80002810:	ccbc                	sw	a5,88(s1)
          qcount[p->q_no]++;
    80002812:	00271793          	slli	a5,a4,0x2
    80002816:	97da                	add	a5,a5,s6
    80002818:	4307a703          	lw	a4,1072(a5)
    8000281c:	2705                	addiw	a4,a4,1
    8000281e:	42e7a823          	sw	a4,1072(a5)
          p->arrival_time = ticks;
    80002822:	000c2783          	lw	a5,0(s8)
    80002826:	c8fc                	sw	a5,84(s1)
          p->wait_time = 0;
    80002828:	0404ae23          	sw	zero,92(s1)
    8000282c:	bf49                	j	800027be <update_time+0x52>
  {
    if(p->pid > 3 && p->pid < 14)
        printf("%d %d %d\n", p->pid, p->q_no, ticks);
  }
  #endif
    8000282e:	60a6                	ld	ra,72(sp)
    80002830:	6406                	ld	s0,64(sp)
    80002832:	74e2                	ld	s1,56(sp)
    80002834:	7942                	ld	s2,48(sp)
    80002836:	79a2                	ld	s3,40(sp)
    80002838:	7a02                	ld	s4,32(sp)
    8000283a:	6ae2                	ld	s5,24(sp)
    8000283c:	6b42                	ld	s6,16(sp)
    8000283e:	6ba2                	ld	s7,8(sp)
    80002840:	6c02                	ld	s8,0(sp)
    80002842:	6161                	addi	sp,sp,80
    80002844:	8082                	ret

0000000080002846 <swtch>:
    80002846:	00153023          	sd	ra,0(a0)
    8000284a:	00253423          	sd	sp,8(a0)
    8000284e:	e900                	sd	s0,16(a0)
    80002850:	ed04                	sd	s1,24(a0)
    80002852:	03253023          	sd	s2,32(a0)
    80002856:	03353423          	sd	s3,40(a0)
    8000285a:	03453823          	sd	s4,48(a0)
    8000285e:	03553c23          	sd	s5,56(a0)
    80002862:	05653023          	sd	s6,64(a0)
    80002866:	05753423          	sd	s7,72(a0)
    8000286a:	05853823          	sd	s8,80(a0)
    8000286e:	05953c23          	sd	s9,88(a0)
    80002872:	07a53023          	sd	s10,96(a0)
    80002876:	07b53423          	sd	s11,104(a0)
    8000287a:	0005b083          	ld	ra,0(a1)
    8000287e:	0085b103          	ld	sp,8(a1)
    80002882:	6980                	ld	s0,16(a1)
    80002884:	6d84                	ld	s1,24(a1)
    80002886:	0205b903          	ld	s2,32(a1)
    8000288a:	0285b983          	ld	s3,40(a1)
    8000288e:	0305ba03          	ld	s4,48(a1)
    80002892:	0385ba83          	ld	s5,56(a1)
    80002896:	0405bb03          	ld	s6,64(a1)
    8000289a:	0485bb83          	ld	s7,72(a1)
    8000289e:	0505bc03          	ld	s8,80(a1)
    800028a2:	0585bc83          	ld	s9,88(a1)
    800028a6:	0605bd03          	ld	s10,96(a1)
    800028aa:	0685bd83          	ld	s11,104(a1)
    800028ae:	8082                	ret

00000000800028b0 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800028b0:	1141                	addi	sp,sp,-16
    800028b2:	e406                	sd	ra,8(sp)
    800028b4:	e022                	sd	s0,0(sp)
    800028b6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028b8:	00006597          	auipc	a1,0x6
    800028bc:	a4058593          	addi	a1,a1,-1472 # 800082f8 <states.0+0x30>
    800028c0:	00015517          	auipc	a0,0x15
    800028c4:	2d050513          	addi	a0,a0,720 # 80017b90 <tickslock>
    800028c8:	ffffe097          	auipc	ra,0xffffe
    800028cc:	27e080e7          	jalr	638(ra) # 80000b46 <initlock>
}
    800028d0:	60a2                	ld	ra,8(sp)
    800028d2:	6402                	ld	s0,0(sp)
    800028d4:	0141                	addi	sp,sp,16
    800028d6:	8082                	ret

00000000800028d8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    800028d8:	1141                	addi	sp,sp,-16
    800028da:	e422                	sd	s0,8(sp)
    800028dc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028de:	00003797          	auipc	a5,0x3
    800028e2:	6a278793          	addi	a5,a5,1698 # 80005f80 <kernelvec>
    800028e6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028ea:	6422                	ld	s0,8(sp)
    800028ec:	0141                	addi	sp,sp,16
    800028ee:	8082                	ret

00000000800028f0 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    800028f0:	1141                	addi	sp,sp,-16
    800028f2:	e406                	sd	ra,8(sp)
    800028f4:	e022                	sd	s0,0(sp)
    800028f6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028f8:	fffff097          	auipc	ra,0xfffff
    800028fc:	0b4080e7          	jalr	180(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002900:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002904:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002906:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000290a:	00004617          	auipc	a2,0x4
    8000290e:	6f660613          	addi	a2,a2,1782 # 80007000 <_trampoline>
    80002912:	00004697          	auipc	a3,0x4
    80002916:	6ee68693          	addi	a3,a3,1774 # 80007000 <_trampoline>
    8000291a:	8e91                	sub	a3,a3,a2
    8000291c:	040007b7          	lui	a5,0x4000
    80002920:	17fd                	addi	a5,a5,-1
    80002922:	07b2                	slli	a5,a5,0xc
    80002924:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002926:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000292a:	6958                	ld	a4,144(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000292c:	180026f3          	csrr	a3,satp
    80002930:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002932:	6958                	ld	a4,144(a0)
    80002934:	7d34                	ld	a3,120(a0)
    80002936:	6585                	lui	a1,0x1
    80002938:	96ae                	add	a3,a3,a1
    8000293a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000293c:	6958                	ld	a4,144(a0)
    8000293e:	00000697          	auipc	a3,0x0
    80002942:	13e68693          	addi	a3,a3,318 # 80002a7c <usertrap>
    80002946:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002948:	6958                	ld	a4,144(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000294a:	8692                	mv	a3,tp
    8000294c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000294e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002952:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002956:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000295a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000295e:	6958                	ld	a4,144(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002960:	6f18                	ld	a4,24(a4)
    80002962:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002966:	6548                	ld	a0,136(a0)
    80002968:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000296a:	00004717          	auipc	a4,0x4
    8000296e:	73270713          	addi	a4,a4,1842 # 8000709c <userret>
    80002972:	8f11                	sub	a4,a4,a2
    80002974:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002976:	577d                	li	a4,-1
    80002978:	177e                	slli	a4,a4,0x3f
    8000297a:	8d59                	or	a0,a0,a4
    8000297c:	9782                	jalr	a5
}
    8000297e:	60a2                	ld	ra,8(sp)
    80002980:	6402                	ld	s0,0(sp)
    80002982:	0141                	addi	sp,sp,16
    80002984:	8082                	ret

0000000080002986 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002986:	1101                	addi	sp,sp,-32
    80002988:	ec06                	sd	ra,24(sp)
    8000298a:	e822                	sd	s0,16(sp)
    8000298c:	e426                	sd	s1,8(sp)
    8000298e:	e04a                	sd	s2,0(sp)
    80002990:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002992:	00015917          	auipc	s2,0x15
    80002996:	1fe90913          	addi	s2,s2,510 # 80017b90 <tickslock>
    8000299a:	854a                	mv	a0,s2
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	23a080e7          	jalr	570(ra) # 80000bd6 <acquire>
  ticks++;
    800029a4:	00006497          	auipc	s1,0x6
    800029a8:	f3c48493          	addi	s1,s1,-196 # 800088e0 <ticks>
    800029ac:	409c                	lw	a5,0(s1)
    800029ae:	2785                	addiw	a5,a5,1
    800029b0:	c09c                	sw	a5,0(s1)
  update_time();
    800029b2:	00000097          	auipc	ra,0x0
    800029b6:	dba080e7          	jalr	-582(ra) # 8000276c <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    800029ba:	8526                	mv	a0,s1
    800029bc:	fffff097          	auipc	ra,0xfffff
    800029c0:	75a080e7          	jalr	1882(ra) # 80002116 <wakeup>
  release(&tickslock);
    800029c4:	854a                	mv	a0,s2
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	2c4080e7          	jalr	708(ra) # 80000c8a <release>
}
    800029ce:	60e2                	ld	ra,24(sp)
    800029d0:	6442                	ld	s0,16(sp)
    800029d2:	64a2                	ld	s1,8(sp)
    800029d4:	6902                	ld	s2,0(sp)
    800029d6:	6105                	addi	sp,sp,32
    800029d8:	8082                	ret

00000000800029da <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    800029da:	1101                	addi	sp,sp,-32
    800029dc:	ec06                	sd	ra,24(sp)
    800029de:	e822                	sd	s0,16(sp)
    800029e0:	e426                	sd	s1,8(sp)
    800029e2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029e4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    800029e8:	00074d63          	bltz	a4,80002a02 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    800029ec:	57fd                	li	a5,-1
    800029ee:	17fe                	slli	a5,a5,0x3f
    800029f0:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    800029f2:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    800029f4:	06f70363          	beq	a4,a5,80002a5a <devintr+0x80>
  }
}
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6105                	addi	sp,sp,32
    80002a00:	8082                	ret
      (scause & 0xff) == 9)
    80002a02:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002a06:	46a5                	li	a3,9
    80002a08:	fed792e3          	bne	a5,a3,800029ec <devintr+0x12>
    int irq = plic_claim();
    80002a0c:	00003097          	auipc	ra,0x3
    80002a10:	67c080e7          	jalr	1660(ra) # 80006088 <plic_claim>
    80002a14:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002a16:	47a9                	li	a5,10
    80002a18:	02f50763          	beq	a0,a5,80002a46 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002a1c:	4785                	li	a5,1
    80002a1e:	02f50963          	beq	a0,a5,80002a50 <devintr+0x76>
    return 1;
    80002a22:	4505                	li	a0,1
    else if (irq)
    80002a24:	d8f1                	beqz	s1,800029f8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a26:	85a6                	mv	a1,s1
    80002a28:	00006517          	auipc	a0,0x6
    80002a2c:	8d850513          	addi	a0,a0,-1832 # 80008300 <states.0+0x38>
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	b58080e7          	jalr	-1192(ra) # 80000588 <printf>
      plic_complete(irq);
    80002a38:	8526                	mv	a0,s1
    80002a3a:	00003097          	auipc	ra,0x3
    80002a3e:	672080e7          	jalr	1650(ra) # 800060ac <plic_complete>
    return 1;
    80002a42:	4505                	li	a0,1
    80002a44:	bf55                	j	800029f8 <devintr+0x1e>
      uartintr();
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	f54080e7          	jalr	-172(ra) # 8000099a <uartintr>
    80002a4e:	b7ed                	j	80002a38 <devintr+0x5e>
      virtio_disk_intr();
    80002a50:	00004097          	auipc	ra,0x4
    80002a54:	b28080e7          	jalr	-1240(ra) # 80006578 <virtio_disk_intr>
    80002a58:	b7c5                	j	80002a38 <devintr+0x5e>
    if (cpuid() == 0)
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	f26080e7          	jalr	-218(ra) # 80001980 <cpuid>
    80002a62:	c901                	beqz	a0,80002a72 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a64:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a68:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a6a:	14479073          	csrw	sip,a5
    return 2;
    80002a6e:	4509                	li	a0,2
    80002a70:	b761                	j	800029f8 <devintr+0x1e>
      clockintr();
    80002a72:	00000097          	auipc	ra,0x0
    80002a76:	f14080e7          	jalr	-236(ra) # 80002986 <clockintr>
    80002a7a:	b7ed                	j	80002a64 <devintr+0x8a>

0000000080002a7c <usertrap>:
{
    80002a7c:	1101                	addi	sp,sp,-32
    80002a7e:	ec06                	sd	ra,24(sp)
    80002a80:	e822                	sd	s0,16(sp)
    80002a82:	e426                	sd	s1,8(sp)
    80002a84:	e04a                	sd	s2,0(sp)
    80002a86:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a88:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002a8c:	1007f793          	andi	a5,a5,256
    80002a90:	e3b1                	bnez	a5,80002ad4 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a92:	00003797          	auipc	a5,0x3
    80002a96:	4ee78793          	addi	a5,a5,1262 # 80005f80 <kernelvec>
    80002a9a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a9e:	fffff097          	auipc	ra,0xfffff
    80002aa2:	f0e080e7          	jalr	-242(ra) # 800019ac <myproc>
    80002aa6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002aa8:	695c                	ld	a5,144(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aaa:	14102773          	csrr	a4,sepc
    80002aae:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ab0:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002ab4:	47a1                	li	a5,8
    80002ab6:	02f70763          	beq	a4,a5,80002ae4 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002aba:	00000097          	auipc	ra,0x0
    80002abe:	f20080e7          	jalr	-224(ra) # 800029da <devintr>
    80002ac2:	892a                	mv	s2,a0
    80002ac4:	c92d                	beqz	a0,80002b36 <usertrap+0xba>
  if (killed(p))
    80002ac6:	8526                	mv	a0,s1
    80002ac8:	00000097          	auipc	ra,0x0
    80002acc:	89e080e7          	jalr	-1890(ra) # 80002366 <killed>
    80002ad0:	c555                	beqz	a0,80002b7c <usertrap+0x100>
    80002ad2:	a045                	j	80002b72 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002ad4:	00006517          	auipc	a0,0x6
    80002ad8:	84c50513          	addi	a0,a0,-1972 # 80008320 <states.0+0x58>
    80002adc:	ffffe097          	auipc	ra,0xffffe
    80002ae0:	a62080e7          	jalr	-1438(ra) # 8000053e <panic>
    if (killed(p))
    80002ae4:	00000097          	auipc	ra,0x0
    80002ae8:	882080e7          	jalr	-1918(ra) # 80002366 <killed>
    80002aec:	ed1d                	bnez	a0,80002b2a <usertrap+0xae>
    p->trapframe->epc += 4;
    80002aee:	68d8                	ld	a4,144(s1)
    80002af0:	6f1c                	ld	a5,24(a4)
    80002af2:	0791                	addi	a5,a5,4
    80002af4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002afa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002afe:	10079073          	csrw	sstatus,a5
    syscall();
    80002b02:	00000097          	auipc	ra,0x0
    80002b06:	332080e7          	jalr	818(ra) # 80002e34 <syscall>
  if (killed(p))
    80002b0a:	8526                	mv	a0,s1
    80002b0c:	00000097          	auipc	ra,0x0
    80002b10:	85a080e7          	jalr	-1958(ra) # 80002366 <killed>
    80002b14:	ed31                	bnez	a0,80002b70 <usertrap+0xf4>
  usertrapret();
    80002b16:	00000097          	auipc	ra,0x0
    80002b1a:	dda080e7          	jalr	-550(ra) # 800028f0 <usertrapret>
}
    80002b1e:	60e2                	ld	ra,24(sp)
    80002b20:	6442                	ld	s0,16(sp)
    80002b22:	64a2                	ld	s1,8(sp)
    80002b24:	6902                	ld	s2,0(sp)
    80002b26:	6105                	addi	sp,sp,32
    80002b28:	8082                	ret
      exit(-1);
    80002b2a:	557d                	li	a0,-1
    80002b2c:	fffff097          	auipc	ra,0xfffff
    80002b30:	6ba080e7          	jalr	1722(ra) # 800021e6 <exit>
    80002b34:	bf6d                	j	80002aee <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b36:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b3a:	5890                	lw	a2,48(s1)
    80002b3c:	00006517          	auipc	a0,0x6
    80002b40:	80450513          	addi	a0,a0,-2044 # 80008340 <states.0+0x78>
    80002b44:	ffffe097          	auipc	ra,0xffffe
    80002b48:	a44080e7          	jalr	-1468(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b4c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b50:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b54:	00006517          	auipc	a0,0x6
    80002b58:	81c50513          	addi	a0,a0,-2020 # 80008370 <states.0+0xa8>
    80002b5c:	ffffe097          	auipc	ra,0xffffe
    80002b60:	a2c080e7          	jalr	-1492(ra) # 80000588 <printf>
    setkilled(p);
    80002b64:	8526                	mv	a0,s1
    80002b66:	fffff097          	auipc	ra,0xfffff
    80002b6a:	7d4080e7          	jalr	2004(ra) # 8000233a <setkilled>
    80002b6e:	bf71                	j	80002b0a <usertrap+0x8e>
  if (killed(p))
    80002b70:	4901                	li	s2,0
    exit(-1);
    80002b72:	557d                	li	a0,-1
    80002b74:	fffff097          	auipc	ra,0xfffff
    80002b78:	672080e7          	jalr	1650(ra) # 800021e6 <exit>
  if (which_dev == 2)
    80002b7c:	4789                	li	a5,2
    80002b7e:	f8f91ce3          	bne	s2,a5,80002b16 <usertrap+0x9a>
    if(p->ticks > 0)
    80002b82:	40b8                	lw	a4,64(s1)
    80002b84:	00e05b63          	blez	a4,80002b9a <usertrap+0x11e>
      p->cur_ticks++;
    80002b88:	40fc                	lw	a5,68(s1)
    80002b8a:	2785                	addiw	a5,a5,1
    80002b8c:	0007869b          	sext.w	a3,a5
    80002b90:	c0fc                	sw	a5,68(s1)
      if(p->alarm_on == 0 && p->cur_ticks >= p->ticks)
    80002b92:	48bc                	lw	a5,80(s1)
    80002b94:	e399                	bnez	a5,80002b9a <usertrap+0x11e>
    80002b96:	00e6d763          	bge	a3,a4,80002ba4 <usertrap+0x128>
    yield();
    80002b9a:	fffff097          	auipc	ra,0xfffff
    80002b9e:	4dc080e7          	jalr	1244(ra) # 80002076 <yield>
    80002ba2:	bf95                	j	80002b16 <usertrap+0x9a>
        struct trapframe* tf = kalloc();
    80002ba4:	ffffe097          	auipc	ra,0xffffe
    80002ba8:	f42080e7          	jalr	-190(ra) # 80000ae6 <kalloc>
    80002bac:	892a                	mv	s2,a0
        p->alarm_on = 1;
    80002bae:	4785                	li	a5,1
    80002bb0:	c8bc                	sw	a5,80(s1)
        p->cur_ticks = 0;
    80002bb2:	0404a223          	sw	zero,68(s1)
        memmove(tf, p->trapframe, PGSIZE);
    80002bb6:	6605                	lui	a2,0x1
    80002bb8:	68cc                	ld	a1,144(s1)
    80002bba:	ffffe097          	auipc	ra,0xffffe
    80002bbe:	174080e7          	jalr	372(ra) # 80000d2e <memmove>
        p->trapframe->epc = p->handler;
    80002bc2:	68dc                	ld	a5,144(s1)
    80002bc4:	7c98                	ld	a4,56(s1)
    80002bc6:	ef98                	sd	a4,24(a5)
        p->alarm_tf = tf;
    80002bc8:	0524b423          	sd	s2,72(s1)
    80002bcc:	b7f9                	j	80002b9a <usertrap+0x11e>

0000000080002bce <kerneltrap>:
{
    80002bce:	7179                	addi	sp,sp,-48
    80002bd0:	f406                	sd	ra,40(sp)
    80002bd2:	f022                	sd	s0,32(sp)
    80002bd4:	ec26                	sd	s1,24(sp)
    80002bd6:	e84a                	sd	s2,16(sp)
    80002bd8:	e44e                	sd	s3,8(sp)
    80002bda:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bdc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002be0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002be4:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002be8:	1004f793          	andi	a5,s1,256
    80002bec:	cb85                	beqz	a5,80002c1c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bf2:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002bf4:	ef85                	bnez	a5,80002c2c <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002bf6:	00000097          	auipc	ra,0x0
    80002bfa:	de4080e7          	jalr	-540(ra) # 800029da <devintr>
    80002bfe:	cd1d                	beqz	a0,80002c3c <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0)
    80002c00:	4789                	li	a5,2
    80002c02:	06f50a63          	beq	a0,a5,80002c76 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c06:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c0a:	10049073          	csrw	sstatus,s1
}
    80002c0e:	70a2                	ld	ra,40(sp)
    80002c10:	7402                	ld	s0,32(sp)
    80002c12:	64e2                	ld	s1,24(sp)
    80002c14:	6942                	ld	s2,16(sp)
    80002c16:	69a2                	ld	s3,8(sp)
    80002c18:	6145                	addi	sp,sp,48
    80002c1a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c1c:	00005517          	auipc	a0,0x5
    80002c20:	77450513          	addi	a0,a0,1908 # 80008390 <states.0+0xc8>
    80002c24:	ffffe097          	auipc	ra,0xffffe
    80002c28:	91a080e7          	jalr	-1766(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002c2c:	00005517          	auipc	a0,0x5
    80002c30:	78c50513          	addi	a0,a0,1932 # 800083b8 <states.0+0xf0>
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	90a080e7          	jalr	-1782(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002c3c:	85ce                	mv	a1,s3
    80002c3e:	00005517          	auipc	a0,0x5
    80002c42:	79a50513          	addi	a0,a0,1946 # 800083d8 <states.0+0x110>
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	942080e7          	jalr	-1726(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c4e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c52:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c56:	00005517          	auipc	a0,0x5
    80002c5a:	79250513          	addi	a0,a0,1938 # 800083e8 <states.0+0x120>
    80002c5e:	ffffe097          	auipc	ra,0xffffe
    80002c62:	92a080e7          	jalr	-1750(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002c66:	00005517          	auipc	a0,0x5
    80002c6a:	79a50513          	addi	a0,a0,1946 # 80008400 <states.0+0x138>
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	8d0080e7          	jalr	-1840(ra) # 8000053e <panic>
  if (which_dev == 2 && myproc() != 0)
    80002c76:	fffff097          	auipc	ra,0xfffff
    80002c7a:	d36080e7          	jalr	-714(ra) # 800019ac <myproc>
    80002c7e:	d541                	beqz	a0,80002c06 <kerneltrap+0x38>
    struct proc* p = myproc();
    80002c80:	fffff097          	auipc	ra,0xfffff
    80002c84:	d2c080e7          	jalr	-724(ra) # 800019ac <myproc>
    p->cur_ticks++;
    80002c88:	417c                	lw	a5,68(a0)
    80002c8a:	2785                	addiw	a5,a5,1
    80002c8c:	0007869b          	sext.w	a3,a5
    80002c90:	c17c                	sw	a5,68(a0)
    if(p->alarm_on == 1 && p->cur_ticks == p->ticks)
    80002c92:	4938                	lw	a4,80(a0)
    80002c94:	4785                	li	a5,1
    80002c96:	00f70763          	beq	a4,a5,80002ca4 <kerneltrap+0xd6>
    yield();
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	3dc080e7          	jalr	988(ra) # 80002076 <yield>
    80002ca2:	b795                	j	80002c06 <kerneltrap+0x38>
    if(p->alarm_on == 1 && p->cur_ticks == p->ticks)
    80002ca4:	413c                	lw	a5,64(a0)
    80002ca6:	fed79ae3          	bne	a5,a3,80002c9a <kerneltrap+0xcc>
      p->alarm_on = 0;
    80002caa:	04052823          	sw	zero,80(a0)
      p->trapframe->epc = p->handler;
    80002cae:	695c                	ld	a5,144(a0)
    80002cb0:	7d18                	ld	a4,56(a0)
    80002cb2:	ef98                	sd	a4,24(a5)
    80002cb4:	b7dd                	j	80002c9a <kerneltrap+0xcc>

0000000080002cb6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cb6:	1101                	addi	sp,sp,-32
    80002cb8:	ec06                	sd	ra,24(sp)
    80002cba:	e822                	sd	s0,16(sp)
    80002cbc:	e426                	sd	s1,8(sp)
    80002cbe:	1000                	addi	s0,sp,32
    80002cc0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	cea080e7          	jalr	-790(ra) # 800019ac <myproc>
  switch (n) {
    80002cca:	4795                	li	a5,5
    80002ccc:	0497e163          	bltu	a5,s1,80002d0e <argraw+0x58>
    80002cd0:	048a                	slli	s1,s1,0x2
    80002cd2:	00005717          	auipc	a4,0x5
    80002cd6:	76670713          	addi	a4,a4,1894 # 80008438 <states.0+0x170>
    80002cda:	94ba                	add	s1,s1,a4
    80002cdc:	409c                	lw	a5,0(s1)
    80002cde:	97ba                	add	a5,a5,a4
    80002ce0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ce2:	695c                	ld	a5,144(a0)
    80002ce4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ce6:	60e2                	ld	ra,24(sp)
    80002ce8:	6442                	ld	s0,16(sp)
    80002cea:	64a2                	ld	s1,8(sp)
    80002cec:	6105                	addi	sp,sp,32
    80002cee:	8082                	ret
    return p->trapframe->a1;
    80002cf0:	695c                	ld	a5,144(a0)
    80002cf2:	7fa8                	ld	a0,120(a5)
    80002cf4:	bfcd                	j	80002ce6 <argraw+0x30>
    return p->trapframe->a2;
    80002cf6:	695c                	ld	a5,144(a0)
    80002cf8:	63c8                	ld	a0,128(a5)
    80002cfa:	b7f5                	j	80002ce6 <argraw+0x30>
    return p->trapframe->a3;
    80002cfc:	695c                	ld	a5,144(a0)
    80002cfe:	67c8                	ld	a0,136(a5)
    80002d00:	b7dd                	j	80002ce6 <argraw+0x30>
    return p->trapframe->a4;
    80002d02:	695c                	ld	a5,144(a0)
    80002d04:	6bc8                	ld	a0,144(a5)
    80002d06:	b7c5                	j	80002ce6 <argraw+0x30>
    return p->trapframe->a5;
    80002d08:	695c                	ld	a5,144(a0)
    80002d0a:	6fc8                	ld	a0,152(a5)
    80002d0c:	bfe9                	j	80002ce6 <argraw+0x30>
  panic("argraw");
    80002d0e:	00005517          	auipc	a0,0x5
    80002d12:	70250513          	addi	a0,a0,1794 # 80008410 <states.0+0x148>
    80002d16:	ffffe097          	auipc	ra,0xffffe
    80002d1a:	828080e7          	jalr	-2008(ra) # 8000053e <panic>

0000000080002d1e <fetchaddr>:
{
    80002d1e:	1101                	addi	sp,sp,-32
    80002d20:	ec06                	sd	ra,24(sp)
    80002d22:	e822                	sd	s0,16(sp)
    80002d24:	e426                	sd	s1,8(sp)
    80002d26:	e04a                	sd	s2,0(sp)
    80002d28:	1000                	addi	s0,sp,32
    80002d2a:	84aa                	mv	s1,a0
    80002d2c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d2e:	fffff097          	auipc	ra,0xfffff
    80002d32:	c7e080e7          	jalr	-898(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d36:	615c                	ld	a5,128(a0)
    80002d38:	02f4f863          	bgeu	s1,a5,80002d68 <fetchaddr+0x4a>
    80002d3c:	00848713          	addi	a4,s1,8
    80002d40:	02e7e663          	bltu	a5,a4,80002d6c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d44:	46a1                	li	a3,8
    80002d46:	8626                	mv	a2,s1
    80002d48:	85ca                	mv	a1,s2
    80002d4a:	6548                	ld	a0,136(a0)
    80002d4c:	fffff097          	auipc	ra,0xfffff
    80002d50:	9a8080e7          	jalr	-1624(ra) # 800016f4 <copyin>
    80002d54:	00a03533          	snez	a0,a0
    80002d58:	40a00533          	neg	a0,a0
}
    80002d5c:	60e2                	ld	ra,24(sp)
    80002d5e:	6442                	ld	s0,16(sp)
    80002d60:	64a2                	ld	s1,8(sp)
    80002d62:	6902                	ld	s2,0(sp)
    80002d64:	6105                	addi	sp,sp,32
    80002d66:	8082                	ret
    return -1;
    80002d68:	557d                	li	a0,-1
    80002d6a:	bfcd                	j	80002d5c <fetchaddr+0x3e>
    80002d6c:	557d                	li	a0,-1
    80002d6e:	b7fd                	j	80002d5c <fetchaddr+0x3e>

0000000080002d70 <fetchstr>:
{
    80002d70:	7179                	addi	sp,sp,-48
    80002d72:	f406                	sd	ra,40(sp)
    80002d74:	f022                	sd	s0,32(sp)
    80002d76:	ec26                	sd	s1,24(sp)
    80002d78:	e84a                	sd	s2,16(sp)
    80002d7a:	e44e                	sd	s3,8(sp)
    80002d7c:	1800                	addi	s0,sp,48
    80002d7e:	892a                	mv	s2,a0
    80002d80:	84ae                	mv	s1,a1
    80002d82:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	c28080e7          	jalr	-984(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d8c:	86ce                	mv	a3,s3
    80002d8e:	864a                	mv	a2,s2
    80002d90:	85a6                	mv	a1,s1
    80002d92:	6548                	ld	a0,136(a0)
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	9ee080e7          	jalr	-1554(ra) # 80001782 <copyinstr>
    80002d9c:	00054e63          	bltz	a0,80002db8 <fetchstr+0x48>
  return strlen(buf);
    80002da0:	8526                	mv	a0,s1
    80002da2:	ffffe097          	auipc	ra,0xffffe
    80002da6:	0ac080e7          	jalr	172(ra) # 80000e4e <strlen>
}
    80002daa:	70a2                	ld	ra,40(sp)
    80002dac:	7402                	ld	s0,32(sp)
    80002dae:	64e2                	ld	s1,24(sp)
    80002db0:	6942                	ld	s2,16(sp)
    80002db2:	69a2                	ld	s3,8(sp)
    80002db4:	6145                	addi	sp,sp,48
    80002db6:	8082                	ret
    return -1;
    80002db8:	557d                	li	a0,-1
    80002dba:	bfc5                	j	80002daa <fetchstr+0x3a>

0000000080002dbc <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002dbc:	1101                	addi	sp,sp,-32
    80002dbe:	ec06                	sd	ra,24(sp)
    80002dc0:	e822                	sd	s0,16(sp)
    80002dc2:	e426                	sd	s1,8(sp)
    80002dc4:	1000                	addi	s0,sp,32
    80002dc6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dc8:	00000097          	auipc	ra,0x0
    80002dcc:	eee080e7          	jalr	-274(ra) # 80002cb6 <argraw>
    80002dd0:	c088                	sw	a0,0(s1)
}
    80002dd2:	60e2                	ld	ra,24(sp)
    80002dd4:	6442                	ld	s0,16(sp)
    80002dd6:	64a2                	ld	s1,8(sp)
    80002dd8:	6105                	addi	sp,sp,32
    80002dda:	8082                	ret

0000000080002ddc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ddc:	1101                	addi	sp,sp,-32
    80002dde:	ec06                	sd	ra,24(sp)
    80002de0:	e822                	sd	s0,16(sp)
    80002de2:	e426                	sd	s1,8(sp)
    80002de4:	1000                	addi	s0,sp,32
    80002de6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002de8:	00000097          	auipc	ra,0x0
    80002dec:	ece080e7          	jalr	-306(ra) # 80002cb6 <argraw>
    80002df0:	e088                	sd	a0,0(s1)
}
    80002df2:	60e2                	ld	ra,24(sp)
    80002df4:	6442                	ld	s0,16(sp)
    80002df6:	64a2                	ld	s1,8(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret

0000000080002dfc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002dfc:	7179                	addi	sp,sp,-48
    80002dfe:	f406                	sd	ra,40(sp)
    80002e00:	f022                	sd	s0,32(sp)
    80002e02:	ec26                	sd	s1,24(sp)
    80002e04:	e84a                	sd	s2,16(sp)
    80002e06:	1800                	addi	s0,sp,48
    80002e08:	84ae                	mv	s1,a1
    80002e0a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e0c:	fd840593          	addi	a1,s0,-40
    80002e10:	00000097          	auipc	ra,0x0
    80002e14:	fcc080e7          	jalr	-52(ra) # 80002ddc <argaddr>
  return fetchstr(addr, buf, max);
    80002e18:	864a                	mv	a2,s2
    80002e1a:	85a6                	mv	a1,s1
    80002e1c:	fd843503          	ld	a0,-40(s0)
    80002e20:	00000097          	auipc	ra,0x0
    80002e24:	f50080e7          	jalr	-176(ra) # 80002d70 <fetchstr>
}
    80002e28:	70a2                	ld	ra,40(sp)
    80002e2a:	7402                	ld	s0,32(sp)
    80002e2c:	64e2                	ld	s1,24(sp)
    80002e2e:	6942                	ld	s2,16(sp)
    80002e30:	6145                	addi	sp,sp,48
    80002e32:	8082                	ret

0000000080002e34 <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80002e34:	1101                	addi	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	e426                	sd	s1,8(sp)
    80002e3c:	e04a                	sd	s2,0(sp)
    80002e3e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e40:	fffff097          	auipc	ra,0xfffff
    80002e44:	b6c080e7          	jalr	-1172(ra) # 800019ac <myproc>
    80002e48:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80002e4a:	09053903          	ld	s2,144(a0)
    80002e4e:	0a893783          	ld	a5,168(s2)
    80002e52:	0007869b          	sext.w	a3,a5

  if(num == SYS_read)
    80002e56:	4715                	li	a4,5
    80002e58:	02e68363          	beq	a3,a4,80002e7e <syscall+0x4a>
    p->read_count++;

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e5c:	37fd                	addiw	a5,a5,-1
    80002e5e:	4761                	li	a4,24
    80002e60:	02f76a63          	bltu	a4,a5,80002e94 <syscall+0x60>
    80002e64:	00369713          	slli	a4,a3,0x3
    80002e68:	00005797          	auipc	a5,0x5
    80002e6c:	5e878793          	addi	a5,a5,1512 # 80008450 <syscalls>
    80002e70:	97ba                	add	a5,a5,a4
    80002e72:	6398                	ld	a4,0(a5)
    80002e74:	c305                	beqz	a4,80002e94 <syscall+0x60>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e76:	9702                	jalr	a4
    80002e78:	06a93823          	sd	a0,112(s2)
    80002e7c:	a815                	j	80002eb0 <syscall+0x7c>
    p->read_count++;
    80002e7e:	5958                	lw	a4,52(a0)
    80002e80:	2705                	addiw	a4,a4,1
    80002e82:	d958                	sw	a4,52(a0)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e84:	37fd                	addiw	a5,a5,-1
    80002e86:	4661                	li	a2,24
    80002e88:	00002717          	auipc	a4,0x2
    80002e8c:	75c70713          	addi	a4,a4,1884 # 800055e4 <sys_read>
    80002e90:	fef673e3          	bgeu	a2,a5,80002e76 <syscall+0x42>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e94:	19048613          	addi	a2,s1,400
    80002e98:	588c                	lw	a1,48(s1)
    80002e9a:	00005517          	auipc	a0,0x5
    80002e9e:	57e50513          	addi	a0,a0,1406 # 80008418 <states.0+0x150>
    80002ea2:	ffffd097          	auipc	ra,0xffffd
    80002ea6:	6e6080e7          	jalr	1766(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002eaa:	68dc                	ld	a5,144(s1)
    80002eac:	577d                	li	a4,-1
    80002eae:	fbb8                	sd	a4,112(a5)
  }
}
    80002eb0:	60e2                	ld	ra,24(sp)
    80002eb2:	6442                	ld	s0,16(sp)
    80002eb4:	64a2                	ld	s1,8(sp)
    80002eb6:	6902                	ld	s2,0(sp)
    80002eb8:	6105                	addi	sp,sp,32
    80002eba:	8082                	ret

0000000080002ebc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ebc:	1101                	addi	sp,sp,-32
    80002ebe:	ec06                	sd	ra,24(sp)
    80002ec0:	e822                	sd	s0,16(sp)
    80002ec2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ec4:	fec40593          	addi	a1,s0,-20
    80002ec8:	4501                	li	a0,0
    80002eca:	00000097          	auipc	ra,0x0
    80002ece:	ef2080e7          	jalr	-270(ra) # 80002dbc <argint>
  exit(n);
    80002ed2:	fec42503          	lw	a0,-20(s0)
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	310080e7          	jalr	784(ra) # 800021e6 <exit>
  return 0; // not reached
}
    80002ede:	4501                	li	a0,0
    80002ee0:	60e2                	ld	ra,24(sp)
    80002ee2:	6442                	ld	s0,16(sp)
    80002ee4:	6105                	addi	sp,sp,32
    80002ee6:	8082                	ret

0000000080002ee8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ee8:	1141                	addi	sp,sp,-16
    80002eea:	e406                	sd	ra,8(sp)
    80002eec:	e022                	sd	s0,0(sp)
    80002eee:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ef0:	fffff097          	auipc	ra,0xfffff
    80002ef4:	abc080e7          	jalr	-1348(ra) # 800019ac <myproc>
}
    80002ef8:	5908                	lw	a0,48(a0)
    80002efa:	60a2                	ld	ra,8(sp)
    80002efc:	6402                	ld	s0,0(sp)
    80002efe:	0141                	addi	sp,sp,16
    80002f00:	8082                	ret

0000000080002f02 <sys_fork>:

uint64
sys_fork(void)
{
    80002f02:	1141                	addi	sp,sp,-16
    80002f04:	e406                	sd	ra,8(sp)
    80002f06:	e022                	sd	s0,0(sp)
    80002f08:	0800                	addi	s0,sp,16
  return fork();
    80002f0a:	fffff097          	auipc	ra,0xfffff
    80002f0e:	ea0080e7          	jalr	-352(ra) # 80001daa <fork>
}
    80002f12:	60a2                	ld	ra,8(sp)
    80002f14:	6402                	ld	s0,0(sp)
    80002f16:	0141                	addi	sp,sp,16
    80002f18:	8082                	ret

0000000080002f1a <sys_wait>:

uint64
sys_wait(void)
{
    80002f1a:	1101                	addi	sp,sp,-32
    80002f1c:	ec06                	sd	ra,24(sp)
    80002f1e:	e822                	sd	s0,16(sp)
    80002f20:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f22:	fe840593          	addi	a1,s0,-24
    80002f26:	4501                	li	a0,0
    80002f28:	00000097          	auipc	ra,0x0
    80002f2c:	eb4080e7          	jalr	-332(ra) # 80002ddc <argaddr>
  return wait(p);
    80002f30:	fe843503          	ld	a0,-24(s0)
    80002f34:	fffff097          	auipc	ra,0xfffff
    80002f38:	464080e7          	jalr	1124(ra) # 80002398 <wait>
}
    80002f3c:	60e2                	ld	ra,24(sp)
    80002f3e:	6442                	ld	s0,16(sp)
    80002f40:	6105                	addi	sp,sp,32
    80002f42:	8082                	ret

0000000080002f44 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f44:	7179                	addi	sp,sp,-48
    80002f46:	f406                	sd	ra,40(sp)
    80002f48:	f022                	sd	s0,32(sp)
    80002f4a:	ec26                	sd	s1,24(sp)
    80002f4c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f4e:	fdc40593          	addi	a1,s0,-36
    80002f52:	4501                	li	a0,0
    80002f54:	00000097          	auipc	ra,0x0
    80002f58:	e68080e7          	jalr	-408(ra) # 80002dbc <argint>
  addr = myproc()->sz;
    80002f5c:	fffff097          	auipc	ra,0xfffff
    80002f60:	a50080e7          	jalr	-1456(ra) # 800019ac <myproc>
    80002f64:	6144                	ld	s1,128(a0)
  if (growproc(n) < 0)
    80002f66:	fdc42503          	lw	a0,-36(s0)
    80002f6a:	fffff097          	auipc	ra,0xfffff
    80002f6e:	de4080e7          	jalr	-540(ra) # 80001d4e <growproc>
    80002f72:	00054863          	bltz	a0,80002f82 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f76:	8526                	mv	a0,s1
    80002f78:	70a2                	ld	ra,40(sp)
    80002f7a:	7402                	ld	s0,32(sp)
    80002f7c:	64e2                	ld	s1,24(sp)
    80002f7e:	6145                	addi	sp,sp,48
    80002f80:	8082                	ret
    return -1;
    80002f82:	54fd                	li	s1,-1
    80002f84:	bfcd                	j	80002f76 <sys_sbrk+0x32>

0000000080002f86 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f86:	7139                	addi	sp,sp,-64
    80002f88:	fc06                	sd	ra,56(sp)
    80002f8a:	f822                	sd	s0,48(sp)
    80002f8c:	f426                	sd	s1,40(sp)
    80002f8e:	f04a                	sd	s2,32(sp)
    80002f90:	ec4e                	sd	s3,24(sp)
    80002f92:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f94:	fcc40593          	addi	a1,s0,-52
    80002f98:	4501                	li	a0,0
    80002f9a:	00000097          	auipc	ra,0x0
    80002f9e:	e22080e7          	jalr	-478(ra) # 80002dbc <argint>
  acquire(&tickslock);
    80002fa2:	00015517          	auipc	a0,0x15
    80002fa6:	bee50513          	addi	a0,a0,-1042 # 80017b90 <tickslock>
    80002faa:	ffffe097          	auipc	ra,0xffffe
    80002fae:	c2c080e7          	jalr	-980(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002fb2:	00006917          	auipc	s2,0x6
    80002fb6:	92e92903          	lw	s2,-1746(s2) # 800088e0 <ticks>
  while (ticks - ticks0 < n)
    80002fba:	fcc42783          	lw	a5,-52(s0)
    80002fbe:	cf9d                	beqz	a5,80002ffc <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fc0:	00015997          	auipc	s3,0x15
    80002fc4:	bd098993          	addi	s3,s3,-1072 # 80017b90 <tickslock>
    80002fc8:	00006497          	auipc	s1,0x6
    80002fcc:	91848493          	addi	s1,s1,-1768 # 800088e0 <ticks>
    if (killed(myproc()))
    80002fd0:	fffff097          	auipc	ra,0xfffff
    80002fd4:	9dc080e7          	jalr	-1572(ra) # 800019ac <myproc>
    80002fd8:	fffff097          	auipc	ra,0xfffff
    80002fdc:	38e080e7          	jalr	910(ra) # 80002366 <killed>
    80002fe0:	ed15                	bnez	a0,8000301c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002fe2:	85ce                	mv	a1,s3
    80002fe4:	8526                	mv	a0,s1
    80002fe6:	fffff097          	auipc	ra,0xfffff
    80002fea:	0cc080e7          	jalr	204(ra) # 800020b2 <sleep>
  while (ticks - ticks0 < n)
    80002fee:	409c                	lw	a5,0(s1)
    80002ff0:	412787bb          	subw	a5,a5,s2
    80002ff4:	fcc42703          	lw	a4,-52(s0)
    80002ff8:	fce7ece3          	bltu	a5,a4,80002fd0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002ffc:	00015517          	auipc	a0,0x15
    80003000:	b9450513          	addi	a0,a0,-1132 # 80017b90 <tickslock>
    80003004:	ffffe097          	auipc	ra,0xffffe
    80003008:	c86080e7          	jalr	-890(ra) # 80000c8a <release>
  return 0;
    8000300c:	4501                	li	a0,0
}
    8000300e:	70e2                	ld	ra,56(sp)
    80003010:	7442                	ld	s0,48(sp)
    80003012:	74a2                	ld	s1,40(sp)
    80003014:	7902                	ld	s2,32(sp)
    80003016:	69e2                	ld	s3,24(sp)
    80003018:	6121                	addi	sp,sp,64
    8000301a:	8082                	ret
      release(&tickslock);
    8000301c:	00015517          	auipc	a0,0x15
    80003020:	b7450513          	addi	a0,a0,-1164 # 80017b90 <tickslock>
    80003024:	ffffe097          	auipc	ra,0xffffe
    80003028:	c66080e7          	jalr	-922(ra) # 80000c8a <release>
      return -1;
    8000302c:	557d                	li	a0,-1
    8000302e:	b7c5                	j	8000300e <sys_sleep+0x88>

0000000080003030 <sys_kill>:

uint64
sys_kill(void)
{
    80003030:	1101                	addi	sp,sp,-32
    80003032:	ec06                	sd	ra,24(sp)
    80003034:	e822                	sd	s0,16(sp)
    80003036:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003038:	fec40593          	addi	a1,s0,-20
    8000303c:	4501                	li	a0,0
    8000303e:	00000097          	auipc	ra,0x0
    80003042:	d7e080e7          	jalr	-642(ra) # 80002dbc <argint>
  return kill(pid);
    80003046:	fec42503          	lw	a0,-20(s0)
    8000304a:	fffff097          	auipc	ra,0xfffff
    8000304e:	27e080e7          	jalr	638(ra) # 800022c8 <kill>
}
    80003052:	60e2                	ld	ra,24(sp)
    80003054:	6442                	ld	s0,16(sp)
    80003056:	6105                	addi	sp,sp,32
    80003058:	8082                	ret

000000008000305a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000305a:	1101                	addi	sp,sp,-32
    8000305c:	ec06                	sd	ra,24(sp)
    8000305e:	e822                	sd	s0,16(sp)
    80003060:	e426                	sd	s1,8(sp)
    80003062:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003064:	00015517          	auipc	a0,0x15
    80003068:	b2c50513          	addi	a0,a0,-1236 # 80017b90 <tickslock>
    8000306c:	ffffe097          	auipc	ra,0xffffe
    80003070:	b6a080e7          	jalr	-1174(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003074:	00006497          	auipc	s1,0x6
    80003078:	86c4a483          	lw	s1,-1940(s1) # 800088e0 <ticks>
  release(&tickslock);
    8000307c:	00015517          	auipc	a0,0x15
    80003080:	b1450513          	addi	a0,a0,-1260 # 80017b90 <tickslock>
    80003084:	ffffe097          	auipc	ra,0xffffe
    80003088:	c06080e7          	jalr	-1018(ra) # 80000c8a <release>
  return xticks;
}
    8000308c:	02049513          	slli	a0,s1,0x20
    80003090:	9101                	srli	a0,a0,0x20
    80003092:	60e2                	ld	ra,24(sp)
    80003094:	6442                	ld	s0,16(sp)
    80003096:	64a2                	ld	s1,8(sp)
    80003098:	6105                	addi	sp,sp,32
    8000309a:	8082                	ret

000000008000309c <sys_waitx>:

uint64
sys_waitx(void)
{
    8000309c:	7139                	addi	sp,sp,-64
    8000309e:	fc06                	sd	ra,56(sp)
    800030a0:	f822                	sd	s0,48(sp)
    800030a2:	f426                	sd	s1,40(sp)
    800030a4:	f04a                	sd	s2,32(sp)
    800030a6:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800030a8:	fd840593          	addi	a1,s0,-40
    800030ac:	4501                	li	a0,0
    800030ae:	00000097          	auipc	ra,0x0
    800030b2:	d2e080e7          	jalr	-722(ra) # 80002ddc <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800030b6:	fd040593          	addi	a1,s0,-48
    800030ba:	4505                	li	a0,1
    800030bc:	00000097          	auipc	ra,0x0
    800030c0:	d20080e7          	jalr	-736(ra) # 80002ddc <argaddr>
  argaddr(2, &addr2);
    800030c4:	fc840593          	addi	a1,s0,-56
    800030c8:	4509                	li	a0,2
    800030ca:	00000097          	auipc	ra,0x0
    800030ce:	d12080e7          	jalr	-750(ra) # 80002ddc <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800030d2:	fc040613          	addi	a2,s0,-64
    800030d6:	fc440593          	addi	a1,s0,-60
    800030da:	fd843503          	ld	a0,-40(s0)
    800030de:	fffff097          	auipc	ra,0xfffff
    800030e2:	542080e7          	jalr	1346(ra) # 80002620 <waitx>
    800030e6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800030e8:	fffff097          	auipc	ra,0xfffff
    800030ec:	8c4080e7          	jalr	-1852(ra) # 800019ac <myproc>
    800030f0:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030f2:	4691                	li	a3,4
    800030f4:	fc440613          	addi	a2,s0,-60
    800030f8:	fd043583          	ld	a1,-48(s0)
    800030fc:	6548                	ld	a0,136(a0)
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	56a080e7          	jalr	1386(ra) # 80001668 <copyout>
    return -1;
    80003106:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003108:	00054f63          	bltz	a0,80003126 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    8000310c:	4691                	li	a3,4
    8000310e:	fc040613          	addi	a2,s0,-64
    80003112:	fc843583          	ld	a1,-56(s0)
    80003116:	64c8                	ld	a0,136(s1)
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	550080e7          	jalr	1360(ra) # 80001668 <copyout>
    80003120:	00054a63          	bltz	a0,80003134 <sys_waitx+0x98>
    return -1;
  return ret;
    80003124:	87ca                	mv	a5,s2
}
    80003126:	853e                	mv	a0,a5
    80003128:	70e2                	ld	ra,56(sp)
    8000312a:	7442                	ld	s0,48(sp)
    8000312c:	74a2                	ld	s1,40(sp)
    8000312e:	7902                	ld	s2,32(sp)
    80003130:	6121                	addi	sp,sp,64
    80003132:	8082                	ret
    return -1;
    80003134:	57fd                	li	a5,-1
    80003136:	bfc5                	j	80003126 <sys_waitx+0x8a>

0000000080003138 <sys_getreadcount>:

uint64
sys_getreadcount(void)
{
    80003138:	1141                	addi	sp,sp,-16
    8000313a:	e406                	sd	ra,8(sp)
    8000313c:	e022                	sd	s0,0(sp)
    8000313e:	0800                	addi	s0,sp,16
  return myproc()->read_count;
    80003140:	fffff097          	auipc	ra,0xfffff
    80003144:	86c080e7          	jalr	-1940(ra) # 800019ac <myproc>
}
    80003148:	5948                	lw	a0,52(a0)
    8000314a:	60a2                	ld	ra,8(sp)
    8000314c:	6402                	ld	s0,0(sp)
    8000314e:	0141                	addi	sp,sp,16
    80003150:	8082                	ret

0000000080003152 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80003152:	1101                	addi	sp,sp,-32
    80003154:	ec06                	sd	ra,24(sp)
    80003156:	e822                	sd	s0,16(sp)
    80003158:	1000                	addi	s0,sp,32
  uint64 addr;
  int ticks;

  argint(0, &ticks);
    8000315a:	fe440593          	addi	a1,s0,-28
    8000315e:	4501                	li	a0,0
    80003160:	00000097          	auipc	ra,0x0
    80003164:	c5c080e7          	jalr	-932(ra) # 80002dbc <argint>
  argaddr(1, &addr);
    80003168:	fe840593          	addi	a1,s0,-24
    8000316c:	4505                	li	a0,1
    8000316e:	00000097          	auipc	ra,0x0
    80003172:	c6e080e7          	jalr	-914(ra) # 80002ddc <argaddr>
  myproc()->ticks = ticks;
    80003176:	fffff097          	auipc	ra,0xfffff
    8000317a:	836080e7          	jalr	-1994(ra) # 800019ac <myproc>
    8000317e:	fe442783          	lw	a5,-28(s0)
    80003182:	c13c                	sw	a5,64(a0)
  myproc()->handler = addr;
    80003184:	fffff097          	auipc	ra,0xfffff
    80003188:	828080e7          	jalr	-2008(ra) # 800019ac <myproc>
    8000318c:	fe843783          	ld	a5,-24(s0)
    80003190:	fd1c                	sd	a5,56(a0)
  myproc()->alarm_on = 0;
    80003192:	fffff097          	auipc	ra,0xfffff
    80003196:	81a080e7          	jalr	-2022(ra) # 800019ac <myproc>
    8000319a:	04052823          	sw	zero,80(a0)
  myproc()->cur_ticks = 0;
    8000319e:	fffff097          	auipc	ra,0xfffff
    800031a2:	80e080e7          	jalr	-2034(ra) # 800019ac <myproc>
    800031a6:	04052223          	sw	zero,68(a0)

  return 0;
}
    800031aa:	4501                	li	a0,0
    800031ac:	60e2                	ld	ra,24(sp)
    800031ae:	6442                	ld	s0,16(sp)
    800031b0:	6105                	addi	sp,sp,32
    800031b2:	8082                	ret

00000000800031b4 <sys_sigreturn>:

uint64
sys_sigreturn(void)
{
    800031b4:	1101                	addi	sp,sp,-32
    800031b6:	ec06                	sd	ra,24(sp)
    800031b8:	e822                	sd	s0,16(sp)
    800031ba:	e426                	sd	s1,8(sp)
    800031bc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800031be:	ffffe097          	auipc	ra,0xffffe
    800031c2:	7ee080e7          	jalr	2030(ra) # 800019ac <myproc>
    800031c6:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    800031c8:	6605                	lui	a2,0x1
    800031ca:	652c                	ld	a1,72(a0)
    800031cc:	6948                	ld	a0,144(a0)
    800031ce:	ffffe097          	auipc	ra,0xffffe
    800031d2:	b60080e7          	jalr	-1184(ra) # 80000d2e <memmove>

  kfree(p->alarm_tf);
    800031d6:	64a8                	ld	a0,72(s1)
    800031d8:	ffffe097          	auipc	ra,0xffffe
    800031dc:	812080e7          	jalr	-2030(ra) # 800009ea <kfree>
  p->alarm_tf = 0;
    800031e0:	0404b423          	sd	zero,72(s1)
  p->alarm_on = 0;
    800031e4:	0404a823          	sw	zero,80(s1)
  p->cur_ticks = 0;
    800031e8:	0404a223          	sw	zero,68(s1)
  // return 0;
  return p->trapframe->a0;
    800031ec:	68dc                	ld	a5,144(s1)
    800031ee:	7ba8                	ld	a0,112(a5)
    800031f0:	60e2                	ld	ra,24(sp)
    800031f2:	6442                	ld	s0,16(sp)
    800031f4:	64a2                	ld	s1,8(sp)
    800031f6:	6105                	addi	sp,sp,32
    800031f8:	8082                	ret

00000000800031fa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800031fa:	7179                	addi	sp,sp,-48
    800031fc:	f406                	sd	ra,40(sp)
    800031fe:	f022                	sd	s0,32(sp)
    80003200:	ec26                	sd	s1,24(sp)
    80003202:	e84a                	sd	s2,16(sp)
    80003204:	e44e                	sd	s3,8(sp)
    80003206:	e052                	sd	s4,0(sp)
    80003208:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000320a:	00005597          	auipc	a1,0x5
    8000320e:	31658593          	addi	a1,a1,790 # 80008520 <syscalls+0xd0>
    80003212:	00015517          	auipc	a0,0x15
    80003216:	99650513          	addi	a0,a0,-1642 # 80017ba8 <bcache>
    8000321a:	ffffe097          	auipc	ra,0xffffe
    8000321e:	92c080e7          	jalr	-1748(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003222:	0001d797          	auipc	a5,0x1d
    80003226:	98678793          	addi	a5,a5,-1658 # 8001fba8 <bcache+0x8000>
    8000322a:	0001d717          	auipc	a4,0x1d
    8000322e:	be670713          	addi	a4,a4,-1050 # 8001fe10 <bcache+0x8268>
    80003232:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003236:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000323a:	00015497          	auipc	s1,0x15
    8000323e:	98648493          	addi	s1,s1,-1658 # 80017bc0 <bcache+0x18>
    b->next = bcache.head.next;
    80003242:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003244:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003246:	00005a17          	auipc	s4,0x5
    8000324a:	2e2a0a13          	addi	s4,s4,738 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    8000324e:	2b893783          	ld	a5,696(s2)
    80003252:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003254:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003258:	85d2                	mv	a1,s4
    8000325a:	01048513          	addi	a0,s1,16
    8000325e:	00001097          	auipc	ra,0x1
    80003262:	4c4080e7          	jalr	1220(ra) # 80004722 <initsleeplock>
    bcache.head.next->prev = b;
    80003266:	2b893783          	ld	a5,696(s2)
    8000326a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000326c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003270:	45848493          	addi	s1,s1,1112
    80003274:	fd349de3          	bne	s1,s3,8000324e <binit+0x54>
  }
}
    80003278:	70a2                	ld	ra,40(sp)
    8000327a:	7402                	ld	s0,32(sp)
    8000327c:	64e2                	ld	s1,24(sp)
    8000327e:	6942                	ld	s2,16(sp)
    80003280:	69a2                	ld	s3,8(sp)
    80003282:	6a02                	ld	s4,0(sp)
    80003284:	6145                	addi	sp,sp,48
    80003286:	8082                	ret

0000000080003288 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003288:	7179                	addi	sp,sp,-48
    8000328a:	f406                	sd	ra,40(sp)
    8000328c:	f022                	sd	s0,32(sp)
    8000328e:	ec26                	sd	s1,24(sp)
    80003290:	e84a                	sd	s2,16(sp)
    80003292:	e44e                	sd	s3,8(sp)
    80003294:	1800                	addi	s0,sp,48
    80003296:	892a                	mv	s2,a0
    80003298:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000329a:	00015517          	auipc	a0,0x15
    8000329e:	90e50513          	addi	a0,a0,-1778 # 80017ba8 <bcache>
    800032a2:	ffffe097          	auipc	ra,0xffffe
    800032a6:	934080e7          	jalr	-1740(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800032aa:	0001d497          	auipc	s1,0x1d
    800032ae:	bb64b483          	ld	s1,-1098(s1) # 8001fe60 <bcache+0x82b8>
    800032b2:	0001d797          	auipc	a5,0x1d
    800032b6:	b5e78793          	addi	a5,a5,-1186 # 8001fe10 <bcache+0x8268>
    800032ba:	02f48f63          	beq	s1,a5,800032f8 <bread+0x70>
    800032be:	873e                	mv	a4,a5
    800032c0:	a021                	j	800032c8 <bread+0x40>
    800032c2:	68a4                	ld	s1,80(s1)
    800032c4:	02e48a63          	beq	s1,a4,800032f8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800032c8:	449c                	lw	a5,8(s1)
    800032ca:	ff279ce3          	bne	a5,s2,800032c2 <bread+0x3a>
    800032ce:	44dc                	lw	a5,12(s1)
    800032d0:	ff3799e3          	bne	a5,s3,800032c2 <bread+0x3a>
      b->refcnt++;
    800032d4:	40bc                	lw	a5,64(s1)
    800032d6:	2785                	addiw	a5,a5,1
    800032d8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032da:	00015517          	auipc	a0,0x15
    800032de:	8ce50513          	addi	a0,a0,-1842 # 80017ba8 <bcache>
    800032e2:	ffffe097          	auipc	ra,0xffffe
    800032e6:	9a8080e7          	jalr	-1624(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800032ea:	01048513          	addi	a0,s1,16
    800032ee:	00001097          	auipc	ra,0x1
    800032f2:	46e080e7          	jalr	1134(ra) # 8000475c <acquiresleep>
      return b;
    800032f6:	a8b9                	j	80003354 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032f8:	0001d497          	auipc	s1,0x1d
    800032fc:	b604b483          	ld	s1,-1184(s1) # 8001fe58 <bcache+0x82b0>
    80003300:	0001d797          	auipc	a5,0x1d
    80003304:	b1078793          	addi	a5,a5,-1264 # 8001fe10 <bcache+0x8268>
    80003308:	00f48863          	beq	s1,a5,80003318 <bread+0x90>
    8000330c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000330e:	40bc                	lw	a5,64(s1)
    80003310:	cf81                	beqz	a5,80003328 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003312:	64a4                	ld	s1,72(s1)
    80003314:	fee49de3          	bne	s1,a4,8000330e <bread+0x86>
  panic("bget: no buffers");
    80003318:	00005517          	auipc	a0,0x5
    8000331c:	21850513          	addi	a0,a0,536 # 80008530 <syscalls+0xe0>
    80003320:	ffffd097          	auipc	ra,0xffffd
    80003324:	21e080e7          	jalr	542(ra) # 8000053e <panic>
      b->dev = dev;
    80003328:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000332c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003330:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003334:	4785                	li	a5,1
    80003336:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003338:	00015517          	auipc	a0,0x15
    8000333c:	87050513          	addi	a0,a0,-1936 # 80017ba8 <bcache>
    80003340:	ffffe097          	auipc	ra,0xffffe
    80003344:	94a080e7          	jalr	-1718(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003348:	01048513          	addi	a0,s1,16
    8000334c:	00001097          	auipc	ra,0x1
    80003350:	410080e7          	jalr	1040(ra) # 8000475c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003354:	409c                	lw	a5,0(s1)
    80003356:	cb89                	beqz	a5,80003368 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003358:	8526                	mv	a0,s1
    8000335a:	70a2                	ld	ra,40(sp)
    8000335c:	7402                	ld	s0,32(sp)
    8000335e:	64e2                	ld	s1,24(sp)
    80003360:	6942                	ld	s2,16(sp)
    80003362:	69a2                	ld	s3,8(sp)
    80003364:	6145                	addi	sp,sp,48
    80003366:	8082                	ret
    virtio_disk_rw(b, 0);
    80003368:	4581                	li	a1,0
    8000336a:	8526                	mv	a0,s1
    8000336c:	00003097          	auipc	ra,0x3
    80003370:	fd8080e7          	jalr	-40(ra) # 80006344 <virtio_disk_rw>
    b->valid = 1;
    80003374:	4785                	li	a5,1
    80003376:	c09c                	sw	a5,0(s1)
  return b;
    80003378:	b7c5                	j	80003358 <bread+0xd0>

000000008000337a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000337a:	1101                	addi	sp,sp,-32
    8000337c:	ec06                	sd	ra,24(sp)
    8000337e:	e822                	sd	s0,16(sp)
    80003380:	e426                	sd	s1,8(sp)
    80003382:	1000                	addi	s0,sp,32
    80003384:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003386:	0541                	addi	a0,a0,16
    80003388:	00001097          	auipc	ra,0x1
    8000338c:	46e080e7          	jalr	1134(ra) # 800047f6 <holdingsleep>
    80003390:	cd01                	beqz	a0,800033a8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003392:	4585                	li	a1,1
    80003394:	8526                	mv	a0,s1
    80003396:	00003097          	auipc	ra,0x3
    8000339a:	fae080e7          	jalr	-82(ra) # 80006344 <virtio_disk_rw>
}
    8000339e:	60e2                	ld	ra,24(sp)
    800033a0:	6442                	ld	s0,16(sp)
    800033a2:	64a2                	ld	s1,8(sp)
    800033a4:	6105                	addi	sp,sp,32
    800033a6:	8082                	ret
    panic("bwrite");
    800033a8:	00005517          	auipc	a0,0x5
    800033ac:	1a050513          	addi	a0,a0,416 # 80008548 <syscalls+0xf8>
    800033b0:	ffffd097          	auipc	ra,0xffffd
    800033b4:	18e080e7          	jalr	398(ra) # 8000053e <panic>

00000000800033b8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800033b8:	1101                	addi	sp,sp,-32
    800033ba:	ec06                	sd	ra,24(sp)
    800033bc:	e822                	sd	s0,16(sp)
    800033be:	e426                	sd	s1,8(sp)
    800033c0:	e04a                	sd	s2,0(sp)
    800033c2:	1000                	addi	s0,sp,32
    800033c4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033c6:	01050913          	addi	s2,a0,16
    800033ca:	854a                	mv	a0,s2
    800033cc:	00001097          	auipc	ra,0x1
    800033d0:	42a080e7          	jalr	1066(ra) # 800047f6 <holdingsleep>
    800033d4:	c92d                	beqz	a0,80003446 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800033d6:	854a                	mv	a0,s2
    800033d8:	00001097          	auipc	ra,0x1
    800033dc:	3da080e7          	jalr	986(ra) # 800047b2 <releasesleep>

  acquire(&bcache.lock);
    800033e0:	00014517          	auipc	a0,0x14
    800033e4:	7c850513          	addi	a0,a0,1992 # 80017ba8 <bcache>
    800033e8:	ffffd097          	auipc	ra,0xffffd
    800033ec:	7ee080e7          	jalr	2030(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800033f0:	40bc                	lw	a5,64(s1)
    800033f2:	37fd                	addiw	a5,a5,-1
    800033f4:	0007871b          	sext.w	a4,a5
    800033f8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800033fa:	eb05                	bnez	a4,8000342a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800033fc:	68bc                	ld	a5,80(s1)
    800033fe:	64b8                	ld	a4,72(s1)
    80003400:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003402:	64bc                	ld	a5,72(s1)
    80003404:	68b8                	ld	a4,80(s1)
    80003406:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003408:	0001c797          	auipc	a5,0x1c
    8000340c:	7a078793          	addi	a5,a5,1952 # 8001fba8 <bcache+0x8000>
    80003410:	2b87b703          	ld	a4,696(a5)
    80003414:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003416:	0001d717          	auipc	a4,0x1d
    8000341a:	9fa70713          	addi	a4,a4,-1542 # 8001fe10 <bcache+0x8268>
    8000341e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003420:	2b87b703          	ld	a4,696(a5)
    80003424:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003426:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000342a:	00014517          	auipc	a0,0x14
    8000342e:	77e50513          	addi	a0,a0,1918 # 80017ba8 <bcache>
    80003432:	ffffe097          	auipc	ra,0xffffe
    80003436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
}
    8000343a:	60e2                	ld	ra,24(sp)
    8000343c:	6442                	ld	s0,16(sp)
    8000343e:	64a2                	ld	s1,8(sp)
    80003440:	6902                	ld	s2,0(sp)
    80003442:	6105                	addi	sp,sp,32
    80003444:	8082                	ret
    panic("brelse");
    80003446:	00005517          	auipc	a0,0x5
    8000344a:	10a50513          	addi	a0,a0,266 # 80008550 <syscalls+0x100>
    8000344e:	ffffd097          	auipc	ra,0xffffd
    80003452:	0f0080e7          	jalr	240(ra) # 8000053e <panic>

0000000080003456 <bpin>:

void
bpin(struct buf *b) {
    80003456:	1101                	addi	sp,sp,-32
    80003458:	ec06                	sd	ra,24(sp)
    8000345a:	e822                	sd	s0,16(sp)
    8000345c:	e426                	sd	s1,8(sp)
    8000345e:	1000                	addi	s0,sp,32
    80003460:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003462:	00014517          	auipc	a0,0x14
    80003466:	74650513          	addi	a0,a0,1862 # 80017ba8 <bcache>
    8000346a:	ffffd097          	auipc	ra,0xffffd
    8000346e:	76c080e7          	jalr	1900(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003472:	40bc                	lw	a5,64(s1)
    80003474:	2785                	addiw	a5,a5,1
    80003476:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003478:	00014517          	auipc	a0,0x14
    8000347c:	73050513          	addi	a0,a0,1840 # 80017ba8 <bcache>
    80003480:	ffffe097          	auipc	ra,0xffffe
    80003484:	80a080e7          	jalr	-2038(ra) # 80000c8a <release>
}
    80003488:	60e2                	ld	ra,24(sp)
    8000348a:	6442                	ld	s0,16(sp)
    8000348c:	64a2                	ld	s1,8(sp)
    8000348e:	6105                	addi	sp,sp,32
    80003490:	8082                	ret

0000000080003492 <bunpin>:

void
bunpin(struct buf *b) {
    80003492:	1101                	addi	sp,sp,-32
    80003494:	ec06                	sd	ra,24(sp)
    80003496:	e822                	sd	s0,16(sp)
    80003498:	e426                	sd	s1,8(sp)
    8000349a:	1000                	addi	s0,sp,32
    8000349c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000349e:	00014517          	auipc	a0,0x14
    800034a2:	70a50513          	addi	a0,a0,1802 # 80017ba8 <bcache>
    800034a6:	ffffd097          	auipc	ra,0xffffd
    800034aa:	730080e7          	jalr	1840(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800034ae:	40bc                	lw	a5,64(s1)
    800034b0:	37fd                	addiw	a5,a5,-1
    800034b2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034b4:	00014517          	auipc	a0,0x14
    800034b8:	6f450513          	addi	a0,a0,1780 # 80017ba8 <bcache>
    800034bc:	ffffd097          	auipc	ra,0xffffd
    800034c0:	7ce080e7          	jalr	1998(ra) # 80000c8a <release>
}
    800034c4:	60e2                	ld	ra,24(sp)
    800034c6:	6442                	ld	s0,16(sp)
    800034c8:	64a2                	ld	s1,8(sp)
    800034ca:	6105                	addi	sp,sp,32
    800034cc:	8082                	ret

00000000800034ce <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800034ce:	1101                	addi	sp,sp,-32
    800034d0:	ec06                	sd	ra,24(sp)
    800034d2:	e822                	sd	s0,16(sp)
    800034d4:	e426                	sd	s1,8(sp)
    800034d6:	e04a                	sd	s2,0(sp)
    800034d8:	1000                	addi	s0,sp,32
    800034da:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800034dc:	00d5d59b          	srliw	a1,a1,0xd
    800034e0:	0001d797          	auipc	a5,0x1d
    800034e4:	da47a783          	lw	a5,-604(a5) # 80020284 <sb+0x1c>
    800034e8:	9dbd                	addw	a1,a1,a5
    800034ea:	00000097          	auipc	ra,0x0
    800034ee:	d9e080e7          	jalr	-610(ra) # 80003288 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800034f2:	0074f713          	andi	a4,s1,7
    800034f6:	4785                	li	a5,1
    800034f8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800034fc:	14ce                	slli	s1,s1,0x33
    800034fe:	90d9                	srli	s1,s1,0x36
    80003500:	00950733          	add	a4,a0,s1
    80003504:	05874703          	lbu	a4,88(a4)
    80003508:	00e7f6b3          	and	a3,a5,a4
    8000350c:	c69d                	beqz	a3,8000353a <bfree+0x6c>
    8000350e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003510:	94aa                	add	s1,s1,a0
    80003512:	fff7c793          	not	a5,a5
    80003516:	8ff9                	and	a5,a5,a4
    80003518:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000351c:	00001097          	auipc	ra,0x1
    80003520:	120080e7          	jalr	288(ra) # 8000463c <log_write>
  brelse(bp);
    80003524:	854a                	mv	a0,s2
    80003526:	00000097          	auipc	ra,0x0
    8000352a:	e92080e7          	jalr	-366(ra) # 800033b8 <brelse>
}
    8000352e:	60e2                	ld	ra,24(sp)
    80003530:	6442                	ld	s0,16(sp)
    80003532:	64a2                	ld	s1,8(sp)
    80003534:	6902                	ld	s2,0(sp)
    80003536:	6105                	addi	sp,sp,32
    80003538:	8082                	ret
    panic("freeing free block");
    8000353a:	00005517          	auipc	a0,0x5
    8000353e:	01e50513          	addi	a0,a0,30 # 80008558 <syscalls+0x108>
    80003542:	ffffd097          	auipc	ra,0xffffd
    80003546:	ffc080e7          	jalr	-4(ra) # 8000053e <panic>

000000008000354a <balloc>:
{
    8000354a:	711d                	addi	sp,sp,-96
    8000354c:	ec86                	sd	ra,88(sp)
    8000354e:	e8a2                	sd	s0,80(sp)
    80003550:	e4a6                	sd	s1,72(sp)
    80003552:	e0ca                	sd	s2,64(sp)
    80003554:	fc4e                	sd	s3,56(sp)
    80003556:	f852                	sd	s4,48(sp)
    80003558:	f456                	sd	s5,40(sp)
    8000355a:	f05a                	sd	s6,32(sp)
    8000355c:	ec5e                	sd	s7,24(sp)
    8000355e:	e862                	sd	s8,16(sp)
    80003560:	e466                	sd	s9,8(sp)
    80003562:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003564:	0001d797          	auipc	a5,0x1d
    80003568:	d087a783          	lw	a5,-760(a5) # 8002026c <sb+0x4>
    8000356c:	10078163          	beqz	a5,8000366e <balloc+0x124>
    80003570:	8baa                	mv	s7,a0
    80003572:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003574:	0001db17          	auipc	s6,0x1d
    80003578:	cf4b0b13          	addi	s6,s6,-780 # 80020268 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000357c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000357e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003580:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003582:	6c89                	lui	s9,0x2
    80003584:	a061                	j	8000360c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003586:	974a                	add	a4,a4,s2
    80003588:	8fd5                	or	a5,a5,a3
    8000358a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000358e:	854a                	mv	a0,s2
    80003590:	00001097          	auipc	ra,0x1
    80003594:	0ac080e7          	jalr	172(ra) # 8000463c <log_write>
        brelse(bp);
    80003598:	854a                	mv	a0,s2
    8000359a:	00000097          	auipc	ra,0x0
    8000359e:	e1e080e7          	jalr	-482(ra) # 800033b8 <brelse>
  bp = bread(dev, bno);
    800035a2:	85a6                	mv	a1,s1
    800035a4:	855e                	mv	a0,s7
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	ce2080e7          	jalr	-798(ra) # 80003288 <bread>
    800035ae:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035b0:	40000613          	li	a2,1024
    800035b4:	4581                	li	a1,0
    800035b6:	05850513          	addi	a0,a0,88
    800035ba:	ffffd097          	auipc	ra,0xffffd
    800035be:	718080e7          	jalr	1816(ra) # 80000cd2 <memset>
  log_write(bp);
    800035c2:	854a                	mv	a0,s2
    800035c4:	00001097          	auipc	ra,0x1
    800035c8:	078080e7          	jalr	120(ra) # 8000463c <log_write>
  brelse(bp);
    800035cc:	854a                	mv	a0,s2
    800035ce:	00000097          	auipc	ra,0x0
    800035d2:	dea080e7          	jalr	-534(ra) # 800033b8 <brelse>
}
    800035d6:	8526                	mv	a0,s1
    800035d8:	60e6                	ld	ra,88(sp)
    800035da:	6446                	ld	s0,80(sp)
    800035dc:	64a6                	ld	s1,72(sp)
    800035de:	6906                	ld	s2,64(sp)
    800035e0:	79e2                	ld	s3,56(sp)
    800035e2:	7a42                	ld	s4,48(sp)
    800035e4:	7aa2                	ld	s5,40(sp)
    800035e6:	7b02                	ld	s6,32(sp)
    800035e8:	6be2                	ld	s7,24(sp)
    800035ea:	6c42                	ld	s8,16(sp)
    800035ec:	6ca2                	ld	s9,8(sp)
    800035ee:	6125                	addi	sp,sp,96
    800035f0:	8082                	ret
    brelse(bp);
    800035f2:	854a                	mv	a0,s2
    800035f4:	00000097          	auipc	ra,0x0
    800035f8:	dc4080e7          	jalr	-572(ra) # 800033b8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035fc:	015c87bb          	addw	a5,s9,s5
    80003600:	00078a9b          	sext.w	s5,a5
    80003604:	004b2703          	lw	a4,4(s6)
    80003608:	06eaf363          	bgeu	s5,a4,8000366e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000360c:	41fad79b          	sraiw	a5,s5,0x1f
    80003610:	0137d79b          	srliw	a5,a5,0x13
    80003614:	015787bb          	addw	a5,a5,s5
    80003618:	40d7d79b          	sraiw	a5,a5,0xd
    8000361c:	01cb2583          	lw	a1,28(s6)
    80003620:	9dbd                	addw	a1,a1,a5
    80003622:	855e                	mv	a0,s7
    80003624:	00000097          	auipc	ra,0x0
    80003628:	c64080e7          	jalr	-924(ra) # 80003288 <bread>
    8000362c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000362e:	004b2503          	lw	a0,4(s6)
    80003632:	000a849b          	sext.w	s1,s5
    80003636:	8662                	mv	a2,s8
    80003638:	faa4fde3          	bgeu	s1,a0,800035f2 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000363c:	41f6579b          	sraiw	a5,a2,0x1f
    80003640:	01d7d69b          	srliw	a3,a5,0x1d
    80003644:	00c6873b          	addw	a4,a3,a2
    80003648:	00777793          	andi	a5,a4,7
    8000364c:	9f95                	subw	a5,a5,a3
    8000364e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003652:	4037571b          	sraiw	a4,a4,0x3
    80003656:	00e906b3          	add	a3,s2,a4
    8000365a:	0586c683          	lbu	a3,88(a3)
    8000365e:	00d7f5b3          	and	a1,a5,a3
    80003662:	d195                	beqz	a1,80003586 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003664:	2605                	addiw	a2,a2,1
    80003666:	2485                	addiw	s1,s1,1
    80003668:	fd4618e3          	bne	a2,s4,80003638 <balloc+0xee>
    8000366c:	b759                	j	800035f2 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000366e:	00005517          	auipc	a0,0x5
    80003672:	f0250513          	addi	a0,a0,-254 # 80008570 <syscalls+0x120>
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	f12080e7          	jalr	-238(ra) # 80000588 <printf>
  return 0;
    8000367e:	4481                	li	s1,0
    80003680:	bf99                	j	800035d6 <balloc+0x8c>

0000000080003682 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003682:	7179                	addi	sp,sp,-48
    80003684:	f406                	sd	ra,40(sp)
    80003686:	f022                	sd	s0,32(sp)
    80003688:	ec26                	sd	s1,24(sp)
    8000368a:	e84a                	sd	s2,16(sp)
    8000368c:	e44e                	sd	s3,8(sp)
    8000368e:	e052                	sd	s4,0(sp)
    80003690:	1800                	addi	s0,sp,48
    80003692:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003694:	47ad                	li	a5,11
    80003696:	02b7e763          	bltu	a5,a1,800036c4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000369a:	02059493          	slli	s1,a1,0x20
    8000369e:	9081                	srli	s1,s1,0x20
    800036a0:	048a                	slli	s1,s1,0x2
    800036a2:	94aa                	add	s1,s1,a0
    800036a4:	0504a903          	lw	s2,80(s1)
    800036a8:	06091e63          	bnez	s2,80003724 <bmap+0xa2>
      addr = balloc(ip->dev);
    800036ac:	4108                	lw	a0,0(a0)
    800036ae:	00000097          	auipc	ra,0x0
    800036b2:	e9c080e7          	jalr	-356(ra) # 8000354a <balloc>
    800036b6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036ba:	06090563          	beqz	s2,80003724 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800036be:	0524a823          	sw	s2,80(s1)
    800036c2:	a08d                	j	80003724 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800036c4:	ff45849b          	addiw	s1,a1,-12
    800036c8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036cc:	0ff00793          	li	a5,255
    800036d0:	08e7e563          	bltu	a5,a4,8000375a <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800036d4:	08052903          	lw	s2,128(a0)
    800036d8:	00091d63          	bnez	s2,800036f2 <bmap+0x70>
      addr = balloc(ip->dev);
    800036dc:	4108                	lw	a0,0(a0)
    800036de:	00000097          	auipc	ra,0x0
    800036e2:	e6c080e7          	jalr	-404(ra) # 8000354a <balloc>
    800036e6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036ea:	02090d63          	beqz	s2,80003724 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800036ee:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800036f2:	85ca                	mv	a1,s2
    800036f4:	0009a503          	lw	a0,0(s3)
    800036f8:	00000097          	auipc	ra,0x0
    800036fc:	b90080e7          	jalr	-1136(ra) # 80003288 <bread>
    80003700:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003702:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003706:	02049593          	slli	a1,s1,0x20
    8000370a:	9181                	srli	a1,a1,0x20
    8000370c:	058a                	slli	a1,a1,0x2
    8000370e:	00b784b3          	add	s1,a5,a1
    80003712:	0004a903          	lw	s2,0(s1)
    80003716:	02090063          	beqz	s2,80003736 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000371a:	8552                	mv	a0,s4
    8000371c:	00000097          	auipc	ra,0x0
    80003720:	c9c080e7          	jalr	-868(ra) # 800033b8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003724:	854a                	mv	a0,s2
    80003726:	70a2                	ld	ra,40(sp)
    80003728:	7402                	ld	s0,32(sp)
    8000372a:	64e2                	ld	s1,24(sp)
    8000372c:	6942                	ld	s2,16(sp)
    8000372e:	69a2                	ld	s3,8(sp)
    80003730:	6a02                	ld	s4,0(sp)
    80003732:	6145                	addi	sp,sp,48
    80003734:	8082                	ret
      addr = balloc(ip->dev);
    80003736:	0009a503          	lw	a0,0(s3)
    8000373a:	00000097          	auipc	ra,0x0
    8000373e:	e10080e7          	jalr	-496(ra) # 8000354a <balloc>
    80003742:	0005091b          	sext.w	s2,a0
      if(addr){
    80003746:	fc090ae3          	beqz	s2,8000371a <bmap+0x98>
        a[bn] = addr;
    8000374a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000374e:	8552                	mv	a0,s4
    80003750:	00001097          	auipc	ra,0x1
    80003754:	eec080e7          	jalr	-276(ra) # 8000463c <log_write>
    80003758:	b7c9                	j	8000371a <bmap+0x98>
  panic("bmap: out of range");
    8000375a:	00005517          	auipc	a0,0x5
    8000375e:	e2e50513          	addi	a0,a0,-466 # 80008588 <syscalls+0x138>
    80003762:	ffffd097          	auipc	ra,0xffffd
    80003766:	ddc080e7          	jalr	-548(ra) # 8000053e <panic>

000000008000376a <iget>:
{
    8000376a:	7179                	addi	sp,sp,-48
    8000376c:	f406                	sd	ra,40(sp)
    8000376e:	f022                	sd	s0,32(sp)
    80003770:	ec26                	sd	s1,24(sp)
    80003772:	e84a                	sd	s2,16(sp)
    80003774:	e44e                	sd	s3,8(sp)
    80003776:	e052                	sd	s4,0(sp)
    80003778:	1800                	addi	s0,sp,48
    8000377a:	89aa                	mv	s3,a0
    8000377c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000377e:	0001d517          	auipc	a0,0x1d
    80003782:	b0a50513          	addi	a0,a0,-1270 # 80020288 <itable>
    80003786:	ffffd097          	auipc	ra,0xffffd
    8000378a:	450080e7          	jalr	1104(ra) # 80000bd6 <acquire>
  empty = 0;
    8000378e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003790:	0001d497          	auipc	s1,0x1d
    80003794:	b1048493          	addi	s1,s1,-1264 # 800202a0 <itable+0x18>
    80003798:	0001e697          	auipc	a3,0x1e
    8000379c:	59868693          	addi	a3,a3,1432 # 80021d30 <log>
    800037a0:	a039                	j	800037ae <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037a2:	02090b63          	beqz	s2,800037d8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037a6:	08848493          	addi	s1,s1,136
    800037aa:	02d48a63          	beq	s1,a3,800037de <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037ae:	449c                	lw	a5,8(s1)
    800037b0:	fef059e3          	blez	a5,800037a2 <iget+0x38>
    800037b4:	4098                	lw	a4,0(s1)
    800037b6:	ff3716e3          	bne	a4,s3,800037a2 <iget+0x38>
    800037ba:	40d8                	lw	a4,4(s1)
    800037bc:	ff4713e3          	bne	a4,s4,800037a2 <iget+0x38>
      ip->ref++;
    800037c0:	2785                	addiw	a5,a5,1
    800037c2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800037c4:	0001d517          	auipc	a0,0x1d
    800037c8:	ac450513          	addi	a0,a0,-1340 # 80020288 <itable>
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	4be080e7          	jalr	1214(ra) # 80000c8a <release>
      return ip;
    800037d4:	8926                	mv	s2,s1
    800037d6:	a03d                	j	80003804 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037d8:	f7f9                	bnez	a5,800037a6 <iget+0x3c>
    800037da:	8926                	mv	s2,s1
    800037dc:	b7e9                	j	800037a6 <iget+0x3c>
  if(empty == 0)
    800037de:	02090c63          	beqz	s2,80003816 <iget+0xac>
  ip->dev = dev;
    800037e2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800037e6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800037ea:	4785                	li	a5,1
    800037ec:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800037f0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800037f4:	0001d517          	auipc	a0,0x1d
    800037f8:	a9450513          	addi	a0,a0,-1388 # 80020288 <itable>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	48e080e7          	jalr	1166(ra) # 80000c8a <release>
}
    80003804:	854a                	mv	a0,s2
    80003806:	70a2                	ld	ra,40(sp)
    80003808:	7402                	ld	s0,32(sp)
    8000380a:	64e2                	ld	s1,24(sp)
    8000380c:	6942                	ld	s2,16(sp)
    8000380e:	69a2                	ld	s3,8(sp)
    80003810:	6a02                	ld	s4,0(sp)
    80003812:	6145                	addi	sp,sp,48
    80003814:	8082                	ret
    panic("iget: no inodes");
    80003816:	00005517          	auipc	a0,0x5
    8000381a:	d8a50513          	addi	a0,a0,-630 # 800085a0 <syscalls+0x150>
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	d20080e7          	jalr	-736(ra) # 8000053e <panic>

0000000080003826 <fsinit>:
fsinit(int dev) {
    80003826:	7179                	addi	sp,sp,-48
    80003828:	f406                	sd	ra,40(sp)
    8000382a:	f022                	sd	s0,32(sp)
    8000382c:	ec26                	sd	s1,24(sp)
    8000382e:	e84a                	sd	s2,16(sp)
    80003830:	e44e                	sd	s3,8(sp)
    80003832:	1800                	addi	s0,sp,48
    80003834:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003836:	4585                	li	a1,1
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	a50080e7          	jalr	-1456(ra) # 80003288 <bread>
    80003840:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003842:	0001d997          	auipc	s3,0x1d
    80003846:	a2698993          	addi	s3,s3,-1498 # 80020268 <sb>
    8000384a:	02000613          	li	a2,32
    8000384e:	05850593          	addi	a1,a0,88
    80003852:	854e                	mv	a0,s3
    80003854:	ffffd097          	auipc	ra,0xffffd
    80003858:	4da080e7          	jalr	1242(ra) # 80000d2e <memmove>
  brelse(bp);
    8000385c:	8526                	mv	a0,s1
    8000385e:	00000097          	auipc	ra,0x0
    80003862:	b5a080e7          	jalr	-1190(ra) # 800033b8 <brelse>
  if(sb.magic != FSMAGIC)
    80003866:	0009a703          	lw	a4,0(s3)
    8000386a:	102037b7          	lui	a5,0x10203
    8000386e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003872:	02f71263          	bne	a4,a5,80003896 <fsinit+0x70>
  initlog(dev, &sb);
    80003876:	0001d597          	auipc	a1,0x1d
    8000387a:	9f258593          	addi	a1,a1,-1550 # 80020268 <sb>
    8000387e:	854a                	mv	a0,s2
    80003880:	00001097          	auipc	ra,0x1
    80003884:	b40080e7          	jalr	-1216(ra) # 800043c0 <initlog>
}
    80003888:	70a2                	ld	ra,40(sp)
    8000388a:	7402                	ld	s0,32(sp)
    8000388c:	64e2                	ld	s1,24(sp)
    8000388e:	6942                	ld	s2,16(sp)
    80003890:	69a2                	ld	s3,8(sp)
    80003892:	6145                	addi	sp,sp,48
    80003894:	8082                	ret
    panic("invalid file system");
    80003896:	00005517          	auipc	a0,0x5
    8000389a:	d1a50513          	addi	a0,a0,-742 # 800085b0 <syscalls+0x160>
    8000389e:	ffffd097          	auipc	ra,0xffffd
    800038a2:	ca0080e7          	jalr	-864(ra) # 8000053e <panic>

00000000800038a6 <iinit>:
{
    800038a6:	7179                	addi	sp,sp,-48
    800038a8:	f406                	sd	ra,40(sp)
    800038aa:	f022                	sd	s0,32(sp)
    800038ac:	ec26                	sd	s1,24(sp)
    800038ae:	e84a                	sd	s2,16(sp)
    800038b0:	e44e                	sd	s3,8(sp)
    800038b2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800038b4:	00005597          	auipc	a1,0x5
    800038b8:	d1458593          	addi	a1,a1,-748 # 800085c8 <syscalls+0x178>
    800038bc:	0001d517          	auipc	a0,0x1d
    800038c0:	9cc50513          	addi	a0,a0,-1588 # 80020288 <itable>
    800038c4:	ffffd097          	auipc	ra,0xffffd
    800038c8:	282080e7          	jalr	642(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800038cc:	0001d497          	auipc	s1,0x1d
    800038d0:	9e448493          	addi	s1,s1,-1564 # 800202b0 <itable+0x28>
    800038d4:	0001e997          	auipc	s3,0x1e
    800038d8:	46c98993          	addi	s3,s3,1132 # 80021d40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800038dc:	00005917          	auipc	s2,0x5
    800038e0:	cf490913          	addi	s2,s2,-780 # 800085d0 <syscalls+0x180>
    800038e4:	85ca                	mv	a1,s2
    800038e6:	8526                	mv	a0,s1
    800038e8:	00001097          	auipc	ra,0x1
    800038ec:	e3a080e7          	jalr	-454(ra) # 80004722 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800038f0:	08848493          	addi	s1,s1,136
    800038f4:	ff3498e3          	bne	s1,s3,800038e4 <iinit+0x3e>
}
    800038f8:	70a2                	ld	ra,40(sp)
    800038fa:	7402                	ld	s0,32(sp)
    800038fc:	64e2                	ld	s1,24(sp)
    800038fe:	6942                	ld	s2,16(sp)
    80003900:	69a2                	ld	s3,8(sp)
    80003902:	6145                	addi	sp,sp,48
    80003904:	8082                	ret

0000000080003906 <ialloc>:
{
    80003906:	715d                	addi	sp,sp,-80
    80003908:	e486                	sd	ra,72(sp)
    8000390a:	e0a2                	sd	s0,64(sp)
    8000390c:	fc26                	sd	s1,56(sp)
    8000390e:	f84a                	sd	s2,48(sp)
    80003910:	f44e                	sd	s3,40(sp)
    80003912:	f052                	sd	s4,32(sp)
    80003914:	ec56                	sd	s5,24(sp)
    80003916:	e85a                	sd	s6,16(sp)
    80003918:	e45e                	sd	s7,8(sp)
    8000391a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000391c:	0001d717          	auipc	a4,0x1d
    80003920:	95872703          	lw	a4,-1704(a4) # 80020274 <sb+0xc>
    80003924:	4785                	li	a5,1
    80003926:	04e7fa63          	bgeu	a5,a4,8000397a <ialloc+0x74>
    8000392a:	8aaa                	mv	s5,a0
    8000392c:	8bae                	mv	s7,a1
    8000392e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003930:	0001da17          	auipc	s4,0x1d
    80003934:	938a0a13          	addi	s4,s4,-1736 # 80020268 <sb>
    80003938:	00048b1b          	sext.w	s6,s1
    8000393c:	0044d793          	srli	a5,s1,0x4
    80003940:	018a2583          	lw	a1,24(s4)
    80003944:	9dbd                	addw	a1,a1,a5
    80003946:	8556                	mv	a0,s5
    80003948:	00000097          	auipc	ra,0x0
    8000394c:	940080e7          	jalr	-1728(ra) # 80003288 <bread>
    80003950:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003952:	05850993          	addi	s3,a0,88
    80003956:	00f4f793          	andi	a5,s1,15
    8000395a:	079a                	slli	a5,a5,0x6
    8000395c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000395e:	00099783          	lh	a5,0(s3)
    80003962:	c3a1                	beqz	a5,800039a2 <ialloc+0x9c>
    brelse(bp);
    80003964:	00000097          	auipc	ra,0x0
    80003968:	a54080e7          	jalr	-1452(ra) # 800033b8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000396c:	0485                	addi	s1,s1,1
    8000396e:	00ca2703          	lw	a4,12(s4)
    80003972:	0004879b          	sext.w	a5,s1
    80003976:	fce7e1e3          	bltu	a5,a4,80003938 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000397a:	00005517          	auipc	a0,0x5
    8000397e:	c5e50513          	addi	a0,a0,-930 # 800085d8 <syscalls+0x188>
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	c06080e7          	jalr	-1018(ra) # 80000588 <printf>
  return 0;
    8000398a:	4501                	li	a0,0
}
    8000398c:	60a6                	ld	ra,72(sp)
    8000398e:	6406                	ld	s0,64(sp)
    80003990:	74e2                	ld	s1,56(sp)
    80003992:	7942                	ld	s2,48(sp)
    80003994:	79a2                	ld	s3,40(sp)
    80003996:	7a02                	ld	s4,32(sp)
    80003998:	6ae2                	ld	s5,24(sp)
    8000399a:	6b42                	ld	s6,16(sp)
    8000399c:	6ba2                	ld	s7,8(sp)
    8000399e:	6161                	addi	sp,sp,80
    800039a0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800039a2:	04000613          	li	a2,64
    800039a6:	4581                	li	a1,0
    800039a8:	854e                	mv	a0,s3
    800039aa:	ffffd097          	auipc	ra,0xffffd
    800039ae:	328080e7          	jalr	808(ra) # 80000cd2 <memset>
      dip->type = type;
    800039b2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039b6:	854a                	mv	a0,s2
    800039b8:	00001097          	auipc	ra,0x1
    800039bc:	c84080e7          	jalr	-892(ra) # 8000463c <log_write>
      brelse(bp);
    800039c0:	854a                	mv	a0,s2
    800039c2:	00000097          	auipc	ra,0x0
    800039c6:	9f6080e7          	jalr	-1546(ra) # 800033b8 <brelse>
      return iget(dev, inum);
    800039ca:	85da                	mv	a1,s6
    800039cc:	8556                	mv	a0,s5
    800039ce:	00000097          	auipc	ra,0x0
    800039d2:	d9c080e7          	jalr	-612(ra) # 8000376a <iget>
    800039d6:	bf5d                	j	8000398c <ialloc+0x86>

00000000800039d8 <iupdate>:
{
    800039d8:	1101                	addi	sp,sp,-32
    800039da:	ec06                	sd	ra,24(sp)
    800039dc:	e822                	sd	s0,16(sp)
    800039de:	e426                	sd	s1,8(sp)
    800039e0:	e04a                	sd	s2,0(sp)
    800039e2:	1000                	addi	s0,sp,32
    800039e4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039e6:	415c                	lw	a5,4(a0)
    800039e8:	0047d79b          	srliw	a5,a5,0x4
    800039ec:	0001d597          	auipc	a1,0x1d
    800039f0:	8945a583          	lw	a1,-1900(a1) # 80020280 <sb+0x18>
    800039f4:	9dbd                	addw	a1,a1,a5
    800039f6:	4108                	lw	a0,0(a0)
    800039f8:	00000097          	auipc	ra,0x0
    800039fc:	890080e7          	jalr	-1904(ra) # 80003288 <bread>
    80003a00:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a02:	05850793          	addi	a5,a0,88
    80003a06:	40c8                	lw	a0,4(s1)
    80003a08:	893d                	andi	a0,a0,15
    80003a0a:	051a                	slli	a0,a0,0x6
    80003a0c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003a0e:	04449703          	lh	a4,68(s1)
    80003a12:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003a16:	04649703          	lh	a4,70(s1)
    80003a1a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003a1e:	04849703          	lh	a4,72(s1)
    80003a22:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003a26:	04a49703          	lh	a4,74(s1)
    80003a2a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003a2e:	44f8                	lw	a4,76(s1)
    80003a30:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a32:	03400613          	li	a2,52
    80003a36:	05048593          	addi	a1,s1,80
    80003a3a:	0531                	addi	a0,a0,12
    80003a3c:	ffffd097          	auipc	ra,0xffffd
    80003a40:	2f2080e7          	jalr	754(ra) # 80000d2e <memmove>
  log_write(bp);
    80003a44:	854a                	mv	a0,s2
    80003a46:	00001097          	auipc	ra,0x1
    80003a4a:	bf6080e7          	jalr	-1034(ra) # 8000463c <log_write>
  brelse(bp);
    80003a4e:	854a                	mv	a0,s2
    80003a50:	00000097          	auipc	ra,0x0
    80003a54:	968080e7          	jalr	-1688(ra) # 800033b8 <brelse>
}
    80003a58:	60e2                	ld	ra,24(sp)
    80003a5a:	6442                	ld	s0,16(sp)
    80003a5c:	64a2                	ld	s1,8(sp)
    80003a5e:	6902                	ld	s2,0(sp)
    80003a60:	6105                	addi	sp,sp,32
    80003a62:	8082                	ret

0000000080003a64 <idup>:
{
    80003a64:	1101                	addi	sp,sp,-32
    80003a66:	ec06                	sd	ra,24(sp)
    80003a68:	e822                	sd	s0,16(sp)
    80003a6a:	e426                	sd	s1,8(sp)
    80003a6c:	1000                	addi	s0,sp,32
    80003a6e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a70:	0001d517          	auipc	a0,0x1d
    80003a74:	81850513          	addi	a0,a0,-2024 # 80020288 <itable>
    80003a78:	ffffd097          	auipc	ra,0xffffd
    80003a7c:	15e080e7          	jalr	350(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003a80:	449c                	lw	a5,8(s1)
    80003a82:	2785                	addiw	a5,a5,1
    80003a84:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a86:	0001d517          	auipc	a0,0x1d
    80003a8a:	80250513          	addi	a0,a0,-2046 # 80020288 <itable>
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	1fc080e7          	jalr	508(ra) # 80000c8a <release>
}
    80003a96:	8526                	mv	a0,s1
    80003a98:	60e2                	ld	ra,24(sp)
    80003a9a:	6442                	ld	s0,16(sp)
    80003a9c:	64a2                	ld	s1,8(sp)
    80003a9e:	6105                	addi	sp,sp,32
    80003aa0:	8082                	ret

0000000080003aa2 <ilock>:
{
    80003aa2:	1101                	addi	sp,sp,-32
    80003aa4:	ec06                	sd	ra,24(sp)
    80003aa6:	e822                	sd	s0,16(sp)
    80003aa8:	e426                	sd	s1,8(sp)
    80003aaa:	e04a                	sd	s2,0(sp)
    80003aac:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003aae:	c115                	beqz	a0,80003ad2 <ilock+0x30>
    80003ab0:	84aa                	mv	s1,a0
    80003ab2:	451c                	lw	a5,8(a0)
    80003ab4:	00f05f63          	blez	a5,80003ad2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ab8:	0541                	addi	a0,a0,16
    80003aba:	00001097          	auipc	ra,0x1
    80003abe:	ca2080e7          	jalr	-862(ra) # 8000475c <acquiresleep>
  if(ip->valid == 0){
    80003ac2:	40bc                	lw	a5,64(s1)
    80003ac4:	cf99                	beqz	a5,80003ae2 <ilock+0x40>
}
    80003ac6:	60e2                	ld	ra,24(sp)
    80003ac8:	6442                	ld	s0,16(sp)
    80003aca:	64a2                	ld	s1,8(sp)
    80003acc:	6902                	ld	s2,0(sp)
    80003ace:	6105                	addi	sp,sp,32
    80003ad0:	8082                	ret
    panic("ilock");
    80003ad2:	00005517          	auipc	a0,0x5
    80003ad6:	b1e50513          	addi	a0,a0,-1250 # 800085f0 <syscalls+0x1a0>
    80003ada:	ffffd097          	auipc	ra,0xffffd
    80003ade:	a64080e7          	jalr	-1436(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ae2:	40dc                	lw	a5,4(s1)
    80003ae4:	0047d79b          	srliw	a5,a5,0x4
    80003ae8:	0001c597          	auipc	a1,0x1c
    80003aec:	7985a583          	lw	a1,1944(a1) # 80020280 <sb+0x18>
    80003af0:	9dbd                	addw	a1,a1,a5
    80003af2:	4088                	lw	a0,0(s1)
    80003af4:	fffff097          	auipc	ra,0xfffff
    80003af8:	794080e7          	jalr	1940(ra) # 80003288 <bread>
    80003afc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003afe:	05850593          	addi	a1,a0,88
    80003b02:	40dc                	lw	a5,4(s1)
    80003b04:	8bbd                	andi	a5,a5,15
    80003b06:	079a                	slli	a5,a5,0x6
    80003b08:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b0a:	00059783          	lh	a5,0(a1)
    80003b0e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b12:	00259783          	lh	a5,2(a1)
    80003b16:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b1a:	00459783          	lh	a5,4(a1)
    80003b1e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b22:	00659783          	lh	a5,6(a1)
    80003b26:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b2a:	459c                	lw	a5,8(a1)
    80003b2c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b2e:	03400613          	li	a2,52
    80003b32:	05b1                	addi	a1,a1,12
    80003b34:	05048513          	addi	a0,s1,80
    80003b38:	ffffd097          	auipc	ra,0xffffd
    80003b3c:	1f6080e7          	jalr	502(ra) # 80000d2e <memmove>
    brelse(bp);
    80003b40:	854a                	mv	a0,s2
    80003b42:	00000097          	auipc	ra,0x0
    80003b46:	876080e7          	jalr	-1930(ra) # 800033b8 <brelse>
    ip->valid = 1;
    80003b4a:	4785                	li	a5,1
    80003b4c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b4e:	04449783          	lh	a5,68(s1)
    80003b52:	fbb5                	bnez	a5,80003ac6 <ilock+0x24>
      panic("ilock: no type");
    80003b54:	00005517          	auipc	a0,0x5
    80003b58:	aa450513          	addi	a0,a0,-1372 # 800085f8 <syscalls+0x1a8>
    80003b5c:	ffffd097          	auipc	ra,0xffffd
    80003b60:	9e2080e7          	jalr	-1566(ra) # 8000053e <panic>

0000000080003b64 <iunlock>:
{
    80003b64:	1101                	addi	sp,sp,-32
    80003b66:	ec06                	sd	ra,24(sp)
    80003b68:	e822                	sd	s0,16(sp)
    80003b6a:	e426                	sd	s1,8(sp)
    80003b6c:	e04a                	sd	s2,0(sp)
    80003b6e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b70:	c905                	beqz	a0,80003ba0 <iunlock+0x3c>
    80003b72:	84aa                	mv	s1,a0
    80003b74:	01050913          	addi	s2,a0,16
    80003b78:	854a                	mv	a0,s2
    80003b7a:	00001097          	auipc	ra,0x1
    80003b7e:	c7c080e7          	jalr	-900(ra) # 800047f6 <holdingsleep>
    80003b82:	cd19                	beqz	a0,80003ba0 <iunlock+0x3c>
    80003b84:	449c                	lw	a5,8(s1)
    80003b86:	00f05d63          	blez	a5,80003ba0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b8a:	854a                	mv	a0,s2
    80003b8c:	00001097          	auipc	ra,0x1
    80003b90:	c26080e7          	jalr	-986(ra) # 800047b2 <releasesleep>
}
    80003b94:	60e2                	ld	ra,24(sp)
    80003b96:	6442                	ld	s0,16(sp)
    80003b98:	64a2                	ld	s1,8(sp)
    80003b9a:	6902                	ld	s2,0(sp)
    80003b9c:	6105                	addi	sp,sp,32
    80003b9e:	8082                	ret
    panic("iunlock");
    80003ba0:	00005517          	auipc	a0,0x5
    80003ba4:	a6850513          	addi	a0,a0,-1432 # 80008608 <syscalls+0x1b8>
    80003ba8:	ffffd097          	auipc	ra,0xffffd
    80003bac:	996080e7          	jalr	-1642(ra) # 8000053e <panic>

0000000080003bb0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003bb0:	7179                	addi	sp,sp,-48
    80003bb2:	f406                	sd	ra,40(sp)
    80003bb4:	f022                	sd	s0,32(sp)
    80003bb6:	ec26                	sd	s1,24(sp)
    80003bb8:	e84a                	sd	s2,16(sp)
    80003bba:	e44e                	sd	s3,8(sp)
    80003bbc:	e052                	sd	s4,0(sp)
    80003bbe:	1800                	addi	s0,sp,48
    80003bc0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003bc2:	05050493          	addi	s1,a0,80
    80003bc6:	08050913          	addi	s2,a0,128
    80003bca:	a021                	j	80003bd2 <itrunc+0x22>
    80003bcc:	0491                	addi	s1,s1,4
    80003bce:	01248d63          	beq	s1,s2,80003be8 <itrunc+0x38>
    if(ip->addrs[i]){
    80003bd2:	408c                	lw	a1,0(s1)
    80003bd4:	dde5                	beqz	a1,80003bcc <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003bd6:	0009a503          	lw	a0,0(s3)
    80003bda:	00000097          	auipc	ra,0x0
    80003bde:	8f4080e7          	jalr	-1804(ra) # 800034ce <bfree>
      ip->addrs[i] = 0;
    80003be2:	0004a023          	sw	zero,0(s1)
    80003be6:	b7dd                	j	80003bcc <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003be8:	0809a583          	lw	a1,128(s3)
    80003bec:	e185                	bnez	a1,80003c0c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003bee:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003bf2:	854e                	mv	a0,s3
    80003bf4:	00000097          	auipc	ra,0x0
    80003bf8:	de4080e7          	jalr	-540(ra) # 800039d8 <iupdate>
}
    80003bfc:	70a2                	ld	ra,40(sp)
    80003bfe:	7402                	ld	s0,32(sp)
    80003c00:	64e2                	ld	s1,24(sp)
    80003c02:	6942                	ld	s2,16(sp)
    80003c04:	69a2                	ld	s3,8(sp)
    80003c06:	6a02                	ld	s4,0(sp)
    80003c08:	6145                	addi	sp,sp,48
    80003c0a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c0c:	0009a503          	lw	a0,0(s3)
    80003c10:	fffff097          	auipc	ra,0xfffff
    80003c14:	678080e7          	jalr	1656(ra) # 80003288 <bread>
    80003c18:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c1a:	05850493          	addi	s1,a0,88
    80003c1e:	45850913          	addi	s2,a0,1112
    80003c22:	a021                	j	80003c2a <itrunc+0x7a>
    80003c24:	0491                	addi	s1,s1,4
    80003c26:	01248b63          	beq	s1,s2,80003c3c <itrunc+0x8c>
      if(a[j])
    80003c2a:	408c                	lw	a1,0(s1)
    80003c2c:	dde5                	beqz	a1,80003c24 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c2e:	0009a503          	lw	a0,0(s3)
    80003c32:	00000097          	auipc	ra,0x0
    80003c36:	89c080e7          	jalr	-1892(ra) # 800034ce <bfree>
    80003c3a:	b7ed                	j	80003c24 <itrunc+0x74>
    brelse(bp);
    80003c3c:	8552                	mv	a0,s4
    80003c3e:	fffff097          	auipc	ra,0xfffff
    80003c42:	77a080e7          	jalr	1914(ra) # 800033b8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c46:	0809a583          	lw	a1,128(s3)
    80003c4a:	0009a503          	lw	a0,0(s3)
    80003c4e:	00000097          	auipc	ra,0x0
    80003c52:	880080e7          	jalr	-1920(ra) # 800034ce <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c56:	0809a023          	sw	zero,128(s3)
    80003c5a:	bf51                	j	80003bee <itrunc+0x3e>

0000000080003c5c <iput>:
{
    80003c5c:	1101                	addi	sp,sp,-32
    80003c5e:	ec06                	sd	ra,24(sp)
    80003c60:	e822                	sd	s0,16(sp)
    80003c62:	e426                	sd	s1,8(sp)
    80003c64:	e04a                	sd	s2,0(sp)
    80003c66:	1000                	addi	s0,sp,32
    80003c68:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c6a:	0001c517          	auipc	a0,0x1c
    80003c6e:	61e50513          	addi	a0,a0,1566 # 80020288 <itable>
    80003c72:	ffffd097          	auipc	ra,0xffffd
    80003c76:	f64080e7          	jalr	-156(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c7a:	4498                	lw	a4,8(s1)
    80003c7c:	4785                	li	a5,1
    80003c7e:	02f70363          	beq	a4,a5,80003ca4 <iput+0x48>
  ip->ref--;
    80003c82:	449c                	lw	a5,8(s1)
    80003c84:	37fd                	addiw	a5,a5,-1
    80003c86:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c88:	0001c517          	auipc	a0,0x1c
    80003c8c:	60050513          	addi	a0,a0,1536 # 80020288 <itable>
    80003c90:	ffffd097          	auipc	ra,0xffffd
    80003c94:	ffa080e7          	jalr	-6(ra) # 80000c8a <release>
}
    80003c98:	60e2                	ld	ra,24(sp)
    80003c9a:	6442                	ld	s0,16(sp)
    80003c9c:	64a2                	ld	s1,8(sp)
    80003c9e:	6902                	ld	s2,0(sp)
    80003ca0:	6105                	addi	sp,sp,32
    80003ca2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ca4:	40bc                	lw	a5,64(s1)
    80003ca6:	dff1                	beqz	a5,80003c82 <iput+0x26>
    80003ca8:	04a49783          	lh	a5,74(s1)
    80003cac:	fbf9                	bnez	a5,80003c82 <iput+0x26>
    acquiresleep(&ip->lock);
    80003cae:	01048913          	addi	s2,s1,16
    80003cb2:	854a                	mv	a0,s2
    80003cb4:	00001097          	auipc	ra,0x1
    80003cb8:	aa8080e7          	jalr	-1368(ra) # 8000475c <acquiresleep>
    release(&itable.lock);
    80003cbc:	0001c517          	auipc	a0,0x1c
    80003cc0:	5cc50513          	addi	a0,a0,1484 # 80020288 <itable>
    80003cc4:	ffffd097          	auipc	ra,0xffffd
    80003cc8:	fc6080e7          	jalr	-58(ra) # 80000c8a <release>
    itrunc(ip);
    80003ccc:	8526                	mv	a0,s1
    80003cce:	00000097          	auipc	ra,0x0
    80003cd2:	ee2080e7          	jalr	-286(ra) # 80003bb0 <itrunc>
    ip->type = 0;
    80003cd6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003cda:	8526                	mv	a0,s1
    80003cdc:	00000097          	auipc	ra,0x0
    80003ce0:	cfc080e7          	jalr	-772(ra) # 800039d8 <iupdate>
    ip->valid = 0;
    80003ce4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ce8:	854a                	mv	a0,s2
    80003cea:	00001097          	auipc	ra,0x1
    80003cee:	ac8080e7          	jalr	-1336(ra) # 800047b2 <releasesleep>
    acquire(&itable.lock);
    80003cf2:	0001c517          	auipc	a0,0x1c
    80003cf6:	59650513          	addi	a0,a0,1430 # 80020288 <itable>
    80003cfa:	ffffd097          	auipc	ra,0xffffd
    80003cfe:	edc080e7          	jalr	-292(ra) # 80000bd6 <acquire>
    80003d02:	b741                	j	80003c82 <iput+0x26>

0000000080003d04 <iunlockput>:
{
    80003d04:	1101                	addi	sp,sp,-32
    80003d06:	ec06                	sd	ra,24(sp)
    80003d08:	e822                	sd	s0,16(sp)
    80003d0a:	e426                	sd	s1,8(sp)
    80003d0c:	1000                	addi	s0,sp,32
    80003d0e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d10:	00000097          	auipc	ra,0x0
    80003d14:	e54080e7          	jalr	-428(ra) # 80003b64 <iunlock>
  iput(ip);
    80003d18:	8526                	mv	a0,s1
    80003d1a:	00000097          	auipc	ra,0x0
    80003d1e:	f42080e7          	jalr	-190(ra) # 80003c5c <iput>
}
    80003d22:	60e2                	ld	ra,24(sp)
    80003d24:	6442                	ld	s0,16(sp)
    80003d26:	64a2                	ld	s1,8(sp)
    80003d28:	6105                	addi	sp,sp,32
    80003d2a:	8082                	ret

0000000080003d2c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d2c:	1141                	addi	sp,sp,-16
    80003d2e:	e422                	sd	s0,8(sp)
    80003d30:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d32:	411c                	lw	a5,0(a0)
    80003d34:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d36:	415c                	lw	a5,4(a0)
    80003d38:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d3a:	04451783          	lh	a5,68(a0)
    80003d3e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d42:	04a51783          	lh	a5,74(a0)
    80003d46:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d4a:	04c56783          	lwu	a5,76(a0)
    80003d4e:	e99c                	sd	a5,16(a1)
}
    80003d50:	6422                	ld	s0,8(sp)
    80003d52:	0141                	addi	sp,sp,16
    80003d54:	8082                	ret

0000000080003d56 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d56:	457c                	lw	a5,76(a0)
    80003d58:	0ed7e963          	bltu	a5,a3,80003e4a <readi+0xf4>
{
    80003d5c:	7159                	addi	sp,sp,-112
    80003d5e:	f486                	sd	ra,104(sp)
    80003d60:	f0a2                	sd	s0,96(sp)
    80003d62:	eca6                	sd	s1,88(sp)
    80003d64:	e8ca                	sd	s2,80(sp)
    80003d66:	e4ce                	sd	s3,72(sp)
    80003d68:	e0d2                	sd	s4,64(sp)
    80003d6a:	fc56                	sd	s5,56(sp)
    80003d6c:	f85a                	sd	s6,48(sp)
    80003d6e:	f45e                	sd	s7,40(sp)
    80003d70:	f062                	sd	s8,32(sp)
    80003d72:	ec66                	sd	s9,24(sp)
    80003d74:	e86a                	sd	s10,16(sp)
    80003d76:	e46e                	sd	s11,8(sp)
    80003d78:	1880                	addi	s0,sp,112
    80003d7a:	8b2a                	mv	s6,a0
    80003d7c:	8bae                	mv	s7,a1
    80003d7e:	8a32                	mv	s4,a2
    80003d80:	84b6                	mv	s1,a3
    80003d82:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003d84:	9f35                	addw	a4,a4,a3
    return 0;
    80003d86:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d88:	0ad76063          	bltu	a4,a3,80003e28 <readi+0xd2>
  if(off + n > ip->size)
    80003d8c:	00e7f463          	bgeu	a5,a4,80003d94 <readi+0x3e>
    n = ip->size - off;
    80003d90:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d94:	0a0a8963          	beqz	s5,80003e46 <readi+0xf0>
    80003d98:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d9a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d9e:	5c7d                	li	s8,-1
    80003da0:	a82d                	j	80003dda <readi+0x84>
    80003da2:	020d1d93          	slli	s11,s10,0x20
    80003da6:	020ddd93          	srli	s11,s11,0x20
    80003daa:	05890793          	addi	a5,s2,88
    80003dae:	86ee                	mv	a3,s11
    80003db0:	963e                	add	a2,a2,a5
    80003db2:	85d2                	mv	a1,s4
    80003db4:	855e                	mv	a0,s7
    80003db6:	ffffe097          	auipc	ra,0xffffe
    80003dba:	710080e7          	jalr	1808(ra) # 800024c6 <either_copyout>
    80003dbe:	05850d63          	beq	a0,s8,80003e18 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003dc2:	854a                	mv	a0,s2
    80003dc4:	fffff097          	auipc	ra,0xfffff
    80003dc8:	5f4080e7          	jalr	1524(ra) # 800033b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dcc:	013d09bb          	addw	s3,s10,s3
    80003dd0:	009d04bb          	addw	s1,s10,s1
    80003dd4:	9a6e                	add	s4,s4,s11
    80003dd6:	0559f763          	bgeu	s3,s5,80003e24 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003dda:	00a4d59b          	srliw	a1,s1,0xa
    80003dde:	855a                	mv	a0,s6
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	8a2080e7          	jalr	-1886(ra) # 80003682 <bmap>
    80003de8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003dec:	cd85                	beqz	a1,80003e24 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003dee:	000b2503          	lw	a0,0(s6)
    80003df2:	fffff097          	auipc	ra,0xfffff
    80003df6:	496080e7          	jalr	1174(ra) # 80003288 <bread>
    80003dfa:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dfc:	3ff4f613          	andi	a2,s1,1023
    80003e00:	40cc87bb          	subw	a5,s9,a2
    80003e04:	413a873b          	subw	a4,s5,s3
    80003e08:	8d3e                	mv	s10,a5
    80003e0a:	2781                	sext.w	a5,a5
    80003e0c:	0007069b          	sext.w	a3,a4
    80003e10:	f8f6f9e3          	bgeu	a3,a5,80003da2 <readi+0x4c>
    80003e14:	8d3a                	mv	s10,a4
    80003e16:	b771                	j	80003da2 <readi+0x4c>
      brelse(bp);
    80003e18:	854a                	mv	a0,s2
    80003e1a:	fffff097          	auipc	ra,0xfffff
    80003e1e:	59e080e7          	jalr	1438(ra) # 800033b8 <brelse>
      tot = -1;
    80003e22:	59fd                	li	s3,-1
  }
  return tot;
    80003e24:	0009851b          	sext.w	a0,s3
}
    80003e28:	70a6                	ld	ra,104(sp)
    80003e2a:	7406                	ld	s0,96(sp)
    80003e2c:	64e6                	ld	s1,88(sp)
    80003e2e:	6946                	ld	s2,80(sp)
    80003e30:	69a6                	ld	s3,72(sp)
    80003e32:	6a06                	ld	s4,64(sp)
    80003e34:	7ae2                	ld	s5,56(sp)
    80003e36:	7b42                	ld	s6,48(sp)
    80003e38:	7ba2                	ld	s7,40(sp)
    80003e3a:	7c02                	ld	s8,32(sp)
    80003e3c:	6ce2                	ld	s9,24(sp)
    80003e3e:	6d42                	ld	s10,16(sp)
    80003e40:	6da2                	ld	s11,8(sp)
    80003e42:	6165                	addi	sp,sp,112
    80003e44:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e46:	89d6                	mv	s3,s5
    80003e48:	bff1                	j	80003e24 <readi+0xce>
    return 0;
    80003e4a:	4501                	li	a0,0
}
    80003e4c:	8082                	ret

0000000080003e4e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e4e:	457c                	lw	a5,76(a0)
    80003e50:	10d7e863          	bltu	a5,a3,80003f60 <writei+0x112>
{
    80003e54:	7159                	addi	sp,sp,-112
    80003e56:	f486                	sd	ra,104(sp)
    80003e58:	f0a2                	sd	s0,96(sp)
    80003e5a:	eca6                	sd	s1,88(sp)
    80003e5c:	e8ca                	sd	s2,80(sp)
    80003e5e:	e4ce                	sd	s3,72(sp)
    80003e60:	e0d2                	sd	s4,64(sp)
    80003e62:	fc56                	sd	s5,56(sp)
    80003e64:	f85a                	sd	s6,48(sp)
    80003e66:	f45e                	sd	s7,40(sp)
    80003e68:	f062                	sd	s8,32(sp)
    80003e6a:	ec66                	sd	s9,24(sp)
    80003e6c:	e86a                	sd	s10,16(sp)
    80003e6e:	e46e                	sd	s11,8(sp)
    80003e70:	1880                	addi	s0,sp,112
    80003e72:	8aaa                	mv	s5,a0
    80003e74:	8bae                	mv	s7,a1
    80003e76:	8a32                	mv	s4,a2
    80003e78:	8936                	mv	s2,a3
    80003e7a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e7c:	00e687bb          	addw	a5,a3,a4
    80003e80:	0ed7e263          	bltu	a5,a3,80003f64 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e84:	00043737          	lui	a4,0x43
    80003e88:	0ef76063          	bltu	a4,a5,80003f68 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e8c:	0c0b0863          	beqz	s6,80003f5c <writei+0x10e>
    80003e90:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e92:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e96:	5c7d                	li	s8,-1
    80003e98:	a091                	j	80003edc <writei+0x8e>
    80003e9a:	020d1d93          	slli	s11,s10,0x20
    80003e9e:	020ddd93          	srli	s11,s11,0x20
    80003ea2:	05848793          	addi	a5,s1,88
    80003ea6:	86ee                	mv	a3,s11
    80003ea8:	8652                	mv	a2,s4
    80003eaa:	85de                	mv	a1,s7
    80003eac:	953e                	add	a0,a0,a5
    80003eae:	ffffe097          	auipc	ra,0xffffe
    80003eb2:	66e080e7          	jalr	1646(ra) # 8000251c <either_copyin>
    80003eb6:	07850263          	beq	a0,s8,80003f1a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003eba:	8526                	mv	a0,s1
    80003ebc:	00000097          	auipc	ra,0x0
    80003ec0:	780080e7          	jalr	1920(ra) # 8000463c <log_write>
    brelse(bp);
    80003ec4:	8526                	mv	a0,s1
    80003ec6:	fffff097          	auipc	ra,0xfffff
    80003eca:	4f2080e7          	jalr	1266(ra) # 800033b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ece:	013d09bb          	addw	s3,s10,s3
    80003ed2:	012d093b          	addw	s2,s10,s2
    80003ed6:	9a6e                	add	s4,s4,s11
    80003ed8:	0569f663          	bgeu	s3,s6,80003f24 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003edc:	00a9559b          	srliw	a1,s2,0xa
    80003ee0:	8556                	mv	a0,s5
    80003ee2:	fffff097          	auipc	ra,0xfffff
    80003ee6:	7a0080e7          	jalr	1952(ra) # 80003682 <bmap>
    80003eea:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003eee:	c99d                	beqz	a1,80003f24 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003ef0:	000aa503          	lw	a0,0(s5)
    80003ef4:	fffff097          	auipc	ra,0xfffff
    80003ef8:	394080e7          	jalr	916(ra) # 80003288 <bread>
    80003efc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003efe:	3ff97513          	andi	a0,s2,1023
    80003f02:	40ac87bb          	subw	a5,s9,a0
    80003f06:	413b073b          	subw	a4,s6,s3
    80003f0a:	8d3e                	mv	s10,a5
    80003f0c:	2781                	sext.w	a5,a5
    80003f0e:	0007069b          	sext.w	a3,a4
    80003f12:	f8f6f4e3          	bgeu	a3,a5,80003e9a <writei+0x4c>
    80003f16:	8d3a                	mv	s10,a4
    80003f18:	b749                	j	80003e9a <writei+0x4c>
      brelse(bp);
    80003f1a:	8526                	mv	a0,s1
    80003f1c:	fffff097          	auipc	ra,0xfffff
    80003f20:	49c080e7          	jalr	1180(ra) # 800033b8 <brelse>
  }

  if(off > ip->size)
    80003f24:	04caa783          	lw	a5,76(s5)
    80003f28:	0127f463          	bgeu	a5,s2,80003f30 <writei+0xe2>
    ip->size = off;
    80003f2c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f30:	8556                	mv	a0,s5
    80003f32:	00000097          	auipc	ra,0x0
    80003f36:	aa6080e7          	jalr	-1370(ra) # 800039d8 <iupdate>

  return tot;
    80003f3a:	0009851b          	sext.w	a0,s3
}
    80003f3e:	70a6                	ld	ra,104(sp)
    80003f40:	7406                	ld	s0,96(sp)
    80003f42:	64e6                	ld	s1,88(sp)
    80003f44:	6946                	ld	s2,80(sp)
    80003f46:	69a6                	ld	s3,72(sp)
    80003f48:	6a06                	ld	s4,64(sp)
    80003f4a:	7ae2                	ld	s5,56(sp)
    80003f4c:	7b42                	ld	s6,48(sp)
    80003f4e:	7ba2                	ld	s7,40(sp)
    80003f50:	7c02                	ld	s8,32(sp)
    80003f52:	6ce2                	ld	s9,24(sp)
    80003f54:	6d42                	ld	s10,16(sp)
    80003f56:	6da2                	ld	s11,8(sp)
    80003f58:	6165                	addi	sp,sp,112
    80003f5a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f5c:	89da                	mv	s3,s6
    80003f5e:	bfc9                	j	80003f30 <writei+0xe2>
    return -1;
    80003f60:	557d                	li	a0,-1
}
    80003f62:	8082                	ret
    return -1;
    80003f64:	557d                	li	a0,-1
    80003f66:	bfe1                	j	80003f3e <writei+0xf0>
    return -1;
    80003f68:	557d                	li	a0,-1
    80003f6a:	bfd1                	j	80003f3e <writei+0xf0>

0000000080003f6c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f6c:	1141                	addi	sp,sp,-16
    80003f6e:	e406                	sd	ra,8(sp)
    80003f70:	e022                	sd	s0,0(sp)
    80003f72:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f74:	4639                	li	a2,14
    80003f76:	ffffd097          	auipc	ra,0xffffd
    80003f7a:	e2c080e7          	jalr	-468(ra) # 80000da2 <strncmp>
}
    80003f7e:	60a2                	ld	ra,8(sp)
    80003f80:	6402                	ld	s0,0(sp)
    80003f82:	0141                	addi	sp,sp,16
    80003f84:	8082                	ret

0000000080003f86 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f86:	7139                	addi	sp,sp,-64
    80003f88:	fc06                	sd	ra,56(sp)
    80003f8a:	f822                	sd	s0,48(sp)
    80003f8c:	f426                	sd	s1,40(sp)
    80003f8e:	f04a                	sd	s2,32(sp)
    80003f90:	ec4e                	sd	s3,24(sp)
    80003f92:	e852                	sd	s4,16(sp)
    80003f94:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f96:	04451703          	lh	a4,68(a0)
    80003f9a:	4785                	li	a5,1
    80003f9c:	00f71a63          	bne	a4,a5,80003fb0 <dirlookup+0x2a>
    80003fa0:	892a                	mv	s2,a0
    80003fa2:	89ae                	mv	s3,a1
    80003fa4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fa6:	457c                	lw	a5,76(a0)
    80003fa8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003faa:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fac:	e79d                	bnez	a5,80003fda <dirlookup+0x54>
    80003fae:	a8a5                	j	80004026 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003fb0:	00004517          	auipc	a0,0x4
    80003fb4:	66050513          	addi	a0,a0,1632 # 80008610 <syscalls+0x1c0>
    80003fb8:	ffffc097          	auipc	ra,0xffffc
    80003fbc:	586080e7          	jalr	1414(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003fc0:	00004517          	auipc	a0,0x4
    80003fc4:	66850513          	addi	a0,a0,1640 # 80008628 <syscalls+0x1d8>
    80003fc8:	ffffc097          	auipc	ra,0xffffc
    80003fcc:	576080e7          	jalr	1398(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fd0:	24c1                	addiw	s1,s1,16
    80003fd2:	04c92783          	lw	a5,76(s2)
    80003fd6:	04f4f763          	bgeu	s1,a5,80004024 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fda:	4741                	li	a4,16
    80003fdc:	86a6                	mv	a3,s1
    80003fde:	fc040613          	addi	a2,s0,-64
    80003fe2:	4581                	li	a1,0
    80003fe4:	854a                	mv	a0,s2
    80003fe6:	00000097          	auipc	ra,0x0
    80003fea:	d70080e7          	jalr	-656(ra) # 80003d56 <readi>
    80003fee:	47c1                	li	a5,16
    80003ff0:	fcf518e3          	bne	a0,a5,80003fc0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003ff4:	fc045783          	lhu	a5,-64(s0)
    80003ff8:	dfe1                	beqz	a5,80003fd0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ffa:	fc240593          	addi	a1,s0,-62
    80003ffe:	854e                	mv	a0,s3
    80004000:	00000097          	auipc	ra,0x0
    80004004:	f6c080e7          	jalr	-148(ra) # 80003f6c <namecmp>
    80004008:	f561                	bnez	a0,80003fd0 <dirlookup+0x4a>
      if(poff)
    8000400a:	000a0463          	beqz	s4,80004012 <dirlookup+0x8c>
        *poff = off;
    8000400e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004012:	fc045583          	lhu	a1,-64(s0)
    80004016:	00092503          	lw	a0,0(s2)
    8000401a:	fffff097          	auipc	ra,0xfffff
    8000401e:	750080e7          	jalr	1872(ra) # 8000376a <iget>
    80004022:	a011                	j	80004026 <dirlookup+0xa0>
  return 0;
    80004024:	4501                	li	a0,0
}
    80004026:	70e2                	ld	ra,56(sp)
    80004028:	7442                	ld	s0,48(sp)
    8000402a:	74a2                	ld	s1,40(sp)
    8000402c:	7902                	ld	s2,32(sp)
    8000402e:	69e2                	ld	s3,24(sp)
    80004030:	6a42                	ld	s4,16(sp)
    80004032:	6121                	addi	sp,sp,64
    80004034:	8082                	ret

0000000080004036 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004036:	711d                	addi	sp,sp,-96
    80004038:	ec86                	sd	ra,88(sp)
    8000403a:	e8a2                	sd	s0,80(sp)
    8000403c:	e4a6                	sd	s1,72(sp)
    8000403e:	e0ca                	sd	s2,64(sp)
    80004040:	fc4e                	sd	s3,56(sp)
    80004042:	f852                	sd	s4,48(sp)
    80004044:	f456                	sd	s5,40(sp)
    80004046:	f05a                	sd	s6,32(sp)
    80004048:	ec5e                	sd	s7,24(sp)
    8000404a:	e862                	sd	s8,16(sp)
    8000404c:	e466                	sd	s9,8(sp)
    8000404e:	1080                	addi	s0,sp,96
    80004050:	84aa                	mv	s1,a0
    80004052:	8aae                	mv	s5,a1
    80004054:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004056:	00054703          	lbu	a4,0(a0)
    8000405a:	02f00793          	li	a5,47
    8000405e:	02f70363          	beq	a4,a5,80004084 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004062:	ffffe097          	auipc	ra,0xffffe
    80004066:	94a080e7          	jalr	-1718(ra) # 800019ac <myproc>
    8000406a:	18853503          	ld	a0,392(a0)
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	9f6080e7          	jalr	-1546(ra) # 80003a64 <idup>
    80004076:	89aa                	mv	s3,a0
  while(*path == '/')
    80004078:	02f00913          	li	s2,47
  len = path - s;
    8000407c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000407e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004080:	4b85                	li	s7,1
    80004082:	a865                	j	8000413a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004084:	4585                	li	a1,1
    80004086:	4505                	li	a0,1
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	6e2080e7          	jalr	1762(ra) # 8000376a <iget>
    80004090:	89aa                	mv	s3,a0
    80004092:	b7dd                	j	80004078 <namex+0x42>
      iunlockput(ip);
    80004094:	854e                	mv	a0,s3
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	c6e080e7          	jalr	-914(ra) # 80003d04 <iunlockput>
      return 0;
    8000409e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040a0:	854e                	mv	a0,s3
    800040a2:	60e6                	ld	ra,88(sp)
    800040a4:	6446                	ld	s0,80(sp)
    800040a6:	64a6                	ld	s1,72(sp)
    800040a8:	6906                	ld	s2,64(sp)
    800040aa:	79e2                	ld	s3,56(sp)
    800040ac:	7a42                	ld	s4,48(sp)
    800040ae:	7aa2                	ld	s5,40(sp)
    800040b0:	7b02                	ld	s6,32(sp)
    800040b2:	6be2                	ld	s7,24(sp)
    800040b4:	6c42                	ld	s8,16(sp)
    800040b6:	6ca2                	ld	s9,8(sp)
    800040b8:	6125                	addi	sp,sp,96
    800040ba:	8082                	ret
      iunlock(ip);
    800040bc:	854e                	mv	a0,s3
    800040be:	00000097          	auipc	ra,0x0
    800040c2:	aa6080e7          	jalr	-1370(ra) # 80003b64 <iunlock>
      return ip;
    800040c6:	bfe9                	j	800040a0 <namex+0x6a>
      iunlockput(ip);
    800040c8:	854e                	mv	a0,s3
    800040ca:	00000097          	auipc	ra,0x0
    800040ce:	c3a080e7          	jalr	-966(ra) # 80003d04 <iunlockput>
      return 0;
    800040d2:	89e6                	mv	s3,s9
    800040d4:	b7f1                	j	800040a0 <namex+0x6a>
  len = path - s;
    800040d6:	40b48633          	sub	a2,s1,a1
    800040da:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800040de:	099c5463          	bge	s8,s9,80004166 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800040e2:	4639                	li	a2,14
    800040e4:	8552                	mv	a0,s4
    800040e6:	ffffd097          	auipc	ra,0xffffd
    800040ea:	c48080e7          	jalr	-952(ra) # 80000d2e <memmove>
  while(*path == '/')
    800040ee:	0004c783          	lbu	a5,0(s1)
    800040f2:	01279763          	bne	a5,s2,80004100 <namex+0xca>
    path++;
    800040f6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040f8:	0004c783          	lbu	a5,0(s1)
    800040fc:	ff278de3          	beq	a5,s2,800040f6 <namex+0xc0>
    ilock(ip);
    80004100:	854e                	mv	a0,s3
    80004102:	00000097          	auipc	ra,0x0
    80004106:	9a0080e7          	jalr	-1632(ra) # 80003aa2 <ilock>
    if(ip->type != T_DIR){
    8000410a:	04499783          	lh	a5,68(s3)
    8000410e:	f97793e3          	bne	a5,s7,80004094 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004112:	000a8563          	beqz	s5,8000411c <namex+0xe6>
    80004116:	0004c783          	lbu	a5,0(s1)
    8000411a:	d3cd                	beqz	a5,800040bc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000411c:	865a                	mv	a2,s6
    8000411e:	85d2                	mv	a1,s4
    80004120:	854e                	mv	a0,s3
    80004122:	00000097          	auipc	ra,0x0
    80004126:	e64080e7          	jalr	-412(ra) # 80003f86 <dirlookup>
    8000412a:	8caa                	mv	s9,a0
    8000412c:	dd51                	beqz	a0,800040c8 <namex+0x92>
    iunlockput(ip);
    8000412e:	854e                	mv	a0,s3
    80004130:	00000097          	auipc	ra,0x0
    80004134:	bd4080e7          	jalr	-1068(ra) # 80003d04 <iunlockput>
    ip = next;
    80004138:	89e6                	mv	s3,s9
  while(*path == '/')
    8000413a:	0004c783          	lbu	a5,0(s1)
    8000413e:	05279763          	bne	a5,s2,8000418c <namex+0x156>
    path++;
    80004142:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004144:	0004c783          	lbu	a5,0(s1)
    80004148:	ff278de3          	beq	a5,s2,80004142 <namex+0x10c>
  if(*path == 0)
    8000414c:	c79d                	beqz	a5,8000417a <namex+0x144>
    path++;
    8000414e:	85a6                	mv	a1,s1
  len = path - s;
    80004150:	8cda                	mv	s9,s6
    80004152:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004154:	01278963          	beq	a5,s2,80004166 <namex+0x130>
    80004158:	dfbd                	beqz	a5,800040d6 <namex+0xa0>
    path++;
    8000415a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000415c:	0004c783          	lbu	a5,0(s1)
    80004160:	ff279ce3          	bne	a5,s2,80004158 <namex+0x122>
    80004164:	bf8d                	j	800040d6 <namex+0xa0>
    memmove(name, s, len);
    80004166:	2601                	sext.w	a2,a2
    80004168:	8552                	mv	a0,s4
    8000416a:	ffffd097          	auipc	ra,0xffffd
    8000416e:	bc4080e7          	jalr	-1084(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004172:	9cd2                	add	s9,s9,s4
    80004174:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004178:	bf9d                	j	800040ee <namex+0xb8>
  if(nameiparent){
    8000417a:	f20a83e3          	beqz	s5,800040a0 <namex+0x6a>
    iput(ip);
    8000417e:	854e                	mv	a0,s3
    80004180:	00000097          	auipc	ra,0x0
    80004184:	adc080e7          	jalr	-1316(ra) # 80003c5c <iput>
    return 0;
    80004188:	4981                	li	s3,0
    8000418a:	bf19                	j	800040a0 <namex+0x6a>
  if(*path == 0)
    8000418c:	d7fd                	beqz	a5,8000417a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000418e:	0004c783          	lbu	a5,0(s1)
    80004192:	85a6                	mv	a1,s1
    80004194:	b7d1                	j	80004158 <namex+0x122>

0000000080004196 <dirlink>:
{
    80004196:	7139                	addi	sp,sp,-64
    80004198:	fc06                	sd	ra,56(sp)
    8000419a:	f822                	sd	s0,48(sp)
    8000419c:	f426                	sd	s1,40(sp)
    8000419e:	f04a                	sd	s2,32(sp)
    800041a0:	ec4e                	sd	s3,24(sp)
    800041a2:	e852                	sd	s4,16(sp)
    800041a4:	0080                	addi	s0,sp,64
    800041a6:	892a                	mv	s2,a0
    800041a8:	8a2e                	mv	s4,a1
    800041aa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041ac:	4601                	li	a2,0
    800041ae:	00000097          	auipc	ra,0x0
    800041b2:	dd8080e7          	jalr	-552(ra) # 80003f86 <dirlookup>
    800041b6:	e93d                	bnez	a0,8000422c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041b8:	04c92483          	lw	s1,76(s2)
    800041bc:	c49d                	beqz	s1,800041ea <dirlink+0x54>
    800041be:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041c0:	4741                	li	a4,16
    800041c2:	86a6                	mv	a3,s1
    800041c4:	fc040613          	addi	a2,s0,-64
    800041c8:	4581                	li	a1,0
    800041ca:	854a                	mv	a0,s2
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	b8a080e7          	jalr	-1142(ra) # 80003d56 <readi>
    800041d4:	47c1                	li	a5,16
    800041d6:	06f51163          	bne	a0,a5,80004238 <dirlink+0xa2>
    if(de.inum == 0)
    800041da:	fc045783          	lhu	a5,-64(s0)
    800041de:	c791                	beqz	a5,800041ea <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041e0:	24c1                	addiw	s1,s1,16
    800041e2:	04c92783          	lw	a5,76(s2)
    800041e6:	fcf4ede3          	bltu	s1,a5,800041c0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800041ea:	4639                	li	a2,14
    800041ec:	85d2                	mv	a1,s4
    800041ee:	fc240513          	addi	a0,s0,-62
    800041f2:	ffffd097          	auipc	ra,0xffffd
    800041f6:	bec080e7          	jalr	-1044(ra) # 80000dde <strncpy>
  de.inum = inum;
    800041fa:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041fe:	4741                	li	a4,16
    80004200:	86a6                	mv	a3,s1
    80004202:	fc040613          	addi	a2,s0,-64
    80004206:	4581                	li	a1,0
    80004208:	854a                	mv	a0,s2
    8000420a:	00000097          	auipc	ra,0x0
    8000420e:	c44080e7          	jalr	-956(ra) # 80003e4e <writei>
    80004212:	1541                	addi	a0,a0,-16
    80004214:	00a03533          	snez	a0,a0
    80004218:	40a00533          	neg	a0,a0
}
    8000421c:	70e2                	ld	ra,56(sp)
    8000421e:	7442                	ld	s0,48(sp)
    80004220:	74a2                	ld	s1,40(sp)
    80004222:	7902                	ld	s2,32(sp)
    80004224:	69e2                	ld	s3,24(sp)
    80004226:	6a42                	ld	s4,16(sp)
    80004228:	6121                	addi	sp,sp,64
    8000422a:	8082                	ret
    iput(ip);
    8000422c:	00000097          	auipc	ra,0x0
    80004230:	a30080e7          	jalr	-1488(ra) # 80003c5c <iput>
    return -1;
    80004234:	557d                	li	a0,-1
    80004236:	b7dd                	j	8000421c <dirlink+0x86>
      panic("dirlink read");
    80004238:	00004517          	auipc	a0,0x4
    8000423c:	40050513          	addi	a0,a0,1024 # 80008638 <syscalls+0x1e8>
    80004240:	ffffc097          	auipc	ra,0xffffc
    80004244:	2fe080e7          	jalr	766(ra) # 8000053e <panic>

0000000080004248 <namei>:

struct inode*
namei(char *path)
{
    80004248:	1101                	addi	sp,sp,-32
    8000424a:	ec06                	sd	ra,24(sp)
    8000424c:	e822                	sd	s0,16(sp)
    8000424e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004250:	fe040613          	addi	a2,s0,-32
    80004254:	4581                	li	a1,0
    80004256:	00000097          	auipc	ra,0x0
    8000425a:	de0080e7          	jalr	-544(ra) # 80004036 <namex>
}
    8000425e:	60e2                	ld	ra,24(sp)
    80004260:	6442                	ld	s0,16(sp)
    80004262:	6105                	addi	sp,sp,32
    80004264:	8082                	ret

0000000080004266 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004266:	1141                	addi	sp,sp,-16
    80004268:	e406                	sd	ra,8(sp)
    8000426a:	e022                	sd	s0,0(sp)
    8000426c:	0800                	addi	s0,sp,16
    8000426e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004270:	4585                	li	a1,1
    80004272:	00000097          	auipc	ra,0x0
    80004276:	dc4080e7          	jalr	-572(ra) # 80004036 <namex>
}
    8000427a:	60a2                	ld	ra,8(sp)
    8000427c:	6402                	ld	s0,0(sp)
    8000427e:	0141                	addi	sp,sp,16
    80004280:	8082                	ret

0000000080004282 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004282:	1101                	addi	sp,sp,-32
    80004284:	ec06                	sd	ra,24(sp)
    80004286:	e822                	sd	s0,16(sp)
    80004288:	e426                	sd	s1,8(sp)
    8000428a:	e04a                	sd	s2,0(sp)
    8000428c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000428e:	0001e917          	auipc	s2,0x1e
    80004292:	aa290913          	addi	s2,s2,-1374 # 80021d30 <log>
    80004296:	01892583          	lw	a1,24(s2)
    8000429a:	02892503          	lw	a0,40(s2)
    8000429e:	fffff097          	auipc	ra,0xfffff
    800042a2:	fea080e7          	jalr	-22(ra) # 80003288 <bread>
    800042a6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042a8:	02c92683          	lw	a3,44(s2)
    800042ac:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042ae:	02d05763          	blez	a3,800042dc <write_head+0x5a>
    800042b2:	0001e797          	auipc	a5,0x1e
    800042b6:	aae78793          	addi	a5,a5,-1362 # 80021d60 <log+0x30>
    800042ba:	05c50713          	addi	a4,a0,92
    800042be:	36fd                	addiw	a3,a3,-1
    800042c0:	1682                	slli	a3,a3,0x20
    800042c2:	9281                	srli	a3,a3,0x20
    800042c4:	068a                	slli	a3,a3,0x2
    800042c6:	0001e617          	auipc	a2,0x1e
    800042ca:	a9e60613          	addi	a2,a2,-1378 # 80021d64 <log+0x34>
    800042ce:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800042d0:	4390                	lw	a2,0(a5)
    800042d2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042d4:	0791                	addi	a5,a5,4
    800042d6:	0711                	addi	a4,a4,4
    800042d8:	fed79ce3          	bne	a5,a3,800042d0 <write_head+0x4e>
  }
  bwrite(buf);
    800042dc:	8526                	mv	a0,s1
    800042de:	fffff097          	auipc	ra,0xfffff
    800042e2:	09c080e7          	jalr	156(ra) # 8000337a <bwrite>
  brelse(buf);
    800042e6:	8526                	mv	a0,s1
    800042e8:	fffff097          	auipc	ra,0xfffff
    800042ec:	0d0080e7          	jalr	208(ra) # 800033b8 <brelse>
}
    800042f0:	60e2                	ld	ra,24(sp)
    800042f2:	6442                	ld	s0,16(sp)
    800042f4:	64a2                	ld	s1,8(sp)
    800042f6:	6902                	ld	s2,0(sp)
    800042f8:	6105                	addi	sp,sp,32
    800042fa:	8082                	ret

00000000800042fc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800042fc:	0001e797          	auipc	a5,0x1e
    80004300:	a607a783          	lw	a5,-1440(a5) # 80021d5c <log+0x2c>
    80004304:	0af05d63          	blez	a5,800043be <install_trans+0xc2>
{
    80004308:	7139                	addi	sp,sp,-64
    8000430a:	fc06                	sd	ra,56(sp)
    8000430c:	f822                	sd	s0,48(sp)
    8000430e:	f426                	sd	s1,40(sp)
    80004310:	f04a                	sd	s2,32(sp)
    80004312:	ec4e                	sd	s3,24(sp)
    80004314:	e852                	sd	s4,16(sp)
    80004316:	e456                	sd	s5,8(sp)
    80004318:	e05a                	sd	s6,0(sp)
    8000431a:	0080                	addi	s0,sp,64
    8000431c:	8b2a                	mv	s6,a0
    8000431e:	0001ea97          	auipc	s5,0x1e
    80004322:	a42a8a93          	addi	s5,s5,-1470 # 80021d60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004326:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004328:	0001e997          	auipc	s3,0x1e
    8000432c:	a0898993          	addi	s3,s3,-1528 # 80021d30 <log>
    80004330:	a00d                	j	80004352 <install_trans+0x56>
    brelse(lbuf);
    80004332:	854a                	mv	a0,s2
    80004334:	fffff097          	auipc	ra,0xfffff
    80004338:	084080e7          	jalr	132(ra) # 800033b8 <brelse>
    brelse(dbuf);
    8000433c:	8526                	mv	a0,s1
    8000433e:	fffff097          	auipc	ra,0xfffff
    80004342:	07a080e7          	jalr	122(ra) # 800033b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004346:	2a05                	addiw	s4,s4,1
    80004348:	0a91                	addi	s5,s5,4
    8000434a:	02c9a783          	lw	a5,44(s3)
    8000434e:	04fa5e63          	bge	s4,a5,800043aa <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004352:	0189a583          	lw	a1,24(s3)
    80004356:	014585bb          	addw	a1,a1,s4
    8000435a:	2585                	addiw	a1,a1,1
    8000435c:	0289a503          	lw	a0,40(s3)
    80004360:	fffff097          	auipc	ra,0xfffff
    80004364:	f28080e7          	jalr	-216(ra) # 80003288 <bread>
    80004368:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000436a:	000aa583          	lw	a1,0(s5)
    8000436e:	0289a503          	lw	a0,40(s3)
    80004372:	fffff097          	auipc	ra,0xfffff
    80004376:	f16080e7          	jalr	-234(ra) # 80003288 <bread>
    8000437a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000437c:	40000613          	li	a2,1024
    80004380:	05890593          	addi	a1,s2,88
    80004384:	05850513          	addi	a0,a0,88
    80004388:	ffffd097          	auipc	ra,0xffffd
    8000438c:	9a6080e7          	jalr	-1626(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004390:	8526                	mv	a0,s1
    80004392:	fffff097          	auipc	ra,0xfffff
    80004396:	fe8080e7          	jalr	-24(ra) # 8000337a <bwrite>
    if(recovering == 0)
    8000439a:	f80b1ce3          	bnez	s6,80004332 <install_trans+0x36>
      bunpin(dbuf);
    8000439e:	8526                	mv	a0,s1
    800043a0:	fffff097          	auipc	ra,0xfffff
    800043a4:	0f2080e7          	jalr	242(ra) # 80003492 <bunpin>
    800043a8:	b769                	j	80004332 <install_trans+0x36>
}
    800043aa:	70e2                	ld	ra,56(sp)
    800043ac:	7442                	ld	s0,48(sp)
    800043ae:	74a2                	ld	s1,40(sp)
    800043b0:	7902                	ld	s2,32(sp)
    800043b2:	69e2                	ld	s3,24(sp)
    800043b4:	6a42                	ld	s4,16(sp)
    800043b6:	6aa2                	ld	s5,8(sp)
    800043b8:	6b02                	ld	s6,0(sp)
    800043ba:	6121                	addi	sp,sp,64
    800043bc:	8082                	ret
    800043be:	8082                	ret

00000000800043c0 <initlog>:
{
    800043c0:	7179                	addi	sp,sp,-48
    800043c2:	f406                	sd	ra,40(sp)
    800043c4:	f022                	sd	s0,32(sp)
    800043c6:	ec26                	sd	s1,24(sp)
    800043c8:	e84a                	sd	s2,16(sp)
    800043ca:	e44e                	sd	s3,8(sp)
    800043cc:	1800                	addi	s0,sp,48
    800043ce:	892a                	mv	s2,a0
    800043d0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800043d2:	0001e497          	auipc	s1,0x1e
    800043d6:	95e48493          	addi	s1,s1,-1698 # 80021d30 <log>
    800043da:	00004597          	auipc	a1,0x4
    800043de:	26e58593          	addi	a1,a1,622 # 80008648 <syscalls+0x1f8>
    800043e2:	8526                	mv	a0,s1
    800043e4:	ffffc097          	auipc	ra,0xffffc
    800043e8:	762080e7          	jalr	1890(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800043ec:	0149a583          	lw	a1,20(s3)
    800043f0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800043f2:	0109a783          	lw	a5,16(s3)
    800043f6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800043f8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800043fc:	854a                	mv	a0,s2
    800043fe:	fffff097          	auipc	ra,0xfffff
    80004402:	e8a080e7          	jalr	-374(ra) # 80003288 <bread>
  log.lh.n = lh->n;
    80004406:	4d34                	lw	a3,88(a0)
    80004408:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000440a:	02d05563          	blez	a3,80004434 <initlog+0x74>
    8000440e:	05c50793          	addi	a5,a0,92
    80004412:	0001e717          	auipc	a4,0x1e
    80004416:	94e70713          	addi	a4,a4,-1714 # 80021d60 <log+0x30>
    8000441a:	36fd                	addiw	a3,a3,-1
    8000441c:	1682                	slli	a3,a3,0x20
    8000441e:	9281                	srli	a3,a3,0x20
    80004420:	068a                	slli	a3,a3,0x2
    80004422:	06050613          	addi	a2,a0,96
    80004426:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004428:	4390                	lw	a2,0(a5)
    8000442a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000442c:	0791                	addi	a5,a5,4
    8000442e:	0711                	addi	a4,a4,4
    80004430:	fed79ce3          	bne	a5,a3,80004428 <initlog+0x68>
  brelse(buf);
    80004434:	fffff097          	auipc	ra,0xfffff
    80004438:	f84080e7          	jalr	-124(ra) # 800033b8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000443c:	4505                	li	a0,1
    8000443e:	00000097          	auipc	ra,0x0
    80004442:	ebe080e7          	jalr	-322(ra) # 800042fc <install_trans>
  log.lh.n = 0;
    80004446:	0001e797          	auipc	a5,0x1e
    8000444a:	9007ab23          	sw	zero,-1770(a5) # 80021d5c <log+0x2c>
  write_head(); // clear the log
    8000444e:	00000097          	auipc	ra,0x0
    80004452:	e34080e7          	jalr	-460(ra) # 80004282 <write_head>
}
    80004456:	70a2                	ld	ra,40(sp)
    80004458:	7402                	ld	s0,32(sp)
    8000445a:	64e2                	ld	s1,24(sp)
    8000445c:	6942                	ld	s2,16(sp)
    8000445e:	69a2                	ld	s3,8(sp)
    80004460:	6145                	addi	sp,sp,48
    80004462:	8082                	ret

0000000080004464 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004464:	1101                	addi	sp,sp,-32
    80004466:	ec06                	sd	ra,24(sp)
    80004468:	e822                	sd	s0,16(sp)
    8000446a:	e426                	sd	s1,8(sp)
    8000446c:	e04a                	sd	s2,0(sp)
    8000446e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004470:	0001e517          	auipc	a0,0x1e
    80004474:	8c050513          	addi	a0,a0,-1856 # 80021d30 <log>
    80004478:	ffffc097          	auipc	ra,0xffffc
    8000447c:	75e080e7          	jalr	1886(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004480:	0001e497          	auipc	s1,0x1e
    80004484:	8b048493          	addi	s1,s1,-1872 # 80021d30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004488:	4979                	li	s2,30
    8000448a:	a039                	j	80004498 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000448c:	85a6                	mv	a1,s1
    8000448e:	8526                	mv	a0,s1
    80004490:	ffffe097          	auipc	ra,0xffffe
    80004494:	c22080e7          	jalr	-990(ra) # 800020b2 <sleep>
    if(log.committing){
    80004498:	50dc                	lw	a5,36(s1)
    8000449a:	fbed                	bnez	a5,8000448c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000449c:	509c                	lw	a5,32(s1)
    8000449e:	0017871b          	addiw	a4,a5,1
    800044a2:	0007069b          	sext.w	a3,a4
    800044a6:	0027179b          	slliw	a5,a4,0x2
    800044aa:	9fb9                	addw	a5,a5,a4
    800044ac:	0017979b          	slliw	a5,a5,0x1
    800044b0:	54d8                	lw	a4,44(s1)
    800044b2:	9fb9                	addw	a5,a5,a4
    800044b4:	00f95963          	bge	s2,a5,800044c6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800044b8:	85a6                	mv	a1,s1
    800044ba:	8526                	mv	a0,s1
    800044bc:	ffffe097          	auipc	ra,0xffffe
    800044c0:	bf6080e7          	jalr	-1034(ra) # 800020b2 <sleep>
    800044c4:	bfd1                	j	80004498 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800044c6:	0001e517          	auipc	a0,0x1e
    800044ca:	86a50513          	addi	a0,a0,-1942 # 80021d30 <log>
    800044ce:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800044d0:	ffffc097          	auipc	ra,0xffffc
    800044d4:	7ba080e7          	jalr	1978(ra) # 80000c8a <release>
      break;
    }
  }
}
    800044d8:	60e2                	ld	ra,24(sp)
    800044da:	6442                	ld	s0,16(sp)
    800044dc:	64a2                	ld	s1,8(sp)
    800044de:	6902                	ld	s2,0(sp)
    800044e0:	6105                	addi	sp,sp,32
    800044e2:	8082                	ret

00000000800044e4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800044e4:	7139                	addi	sp,sp,-64
    800044e6:	fc06                	sd	ra,56(sp)
    800044e8:	f822                	sd	s0,48(sp)
    800044ea:	f426                	sd	s1,40(sp)
    800044ec:	f04a                	sd	s2,32(sp)
    800044ee:	ec4e                	sd	s3,24(sp)
    800044f0:	e852                	sd	s4,16(sp)
    800044f2:	e456                	sd	s5,8(sp)
    800044f4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800044f6:	0001e497          	auipc	s1,0x1e
    800044fa:	83a48493          	addi	s1,s1,-1990 # 80021d30 <log>
    800044fe:	8526                	mv	a0,s1
    80004500:	ffffc097          	auipc	ra,0xffffc
    80004504:	6d6080e7          	jalr	1750(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004508:	509c                	lw	a5,32(s1)
    8000450a:	37fd                	addiw	a5,a5,-1
    8000450c:	0007891b          	sext.w	s2,a5
    80004510:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004512:	50dc                	lw	a5,36(s1)
    80004514:	e7b9                	bnez	a5,80004562 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004516:	04091e63          	bnez	s2,80004572 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000451a:	0001e497          	auipc	s1,0x1e
    8000451e:	81648493          	addi	s1,s1,-2026 # 80021d30 <log>
    80004522:	4785                	li	a5,1
    80004524:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004526:	8526                	mv	a0,s1
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	762080e7          	jalr	1890(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004530:	54dc                	lw	a5,44(s1)
    80004532:	06f04763          	bgtz	a5,800045a0 <end_op+0xbc>
    acquire(&log.lock);
    80004536:	0001d497          	auipc	s1,0x1d
    8000453a:	7fa48493          	addi	s1,s1,2042 # 80021d30 <log>
    8000453e:	8526                	mv	a0,s1
    80004540:	ffffc097          	auipc	ra,0xffffc
    80004544:	696080e7          	jalr	1686(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004548:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000454c:	8526                	mv	a0,s1
    8000454e:	ffffe097          	auipc	ra,0xffffe
    80004552:	bc8080e7          	jalr	-1080(ra) # 80002116 <wakeup>
    release(&log.lock);
    80004556:	8526                	mv	a0,s1
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	732080e7          	jalr	1842(ra) # 80000c8a <release>
}
    80004560:	a03d                	j	8000458e <end_op+0xaa>
    panic("log.committing");
    80004562:	00004517          	auipc	a0,0x4
    80004566:	0ee50513          	addi	a0,a0,238 # 80008650 <syscalls+0x200>
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	fd4080e7          	jalr	-44(ra) # 8000053e <panic>
    wakeup(&log);
    80004572:	0001d497          	auipc	s1,0x1d
    80004576:	7be48493          	addi	s1,s1,1982 # 80021d30 <log>
    8000457a:	8526                	mv	a0,s1
    8000457c:	ffffe097          	auipc	ra,0xffffe
    80004580:	b9a080e7          	jalr	-1126(ra) # 80002116 <wakeup>
  release(&log.lock);
    80004584:	8526                	mv	a0,s1
    80004586:	ffffc097          	auipc	ra,0xffffc
    8000458a:	704080e7          	jalr	1796(ra) # 80000c8a <release>
}
    8000458e:	70e2                	ld	ra,56(sp)
    80004590:	7442                	ld	s0,48(sp)
    80004592:	74a2                	ld	s1,40(sp)
    80004594:	7902                	ld	s2,32(sp)
    80004596:	69e2                	ld	s3,24(sp)
    80004598:	6a42                	ld	s4,16(sp)
    8000459a:	6aa2                	ld	s5,8(sp)
    8000459c:	6121                	addi	sp,sp,64
    8000459e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800045a0:	0001da97          	auipc	s5,0x1d
    800045a4:	7c0a8a93          	addi	s5,s5,1984 # 80021d60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800045a8:	0001da17          	auipc	s4,0x1d
    800045ac:	788a0a13          	addi	s4,s4,1928 # 80021d30 <log>
    800045b0:	018a2583          	lw	a1,24(s4)
    800045b4:	012585bb          	addw	a1,a1,s2
    800045b8:	2585                	addiw	a1,a1,1
    800045ba:	028a2503          	lw	a0,40(s4)
    800045be:	fffff097          	auipc	ra,0xfffff
    800045c2:	cca080e7          	jalr	-822(ra) # 80003288 <bread>
    800045c6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800045c8:	000aa583          	lw	a1,0(s5)
    800045cc:	028a2503          	lw	a0,40(s4)
    800045d0:	fffff097          	auipc	ra,0xfffff
    800045d4:	cb8080e7          	jalr	-840(ra) # 80003288 <bread>
    800045d8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800045da:	40000613          	li	a2,1024
    800045de:	05850593          	addi	a1,a0,88
    800045e2:	05848513          	addi	a0,s1,88
    800045e6:	ffffc097          	auipc	ra,0xffffc
    800045ea:	748080e7          	jalr	1864(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800045ee:	8526                	mv	a0,s1
    800045f0:	fffff097          	auipc	ra,0xfffff
    800045f4:	d8a080e7          	jalr	-630(ra) # 8000337a <bwrite>
    brelse(from);
    800045f8:	854e                	mv	a0,s3
    800045fa:	fffff097          	auipc	ra,0xfffff
    800045fe:	dbe080e7          	jalr	-578(ra) # 800033b8 <brelse>
    brelse(to);
    80004602:	8526                	mv	a0,s1
    80004604:	fffff097          	auipc	ra,0xfffff
    80004608:	db4080e7          	jalr	-588(ra) # 800033b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000460c:	2905                	addiw	s2,s2,1
    8000460e:	0a91                	addi	s5,s5,4
    80004610:	02ca2783          	lw	a5,44(s4)
    80004614:	f8f94ee3          	blt	s2,a5,800045b0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004618:	00000097          	auipc	ra,0x0
    8000461c:	c6a080e7          	jalr	-918(ra) # 80004282 <write_head>
    install_trans(0); // Now install writes to home locations
    80004620:	4501                	li	a0,0
    80004622:	00000097          	auipc	ra,0x0
    80004626:	cda080e7          	jalr	-806(ra) # 800042fc <install_trans>
    log.lh.n = 0;
    8000462a:	0001d797          	auipc	a5,0x1d
    8000462e:	7207a923          	sw	zero,1842(a5) # 80021d5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004632:	00000097          	auipc	ra,0x0
    80004636:	c50080e7          	jalr	-944(ra) # 80004282 <write_head>
    8000463a:	bdf5                	j	80004536 <end_op+0x52>

000000008000463c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000463c:	1101                	addi	sp,sp,-32
    8000463e:	ec06                	sd	ra,24(sp)
    80004640:	e822                	sd	s0,16(sp)
    80004642:	e426                	sd	s1,8(sp)
    80004644:	e04a                	sd	s2,0(sp)
    80004646:	1000                	addi	s0,sp,32
    80004648:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000464a:	0001d917          	auipc	s2,0x1d
    8000464e:	6e690913          	addi	s2,s2,1766 # 80021d30 <log>
    80004652:	854a                	mv	a0,s2
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	582080e7          	jalr	1410(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000465c:	02c92603          	lw	a2,44(s2)
    80004660:	47f5                	li	a5,29
    80004662:	06c7c563          	blt	a5,a2,800046cc <log_write+0x90>
    80004666:	0001d797          	auipc	a5,0x1d
    8000466a:	6e67a783          	lw	a5,1766(a5) # 80021d4c <log+0x1c>
    8000466e:	37fd                	addiw	a5,a5,-1
    80004670:	04f65e63          	bge	a2,a5,800046cc <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004674:	0001d797          	auipc	a5,0x1d
    80004678:	6dc7a783          	lw	a5,1756(a5) # 80021d50 <log+0x20>
    8000467c:	06f05063          	blez	a5,800046dc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004680:	4781                	li	a5,0
    80004682:	06c05563          	blez	a2,800046ec <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004686:	44cc                	lw	a1,12(s1)
    80004688:	0001d717          	auipc	a4,0x1d
    8000468c:	6d870713          	addi	a4,a4,1752 # 80021d60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004690:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004692:	4314                	lw	a3,0(a4)
    80004694:	04b68c63          	beq	a3,a1,800046ec <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004698:	2785                	addiw	a5,a5,1
    8000469a:	0711                	addi	a4,a4,4
    8000469c:	fef61be3          	bne	a2,a5,80004692 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046a0:	0621                	addi	a2,a2,8
    800046a2:	060a                	slli	a2,a2,0x2
    800046a4:	0001d797          	auipc	a5,0x1d
    800046a8:	68c78793          	addi	a5,a5,1676 # 80021d30 <log>
    800046ac:	963e                	add	a2,a2,a5
    800046ae:	44dc                	lw	a5,12(s1)
    800046b0:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800046b2:	8526                	mv	a0,s1
    800046b4:	fffff097          	auipc	ra,0xfffff
    800046b8:	da2080e7          	jalr	-606(ra) # 80003456 <bpin>
    log.lh.n++;
    800046bc:	0001d717          	auipc	a4,0x1d
    800046c0:	67470713          	addi	a4,a4,1652 # 80021d30 <log>
    800046c4:	575c                	lw	a5,44(a4)
    800046c6:	2785                	addiw	a5,a5,1
    800046c8:	d75c                	sw	a5,44(a4)
    800046ca:	a835                	j	80004706 <log_write+0xca>
    panic("too big a transaction");
    800046cc:	00004517          	auipc	a0,0x4
    800046d0:	f9450513          	addi	a0,a0,-108 # 80008660 <syscalls+0x210>
    800046d4:	ffffc097          	auipc	ra,0xffffc
    800046d8:	e6a080e7          	jalr	-406(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800046dc:	00004517          	auipc	a0,0x4
    800046e0:	f9c50513          	addi	a0,a0,-100 # 80008678 <syscalls+0x228>
    800046e4:	ffffc097          	auipc	ra,0xffffc
    800046e8:	e5a080e7          	jalr	-422(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800046ec:	00878713          	addi	a4,a5,8
    800046f0:	00271693          	slli	a3,a4,0x2
    800046f4:	0001d717          	auipc	a4,0x1d
    800046f8:	63c70713          	addi	a4,a4,1596 # 80021d30 <log>
    800046fc:	9736                	add	a4,a4,a3
    800046fe:	44d4                	lw	a3,12(s1)
    80004700:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004702:	faf608e3          	beq	a2,a5,800046b2 <log_write+0x76>
  }
  release(&log.lock);
    80004706:	0001d517          	auipc	a0,0x1d
    8000470a:	62a50513          	addi	a0,a0,1578 # 80021d30 <log>
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	57c080e7          	jalr	1404(ra) # 80000c8a <release>
}
    80004716:	60e2                	ld	ra,24(sp)
    80004718:	6442                	ld	s0,16(sp)
    8000471a:	64a2                	ld	s1,8(sp)
    8000471c:	6902                	ld	s2,0(sp)
    8000471e:	6105                	addi	sp,sp,32
    80004720:	8082                	ret

0000000080004722 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004722:	1101                	addi	sp,sp,-32
    80004724:	ec06                	sd	ra,24(sp)
    80004726:	e822                	sd	s0,16(sp)
    80004728:	e426                	sd	s1,8(sp)
    8000472a:	e04a                	sd	s2,0(sp)
    8000472c:	1000                	addi	s0,sp,32
    8000472e:	84aa                	mv	s1,a0
    80004730:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004732:	00004597          	auipc	a1,0x4
    80004736:	f6658593          	addi	a1,a1,-154 # 80008698 <syscalls+0x248>
    8000473a:	0521                	addi	a0,a0,8
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	40a080e7          	jalr	1034(ra) # 80000b46 <initlock>
  lk->name = name;
    80004744:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004748:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000474c:	0204a423          	sw	zero,40(s1)
}
    80004750:	60e2                	ld	ra,24(sp)
    80004752:	6442                	ld	s0,16(sp)
    80004754:	64a2                	ld	s1,8(sp)
    80004756:	6902                	ld	s2,0(sp)
    80004758:	6105                	addi	sp,sp,32
    8000475a:	8082                	ret

000000008000475c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000475c:	1101                	addi	sp,sp,-32
    8000475e:	ec06                	sd	ra,24(sp)
    80004760:	e822                	sd	s0,16(sp)
    80004762:	e426                	sd	s1,8(sp)
    80004764:	e04a                	sd	s2,0(sp)
    80004766:	1000                	addi	s0,sp,32
    80004768:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000476a:	00850913          	addi	s2,a0,8
    8000476e:	854a                	mv	a0,s2
    80004770:	ffffc097          	auipc	ra,0xffffc
    80004774:	466080e7          	jalr	1126(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004778:	409c                	lw	a5,0(s1)
    8000477a:	cb89                	beqz	a5,8000478c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000477c:	85ca                	mv	a1,s2
    8000477e:	8526                	mv	a0,s1
    80004780:	ffffe097          	auipc	ra,0xffffe
    80004784:	932080e7          	jalr	-1742(ra) # 800020b2 <sleep>
  while (lk->locked) {
    80004788:	409c                	lw	a5,0(s1)
    8000478a:	fbed                	bnez	a5,8000477c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000478c:	4785                	li	a5,1
    8000478e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004790:	ffffd097          	auipc	ra,0xffffd
    80004794:	21c080e7          	jalr	540(ra) # 800019ac <myproc>
    80004798:	591c                	lw	a5,48(a0)
    8000479a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000479c:	854a                	mv	a0,s2
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	4ec080e7          	jalr	1260(ra) # 80000c8a <release>
}
    800047a6:	60e2                	ld	ra,24(sp)
    800047a8:	6442                	ld	s0,16(sp)
    800047aa:	64a2                	ld	s1,8(sp)
    800047ac:	6902                	ld	s2,0(sp)
    800047ae:	6105                	addi	sp,sp,32
    800047b0:	8082                	ret

00000000800047b2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047b2:	1101                	addi	sp,sp,-32
    800047b4:	ec06                	sd	ra,24(sp)
    800047b6:	e822                	sd	s0,16(sp)
    800047b8:	e426                	sd	s1,8(sp)
    800047ba:	e04a                	sd	s2,0(sp)
    800047bc:	1000                	addi	s0,sp,32
    800047be:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047c0:	00850913          	addi	s2,a0,8
    800047c4:	854a                	mv	a0,s2
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	410080e7          	jalr	1040(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800047ce:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047d2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800047d6:	8526                	mv	a0,s1
    800047d8:	ffffe097          	auipc	ra,0xffffe
    800047dc:	93e080e7          	jalr	-1730(ra) # 80002116 <wakeup>
  release(&lk->lk);
    800047e0:	854a                	mv	a0,s2
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	4a8080e7          	jalr	1192(ra) # 80000c8a <release>
}
    800047ea:	60e2                	ld	ra,24(sp)
    800047ec:	6442                	ld	s0,16(sp)
    800047ee:	64a2                	ld	s1,8(sp)
    800047f0:	6902                	ld	s2,0(sp)
    800047f2:	6105                	addi	sp,sp,32
    800047f4:	8082                	ret

00000000800047f6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800047f6:	7179                	addi	sp,sp,-48
    800047f8:	f406                	sd	ra,40(sp)
    800047fa:	f022                	sd	s0,32(sp)
    800047fc:	ec26                	sd	s1,24(sp)
    800047fe:	e84a                	sd	s2,16(sp)
    80004800:	e44e                	sd	s3,8(sp)
    80004802:	1800                	addi	s0,sp,48
    80004804:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004806:	00850913          	addi	s2,a0,8
    8000480a:	854a                	mv	a0,s2
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	3ca080e7          	jalr	970(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004814:	409c                	lw	a5,0(s1)
    80004816:	ef99                	bnez	a5,80004834 <holdingsleep+0x3e>
    80004818:	4481                	li	s1,0
  release(&lk->lk);
    8000481a:	854a                	mv	a0,s2
    8000481c:	ffffc097          	auipc	ra,0xffffc
    80004820:	46e080e7          	jalr	1134(ra) # 80000c8a <release>
  return r;
}
    80004824:	8526                	mv	a0,s1
    80004826:	70a2                	ld	ra,40(sp)
    80004828:	7402                	ld	s0,32(sp)
    8000482a:	64e2                	ld	s1,24(sp)
    8000482c:	6942                	ld	s2,16(sp)
    8000482e:	69a2                	ld	s3,8(sp)
    80004830:	6145                	addi	sp,sp,48
    80004832:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004834:	0284a983          	lw	s3,40(s1)
    80004838:	ffffd097          	auipc	ra,0xffffd
    8000483c:	174080e7          	jalr	372(ra) # 800019ac <myproc>
    80004840:	5904                	lw	s1,48(a0)
    80004842:	413484b3          	sub	s1,s1,s3
    80004846:	0014b493          	seqz	s1,s1
    8000484a:	bfc1                	j	8000481a <holdingsleep+0x24>

000000008000484c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000484c:	1141                	addi	sp,sp,-16
    8000484e:	e406                	sd	ra,8(sp)
    80004850:	e022                	sd	s0,0(sp)
    80004852:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004854:	00004597          	auipc	a1,0x4
    80004858:	e5458593          	addi	a1,a1,-428 # 800086a8 <syscalls+0x258>
    8000485c:	0001d517          	auipc	a0,0x1d
    80004860:	61c50513          	addi	a0,a0,1564 # 80021e78 <ftable>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	2e2080e7          	jalr	738(ra) # 80000b46 <initlock>
}
    8000486c:	60a2                	ld	ra,8(sp)
    8000486e:	6402                	ld	s0,0(sp)
    80004870:	0141                	addi	sp,sp,16
    80004872:	8082                	ret

0000000080004874 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004874:	1101                	addi	sp,sp,-32
    80004876:	ec06                	sd	ra,24(sp)
    80004878:	e822                	sd	s0,16(sp)
    8000487a:	e426                	sd	s1,8(sp)
    8000487c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000487e:	0001d517          	auipc	a0,0x1d
    80004882:	5fa50513          	addi	a0,a0,1530 # 80021e78 <ftable>
    80004886:	ffffc097          	auipc	ra,0xffffc
    8000488a:	350080e7          	jalr	848(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000488e:	0001d497          	auipc	s1,0x1d
    80004892:	60248493          	addi	s1,s1,1538 # 80021e90 <ftable+0x18>
    80004896:	0001e717          	auipc	a4,0x1e
    8000489a:	59a70713          	addi	a4,a4,1434 # 80022e30 <disk>
    if(f->ref == 0){
    8000489e:	40dc                	lw	a5,4(s1)
    800048a0:	cf99                	beqz	a5,800048be <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048a2:	02848493          	addi	s1,s1,40
    800048a6:	fee49ce3          	bne	s1,a4,8000489e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048aa:	0001d517          	auipc	a0,0x1d
    800048ae:	5ce50513          	addi	a0,a0,1486 # 80021e78 <ftable>
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	3d8080e7          	jalr	984(ra) # 80000c8a <release>
  return 0;
    800048ba:	4481                	li	s1,0
    800048bc:	a819                	j	800048d2 <filealloc+0x5e>
      f->ref = 1;
    800048be:	4785                	li	a5,1
    800048c0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800048c2:	0001d517          	auipc	a0,0x1d
    800048c6:	5b650513          	addi	a0,a0,1462 # 80021e78 <ftable>
    800048ca:	ffffc097          	auipc	ra,0xffffc
    800048ce:	3c0080e7          	jalr	960(ra) # 80000c8a <release>
}
    800048d2:	8526                	mv	a0,s1
    800048d4:	60e2                	ld	ra,24(sp)
    800048d6:	6442                	ld	s0,16(sp)
    800048d8:	64a2                	ld	s1,8(sp)
    800048da:	6105                	addi	sp,sp,32
    800048dc:	8082                	ret

00000000800048de <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800048de:	1101                	addi	sp,sp,-32
    800048e0:	ec06                	sd	ra,24(sp)
    800048e2:	e822                	sd	s0,16(sp)
    800048e4:	e426                	sd	s1,8(sp)
    800048e6:	1000                	addi	s0,sp,32
    800048e8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800048ea:	0001d517          	auipc	a0,0x1d
    800048ee:	58e50513          	addi	a0,a0,1422 # 80021e78 <ftable>
    800048f2:	ffffc097          	auipc	ra,0xffffc
    800048f6:	2e4080e7          	jalr	740(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800048fa:	40dc                	lw	a5,4(s1)
    800048fc:	02f05263          	blez	a5,80004920 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004900:	2785                	addiw	a5,a5,1
    80004902:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004904:	0001d517          	auipc	a0,0x1d
    80004908:	57450513          	addi	a0,a0,1396 # 80021e78 <ftable>
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	37e080e7          	jalr	894(ra) # 80000c8a <release>
  return f;
}
    80004914:	8526                	mv	a0,s1
    80004916:	60e2                	ld	ra,24(sp)
    80004918:	6442                	ld	s0,16(sp)
    8000491a:	64a2                	ld	s1,8(sp)
    8000491c:	6105                	addi	sp,sp,32
    8000491e:	8082                	ret
    panic("filedup");
    80004920:	00004517          	auipc	a0,0x4
    80004924:	d9050513          	addi	a0,a0,-624 # 800086b0 <syscalls+0x260>
    80004928:	ffffc097          	auipc	ra,0xffffc
    8000492c:	c16080e7          	jalr	-1002(ra) # 8000053e <panic>

0000000080004930 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004930:	7139                	addi	sp,sp,-64
    80004932:	fc06                	sd	ra,56(sp)
    80004934:	f822                	sd	s0,48(sp)
    80004936:	f426                	sd	s1,40(sp)
    80004938:	f04a                	sd	s2,32(sp)
    8000493a:	ec4e                	sd	s3,24(sp)
    8000493c:	e852                	sd	s4,16(sp)
    8000493e:	e456                	sd	s5,8(sp)
    80004940:	0080                	addi	s0,sp,64
    80004942:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004944:	0001d517          	auipc	a0,0x1d
    80004948:	53450513          	addi	a0,a0,1332 # 80021e78 <ftable>
    8000494c:	ffffc097          	auipc	ra,0xffffc
    80004950:	28a080e7          	jalr	650(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004954:	40dc                	lw	a5,4(s1)
    80004956:	06f05163          	blez	a5,800049b8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000495a:	37fd                	addiw	a5,a5,-1
    8000495c:	0007871b          	sext.w	a4,a5
    80004960:	c0dc                	sw	a5,4(s1)
    80004962:	06e04363          	bgtz	a4,800049c8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004966:	0004a903          	lw	s2,0(s1)
    8000496a:	0094ca83          	lbu	s5,9(s1)
    8000496e:	0104ba03          	ld	s4,16(s1)
    80004972:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004976:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000497a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000497e:	0001d517          	auipc	a0,0x1d
    80004982:	4fa50513          	addi	a0,a0,1274 # 80021e78 <ftable>
    80004986:	ffffc097          	auipc	ra,0xffffc
    8000498a:	304080e7          	jalr	772(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    8000498e:	4785                	li	a5,1
    80004990:	04f90d63          	beq	s2,a5,800049ea <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004994:	3979                	addiw	s2,s2,-2
    80004996:	4785                	li	a5,1
    80004998:	0527e063          	bltu	a5,s2,800049d8 <fileclose+0xa8>
    begin_op();
    8000499c:	00000097          	auipc	ra,0x0
    800049a0:	ac8080e7          	jalr	-1336(ra) # 80004464 <begin_op>
    iput(ff.ip);
    800049a4:	854e                	mv	a0,s3
    800049a6:	fffff097          	auipc	ra,0xfffff
    800049aa:	2b6080e7          	jalr	694(ra) # 80003c5c <iput>
    end_op();
    800049ae:	00000097          	auipc	ra,0x0
    800049b2:	b36080e7          	jalr	-1226(ra) # 800044e4 <end_op>
    800049b6:	a00d                	j	800049d8 <fileclose+0xa8>
    panic("fileclose");
    800049b8:	00004517          	auipc	a0,0x4
    800049bc:	d0050513          	addi	a0,a0,-768 # 800086b8 <syscalls+0x268>
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	b7e080e7          	jalr	-1154(ra) # 8000053e <panic>
    release(&ftable.lock);
    800049c8:	0001d517          	auipc	a0,0x1d
    800049cc:	4b050513          	addi	a0,a0,1200 # 80021e78 <ftable>
    800049d0:	ffffc097          	auipc	ra,0xffffc
    800049d4:	2ba080e7          	jalr	698(ra) # 80000c8a <release>
  }
}
    800049d8:	70e2                	ld	ra,56(sp)
    800049da:	7442                	ld	s0,48(sp)
    800049dc:	74a2                	ld	s1,40(sp)
    800049de:	7902                	ld	s2,32(sp)
    800049e0:	69e2                	ld	s3,24(sp)
    800049e2:	6a42                	ld	s4,16(sp)
    800049e4:	6aa2                	ld	s5,8(sp)
    800049e6:	6121                	addi	sp,sp,64
    800049e8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800049ea:	85d6                	mv	a1,s5
    800049ec:	8552                	mv	a0,s4
    800049ee:	00000097          	auipc	ra,0x0
    800049f2:	34c080e7          	jalr	844(ra) # 80004d3a <pipeclose>
    800049f6:	b7cd                	j	800049d8 <fileclose+0xa8>

00000000800049f8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800049f8:	715d                	addi	sp,sp,-80
    800049fa:	e486                	sd	ra,72(sp)
    800049fc:	e0a2                	sd	s0,64(sp)
    800049fe:	fc26                	sd	s1,56(sp)
    80004a00:	f84a                	sd	s2,48(sp)
    80004a02:	f44e                	sd	s3,40(sp)
    80004a04:	0880                	addi	s0,sp,80
    80004a06:	84aa                	mv	s1,a0
    80004a08:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a0a:	ffffd097          	auipc	ra,0xffffd
    80004a0e:	fa2080e7          	jalr	-94(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a12:	409c                	lw	a5,0(s1)
    80004a14:	37f9                	addiw	a5,a5,-2
    80004a16:	4705                	li	a4,1
    80004a18:	04f76763          	bltu	a4,a5,80004a66 <filestat+0x6e>
    80004a1c:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a1e:	6c88                	ld	a0,24(s1)
    80004a20:	fffff097          	auipc	ra,0xfffff
    80004a24:	082080e7          	jalr	130(ra) # 80003aa2 <ilock>
    stati(f->ip, &st);
    80004a28:	fb840593          	addi	a1,s0,-72
    80004a2c:	6c88                	ld	a0,24(s1)
    80004a2e:	fffff097          	auipc	ra,0xfffff
    80004a32:	2fe080e7          	jalr	766(ra) # 80003d2c <stati>
    iunlock(f->ip);
    80004a36:	6c88                	ld	a0,24(s1)
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	12c080e7          	jalr	300(ra) # 80003b64 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a40:	46e1                	li	a3,24
    80004a42:	fb840613          	addi	a2,s0,-72
    80004a46:	85ce                	mv	a1,s3
    80004a48:	08893503          	ld	a0,136(s2)
    80004a4c:	ffffd097          	auipc	ra,0xffffd
    80004a50:	c1c080e7          	jalr	-996(ra) # 80001668 <copyout>
    80004a54:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a58:	60a6                	ld	ra,72(sp)
    80004a5a:	6406                	ld	s0,64(sp)
    80004a5c:	74e2                	ld	s1,56(sp)
    80004a5e:	7942                	ld	s2,48(sp)
    80004a60:	79a2                	ld	s3,40(sp)
    80004a62:	6161                	addi	sp,sp,80
    80004a64:	8082                	ret
  return -1;
    80004a66:	557d                	li	a0,-1
    80004a68:	bfc5                	j	80004a58 <filestat+0x60>

0000000080004a6a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a6a:	7179                	addi	sp,sp,-48
    80004a6c:	f406                	sd	ra,40(sp)
    80004a6e:	f022                	sd	s0,32(sp)
    80004a70:	ec26                	sd	s1,24(sp)
    80004a72:	e84a                	sd	s2,16(sp)
    80004a74:	e44e                	sd	s3,8(sp)
    80004a76:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a78:	00854783          	lbu	a5,8(a0)
    80004a7c:	c3d5                	beqz	a5,80004b20 <fileread+0xb6>
    80004a7e:	84aa                	mv	s1,a0
    80004a80:	89ae                	mv	s3,a1
    80004a82:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a84:	411c                	lw	a5,0(a0)
    80004a86:	4705                	li	a4,1
    80004a88:	04e78963          	beq	a5,a4,80004ada <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a8c:	470d                	li	a4,3
    80004a8e:	04e78d63          	beq	a5,a4,80004ae8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a92:	4709                	li	a4,2
    80004a94:	06e79e63          	bne	a5,a4,80004b10 <fileread+0xa6>
    ilock(f->ip);
    80004a98:	6d08                	ld	a0,24(a0)
    80004a9a:	fffff097          	auipc	ra,0xfffff
    80004a9e:	008080e7          	jalr	8(ra) # 80003aa2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004aa2:	874a                	mv	a4,s2
    80004aa4:	5094                	lw	a3,32(s1)
    80004aa6:	864e                	mv	a2,s3
    80004aa8:	4585                	li	a1,1
    80004aaa:	6c88                	ld	a0,24(s1)
    80004aac:	fffff097          	auipc	ra,0xfffff
    80004ab0:	2aa080e7          	jalr	682(ra) # 80003d56 <readi>
    80004ab4:	892a                	mv	s2,a0
    80004ab6:	00a05563          	blez	a0,80004ac0 <fileread+0x56>
      f->off += r;
    80004aba:	509c                	lw	a5,32(s1)
    80004abc:	9fa9                	addw	a5,a5,a0
    80004abe:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ac0:	6c88                	ld	a0,24(s1)
    80004ac2:	fffff097          	auipc	ra,0xfffff
    80004ac6:	0a2080e7          	jalr	162(ra) # 80003b64 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004aca:	854a                	mv	a0,s2
    80004acc:	70a2                	ld	ra,40(sp)
    80004ace:	7402                	ld	s0,32(sp)
    80004ad0:	64e2                	ld	s1,24(sp)
    80004ad2:	6942                	ld	s2,16(sp)
    80004ad4:	69a2                	ld	s3,8(sp)
    80004ad6:	6145                	addi	sp,sp,48
    80004ad8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ada:	6908                	ld	a0,16(a0)
    80004adc:	00000097          	auipc	ra,0x0
    80004ae0:	3c6080e7          	jalr	966(ra) # 80004ea2 <piperead>
    80004ae4:	892a                	mv	s2,a0
    80004ae6:	b7d5                	j	80004aca <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004ae8:	02451783          	lh	a5,36(a0)
    80004aec:	03079693          	slli	a3,a5,0x30
    80004af0:	92c1                	srli	a3,a3,0x30
    80004af2:	4725                	li	a4,9
    80004af4:	02d76863          	bltu	a4,a3,80004b24 <fileread+0xba>
    80004af8:	0792                	slli	a5,a5,0x4
    80004afa:	0001d717          	auipc	a4,0x1d
    80004afe:	2de70713          	addi	a4,a4,734 # 80021dd8 <devsw>
    80004b02:	97ba                	add	a5,a5,a4
    80004b04:	639c                	ld	a5,0(a5)
    80004b06:	c38d                	beqz	a5,80004b28 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b08:	4505                	li	a0,1
    80004b0a:	9782                	jalr	a5
    80004b0c:	892a                	mv	s2,a0
    80004b0e:	bf75                	j	80004aca <fileread+0x60>
    panic("fileread");
    80004b10:	00004517          	auipc	a0,0x4
    80004b14:	bb850513          	addi	a0,a0,-1096 # 800086c8 <syscalls+0x278>
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	a26080e7          	jalr	-1498(ra) # 8000053e <panic>
    return -1;
    80004b20:	597d                	li	s2,-1
    80004b22:	b765                	j	80004aca <fileread+0x60>
      return -1;
    80004b24:	597d                	li	s2,-1
    80004b26:	b755                	j	80004aca <fileread+0x60>
    80004b28:	597d                	li	s2,-1
    80004b2a:	b745                	j	80004aca <fileread+0x60>

0000000080004b2c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b2c:	715d                	addi	sp,sp,-80
    80004b2e:	e486                	sd	ra,72(sp)
    80004b30:	e0a2                	sd	s0,64(sp)
    80004b32:	fc26                	sd	s1,56(sp)
    80004b34:	f84a                	sd	s2,48(sp)
    80004b36:	f44e                	sd	s3,40(sp)
    80004b38:	f052                	sd	s4,32(sp)
    80004b3a:	ec56                	sd	s5,24(sp)
    80004b3c:	e85a                	sd	s6,16(sp)
    80004b3e:	e45e                	sd	s7,8(sp)
    80004b40:	e062                	sd	s8,0(sp)
    80004b42:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b44:	00954783          	lbu	a5,9(a0)
    80004b48:	10078663          	beqz	a5,80004c54 <filewrite+0x128>
    80004b4c:	892a                	mv	s2,a0
    80004b4e:	8aae                	mv	s5,a1
    80004b50:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b52:	411c                	lw	a5,0(a0)
    80004b54:	4705                	li	a4,1
    80004b56:	02e78263          	beq	a5,a4,80004b7a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b5a:	470d                	li	a4,3
    80004b5c:	02e78663          	beq	a5,a4,80004b88 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b60:	4709                	li	a4,2
    80004b62:	0ee79163          	bne	a5,a4,80004c44 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b66:	0ac05d63          	blez	a2,80004c20 <filewrite+0xf4>
    int i = 0;
    80004b6a:	4981                	li	s3,0
    80004b6c:	6b05                	lui	s6,0x1
    80004b6e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004b72:	6b85                	lui	s7,0x1
    80004b74:	c00b8b9b          	addiw	s7,s7,-1024
    80004b78:	a861                	j	80004c10 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004b7a:	6908                	ld	a0,16(a0)
    80004b7c:	00000097          	auipc	ra,0x0
    80004b80:	22e080e7          	jalr	558(ra) # 80004daa <pipewrite>
    80004b84:	8a2a                	mv	s4,a0
    80004b86:	a045                	j	80004c26 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b88:	02451783          	lh	a5,36(a0)
    80004b8c:	03079693          	slli	a3,a5,0x30
    80004b90:	92c1                	srli	a3,a3,0x30
    80004b92:	4725                	li	a4,9
    80004b94:	0cd76263          	bltu	a4,a3,80004c58 <filewrite+0x12c>
    80004b98:	0792                	slli	a5,a5,0x4
    80004b9a:	0001d717          	auipc	a4,0x1d
    80004b9e:	23e70713          	addi	a4,a4,574 # 80021dd8 <devsw>
    80004ba2:	97ba                	add	a5,a5,a4
    80004ba4:	679c                	ld	a5,8(a5)
    80004ba6:	cbdd                	beqz	a5,80004c5c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ba8:	4505                	li	a0,1
    80004baa:	9782                	jalr	a5
    80004bac:	8a2a                	mv	s4,a0
    80004bae:	a8a5                	j	80004c26 <filewrite+0xfa>
    80004bb0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004bb4:	00000097          	auipc	ra,0x0
    80004bb8:	8b0080e7          	jalr	-1872(ra) # 80004464 <begin_op>
      ilock(f->ip);
    80004bbc:	01893503          	ld	a0,24(s2)
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	ee2080e7          	jalr	-286(ra) # 80003aa2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004bc8:	8762                	mv	a4,s8
    80004bca:	02092683          	lw	a3,32(s2)
    80004bce:	01598633          	add	a2,s3,s5
    80004bd2:	4585                	li	a1,1
    80004bd4:	01893503          	ld	a0,24(s2)
    80004bd8:	fffff097          	auipc	ra,0xfffff
    80004bdc:	276080e7          	jalr	630(ra) # 80003e4e <writei>
    80004be0:	84aa                	mv	s1,a0
    80004be2:	00a05763          	blez	a0,80004bf0 <filewrite+0xc4>
        f->off += r;
    80004be6:	02092783          	lw	a5,32(s2)
    80004bea:	9fa9                	addw	a5,a5,a0
    80004bec:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004bf0:	01893503          	ld	a0,24(s2)
    80004bf4:	fffff097          	auipc	ra,0xfffff
    80004bf8:	f70080e7          	jalr	-144(ra) # 80003b64 <iunlock>
      end_op();
    80004bfc:	00000097          	auipc	ra,0x0
    80004c00:	8e8080e7          	jalr	-1816(ra) # 800044e4 <end_op>

      if(r != n1){
    80004c04:	009c1f63          	bne	s8,s1,80004c22 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c08:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c0c:	0149db63          	bge	s3,s4,80004c22 <filewrite+0xf6>
      int n1 = n - i;
    80004c10:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c14:	84be                	mv	s1,a5
    80004c16:	2781                	sext.w	a5,a5
    80004c18:	f8fb5ce3          	bge	s6,a5,80004bb0 <filewrite+0x84>
    80004c1c:	84de                	mv	s1,s7
    80004c1e:	bf49                	j	80004bb0 <filewrite+0x84>
    int i = 0;
    80004c20:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c22:	013a1f63          	bne	s4,s3,80004c40 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c26:	8552                	mv	a0,s4
    80004c28:	60a6                	ld	ra,72(sp)
    80004c2a:	6406                	ld	s0,64(sp)
    80004c2c:	74e2                	ld	s1,56(sp)
    80004c2e:	7942                	ld	s2,48(sp)
    80004c30:	79a2                	ld	s3,40(sp)
    80004c32:	7a02                	ld	s4,32(sp)
    80004c34:	6ae2                	ld	s5,24(sp)
    80004c36:	6b42                	ld	s6,16(sp)
    80004c38:	6ba2                	ld	s7,8(sp)
    80004c3a:	6c02                	ld	s8,0(sp)
    80004c3c:	6161                	addi	sp,sp,80
    80004c3e:	8082                	ret
    ret = (i == n ? n : -1);
    80004c40:	5a7d                	li	s4,-1
    80004c42:	b7d5                	j	80004c26 <filewrite+0xfa>
    panic("filewrite");
    80004c44:	00004517          	auipc	a0,0x4
    80004c48:	a9450513          	addi	a0,a0,-1388 # 800086d8 <syscalls+0x288>
    80004c4c:	ffffc097          	auipc	ra,0xffffc
    80004c50:	8f2080e7          	jalr	-1806(ra) # 8000053e <panic>
    return -1;
    80004c54:	5a7d                	li	s4,-1
    80004c56:	bfc1                	j	80004c26 <filewrite+0xfa>
      return -1;
    80004c58:	5a7d                	li	s4,-1
    80004c5a:	b7f1                	j	80004c26 <filewrite+0xfa>
    80004c5c:	5a7d                	li	s4,-1
    80004c5e:	b7e1                	j	80004c26 <filewrite+0xfa>

0000000080004c60 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c60:	7179                	addi	sp,sp,-48
    80004c62:	f406                	sd	ra,40(sp)
    80004c64:	f022                	sd	s0,32(sp)
    80004c66:	ec26                	sd	s1,24(sp)
    80004c68:	e84a                	sd	s2,16(sp)
    80004c6a:	e44e                	sd	s3,8(sp)
    80004c6c:	e052                	sd	s4,0(sp)
    80004c6e:	1800                	addi	s0,sp,48
    80004c70:	84aa                	mv	s1,a0
    80004c72:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c74:	0005b023          	sd	zero,0(a1)
    80004c78:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c7c:	00000097          	auipc	ra,0x0
    80004c80:	bf8080e7          	jalr	-1032(ra) # 80004874 <filealloc>
    80004c84:	e088                	sd	a0,0(s1)
    80004c86:	c551                	beqz	a0,80004d12 <pipealloc+0xb2>
    80004c88:	00000097          	auipc	ra,0x0
    80004c8c:	bec080e7          	jalr	-1044(ra) # 80004874 <filealloc>
    80004c90:	00aa3023          	sd	a0,0(s4)
    80004c94:	c92d                	beqz	a0,80004d06 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c96:	ffffc097          	auipc	ra,0xffffc
    80004c9a:	e50080e7          	jalr	-432(ra) # 80000ae6 <kalloc>
    80004c9e:	892a                	mv	s2,a0
    80004ca0:	c125                	beqz	a0,80004d00 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ca2:	4985                	li	s3,1
    80004ca4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ca8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004cac:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004cb0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004cb4:	00004597          	auipc	a1,0x4
    80004cb8:	a3458593          	addi	a1,a1,-1484 # 800086e8 <syscalls+0x298>
    80004cbc:	ffffc097          	auipc	ra,0xffffc
    80004cc0:	e8a080e7          	jalr	-374(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004cc4:	609c                	ld	a5,0(s1)
    80004cc6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004cca:	609c                	ld	a5,0(s1)
    80004ccc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004cd0:	609c                	ld	a5,0(s1)
    80004cd2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004cd6:	609c                	ld	a5,0(s1)
    80004cd8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004cdc:	000a3783          	ld	a5,0(s4)
    80004ce0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ce4:	000a3783          	ld	a5,0(s4)
    80004ce8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004cec:	000a3783          	ld	a5,0(s4)
    80004cf0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004cf4:	000a3783          	ld	a5,0(s4)
    80004cf8:	0127b823          	sd	s2,16(a5)
  return 0;
    80004cfc:	4501                	li	a0,0
    80004cfe:	a025                	j	80004d26 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d00:	6088                	ld	a0,0(s1)
    80004d02:	e501                	bnez	a0,80004d0a <pipealloc+0xaa>
    80004d04:	a039                	j	80004d12 <pipealloc+0xb2>
    80004d06:	6088                	ld	a0,0(s1)
    80004d08:	c51d                	beqz	a0,80004d36 <pipealloc+0xd6>
    fileclose(*f0);
    80004d0a:	00000097          	auipc	ra,0x0
    80004d0e:	c26080e7          	jalr	-986(ra) # 80004930 <fileclose>
  if(*f1)
    80004d12:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d16:	557d                	li	a0,-1
  if(*f1)
    80004d18:	c799                	beqz	a5,80004d26 <pipealloc+0xc6>
    fileclose(*f1);
    80004d1a:	853e                	mv	a0,a5
    80004d1c:	00000097          	auipc	ra,0x0
    80004d20:	c14080e7          	jalr	-1004(ra) # 80004930 <fileclose>
  return -1;
    80004d24:	557d                	li	a0,-1
}
    80004d26:	70a2                	ld	ra,40(sp)
    80004d28:	7402                	ld	s0,32(sp)
    80004d2a:	64e2                	ld	s1,24(sp)
    80004d2c:	6942                	ld	s2,16(sp)
    80004d2e:	69a2                	ld	s3,8(sp)
    80004d30:	6a02                	ld	s4,0(sp)
    80004d32:	6145                	addi	sp,sp,48
    80004d34:	8082                	ret
  return -1;
    80004d36:	557d                	li	a0,-1
    80004d38:	b7fd                	j	80004d26 <pipealloc+0xc6>

0000000080004d3a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d3a:	1101                	addi	sp,sp,-32
    80004d3c:	ec06                	sd	ra,24(sp)
    80004d3e:	e822                	sd	s0,16(sp)
    80004d40:	e426                	sd	s1,8(sp)
    80004d42:	e04a                	sd	s2,0(sp)
    80004d44:	1000                	addi	s0,sp,32
    80004d46:	84aa                	mv	s1,a0
    80004d48:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d4a:	ffffc097          	auipc	ra,0xffffc
    80004d4e:	e8c080e7          	jalr	-372(ra) # 80000bd6 <acquire>
  if(writable){
    80004d52:	02090d63          	beqz	s2,80004d8c <pipeclose+0x52>
    pi->writeopen = 0;
    80004d56:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d5a:	21848513          	addi	a0,s1,536
    80004d5e:	ffffd097          	auipc	ra,0xffffd
    80004d62:	3b8080e7          	jalr	952(ra) # 80002116 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d66:	2204b783          	ld	a5,544(s1)
    80004d6a:	eb95                	bnez	a5,80004d9e <pipeclose+0x64>
    release(&pi->lock);
    80004d6c:	8526                	mv	a0,s1
    80004d6e:	ffffc097          	auipc	ra,0xffffc
    80004d72:	f1c080e7          	jalr	-228(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004d76:	8526                	mv	a0,s1
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	c72080e7          	jalr	-910(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004d80:	60e2                	ld	ra,24(sp)
    80004d82:	6442                	ld	s0,16(sp)
    80004d84:	64a2                	ld	s1,8(sp)
    80004d86:	6902                	ld	s2,0(sp)
    80004d88:	6105                	addi	sp,sp,32
    80004d8a:	8082                	ret
    pi->readopen = 0;
    80004d8c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d90:	21c48513          	addi	a0,s1,540
    80004d94:	ffffd097          	auipc	ra,0xffffd
    80004d98:	382080e7          	jalr	898(ra) # 80002116 <wakeup>
    80004d9c:	b7e9                	j	80004d66 <pipeclose+0x2c>
    release(&pi->lock);
    80004d9e:	8526                	mv	a0,s1
    80004da0:	ffffc097          	auipc	ra,0xffffc
    80004da4:	eea080e7          	jalr	-278(ra) # 80000c8a <release>
}
    80004da8:	bfe1                	j	80004d80 <pipeclose+0x46>

0000000080004daa <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004daa:	711d                	addi	sp,sp,-96
    80004dac:	ec86                	sd	ra,88(sp)
    80004dae:	e8a2                	sd	s0,80(sp)
    80004db0:	e4a6                	sd	s1,72(sp)
    80004db2:	e0ca                	sd	s2,64(sp)
    80004db4:	fc4e                	sd	s3,56(sp)
    80004db6:	f852                	sd	s4,48(sp)
    80004db8:	f456                	sd	s5,40(sp)
    80004dba:	f05a                	sd	s6,32(sp)
    80004dbc:	ec5e                	sd	s7,24(sp)
    80004dbe:	e862                	sd	s8,16(sp)
    80004dc0:	1080                	addi	s0,sp,96
    80004dc2:	84aa                	mv	s1,a0
    80004dc4:	8aae                	mv	s5,a1
    80004dc6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004dc8:	ffffd097          	auipc	ra,0xffffd
    80004dcc:	be4080e7          	jalr	-1052(ra) # 800019ac <myproc>
    80004dd0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004dd2:	8526                	mv	a0,s1
    80004dd4:	ffffc097          	auipc	ra,0xffffc
    80004dd8:	e02080e7          	jalr	-510(ra) # 80000bd6 <acquire>
  while(i < n){
    80004ddc:	0b405663          	blez	s4,80004e88 <pipewrite+0xde>
  int i = 0;
    80004de0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004de2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004de4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004de8:	21c48b93          	addi	s7,s1,540
    80004dec:	a089                	j	80004e2e <pipewrite+0x84>
      release(&pi->lock);
    80004dee:	8526                	mv	a0,s1
    80004df0:	ffffc097          	auipc	ra,0xffffc
    80004df4:	e9a080e7          	jalr	-358(ra) # 80000c8a <release>
      return -1;
    80004df8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004dfa:	854a                	mv	a0,s2
    80004dfc:	60e6                	ld	ra,88(sp)
    80004dfe:	6446                	ld	s0,80(sp)
    80004e00:	64a6                	ld	s1,72(sp)
    80004e02:	6906                	ld	s2,64(sp)
    80004e04:	79e2                	ld	s3,56(sp)
    80004e06:	7a42                	ld	s4,48(sp)
    80004e08:	7aa2                	ld	s5,40(sp)
    80004e0a:	7b02                	ld	s6,32(sp)
    80004e0c:	6be2                	ld	s7,24(sp)
    80004e0e:	6c42                	ld	s8,16(sp)
    80004e10:	6125                	addi	sp,sp,96
    80004e12:	8082                	ret
      wakeup(&pi->nread);
    80004e14:	8562                	mv	a0,s8
    80004e16:	ffffd097          	auipc	ra,0xffffd
    80004e1a:	300080e7          	jalr	768(ra) # 80002116 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e1e:	85a6                	mv	a1,s1
    80004e20:	855e                	mv	a0,s7
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	290080e7          	jalr	656(ra) # 800020b2 <sleep>
  while(i < n){
    80004e2a:	07495063          	bge	s2,s4,80004e8a <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004e2e:	2204a783          	lw	a5,544(s1)
    80004e32:	dfd5                	beqz	a5,80004dee <pipewrite+0x44>
    80004e34:	854e                	mv	a0,s3
    80004e36:	ffffd097          	auipc	ra,0xffffd
    80004e3a:	530080e7          	jalr	1328(ra) # 80002366 <killed>
    80004e3e:	f945                	bnez	a0,80004dee <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e40:	2184a783          	lw	a5,536(s1)
    80004e44:	21c4a703          	lw	a4,540(s1)
    80004e48:	2007879b          	addiw	a5,a5,512
    80004e4c:	fcf704e3          	beq	a4,a5,80004e14 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e50:	4685                	li	a3,1
    80004e52:	01590633          	add	a2,s2,s5
    80004e56:	faf40593          	addi	a1,s0,-81
    80004e5a:	0889b503          	ld	a0,136(s3)
    80004e5e:	ffffd097          	auipc	ra,0xffffd
    80004e62:	896080e7          	jalr	-1898(ra) # 800016f4 <copyin>
    80004e66:	03650263          	beq	a0,s6,80004e8a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e6a:	21c4a783          	lw	a5,540(s1)
    80004e6e:	0017871b          	addiw	a4,a5,1
    80004e72:	20e4ae23          	sw	a4,540(s1)
    80004e76:	1ff7f793          	andi	a5,a5,511
    80004e7a:	97a6                	add	a5,a5,s1
    80004e7c:	faf44703          	lbu	a4,-81(s0)
    80004e80:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e84:	2905                	addiw	s2,s2,1
    80004e86:	b755                	j	80004e2a <pipewrite+0x80>
  int i = 0;
    80004e88:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004e8a:	21848513          	addi	a0,s1,536
    80004e8e:	ffffd097          	auipc	ra,0xffffd
    80004e92:	288080e7          	jalr	648(ra) # 80002116 <wakeup>
  release(&pi->lock);
    80004e96:	8526                	mv	a0,s1
    80004e98:	ffffc097          	auipc	ra,0xffffc
    80004e9c:	df2080e7          	jalr	-526(ra) # 80000c8a <release>
  return i;
    80004ea0:	bfa9                	j	80004dfa <pipewrite+0x50>

0000000080004ea2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ea2:	715d                	addi	sp,sp,-80
    80004ea4:	e486                	sd	ra,72(sp)
    80004ea6:	e0a2                	sd	s0,64(sp)
    80004ea8:	fc26                	sd	s1,56(sp)
    80004eaa:	f84a                	sd	s2,48(sp)
    80004eac:	f44e                	sd	s3,40(sp)
    80004eae:	f052                	sd	s4,32(sp)
    80004eb0:	ec56                	sd	s5,24(sp)
    80004eb2:	e85a                	sd	s6,16(sp)
    80004eb4:	0880                	addi	s0,sp,80
    80004eb6:	84aa                	mv	s1,a0
    80004eb8:	892e                	mv	s2,a1
    80004eba:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ebc:	ffffd097          	auipc	ra,0xffffd
    80004ec0:	af0080e7          	jalr	-1296(ra) # 800019ac <myproc>
    80004ec4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	ffffc097          	auipc	ra,0xffffc
    80004ecc:	d0e080e7          	jalr	-754(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ed0:	2184a703          	lw	a4,536(s1)
    80004ed4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ed8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004edc:	02f71763          	bne	a4,a5,80004f0a <piperead+0x68>
    80004ee0:	2244a783          	lw	a5,548(s1)
    80004ee4:	c39d                	beqz	a5,80004f0a <piperead+0x68>
    if(killed(pr)){
    80004ee6:	8552                	mv	a0,s4
    80004ee8:	ffffd097          	auipc	ra,0xffffd
    80004eec:	47e080e7          	jalr	1150(ra) # 80002366 <killed>
    80004ef0:	e941                	bnez	a0,80004f80 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ef2:	85a6                	mv	a1,s1
    80004ef4:	854e                	mv	a0,s3
    80004ef6:	ffffd097          	auipc	ra,0xffffd
    80004efa:	1bc080e7          	jalr	444(ra) # 800020b2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004efe:	2184a703          	lw	a4,536(s1)
    80004f02:	21c4a783          	lw	a5,540(s1)
    80004f06:	fcf70de3          	beq	a4,a5,80004ee0 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f0a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f0c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f0e:	05505363          	blez	s5,80004f54 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004f12:	2184a783          	lw	a5,536(s1)
    80004f16:	21c4a703          	lw	a4,540(s1)
    80004f1a:	02f70d63          	beq	a4,a5,80004f54 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f1e:	0017871b          	addiw	a4,a5,1
    80004f22:	20e4ac23          	sw	a4,536(s1)
    80004f26:	1ff7f793          	andi	a5,a5,511
    80004f2a:	97a6                	add	a5,a5,s1
    80004f2c:	0187c783          	lbu	a5,24(a5)
    80004f30:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f34:	4685                	li	a3,1
    80004f36:	fbf40613          	addi	a2,s0,-65
    80004f3a:	85ca                	mv	a1,s2
    80004f3c:	088a3503          	ld	a0,136(s4)
    80004f40:	ffffc097          	auipc	ra,0xffffc
    80004f44:	728080e7          	jalr	1832(ra) # 80001668 <copyout>
    80004f48:	01650663          	beq	a0,s6,80004f54 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f4c:	2985                	addiw	s3,s3,1
    80004f4e:	0905                	addi	s2,s2,1
    80004f50:	fd3a91e3          	bne	s5,s3,80004f12 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f54:	21c48513          	addi	a0,s1,540
    80004f58:	ffffd097          	auipc	ra,0xffffd
    80004f5c:	1be080e7          	jalr	446(ra) # 80002116 <wakeup>
  release(&pi->lock);
    80004f60:	8526                	mv	a0,s1
    80004f62:	ffffc097          	auipc	ra,0xffffc
    80004f66:	d28080e7          	jalr	-728(ra) # 80000c8a <release>
  return i;
}
    80004f6a:	854e                	mv	a0,s3
    80004f6c:	60a6                	ld	ra,72(sp)
    80004f6e:	6406                	ld	s0,64(sp)
    80004f70:	74e2                	ld	s1,56(sp)
    80004f72:	7942                	ld	s2,48(sp)
    80004f74:	79a2                	ld	s3,40(sp)
    80004f76:	7a02                	ld	s4,32(sp)
    80004f78:	6ae2                	ld	s5,24(sp)
    80004f7a:	6b42                	ld	s6,16(sp)
    80004f7c:	6161                	addi	sp,sp,80
    80004f7e:	8082                	ret
      release(&pi->lock);
    80004f80:	8526                	mv	a0,s1
    80004f82:	ffffc097          	auipc	ra,0xffffc
    80004f86:	d08080e7          	jalr	-760(ra) # 80000c8a <release>
      return -1;
    80004f8a:	59fd                	li	s3,-1
    80004f8c:	bff9                	j	80004f6a <piperead+0xc8>

0000000080004f8e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004f8e:	1141                	addi	sp,sp,-16
    80004f90:	e422                	sd	s0,8(sp)
    80004f92:	0800                	addi	s0,sp,16
    80004f94:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004f96:	8905                	andi	a0,a0,1
    80004f98:	c111                	beqz	a0,80004f9c <flags2perm+0xe>
      perm = PTE_X;
    80004f9a:	4521                	li	a0,8
    if(flags & 0x2)
    80004f9c:	8b89                	andi	a5,a5,2
    80004f9e:	c399                	beqz	a5,80004fa4 <flags2perm+0x16>
      perm |= PTE_W;
    80004fa0:	00456513          	ori	a0,a0,4
    return perm;
}
    80004fa4:	6422                	ld	s0,8(sp)
    80004fa6:	0141                	addi	sp,sp,16
    80004fa8:	8082                	ret

0000000080004faa <exec>:

int
exec(char *path, char **argv)
{
    80004faa:	de010113          	addi	sp,sp,-544
    80004fae:	20113c23          	sd	ra,536(sp)
    80004fb2:	20813823          	sd	s0,528(sp)
    80004fb6:	20913423          	sd	s1,520(sp)
    80004fba:	21213023          	sd	s2,512(sp)
    80004fbe:	ffce                	sd	s3,504(sp)
    80004fc0:	fbd2                	sd	s4,496(sp)
    80004fc2:	f7d6                	sd	s5,488(sp)
    80004fc4:	f3da                	sd	s6,480(sp)
    80004fc6:	efde                	sd	s7,472(sp)
    80004fc8:	ebe2                	sd	s8,464(sp)
    80004fca:	e7e6                	sd	s9,456(sp)
    80004fcc:	e3ea                	sd	s10,448(sp)
    80004fce:	ff6e                	sd	s11,440(sp)
    80004fd0:	1400                	addi	s0,sp,544
    80004fd2:	892a                	mv	s2,a0
    80004fd4:	dea43423          	sd	a0,-536(s0)
    80004fd8:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004fdc:	ffffd097          	auipc	ra,0xffffd
    80004fe0:	9d0080e7          	jalr	-1584(ra) # 800019ac <myproc>
    80004fe4:	84aa                	mv	s1,a0

  begin_op();
    80004fe6:	fffff097          	auipc	ra,0xfffff
    80004fea:	47e080e7          	jalr	1150(ra) # 80004464 <begin_op>

  if((ip = namei(path)) == 0){
    80004fee:	854a                	mv	a0,s2
    80004ff0:	fffff097          	auipc	ra,0xfffff
    80004ff4:	258080e7          	jalr	600(ra) # 80004248 <namei>
    80004ff8:	c93d                	beqz	a0,8000506e <exec+0xc4>
    80004ffa:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ffc:	fffff097          	auipc	ra,0xfffff
    80005000:	aa6080e7          	jalr	-1370(ra) # 80003aa2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005004:	04000713          	li	a4,64
    80005008:	4681                	li	a3,0
    8000500a:	e5040613          	addi	a2,s0,-432
    8000500e:	4581                	li	a1,0
    80005010:	8556                	mv	a0,s5
    80005012:	fffff097          	auipc	ra,0xfffff
    80005016:	d44080e7          	jalr	-700(ra) # 80003d56 <readi>
    8000501a:	04000793          	li	a5,64
    8000501e:	00f51a63          	bne	a0,a5,80005032 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005022:	e5042703          	lw	a4,-432(s0)
    80005026:	464c47b7          	lui	a5,0x464c4
    8000502a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000502e:	04f70663          	beq	a4,a5,8000507a <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005032:	8556                	mv	a0,s5
    80005034:	fffff097          	auipc	ra,0xfffff
    80005038:	cd0080e7          	jalr	-816(ra) # 80003d04 <iunlockput>
    end_op();
    8000503c:	fffff097          	auipc	ra,0xfffff
    80005040:	4a8080e7          	jalr	1192(ra) # 800044e4 <end_op>
  }
  return -1;
    80005044:	557d                	li	a0,-1
}
    80005046:	21813083          	ld	ra,536(sp)
    8000504a:	21013403          	ld	s0,528(sp)
    8000504e:	20813483          	ld	s1,520(sp)
    80005052:	20013903          	ld	s2,512(sp)
    80005056:	79fe                	ld	s3,504(sp)
    80005058:	7a5e                	ld	s4,496(sp)
    8000505a:	7abe                	ld	s5,488(sp)
    8000505c:	7b1e                	ld	s6,480(sp)
    8000505e:	6bfe                	ld	s7,472(sp)
    80005060:	6c5e                	ld	s8,464(sp)
    80005062:	6cbe                	ld	s9,456(sp)
    80005064:	6d1e                	ld	s10,448(sp)
    80005066:	7dfa                	ld	s11,440(sp)
    80005068:	22010113          	addi	sp,sp,544
    8000506c:	8082                	ret
    end_op();
    8000506e:	fffff097          	auipc	ra,0xfffff
    80005072:	476080e7          	jalr	1142(ra) # 800044e4 <end_op>
    return -1;
    80005076:	557d                	li	a0,-1
    80005078:	b7f9                	j	80005046 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000507a:	8526                	mv	a0,s1
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	9f4080e7          	jalr	-1548(ra) # 80001a70 <proc_pagetable>
    80005084:	8b2a                	mv	s6,a0
    80005086:	d555                	beqz	a0,80005032 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005088:	e7042783          	lw	a5,-400(s0)
    8000508c:	e8845703          	lhu	a4,-376(s0)
    80005090:	c735                	beqz	a4,800050fc <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005092:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005094:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005098:	6a05                	lui	s4,0x1
    8000509a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000509e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800050a2:	6d85                	lui	s11,0x1
    800050a4:	7d7d                	lui	s10,0xfffff
    800050a6:	a481                	j	800052e6 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800050a8:	00003517          	auipc	a0,0x3
    800050ac:	64850513          	addi	a0,a0,1608 # 800086f0 <syscalls+0x2a0>
    800050b0:	ffffb097          	auipc	ra,0xffffb
    800050b4:	48e080e7          	jalr	1166(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050b8:	874a                	mv	a4,s2
    800050ba:	009c86bb          	addw	a3,s9,s1
    800050be:	4581                	li	a1,0
    800050c0:	8556                	mv	a0,s5
    800050c2:	fffff097          	auipc	ra,0xfffff
    800050c6:	c94080e7          	jalr	-876(ra) # 80003d56 <readi>
    800050ca:	2501                	sext.w	a0,a0
    800050cc:	1aa91a63          	bne	s2,a0,80005280 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    800050d0:	009d84bb          	addw	s1,s11,s1
    800050d4:	013d09bb          	addw	s3,s10,s3
    800050d8:	1f74f763          	bgeu	s1,s7,800052c6 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    800050dc:	02049593          	slli	a1,s1,0x20
    800050e0:	9181                	srli	a1,a1,0x20
    800050e2:	95e2                	add	a1,a1,s8
    800050e4:	855a                	mv	a0,s6
    800050e6:	ffffc097          	auipc	ra,0xffffc
    800050ea:	f76080e7          	jalr	-138(ra) # 8000105c <walkaddr>
    800050ee:	862a                	mv	a2,a0
    if(pa == 0)
    800050f0:	dd45                	beqz	a0,800050a8 <exec+0xfe>
      n = PGSIZE;
    800050f2:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800050f4:	fd49f2e3          	bgeu	s3,s4,800050b8 <exec+0x10e>
      n = sz - i;
    800050f8:	894e                	mv	s2,s3
    800050fa:	bf7d                	j	800050b8 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050fc:	4901                	li	s2,0
  iunlockput(ip);
    800050fe:	8556                	mv	a0,s5
    80005100:	fffff097          	auipc	ra,0xfffff
    80005104:	c04080e7          	jalr	-1020(ra) # 80003d04 <iunlockput>
  end_op();
    80005108:	fffff097          	auipc	ra,0xfffff
    8000510c:	3dc080e7          	jalr	988(ra) # 800044e4 <end_op>
  p = myproc();
    80005110:	ffffd097          	auipc	ra,0xffffd
    80005114:	89c080e7          	jalr	-1892(ra) # 800019ac <myproc>
    80005118:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000511a:	08053d03          	ld	s10,128(a0)
  sz = PGROUNDUP(sz);
    8000511e:	6785                	lui	a5,0x1
    80005120:	17fd                	addi	a5,a5,-1
    80005122:	993e                	add	s2,s2,a5
    80005124:	77fd                	lui	a5,0xfffff
    80005126:	00f977b3          	and	a5,s2,a5
    8000512a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000512e:	4691                	li	a3,4
    80005130:	6609                	lui	a2,0x2
    80005132:	963e                	add	a2,a2,a5
    80005134:	85be                	mv	a1,a5
    80005136:	855a                	mv	a0,s6
    80005138:	ffffc097          	auipc	ra,0xffffc
    8000513c:	2d8080e7          	jalr	728(ra) # 80001410 <uvmalloc>
    80005140:	8c2a                	mv	s8,a0
  ip = 0;
    80005142:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005144:	12050e63          	beqz	a0,80005280 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005148:	75f9                	lui	a1,0xffffe
    8000514a:	95aa                	add	a1,a1,a0
    8000514c:	855a                	mv	a0,s6
    8000514e:	ffffc097          	auipc	ra,0xffffc
    80005152:	4e8080e7          	jalr	1256(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005156:	7afd                	lui	s5,0xfffff
    80005158:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000515a:	df043783          	ld	a5,-528(s0)
    8000515e:	6388                	ld	a0,0(a5)
    80005160:	c925                	beqz	a0,800051d0 <exec+0x226>
    80005162:	e9040993          	addi	s3,s0,-368
    80005166:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000516a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000516c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000516e:	ffffc097          	auipc	ra,0xffffc
    80005172:	ce0080e7          	jalr	-800(ra) # 80000e4e <strlen>
    80005176:	0015079b          	addiw	a5,a0,1
    8000517a:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000517e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005182:	13596663          	bltu	s2,s5,800052ae <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005186:	df043d83          	ld	s11,-528(s0)
    8000518a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000518e:	8552                	mv	a0,s4
    80005190:	ffffc097          	auipc	ra,0xffffc
    80005194:	cbe080e7          	jalr	-834(ra) # 80000e4e <strlen>
    80005198:	0015069b          	addiw	a3,a0,1
    8000519c:	8652                	mv	a2,s4
    8000519e:	85ca                	mv	a1,s2
    800051a0:	855a                	mv	a0,s6
    800051a2:	ffffc097          	auipc	ra,0xffffc
    800051a6:	4c6080e7          	jalr	1222(ra) # 80001668 <copyout>
    800051aa:	10054663          	bltz	a0,800052b6 <exec+0x30c>
    ustack[argc] = sp;
    800051ae:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051b2:	0485                	addi	s1,s1,1
    800051b4:	008d8793          	addi	a5,s11,8
    800051b8:	def43823          	sd	a5,-528(s0)
    800051bc:	008db503          	ld	a0,8(s11)
    800051c0:	c911                	beqz	a0,800051d4 <exec+0x22a>
    if(argc >= MAXARG)
    800051c2:	09a1                	addi	s3,s3,8
    800051c4:	fb3c95e3          	bne	s9,s3,8000516e <exec+0x1c4>
  sz = sz1;
    800051c8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051cc:	4a81                	li	s5,0
    800051ce:	a84d                	j	80005280 <exec+0x2d6>
  sp = sz;
    800051d0:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800051d2:	4481                	li	s1,0
  ustack[argc] = 0;
    800051d4:	00349793          	slli	a5,s1,0x3
    800051d8:	f9040713          	addi	a4,s0,-112
    800051dc:	97ba                	add	a5,a5,a4
    800051de:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdbf90>
  sp -= (argc+1) * sizeof(uint64);
    800051e2:	00148693          	addi	a3,s1,1
    800051e6:	068e                	slli	a3,a3,0x3
    800051e8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051ec:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800051f0:	01597663          	bgeu	s2,s5,800051fc <exec+0x252>
  sz = sz1;
    800051f4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051f8:	4a81                	li	s5,0
    800051fa:	a059                	j	80005280 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800051fc:	e9040613          	addi	a2,s0,-368
    80005200:	85ca                	mv	a1,s2
    80005202:	855a                	mv	a0,s6
    80005204:	ffffc097          	auipc	ra,0xffffc
    80005208:	464080e7          	jalr	1124(ra) # 80001668 <copyout>
    8000520c:	0a054963          	bltz	a0,800052be <exec+0x314>
  p->trapframe->a1 = sp;
    80005210:	090bb783          	ld	a5,144(s7) # 1090 <_entry-0x7fffef70>
    80005214:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005218:	de843783          	ld	a5,-536(s0)
    8000521c:	0007c703          	lbu	a4,0(a5)
    80005220:	cf11                	beqz	a4,8000523c <exec+0x292>
    80005222:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005224:	02f00693          	li	a3,47
    80005228:	a039                	j	80005236 <exec+0x28c>
      last = s+1;
    8000522a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000522e:	0785                	addi	a5,a5,1
    80005230:	fff7c703          	lbu	a4,-1(a5)
    80005234:	c701                	beqz	a4,8000523c <exec+0x292>
    if(*s == '/')
    80005236:	fed71ce3          	bne	a4,a3,8000522e <exec+0x284>
    8000523a:	bfc5                	j	8000522a <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    8000523c:	4641                	li	a2,16
    8000523e:	de843583          	ld	a1,-536(s0)
    80005242:	190b8513          	addi	a0,s7,400
    80005246:	ffffc097          	auipc	ra,0xffffc
    8000524a:	bd6080e7          	jalr	-1066(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000524e:	088bb503          	ld	a0,136(s7)
  p->pagetable = pagetable;
    80005252:	096bb423          	sd	s6,136(s7)
  p->sz = sz;
    80005256:	098bb023          	sd	s8,128(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000525a:	090bb783          	ld	a5,144(s7)
    8000525e:	e6843703          	ld	a4,-408(s0)
    80005262:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005264:	090bb783          	ld	a5,144(s7)
    80005268:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000526c:	85ea                	mv	a1,s10
    8000526e:	ffffd097          	auipc	ra,0xffffd
    80005272:	89e080e7          	jalr	-1890(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005276:	0004851b          	sext.w	a0,s1
    8000527a:	b3f1                	j	80005046 <exec+0x9c>
    8000527c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005280:	df843583          	ld	a1,-520(s0)
    80005284:	855a                	mv	a0,s6
    80005286:	ffffd097          	auipc	ra,0xffffd
    8000528a:	886080e7          	jalr	-1914(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    8000528e:	da0a92e3          	bnez	s5,80005032 <exec+0x88>
  return -1;
    80005292:	557d                	li	a0,-1
    80005294:	bb4d                	j	80005046 <exec+0x9c>
    80005296:	df243c23          	sd	s2,-520(s0)
    8000529a:	b7dd                	j	80005280 <exec+0x2d6>
    8000529c:	df243c23          	sd	s2,-520(s0)
    800052a0:	b7c5                	j	80005280 <exec+0x2d6>
    800052a2:	df243c23          	sd	s2,-520(s0)
    800052a6:	bfe9                	j	80005280 <exec+0x2d6>
    800052a8:	df243c23          	sd	s2,-520(s0)
    800052ac:	bfd1                	j	80005280 <exec+0x2d6>
  sz = sz1;
    800052ae:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052b2:	4a81                	li	s5,0
    800052b4:	b7f1                	j	80005280 <exec+0x2d6>
  sz = sz1;
    800052b6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052ba:	4a81                	li	s5,0
    800052bc:	b7d1                	j	80005280 <exec+0x2d6>
  sz = sz1;
    800052be:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052c2:	4a81                	li	s5,0
    800052c4:	bf75                	j	80005280 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800052c6:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052ca:	e0843783          	ld	a5,-504(s0)
    800052ce:	0017869b          	addiw	a3,a5,1
    800052d2:	e0d43423          	sd	a3,-504(s0)
    800052d6:	e0043783          	ld	a5,-512(s0)
    800052da:	0387879b          	addiw	a5,a5,56
    800052de:	e8845703          	lhu	a4,-376(s0)
    800052e2:	e0e6dee3          	bge	a3,a4,800050fe <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052e6:	2781                	sext.w	a5,a5
    800052e8:	e0f43023          	sd	a5,-512(s0)
    800052ec:	03800713          	li	a4,56
    800052f0:	86be                	mv	a3,a5
    800052f2:	e1840613          	addi	a2,s0,-488
    800052f6:	4581                	li	a1,0
    800052f8:	8556                	mv	a0,s5
    800052fa:	fffff097          	auipc	ra,0xfffff
    800052fe:	a5c080e7          	jalr	-1444(ra) # 80003d56 <readi>
    80005302:	03800793          	li	a5,56
    80005306:	f6f51be3          	bne	a0,a5,8000527c <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    8000530a:	e1842783          	lw	a5,-488(s0)
    8000530e:	4705                	li	a4,1
    80005310:	fae79de3          	bne	a5,a4,800052ca <exec+0x320>
    if(ph.memsz < ph.filesz)
    80005314:	e4043483          	ld	s1,-448(s0)
    80005318:	e3843783          	ld	a5,-456(s0)
    8000531c:	f6f4ede3          	bltu	s1,a5,80005296 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005320:	e2843783          	ld	a5,-472(s0)
    80005324:	94be                	add	s1,s1,a5
    80005326:	f6f4ebe3          	bltu	s1,a5,8000529c <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    8000532a:	de043703          	ld	a4,-544(s0)
    8000532e:	8ff9                	and	a5,a5,a4
    80005330:	fbad                	bnez	a5,800052a2 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005332:	e1c42503          	lw	a0,-484(s0)
    80005336:	00000097          	auipc	ra,0x0
    8000533a:	c58080e7          	jalr	-936(ra) # 80004f8e <flags2perm>
    8000533e:	86aa                	mv	a3,a0
    80005340:	8626                	mv	a2,s1
    80005342:	85ca                	mv	a1,s2
    80005344:	855a                	mv	a0,s6
    80005346:	ffffc097          	auipc	ra,0xffffc
    8000534a:	0ca080e7          	jalr	202(ra) # 80001410 <uvmalloc>
    8000534e:	dea43c23          	sd	a0,-520(s0)
    80005352:	d939                	beqz	a0,800052a8 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005354:	e2843c03          	ld	s8,-472(s0)
    80005358:	e2042c83          	lw	s9,-480(s0)
    8000535c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005360:	f60b83e3          	beqz	s7,800052c6 <exec+0x31c>
    80005364:	89de                	mv	s3,s7
    80005366:	4481                	li	s1,0
    80005368:	bb95                	j	800050dc <exec+0x132>

000000008000536a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000536a:	7179                	addi	sp,sp,-48
    8000536c:	f406                	sd	ra,40(sp)
    8000536e:	f022                	sd	s0,32(sp)
    80005370:	ec26                	sd	s1,24(sp)
    80005372:	e84a                	sd	s2,16(sp)
    80005374:	1800                	addi	s0,sp,48
    80005376:	892e                	mv	s2,a1
    80005378:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000537a:	fdc40593          	addi	a1,s0,-36
    8000537e:	ffffe097          	auipc	ra,0xffffe
    80005382:	a3e080e7          	jalr	-1474(ra) # 80002dbc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005386:	fdc42703          	lw	a4,-36(s0)
    8000538a:	47bd                	li	a5,15
    8000538c:	02e7eb63          	bltu	a5,a4,800053c2 <argfd+0x58>
    80005390:	ffffc097          	auipc	ra,0xffffc
    80005394:	61c080e7          	jalr	1564(ra) # 800019ac <myproc>
    80005398:	fdc42703          	lw	a4,-36(s0)
    8000539c:	02070793          	addi	a5,a4,32
    800053a0:	078e                	slli	a5,a5,0x3
    800053a2:	953e                	add	a0,a0,a5
    800053a4:	651c                	ld	a5,8(a0)
    800053a6:	c385                	beqz	a5,800053c6 <argfd+0x5c>
    return -1;
  if(pfd)
    800053a8:	00090463          	beqz	s2,800053b0 <argfd+0x46>
    *pfd = fd;
    800053ac:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053b0:	4501                	li	a0,0
  if(pf)
    800053b2:	c091                	beqz	s1,800053b6 <argfd+0x4c>
    *pf = f;
    800053b4:	e09c                	sd	a5,0(s1)
}
    800053b6:	70a2                	ld	ra,40(sp)
    800053b8:	7402                	ld	s0,32(sp)
    800053ba:	64e2                	ld	s1,24(sp)
    800053bc:	6942                	ld	s2,16(sp)
    800053be:	6145                	addi	sp,sp,48
    800053c0:	8082                	ret
    return -1;
    800053c2:	557d                	li	a0,-1
    800053c4:	bfcd                	j	800053b6 <argfd+0x4c>
    800053c6:	557d                	li	a0,-1
    800053c8:	b7fd                	j	800053b6 <argfd+0x4c>

00000000800053ca <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053ca:	1101                	addi	sp,sp,-32
    800053cc:	ec06                	sd	ra,24(sp)
    800053ce:	e822                	sd	s0,16(sp)
    800053d0:	e426                	sd	s1,8(sp)
    800053d2:	1000                	addi	s0,sp,32
    800053d4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053d6:	ffffc097          	auipc	ra,0xffffc
    800053da:	5d6080e7          	jalr	1494(ra) # 800019ac <myproc>
    800053de:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053e0:	10850793          	addi	a5,a0,264
    800053e4:	4501                	li	a0,0
    800053e6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053e8:	6398                	ld	a4,0(a5)
    800053ea:	cb19                	beqz	a4,80005400 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800053ec:	2505                	addiw	a0,a0,1
    800053ee:	07a1                	addi	a5,a5,8
    800053f0:	fed51ce3          	bne	a0,a3,800053e8 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053f4:	557d                	li	a0,-1
}
    800053f6:	60e2                	ld	ra,24(sp)
    800053f8:	6442                	ld	s0,16(sp)
    800053fa:	64a2                	ld	s1,8(sp)
    800053fc:	6105                	addi	sp,sp,32
    800053fe:	8082                	ret
      p->ofile[fd] = f;
    80005400:	02050793          	addi	a5,a0,32
    80005404:	078e                	slli	a5,a5,0x3
    80005406:	963e                	add	a2,a2,a5
    80005408:	e604                	sd	s1,8(a2)
      return fd;
    8000540a:	b7f5                	j	800053f6 <fdalloc+0x2c>

000000008000540c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000540c:	715d                	addi	sp,sp,-80
    8000540e:	e486                	sd	ra,72(sp)
    80005410:	e0a2                	sd	s0,64(sp)
    80005412:	fc26                	sd	s1,56(sp)
    80005414:	f84a                	sd	s2,48(sp)
    80005416:	f44e                	sd	s3,40(sp)
    80005418:	f052                	sd	s4,32(sp)
    8000541a:	ec56                	sd	s5,24(sp)
    8000541c:	e85a                	sd	s6,16(sp)
    8000541e:	0880                	addi	s0,sp,80
    80005420:	8b2e                	mv	s6,a1
    80005422:	89b2                	mv	s3,a2
    80005424:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005426:	fb040593          	addi	a1,s0,-80
    8000542a:	fffff097          	auipc	ra,0xfffff
    8000542e:	e3c080e7          	jalr	-452(ra) # 80004266 <nameiparent>
    80005432:	84aa                	mv	s1,a0
    80005434:	14050f63          	beqz	a0,80005592 <create+0x186>
    return 0;

  ilock(dp);
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	66a080e7          	jalr	1642(ra) # 80003aa2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005440:	4601                	li	a2,0
    80005442:	fb040593          	addi	a1,s0,-80
    80005446:	8526                	mv	a0,s1
    80005448:	fffff097          	auipc	ra,0xfffff
    8000544c:	b3e080e7          	jalr	-1218(ra) # 80003f86 <dirlookup>
    80005450:	8aaa                	mv	s5,a0
    80005452:	c931                	beqz	a0,800054a6 <create+0x9a>
    iunlockput(dp);
    80005454:	8526                	mv	a0,s1
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	8ae080e7          	jalr	-1874(ra) # 80003d04 <iunlockput>
    ilock(ip);
    8000545e:	8556                	mv	a0,s5
    80005460:	ffffe097          	auipc	ra,0xffffe
    80005464:	642080e7          	jalr	1602(ra) # 80003aa2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005468:	000b059b          	sext.w	a1,s6
    8000546c:	4789                	li	a5,2
    8000546e:	02f59563          	bne	a1,a5,80005498 <create+0x8c>
    80005472:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdc0d4>
    80005476:	37f9                	addiw	a5,a5,-2
    80005478:	17c2                	slli	a5,a5,0x30
    8000547a:	93c1                	srli	a5,a5,0x30
    8000547c:	4705                	li	a4,1
    8000547e:	00f76d63          	bltu	a4,a5,80005498 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005482:	8556                	mv	a0,s5
    80005484:	60a6                	ld	ra,72(sp)
    80005486:	6406                	ld	s0,64(sp)
    80005488:	74e2                	ld	s1,56(sp)
    8000548a:	7942                	ld	s2,48(sp)
    8000548c:	79a2                	ld	s3,40(sp)
    8000548e:	7a02                	ld	s4,32(sp)
    80005490:	6ae2                	ld	s5,24(sp)
    80005492:	6b42                	ld	s6,16(sp)
    80005494:	6161                	addi	sp,sp,80
    80005496:	8082                	ret
    iunlockput(ip);
    80005498:	8556                	mv	a0,s5
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	86a080e7          	jalr	-1942(ra) # 80003d04 <iunlockput>
    return 0;
    800054a2:	4a81                	li	s5,0
    800054a4:	bff9                	j	80005482 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800054a6:	85da                	mv	a1,s6
    800054a8:	4088                	lw	a0,0(s1)
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	45c080e7          	jalr	1116(ra) # 80003906 <ialloc>
    800054b2:	8a2a                	mv	s4,a0
    800054b4:	c539                	beqz	a0,80005502 <create+0xf6>
  ilock(ip);
    800054b6:	ffffe097          	auipc	ra,0xffffe
    800054ba:	5ec080e7          	jalr	1516(ra) # 80003aa2 <ilock>
  ip->major = major;
    800054be:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800054c2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800054c6:	4905                	li	s2,1
    800054c8:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800054cc:	8552                	mv	a0,s4
    800054ce:	ffffe097          	auipc	ra,0xffffe
    800054d2:	50a080e7          	jalr	1290(ra) # 800039d8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054d6:	000b059b          	sext.w	a1,s6
    800054da:	03258b63          	beq	a1,s2,80005510 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800054de:	004a2603          	lw	a2,4(s4)
    800054e2:	fb040593          	addi	a1,s0,-80
    800054e6:	8526                	mv	a0,s1
    800054e8:	fffff097          	auipc	ra,0xfffff
    800054ec:	cae080e7          	jalr	-850(ra) # 80004196 <dirlink>
    800054f0:	06054f63          	bltz	a0,8000556e <create+0x162>
  iunlockput(dp);
    800054f4:	8526                	mv	a0,s1
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	80e080e7          	jalr	-2034(ra) # 80003d04 <iunlockput>
  return ip;
    800054fe:	8ad2                	mv	s5,s4
    80005500:	b749                	j	80005482 <create+0x76>
    iunlockput(dp);
    80005502:	8526                	mv	a0,s1
    80005504:	fffff097          	auipc	ra,0xfffff
    80005508:	800080e7          	jalr	-2048(ra) # 80003d04 <iunlockput>
    return 0;
    8000550c:	8ad2                	mv	s5,s4
    8000550e:	bf95                	j	80005482 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005510:	004a2603          	lw	a2,4(s4)
    80005514:	00003597          	auipc	a1,0x3
    80005518:	1fc58593          	addi	a1,a1,508 # 80008710 <syscalls+0x2c0>
    8000551c:	8552                	mv	a0,s4
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	c78080e7          	jalr	-904(ra) # 80004196 <dirlink>
    80005526:	04054463          	bltz	a0,8000556e <create+0x162>
    8000552a:	40d0                	lw	a2,4(s1)
    8000552c:	00003597          	auipc	a1,0x3
    80005530:	1ec58593          	addi	a1,a1,492 # 80008718 <syscalls+0x2c8>
    80005534:	8552                	mv	a0,s4
    80005536:	fffff097          	auipc	ra,0xfffff
    8000553a:	c60080e7          	jalr	-928(ra) # 80004196 <dirlink>
    8000553e:	02054863          	bltz	a0,8000556e <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005542:	004a2603          	lw	a2,4(s4)
    80005546:	fb040593          	addi	a1,s0,-80
    8000554a:	8526                	mv	a0,s1
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	c4a080e7          	jalr	-950(ra) # 80004196 <dirlink>
    80005554:	00054d63          	bltz	a0,8000556e <create+0x162>
    dp->nlink++;  // for ".."
    80005558:	04a4d783          	lhu	a5,74(s1)
    8000555c:	2785                	addiw	a5,a5,1
    8000555e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005562:	8526                	mv	a0,s1
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	474080e7          	jalr	1140(ra) # 800039d8 <iupdate>
    8000556c:	b761                	j	800054f4 <create+0xe8>
  ip->nlink = 0;
    8000556e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005572:	8552                	mv	a0,s4
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	464080e7          	jalr	1124(ra) # 800039d8 <iupdate>
  iunlockput(ip);
    8000557c:	8552                	mv	a0,s4
    8000557e:	ffffe097          	auipc	ra,0xffffe
    80005582:	786080e7          	jalr	1926(ra) # 80003d04 <iunlockput>
  iunlockput(dp);
    80005586:	8526                	mv	a0,s1
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	77c080e7          	jalr	1916(ra) # 80003d04 <iunlockput>
  return 0;
    80005590:	bdcd                	j	80005482 <create+0x76>
    return 0;
    80005592:	8aaa                	mv	s5,a0
    80005594:	b5fd                	j	80005482 <create+0x76>

0000000080005596 <sys_dup>:
{
    80005596:	7179                	addi	sp,sp,-48
    80005598:	f406                	sd	ra,40(sp)
    8000559a:	f022                	sd	s0,32(sp)
    8000559c:	ec26                	sd	s1,24(sp)
    8000559e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800055a0:	fd840613          	addi	a2,s0,-40
    800055a4:	4581                	li	a1,0
    800055a6:	4501                	li	a0,0
    800055a8:	00000097          	auipc	ra,0x0
    800055ac:	dc2080e7          	jalr	-574(ra) # 8000536a <argfd>
    return -1;
    800055b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800055b2:	02054363          	bltz	a0,800055d8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800055b6:	fd843503          	ld	a0,-40(s0)
    800055ba:	00000097          	auipc	ra,0x0
    800055be:	e10080e7          	jalr	-496(ra) # 800053ca <fdalloc>
    800055c2:	84aa                	mv	s1,a0
    return -1;
    800055c4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800055c6:	00054963          	bltz	a0,800055d8 <sys_dup+0x42>
  filedup(f);
    800055ca:	fd843503          	ld	a0,-40(s0)
    800055ce:	fffff097          	auipc	ra,0xfffff
    800055d2:	310080e7          	jalr	784(ra) # 800048de <filedup>
  return fd;
    800055d6:	87a6                	mv	a5,s1
}
    800055d8:	853e                	mv	a0,a5
    800055da:	70a2                	ld	ra,40(sp)
    800055dc:	7402                	ld	s0,32(sp)
    800055de:	64e2                	ld	s1,24(sp)
    800055e0:	6145                	addi	sp,sp,48
    800055e2:	8082                	ret

00000000800055e4 <sys_read>:
{
    800055e4:	7179                	addi	sp,sp,-48
    800055e6:	f406                	sd	ra,40(sp)
    800055e8:	f022                	sd	s0,32(sp)
    800055ea:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800055ec:	fd840593          	addi	a1,s0,-40
    800055f0:	4505                	li	a0,1
    800055f2:	ffffd097          	auipc	ra,0xffffd
    800055f6:	7ea080e7          	jalr	2026(ra) # 80002ddc <argaddr>
  argint(2, &n);
    800055fa:	fe440593          	addi	a1,s0,-28
    800055fe:	4509                	li	a0,2
    80005600:	ffffd097          	auipc	ra,0xffffd
    80005604:	7bc080e7          	jalr	1980(ra) # 80002dbc <argint>
  if(argfd(0, 0, &f) < 0)
    80005608:	fe840613          	addi	a2,s0,-24
    8000560c:	4581                	li	a1,0
    8000560e:	4501                	li	a0,0
    80005610:	00000097          	auipc	ra,0x0
    80005614:	d5a080e7          	jalr	-678(ra) # 8000536a <argfd>
    80005618:	87aa                	mv	a5,a0
    return -1;
    8000561a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000561c:	0007cc63          	bltz	a5,80005634 <sys_read+0x50>
  return fileread(f, p, n);
    80005620:	fe442603          	lw	a2,-28(s0)
    80005624:	fd843583          	ld	a1,-40(s0)
    80005628:	fe843503          	ld	a0,-24(s0)
    8000562c:	fffff097          	auipc	ra,0xfffff
    80005630:	43e080e7          	jalr	1086(ra) # 80004a6a <fileread>
}
    80005634:	70a2                	ld	ra,40(sp)
    80005636:	7402                	ld	s0,32(sp)
    80005638:	6145                	addi	sp,sp,48
    8000563a:	8082                	ret

000000008000563c <sys_write>:
{
    8000563c:	7179                	addi	sp,sp,-48
    8000563e:	f406                	sd	ra,40(sp)
    80005640:	f022                	sd	s0,32(sp)
    80005642:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005644:	fd840593          	addi	a1,s0,-40
    80005648:	4505                	li	a0,1
    8000564a:	ffffd097          	auipc	ra,0xffffd
    8000564e:	792080e7          	jalr	1938(ra) # 80002ddc <argaddr>
  argint(2, &n);
    80005652:	fe440593          	addi	a1,s0,-28
    80005656:	4509                	li	a0,2
    80005658:	ffffd097          	auipc	ra,0xffffd
    8000565c:	764080e7          	jalr	1892(ra) # 80002dbc <argint>
  if(argfd(0, 0, &f) < 0)
    80005660:	fe840613          	addi	a2,s0,-24
    80005664:	4581                	li	a1,0
    80005666:	4501                	li	a0,0
    80005668:	00000097          	auipc	ra,0x0
    8000566c:	d02080e7          	jalr	-766(ra) # 8000536a <argfd>
    80005670:	87aa                	mv	a5,a0
    return -1;
    80005672:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005674:	0007cc63          	bltz	a5,8000568c <sys_write+0x50>
  return filewrite(f, p, n);
    80005678:	fe442603          	lw	a2,-28(s0)
    8000567c:	fd843583          	ld	a1,-40(s0)
    80005680:	fe843503          	ld	a0,-24(s0)
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	4a8080e7          	jalr	1192(ra) # 80004b2c <filewrite>
}
    8000568c:	70a2                	ld	ra,40(sp)
    8000568e:	7402                	ld	s0,32(sp)
    80005690:	6145                	addi	sp,sp,48
    80005692:	8082                	ret

0000000080005694 <sys_close>:
{
    80005694:	1101                	addi	sp,sp,-32
    80005696:	ec06                	sd	ra,24(sp)
    80005698:	e822                	sd	s0,16(sp)
    8000569a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000569c:	fe040613          	addi	a2,s0,-32
    800056a0:	fec40593          	addi	a1,s0,-20
    800056a4:	4501                	li	a0,0
    800056a6:	00000097          	auipc	ra,0x0
    800056aa:	cc4080e7          	jalr	-828(ra) # 8000536a <argfd>
    return -1;
    800056ae:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800056b0:	02054563          	bltz	a0,800056da <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    800056b4:	ffffc097          	auipc	ra,0xffffc
    800056b8:	2f8080e7          	jalr	760(ra) # 800019ac <myproc>
    800056bc:	fec42783          	lw	a5,-20(s0)
    800056c0:	02078793          	addi	a5,a5,32
    800056c4:	078e                	slli	a5,a5,0x3
    800056c6:	97aa                	add	a5,a5,a0
    800056c8:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800056cc:	fe043503          	ld	a0,-32(s0)
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	260080e7          	jalr	608(ra) # 80004930 <fileclose>
  return 0;
    800056d8:	4781                	li	a5,0
}
    800056da:	853e                	mv	a0,a5
    800056dc:	60e2                	ld	ra,24(sp)
    800056de:	6442                	ld	s0,16(sp)
    800056e0:	6105                	addi	sp,sp,32
    800056e2:	8082                	ret

00000000800056e4 <sys_fstat>:
{
    800056e4:	1101                	addi	sp,sp,-32
    800056e6:	ec06                	sd	ra,24(sp)
    800056e8:	e822                	sd	s0,16(sp)
    800056ea:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800056ec:	fe040593          	addi	a1,s0,-32
    800056f0:	4505                	li	a0,1
    800056f2:	ffffd097          	auipc	ra,0xffffd
    800056f6:	6ea080e7          	jalr	1770(ra) # 80002ddc <argaddr>
  if(argfd(0, 0, &f) < 0)
    800056fa:	fe840613          	addi	a2,s0,-24
    800056fe:	4581                	li	a1,0
    80005700:	4501                	li	a0,0
    80005702:	00000097          	auipc	ra,0x0
    80005706:	c68080e7          	jalr	-920(ra) # 8000536a <argfd>
    8000570a:	87aa                	mv	a5,a0
    return -1;
    8000570c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000570e:	0007ca63          	bltz	a5,80005722 <sys_fstat+0x3e>
  return filestat(f, st);
    80005712:	fe043583          	ld	a1,-32(s0)
    80005716:	fe843503          	ld	a0,-24(s0)
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	2de080e7          	jalr	734(ra) # 800049f8 <filestat>
}
    80005722:	60e2                	ld	ra,24(sp)
    80005724:	6442                	ld	s0,16(sp)
    80005726:	6105                	addi	sp,sp,32
    80005728:	8082                	ret

000000008000572a <sys_link>:
{
    8000572a:	7169                	addi	sp,sp,-304
    8000572c:	f606                	sd	ra,296(sp)
    8000572e:	f222                	sd	s0,288(sp)
    80005730:	ee26                	sd	s1,280(sp)
    80005732:	ea4a                	sd	s2,272(sp)
    80005734:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005736:	08000613          	li	a2,128
    8000573a:	ed040593          	addi	a1,s0,-304
    8000573e:	4501                	li	a0,0
    80005740:	ffffd097          	auipc	ra,0xffffd
    80005744:	6bc080e7          	jalr	1724(ra) # 80002dfc <argstr>
    return -1;
    80005748:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000574a:	10054e63          	bltz	a0,80005866 <sys_link+0x13c>
    8000574e:	08000613          	li	a2,128
    80005752:	f5040593          	addi	a1,s0,-176
    80005756:	4505                	li	a0,1
    80005758:	ffffd097          	auipc	ra,0xffffd
    8000575c:	6a4080e7          	jalr	1700(ra) # 80002dfc <argstr>
    return -1;
    80005760:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005762:	10054263          	bltz	a0,80005866 <sys_link+0x13c>
  begin_op();
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	cfe080e7          	jalr	-770(ra) # 80004464 <begin_op>
  if((ip = namei(old)) == 0){
    8000576e:	ed040513          	addi	a0,s0,-304
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	ad6080e7          	jalr	-1322(ra) # 80004248 <namei>
    8000577a:	84aa                	mv	s1,a0
    8000577c:	c551                	beqz	a0,80005808 <sys_link+0xde>
  ilock(ip);
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	324080e7          	jalr	804(ra) # 80003aa2 <ilock>
  if(ip->type == T_DIR){
    80005786:	04449703          	lh	a4,68(s1)
    8000578a:	4785                	li	a5,1
    8000578c:	08f70463          	beq	a4,a5,80005814 <sys_link+0xea>
  ip->nlink++;
    80005790:	04a4d783          	lhu	a5,74(s1)
    80005794:	2785                	addiw	a5,a5,1
    80005796:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000579a:	8526                	mv	a0,s1
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	23c080e7          	jalr	572(ra) # 800039d8 <iupdate>
  iunlock(ip);
    800057a4:	8526                	mv	a0,s1
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	3be080e7          	jalr	958(ra) # 80003b64 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800057ae:	fd040593          	addi	a1,s0,-48
    800057b2:	f5040513          	addi	a0,s0,-176
    800057b6:	fffff097          	auipc	ra,0xfffff
    800057ba:	ab0080e7          	jalr	-1360(ra) # 80004266 <nameiparent>
    800057be:	892a                	mv	s2,a0
    800057c0:	c935                	beqz	a0,80005834 <sys_link+0x10a>
  ilock(dp);
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	2e0080e7          	jalr	736(ra) # 80003aa2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057ca:	00092703          	lw	a4,0(s2)
    800057ce:	409c                	lw	a5,0(s1)
    800057d0:	04f71d63          	bne	a4,a5,8000582a <sys_link+0x100>
    800057d4:	40d0                	lw	a2,4(s1)
    800057d6:	fd040593          	addi	a1,s0,-48
    800057da:	854a                	mv	a0,s2
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	9ba080e7          	jalr	-1606(ra) # 80004196 <dirlink>
    800057e4:	04054363          	bltz	a0,8000582a <sys_link+0x100>
  iunlockput(dp);
    800057e8:	854a                	mv	a0,s2
    800057ea:	ffffe097          	auipc	ra,0xffffe
    800057ee:	51a080e7          	jalr	1306(ra) # 80003d04 <iunlockput>
  iput(ip);
    800057f2:	8526                	mv	a0,s1
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	468080e7          	jalr	1128(ra) # 80003c5c <iput>
  end_op();
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	ce8080e7          	jalr	-792(ra) # 800044e4 <end_op>
  return 0;
    80005804:	4781                	li	a5,0
    80005806:	a085                	j	80005866 <sys_link+0x13c>
    end_op();
    80005808:	fffff097          	auipc	ra,0xfffff
    8000580c:	cdc080e7          	jalr	-804(ra) # 800044e4 <end_op>
    return -1;
    80005810:	57fd                	li	a5,-1
    80005812:	a891                	j	80005866 <sys_link+0x13c>
    iunlockput(ip);
    80005814:	8526                	mv	a0,s1
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	4ee080e7          	jalr	1262(ra) # 80003d04 <iunlockput>
    end_op();
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	cc6080e7          	jalr	-826(ra) # 800044e4 <end_op>
    return -1;
    80005826:	57fd                	li	a5,-1
    80005828:	a83d                	j	80005866 <sys_link+0x13c>
    iunlockput(dp);
    8000582a:	854a                	mv	a0,s2
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	4d8080e7          	jalr	1240(ra) # 80003d04 <iunlockput>
  ilock(ip);
    80005834:	8526                	mv	a0,s1
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	26c080e7          	jalr	620(ra) # 80003aa2 <ilock>
  ip->nlink--;
    8000583e:	04a4d783          	lhu	a5,74(s1)
    80005842:	37fd                	addiw	a5,a5,-1
    80005844:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005848:	8526                	mv	a0,s1
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	18e080e7          	jalr	398(ra) # 800039d8 <iupdate>
  iunlockput(ip);
    80005852:	8526                	mv	a0,s1
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	4b0080e7          	jalr	1200(ra) # 80003d04 <iunlockput>
  end_op();
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	c88080e7          	jalr	-888(ra) # 800044e4 <end_op>
  return -1;
    80005864:	57fd                	li	a5,-1
}
    80005866:	853e                	mv	a0,a5
    80005868:	70b2                	ld	ra,296(sp)
    8000586a:	7412                	ld	s0,288(sp)
    8000586c:	64f2                	ld	s1,280(sp)
    8000586e:	6952                	ld	s2,272(sp)
    80005870:	6155                	addi	sp,sp,304
    80005872:	8082                	ret

0000000080005874 <sys_unlink>:
{
    80005874:	7151                	addi	sp,sp,-240
    80005876:	f586                	sd	ra,232(sp)
    80005878:	f1a2                	sd	s0,224(sp)
    8000587a:	eda6                	sd	s1,216(sp)
    8000587c:	e9ca                	sd	s2,208(sp)
    8000587e:	e5ce                	sd	s3,200(sp)
    80005880:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005882:	08000613          	li	a2,128
    80005886:	f3040593          	addi	a1,s0,-208
    8000588a:	4501                	li	a0,0
    8000588c:	ffffd097          	auipc	ra,0xffffd
    80005890:	570080e7          	jalr	1392(ra) # 80002dfc <argstr>
    80005894:	18054163          	bltz	a0,80005a16 <sys_unlink+0x1a2>
  begin_op();
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	bcc080e7          	jalr	-1076(ra) # 80004464 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058a0:	fb040593          	addi	a1,s0,-80
    800058a4:	f3040513          	addi	a0,s0,-208
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	9be080e7          	jalr	-1602(ra) # 80004266 <nameiparent>
    800058b0:	84aa                	mv	s1,a0
    800058b2:	c979                	beqz	a0,80005988 <sys_unlink+0x114>
  ilock(dp);
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	1ee080e7          	jalr	494(ra) # 80003aa2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058bc:	00003597          	auipc	a1,0x3
    800058c0:	e5458593          	addi	a1,a1,-428 # 80008710 <syscalls+0x2c0>
    800058c4:	fb040513          	addi	a0,s0,-80
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	6a4080e7          	jalr	1700(ra) # 80003f6c <namecmp>
    800058d0:	14050a63          	beqz	a0,80005a24 <sys_unlink+0x1b0>
    800058d4:	00003597          	auipc	a1,0x3
    800058d8:	e4458593          	addi	a1,a1,-444 # 80008718 <syscalls+0x2c8>
    800058dc:	fb040513          	addi	a0,s0,-80
    800058e0:	ffffe097          	auipc	ra,0xffffe
    800058e4:	68c080e7          	jalr	1676(ra) # 80003f6c <namecmp>
    800058e8:	12050e63          	beqz	a0,80005a24 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058ec:	f2c40613          	addi	a2,s0,-212
    800058f0:	fb040593          	addi	a1,s0,-80
    800058f4:	8526                	mv	a0,s1
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	690080e7          	jalr	1680(ra) # 80003f86 <dirlookup>
    800058fe:	892a                	mv	s2,a0
    80005900:	12050263          	beqz	a0,80005a24 <sys_unlink+0x1b0>
  ilock(ip);
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	19e080e7          	jalr	414(ra) # 80003aa2 <ilock>
  if(ip->nlink < 1)
    8000590c:	04a91783          	lh	a5,74(s2)
    80005910:	08f05263          	blez	a5,80005994 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005914:	04491703          	lh	a4,68(s2)
    80005918:	4785                	li	a5,1
    8000591a:	08f70563          	beq	a4,a5,800059a4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000591e:	4641                	li	a2,16
    80005920:	4581                	li	a1,0
    80005922:	fc040513          	addi	a0,s0,-64
    80005926:	ffffb097          	auipc	ra,0xffffb
    8000592a:	3ac080e7          	jalr	940(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000592e:	4741                	li	a4,16
    80005930:	f2c42683          	lw	a3,-212(s0)
    80005934:	fc040613          	addi	a2,s0,-64
    80005938:	4581                	li	a1,0
    8000593a:	8526                	mv	a0,s1
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	512080e7          	jalr	1298(ra) # 80003e4e <writei>
    80005944:	47c1                	li	a5,16
    80005946:	0af51563          	bne	a0,a5,800059f0 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000594a:	04491703          	lh	a4,68(s2)
    8000594e:	4785                	li	a5,1
    80005950:	0af70863          	beq	a4,a5,80005a00 <sys_unlink+0x18c>
  iunlockput(dp);
    80005954:	8526                	mv	a0,s1
    80005956:	ffffe097          	auipc	ra,0xffffe
    8000595a:	3ae080e7          	jalr	942(ra) # 80003d04 <iunlockput>
  ip->nlink--;
    8000595e:	04a95783          	lhu	a5,74(s2)
    80005962:	37fd                	addiw	a5,a5,-1
    80005964:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005968:	854a                	mv	a0,s2
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	06e080e7          	jalr	110(ra) # 800039d8 <iupdate>
  iunlockput(ip);
    80005972:	854a                	mv	a0,s2
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	390080e7          	jalr	912(ra) # 80003d04 <iunlockput>
  end_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	b68080e7          	jalr	-1176(ra) # 800044e4 <end_op>
  return 0;
    80005984:	4501                	li	a0,0
    80005986:	a84d                	j	80005a38 <sys_unlink+0x1c4>
    end_op();
    80005988:	fffff097          	auipc	ra,0xfffff
    8000598c:	b5c080e7          	jalr	-1188(ra) # 800044e4 <end_op>
    return -1;
    80005990:	557d                	li	a0,-1
    80005992:	a05d                	j	80005a38 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005994:	00003517          	auipc	a0,0x3
    80005998:	d8c50513          	addi	a0,a0,-628 # 80008720 <syscalls+0x2d0>
    8000599c:	ffffb097          	auipc	ra,0xffffb
    800059a0:	ba2080e7          	jalr	-1118(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059a4:	04c92703          	lw	a4,76(s2)
    800059a8:	02000793          	li	a5,32
    800059ac:	f6e7f9e3          	bgeu	a5,a4,8000591e <sys_unlink+0xaa>
    800059b0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059b4:	4741                	li	a4,16
    800059b6:	86ce                	mv	a3,s3
    800059b8:	f1840613          	addi	a2,s0,-232
    800059bc:	4581                	li	a1,0
    800059be:	854a                	mv	a0,s2
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	396080e7          	jalr	918(ra) # 80003d56 <readi>
    800059c8:	47c1                	li	a5,16
    800059ca:	00f51b63          	bne	a0,a5,800059e0 <sys_unlink+0x16c>
    if(de.inum != 0)
    800059ce:	f1845783          	lhu	a5,-232(s0)
    800059d2:	e7a1                	bnez	a5,80005a1a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059d4:	29c1                	addiw	s3,s3,16
    800059d6:	04c92783          	lw	a5,76(s2)
    800059da:	fcf9ede3          	bltu	s3,a5,800059b4 <sys_unlink+0x140>
    800059de:	b781                	j	8000591e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059e0:	00003517          	auipc	a0,0x3
    800059e4:	d5850513          	addi	a0,a0,-680 # 80008738 <syscalls+0x2e8>
    800059e8:	ffffb097          	auipc	ra,0xffffb
    800059ec:	b56080e7          	jalr	-1194(ra) # 8000053e <panic>
    panic("unlink: writei");
    800059f0:	00003517          	auipc	a0,0x3
    800059f4:	d6050513          	addi	a0,a0,-672 # 80008750 <syscalls+0x300>
    800059f8:	ffffb097          	auipc	ra,0xffffb
    800059fc:	b46080e7          	jalr	-1210(ra) # 8000053e <panic>
    dp->nlink--;
    80005a00:	04a4d783          	lhu	a5,74(s1)
    80005a04:	37fd                	addiw	a5,a5,-1
    80005a06:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a0a:	8526                	mv	a0,s1
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	fcc080e7          	jalr	-52(ra) # 800039d8 <iupdate>
    80005a14:	b781                	j	80005954 <sys_unlink+0xe0>
    return -1;
    80005a16:	557d                	li	a0,-1
    80005a18:	a005                	j	80005a38 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a1a:	854a                	mv	a0,s2
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	2e8080e7          	jalr	744(ra) # 80003d04 <iunlockput>
  iunlockput(dp);
    80005a24:	8526                	mv	a0,s1
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	2de080e7          	jalr	734(ra) # 80003d04 <iunlockput>
  end_op();
    80005a2e:	fffff097          	auipc	ra,0xfffff
    80005a32:	ab6080e7          	jalr	-1354(ra) # 800044e4 <end_op>
  return -1;
    80005a36:	557d                	li	a0,-1
}
    80005a38:	70ae                	ld	ra,232(sp)
    80005a3a:	740e                	ld	s0,224(sp)
    80005a3c:	64ee                	ld	s1,216(sp)
    80005a3e:	694e                	ld	s2,208(sp)
    80005a40:	69ae                	ld	s3,200(sp)
    80005a42:	616d                	addi	sp,sp,240
    80005a44:	8082                	ret

0000000080005a46 <sys_open>:

uint64
sys_open(void)
{
    80005a46:	7131                	addi	sp,sp,-192
    80005a48:	fd06                	sd	ra,184(sp)
    80005a4a:	f922                	sd	s0,176(sp)
    80005a4c:	f526                	sd	s1,168(sp)
    80005a4e:	f14a                	sd	s2,160(sp)
    80005a50:	ed4e                	sd	s3,152(sp)
    80005a52:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005a54:	f4c40593          	addi	a1,s0,-180
    80005a58:	4505                	li	a0,1
    80005a5a:	ffffd097          	auipc	ra,0xffffd
    80005a5e:	362080e7          	jalr	866(ra) # 80002dbc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a62:	08000613          	li	a2,128
    80005a66:	f5040593          	addi	a1,s0,-176
    80005a6a:	4501                	li	a0,0
    80005a6c:	ffffd097          	auipc	ra,0xffffd
    80005a70:	390080e7          	jalr	912(ra) # 80002dfc <argstr>
    80005a74:	87aa                	mv	a5,a0
    return -1;
    80005a76:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a78:	0a07c963          	bltz	a5,80005b2a <sys_open+0xe4>

  begin_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	9e8080e7          	jalr	-1560(ra) # 80004464 <begin_op>

  if(omode & O_CREATE){
    80005a84:	f4c42783          	lw	a5,-180(s0)
    80005a88:	2007f793          	andi	a5,a5,512
    80005a8c:	cfc5                	beqz	a5,80005b44 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a8e:	4681                	li	a3,0
    80005a90:	4601                	li	a2,0
    80005a92:	4589                	li	a1,2
    80005a94:	f5040513          	addi	a0,s0,-176
    80005a98:	00000097          	auipc	ra,0x0
    80005a9c:	974080e7          	jalr	-1676(ra) # 8000540c <create>
    80005aa0:	84aa                	mv	s1,a0
    if(ip == 0){
    80005aa2:	c959                	beqz	a0,80005b38 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005aa4:	04449703          	lh	a4,68(s1)
    80005aa8:	478d                	li	a5,3
    80005aaa:	00f71763          	bne	a4,a5,80005ab8 <sys_open+0x72>
    80005aae:	0464d703          	lhu	a4,70(s1)
    80005ab2:	47a5                	li	a5,9
    80005ab4:	0ce7ed63          	bltu	a5,a4,80005b8e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	dbc080e7          	jalr	-580(ra) # 80004874 <filealloc>
    80005ac0:	89aa                	mv	s3,a0
    80005ac2:	10050363          	beqz	a0,80005bc8 <sys_open+0x182>
    80005ac6:	00000097          	auipc	ra,0x0
    80005aca:	904080e7          	jalr	-1788(ra) # 800053ca <fdalloc>
    80005ace:	892a                	mv	s2,a0
    80005ad0:	0e054763          	bltz	a0,80005bbe <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ad4:	04449703          	lh	a4,68(s1)
    80005ad8:	478d                	li	a5,3
    80005ada:	0cf70563          	beq	a4,a5,80005ba4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ade:	4789                	li	a5,2
    80005ae0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ae4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ae8:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005aec:	f4c42783          	lw	a5,-180(s0)
    80005af0:	0017c713          	xori	a4,a5,1
    80005af4:	8b05                	andi	a4,a4,1
    80005af6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005afa:	0037f713          	andi	a4,a5,3
    80005afe:	00e03733          	snez	a4,a4
    80005b02:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b06:	4007f793          	andi	a5,a5,1024
    80005b0a:	c791                	beqz	a5,80005b16 <sys_open+0xd0>
    80005b0c:	04449703          	lh	a4,68(s1)
    80005b10:	4789                	li	a5,2
    80005b12:	0af70063          	beq	a4,a5,80005bb2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b16:	8526                	mv	a0,s1
    80005b18:	ffffe097          	auipc	ra,0xffffe
    80005b1c:	04c080e7          	jalr	76(ra) # 80003b64 <iunlock>
  end_op();
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	9c4080e7          	jalr	-1596(ra) # 800044e4 <end_op>

  return fd;
    80005b28:	854a                	mv	a0,s2
}
    80005b2a:	70ea                	ld	ra,184(sp)
    80005b2c:	744a                	ld	s0,176(sp)
    80005b2e:	74aa                	ld	s1,168(sp)
    80005b30:	790a                	ld	s2,160(sp)
    80005b32:	69ea                	ld	s3,152(sp)
    80005b34:	6129                	addi	sp,sp,192
    80005b36:	8082                	ret
      end_op();
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	9ac080e7          	jalr	-1620(ra) # 800044e4 <end_op>
      return -1;
    80005b40:	557d                	li	a0,-1
    80005b42:	b7e5                	j	80005b2a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b44:	f5040513          	addi	a0,s0,-176
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	700080e7          	jalr	1792(ra) # 80004248 <namei>
    80005b50:	84aa                	mv	s1,a0
    80005b52:	c905                	beqz	a0,80005b82 <sys_open+0x13c>
    ilock(ip);
    80005b54:	ffffe097          	auipc	ra,0xffffe
    80005b58:	f4e080e7          	jalr	-178(ra) # 80003aa2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b5c:	04449703          	lh	a4,68(s1)
    80005b60:	4785                	li	a5,1
    80005b62:	f4f711e3          	bne	a4,a5,80005aa4 <sys_open+0x5e>
    80005b66:	f4c42783          	lw	a5,-180(s0)
    80005b6a:	d7b9                	beqz	a5,80005ab8 <sys_open+0x72>
      iunlockput(ip);
    80005b6c:	8526                	mv	a0,s1
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	196080e7          	jalr	406(ra) # 80003d04 <iunlockput>
      end_op();
    80005b76:	fffff097          	auipc	ra,0xfffff
    80005b7a:	96e080e7          	jalr	-1682(ra) # 800044e4 <end_op>
      return -1;
    80005b7e:	557d                	li	a0,-1
    80005b80:	b76d                	j	80005b2a <sys_open+0xe4>
      end_op();
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	962080e7          	jalr	-1694(ra) # 800044e4 <end_op>
      return -1;
    80005b8a:	557d                	li	a0,-1
    80005b8c:	bf79                	j	80005b2a <sys_open+0xe4>
    iunlockput(ip);
    80005b8e:	8526                	mv	a0,s1
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	174080e7          	jalr	372(ra) # 80003d04 <iunlockput>
    end_op();
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	94c080e7          	jalr	-1716(ra) # 800044e4 <end_op>
    return -1;
    80005ba0:	557d                	li	a0,-1
    80005ba2:	b761                	j	80005b2a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ba4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ba8:	04649783          	lh	a5,70(s1)
    80005bac:	02f99223          	sh	a5,36(s3)
    80005bb0:	bf25                	j	80005ae8 <sys_open+0xa2>
    itrunc(ip);
    80005bb2:	8526                	mv	a0,s1
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	ffc080e7          	jalr	-4(ra) # 80003bb0 <itrunc>
    80005bbc:	bfa9                	j	80005b16 <sys_open+0xd0>
      fileclose(f);
    80005bbe:	854e                	mv	a0,s3
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	d70080e7          	jalr	-656(ra) # 80004930 <fileclose>
    iunlockput(ip);
    80005bc8:	8526                	mv	a0,s1
    80005bca:	ffffe097          	auipc	ra,0xffffe
    80005bce:	13a080e7          	jalr	314(ra) # 80003d04 <iunlockput>
    end_op();
    80005bd2:	fffff097          	auipc	ra,0xfffff
    80005bd6:	912080e7          	jalr	-1774(ra) # 800044e4 <end_op>
    return -1;
    80005bda:	557d                	li	a0,-1
    80005bdc:	b7b9                	j	80005b2a <sys_open+0xe4>

0000000080005bde <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bde:	7175                	addi	sp,sp,-144
    80005be0:	e506                	sd	ra,136(sp)
    80005be2:	e122                	sd	s0,128(sp)
    80005be4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005be6:	fffff097          	auipc	ra,0xfffff
    80005bea:	87e080e7          	jalr	-1922(ra) # 80004464 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bee:	08000613          	li	a2,128
    80005bf2:	f7040593          	addi	a1,s0,-144
    80005bf6:	4501                	li	a0,0
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	204080e7          	jalr	516(ra) # 80002dfc <argstr>
    80005c00:	02054963          	bltz	a0,80005c32 <sys_mkdir+0x54>
    80005c04:	4681                	li	a3,0
    80005c06:	4601                	li	a2,0
    80005c08:	4585                	li	a1,1
    80005c0a:	f7040513          	addi	a0,s0,-144
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	7fe080e7          	jalr	2046(ra) # 8000540c <create>
    80005c16:	cd11                	beqz	a0,80005c32 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	0ec080e7          	jalr	236(ra) # 80003d04 <iunlockput>
  end_op();
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	8c4080e7          	jalr	-1852(ra) # 800044e4 <end_op>
  return 0;
    80005c28:	4501                	li	a0,0
}
    80005c2a:	60aa                	ld	ra,136(sp)
    80005c2c:	640a                	ld	s0,128(sp)
    80005c2e:	6149                	addi	sp,sp,144
    80005c30:	8082                	ret
    end_op();
    80005c32:	fffff097          	auipc	ra,0xfffff
    80005c36:	8b2080e7          	jalr	-1870(ra) # 800044e4 <end_op>
    return -1;
    80005c3a:	557d                	li	a0,-1
    80005c3c:	b7fd                	j	80005c2a <sys_mkdir+0x4c>

0000000080005c3e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c3e:	7135                	addi	sp,sp,-160
    80005c40:	ed06                	sd	ra,152(sp)
    80005c42:	e922                	sd	s0,144(sp)
    80005c44:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	81e080e7          	jalr	-2018(ra) # 80004464 <begin_op>
  argint(1, &major);
    80005c4e:	f6c40593          	addi	a1,s0,-148
    80005c52:	4505                	li	a0,1
    80005c54:	ffffd097          	auipc	ra,0xffffd
    80005c58:	168080e7          	jalr	360(ra) # 80002dbc <argint>
  argint(2, &minor);
    80005c5c:	f6840593          	addi	a1,s0,-152
    80005c60:	4509                	li	a0,2
    80005c62:	ffffd097          	auipc	ra,0xffffd
    80005c66:	15a080e7          	jalr	346(ra) # 80002dbc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c6a:	08000613          	li	a2,128
    80005c6e:	f7040593          	addi	a1,s0,-144
    80005c72:	4501                	li	a0,0
    80005c74:	ffffd097          	auipc	ra,0xffffd
    80005c78:	188080e7          	jalr	392(ra) # 80002dfc <argstr>
    80005c7c:	02054b63          	bltz	a0,80005cb2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c80:	f6841683          	lh	a3,-152(s0)
    80005c84:	f6c41603          	lh	a2,-148(s0)
    80005c88:	458d                	li	a1,3
    80005c8a:	f7040513          	addi	a0,s0,-144
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	77e080e7          	jalr	1918(ra) # 8000540c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c96:	cd11                	beqz	a0,80005cb2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c98:	ffffe097          	auipc	ra,0xffffe
    80005c9c:	06c080e7          	jalr	108(ra) # 80003d04 <iunlockput>
  end_op();
    80005ca0:	fffff097          	auipc	ra,0xfffff
    80005ca4:	844080e7          	jalr	-1980(ra) # 800044e4 <end_op>
  return 0;
    80005ca8:	4501                	li	a0,0
}
    80005caa:	60ea                	ld	ra,152(sp)
    80005cac:	644a                	ld	s0,144(sp)
    80005cae:	610d                	addi	sp,sp,160
    80005cb0:	8082                	ret
    end_op();
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	832080e7          	jalr	-1998(ra) # 800044e4 <end_op>
    return -1;
    80005cba:	557d                	li	a0,-1
    80005cbc:	b7fd                	j	80005caa <sys_mknod+0x6c>

0000000080005cbe <sys_chdir>:

uint64
sys_chdir(void)
{
    80005cbe:	7135                	addi	sp,sp,-160
    80005cc0:	ed06                	sd	ra,152(sp)
    80005cc2:	e922                	sd	s0,144(sp)
    80005cc4:	e526                	sd	s1,136(sp)
    80005cc6:	e14a                	sd	s2,128(sp)
    80005cc8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cca:	ffffc097          	auipc	ra,0xffffc
    80005cce:	ce2080e7          	jalr	-798(ra) # 800019ac <myproc>
    80005cd2:	892a                	mv	s2,a0
  
  begin_op();
    80005cd4:	ffffe097          	auipc	ra,0xffffe
    80005cd8:	790080e7          	jalr	1936(ra) # 80004464 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cdc:	08000613          	li	a2,128
    80005ce0:	f6040593          	addi	a1,s0,-160
    80005ce4:	4501                	li	a0,0
    80005ce6:	ffffd097          	auipc	ra,0xffffd
    80005cea:	116080e7          	jalr	278(ra) # 80002dfc <argstr>
    80005cee:	04054b63          	bltz	a0,80005d44 <sys_chdir+0x86>
    80005cf2:	f6040513          	addi	a0,s0,-160
    80005cf6:	ffffe097          	auipc	ra,0xffffe
    80005cfa:	552080e7          	jalr	1362(ra) # 80004248 <namei>
    80005cfe:	84aa                	mv	s1,a0
    80005d00:	c131                	beqz	a0,80005d44 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d02:	ffffe097          	auipc	ra,0xffffe
    80005d06:	da0080e7          	jalr	-608(ra) # 80003aa2 <ilock>
  if(ip->type != T_DIR){
    80005d0a:	04449703          	lh	a4,68(s1)
    80005d0e:	4785                	li	a5,1
    80005d10:	04f71063          	bne	a4,a5,80005d50 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d14:	8526                	mv	a0,s1
    80005d16:	ffffe097          	auipc	ra,0xffffe
    80005d1a:	e4e080e7          	jalr	-434(ra) # 80003b64 <iunlock>
  iput(p->cwd);
    80005d1e:	18893503          	ld	a0,392(s2)
    80005d22:	ffffe097          	auipc	ra,0xffffe
    80005d26:	f3a080e7          	jalr	-198(ra) # 80003c5c <iput>
  end_op();
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	7ba080e7          	jalr	1978(ra) # 800044e4 <end_op>
  p->cwd = ip;
    80005d32:	18993423          	sd	s1,392(s2)
  return 0;
    80005d36:	4501                	li	a0,0
}
    80005d38:	60ea                	ld	ra,152(sp)
    80005d3a:	644a                	ld	s0,144(sp)
    80005d3c:	64aa                	ld	s1,136(sp)
    80005d3e:	690a                	ld	s2,128(sp)
    80005d40:	610d                	addi	sp,sp,160
    80005d42:	8082                	ret
    end_op();
    80005d44:	ffffe097          	auipc	ra,0xffffe
    80005d48:	7a0080e7          	jalr	1952(ra) # 800044e4 <end_op>
    return -1;
    80005d4c:	557d                	li	a0,-1
    80005d4e:	b7ed                	j	80005d38 <sys_chdir+0x7a>
    iunlockput(ip);
    80005d50:	8526                	mv	a0,s1
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	fb2080e7          	jalr	-78(ra) # 80003d04 <iunlockput>
    end_op();
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	78a080e7          	jalr	1930(ra) # 800044e4 <end_op>
    return -1;
    80005d62:	557d                	li	a0,-1
    80005d64:	bfd1                	j	80005d38 <sys_chdir+0x7a>

0000000080005d66 <sys_exec>:

uint64
sys_exec(void)
{
    80005d66:	7145                	addi	sp,sp,-464
    80005d68:	e786                	sd	ra,456(sp)
    80005d6a:	e3a2                	sd	s0,448(sp)
    80005d6c:	ff26                	sd	s1,440(sp)
    80005d6e:	fb4a                	sd	s2,432(sp)
    80005d70:	f74e                	sd	s3,424(sp)
    80005d72:	f352                	sd	s4,416(sp)
    80005d74:	ef56                	sd	s5,408(sp)
    80005d76:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005d78:	e3840593          	addi	a1,s0,-456
    80005d7c:	4505                	li	a0,1
    80005d7e:	ffffd097          	auipc	ra,0xffffd
    80005d82:	05e080e7          	jalr	94(ra) # 80002ddc <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005d86:	08000613          	li	a2,128
    80005d8a:	f4040593          	addi	a1,s0,-192
    80005d8e:	4501                	li	a0,0
    80005d90:	ffffd097          	auipc	ra,0xffffd
    80005d94:	06c080e7          	jalr	108(ra) # 80002dfc <argstr>
    80005d98:	87aa                	mv	a5,a0
    return -1;
    80005d9a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d9c:	0c07c263          	bltz	a5,80005e60 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005da0:	10000613          	li	a2,256
    80005da4:	4581                	li	a1,0
    80005da6:	e4040513          	addi	a0,s0,-448
    80005daa:	ffffb097          	auipc	ra,0xffffb
    80005dae:	f28080e7          	jalr	-216(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005db2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005db6:	89a6                	mv	s3,s1
    80005db8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005dba:	02000a13          	li	s4,32
    80005dbe:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005dc2:	00391793          	slli	a5,s2,0x3
    80005dc6:	e3040593          	addi	a1,s0,-464
    80005dca:	e3843503          	ld	a0,-456(s0)
    80005dce:	953e                	add	a0,a0,a5
    80005dd0:	ffffd097          	auipc	ra,0xffffd
    80005dd4:	f4e080e7          	jalr	-178(ra) # 80002d1e <fetchaddr>
    80005dd8:	02054a63          	bltz	a0,80005e0c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005ddc:	e3043783          	ld	a5,-464(s0)
    80005de0:	c3b9                	beqz	a5,80005e26 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005de2:	ffffb097          	auipc	ra,0xffffb
    80005de6:	d04080e7          	jalr	-764(ra) # 80000ae6 <kalloc>
    80005dea:	85aa                	mv	a1,a0
    80005dec:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005df0:	cd11                	beqz	a0,80005e0c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005df2:	6605                	lui	a2,0x1
    80005df4:	e3043503          	ld	a0,-464(s0)
    80005df8:	ffffd097          	auipc	ra,0xffffd
    80005dfc:	f78080e7          	jalr	-136(ra) # 80002d70 <fetchstr>
    80005e00:	00054663          	bltz	a0,80005e0c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005e04:	0905                	addi	s2,s2,1
    80005e06:	09a1                	addi	s3,s3,8
    80005e08:	fb491be3          	bne	s2,s4,80005dbe <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e0c:	10048913          	addi	s2,s1,256
    80005e10:	6088                	ld	a0,0(s1)
    80005e12:	c531                	beqz	a0,80005e5e <sys_exec+0xf8>
    kfree(argv[i]);
    80005e14:	ffffb097          	auipc	ra,0xffffb
    80005e18:	bd6080e7          	jalr	-1066(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e1c:	04a1                	addi	s1,s1,8
    80005e1e:	ff2499e3          	bne	s1,s2,80005e10 <sys_exec+0xaa>
  return -1;
    80005e22:	557d                	li	a0,-1
    80005e24:	a835                	j	80005e60 <sys_exec+0xfa>
      argv[i] = 0;
    80005e26:	0a8e                	slli	s5,s5,0x3
    80005e28:	fc040793          	addi	a5,s0,-64
    80005e2c:	9abe                	add	s5,s5,a5
    80005e2e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005e32:	e4040593          	addi	a1,s0,-448
    80005e36:	f4040513          	addi	a0,s0,-192
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	170080e7          	jalr	368(ra) # 80004faa <exec>
    80005e42:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e44:	10048993          	addi	s3,s1,256
    80005e48:	6088                	ld	a0,0(s1)
    80005e4a:	c901                	beqz	a0,80005e5a <sys_exec+0xf4>
    kfree(argv[i]);
    80005e4c:	ffffb097          	auipc	ra,0xffffb
    80005e50:	b9e080e7          	jalr	-1122(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e54:	04a1                	addi	s1,s1,8
    80005e56:	ff3499e3          	bne	s1,s3,80005e48 <sys_exec+0xe2>
  return ret;
    80005e5a:	854a                	mv	a0,s2
    80005e5c:	a011                	j	80005e60 <sys_exec+0xfa>
  return -1;
    80005e5e:	557d                	li	a0,-1
}
    80005e60:	60be                	ld	ra,456(sp)
    80005e62:	641e                	ld	s0,448(sp)
    80005e64:	74fa                	ld	s1,440(sp)
    80005e66:	795a                	ld	s2,432(sp)
    80005e68:	79ba                	ld	s3,424(sp)
    80005e6a:	7a1a                	ld	s4,416(sp)
    80005e6c:	6afa                	ld	s5,408(sp)
    80005e6e:	6179                	addi	sp,sp,464
    80005e70:	8082                	ret

0000000080005e72 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e72:	7139                	addi	sp,sp,-64
    80005e74:	fc06                	sd	ra,56(sp)
    80005e76:	f822                	sd	s0,48(sp)
    80005e78:	f426                	sd	s1,40(sp)
    80005e7a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e7c:	ffffc097          	auipc	ra,0xffffc
    80005e80:	b30080e7          	jalr	-1232(ra) # 800019ac <myproc>
    80005e84:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005e86:	fd840593          	addi	a1,s0,-40
    80005e8a:	4501                	li	a0,0
    80005e8c:	ffffd097          	auipc	ra,0xffffd
    80005e90:	f50080e7          	jalr	-176(ra) # 80002ddc <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005e94:	fc840593          	addi	a1,s0,-56
    80005e98:	fd040513          	addi	a0,s0,-48
    80005e9c:	fffff097          	auipc	ra,0xfffff
    80005ea0:	dc4080e7          	jalr	-572(ra) # 80004c60 <pipealloc>
    return -1;
    80005ea4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ea6:	0c054763          	bltz	a0,80005f74 <sys_pipe+0x102>
  fd0 = -1;
    80005eaa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005eae:	fd043503          	ld	a0,-48(s0)
    80005eb2:	fffff097          	auipc	ra,0xfffff
    80005eb6:	518080e7          	jalr	1304(ra) # 800053ca <fdalloc>
    80005eba:	fca42223          	sw	a0,-60(s0)
    80005ebe:	08054e63          	bltz	a0,80005f5a <sys_pipe+0xe8>
    80005ec2:	fc843503          	ld	a0,-56(s0)
    80005ec6:	fffff097          	auipc	ra,0xfffff
    80005eca:	504080e7          	jalr	1284(ra) # 800053ca <fdalloc>
    80005ece:	fca42023          	sw	a0,-64(s0)
    80005ed2:	06054a63          	bltz	a0,80005f46 <sys_pipe+0xd4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ed6:	4691                	li	a3,4
    80005ed8:	fc440613          	addi	a2,s0,-60
    80005edc:	fd843583          	ld	a1,-40(s0)
    80005ee0:	64c8                	ld	a0,136(s1)
    80005ee2:	ffffb097          	auipc	ra,0xffffb
    80005ee6:	786080e7          	jalr	1926(ra) # 80001668 <copyout>
    80005eea:	02054063          	bltz	a0,80005f0a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005eee:	4691                	li	a3,4
    80005ef0:	fc040613          	addi	a2,s0,-64
    80005ef4:	fd843583          	ld	a1,-40(s0)
    80005ef8:	0591                	addi	a1,a1,4
    80005efa:	64c8                	ld	a0,136(s1)
    80005efc:	ffffb097          	auipc	ra,0xffffb
    80005f00:	76c080e7          	jalr	1900(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f04:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f06:	06055763          	bgez	a0,80005f74 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005f0a:	fc442783          	lw	a5,-60(s0)
    80005f0e:	02078793          	addi	a5,a5,32
    80005f12:	078e                	slli	a5,a5,0x3
    80005f14:	97a6                	add	a5,a5,s1
    80005f16:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005f1a:	fc042503          	lw	a0,-64(s0)
    80005f1e:	02050513          	addi	a0,a0,32
    80005f22:	050e                	slli	a0,a0,0x3
    80005f24:	94aa                	add	s1,s1,a0
    80005f26:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005f2a:	fd043503          	ld	a0,-48(s0)
    80005f2e:	fffff097          	auipc	ra,0xfffff
    80005f32:	a02080e7          	jalr	-1534(ra) # 80004930 <fileclose>
    fileclose(wf);
    80005f36:	fc843503          	ld	a0,-56(s0)
    80005f3a:	fffff097          	auipc	ra,0xfffff
    80005f3e:	9f6080e7          	jalr	-1546(ra) # 80004930 <fileclose>
    return -1;
    80005f42:	57fd                	li	a5,-1
    80005f44:	a805                	j	80005f74 <sys_pipe+0x102>
    if(fd0 >= 0)
    80005f46:	fc442783          	lw	a5,-60(s0)
    80005f4a:	0007c863          	bltz	a5,80005f5a <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005f4e:	02078793          	addi	a5,a5,32
    80005f52:	078e                	slli	a5,a5,0x3
    80005f54:	94be                	add	s1,s1,a5
    80005f56:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005f5a:	fd043503          	ld	a0,-48(s0)
    80005f5e:	fffff097          	auipc	ra,0xfffff
    80005f62:	9d2080e7          	jalr	-1582(ra) # 80004930 <fileclose>
    fileclose(wf);
    80005f66:	fc843503          	ld	a0,-56(s0)
    80005f6a:	fffff097          	auipc	ra,0xfffff
    80005f6e:	9c6080e7          	jalr	-1594(ra) # 80004930 <fileclose>
    return -1;
    80005f72:	57fd                	li	a5,-1
}
    80005f74:	853e                	mv	a0,a5
    80005f76:	70e2                	ld	ra,56(sp)
    80005f78:	7442                	ld	s0,48(sp)
    80005f7a:	74a2                	ld	s1,40(sp)
    80005f7c:	6121                	addi	sp,sp,64
    80005f7e:	8082                	ret

0000000080005f80 <kernelvec>:
    80005f80:	7111                	addi	sp,sp,-256
    80005f82:	e006                	sd	ra,0(sp)
    80005f84:	e40a                	sd	sp,8(sp)
    80005f86:	e80e                	sd	gp,16(sp)
    80005f88:	ec12                	sd	tp,24(sp)
    80005f8a:	f016                	sd	t0,32(sp)
    80005f8c:	f41a                	sd	t1,40(sp)
    80005f8e:	f81e                	sd	t2,48(sp)
    80005f90:	fc22                	sd	s0,56(sp)
    80005f92:	e0a6                	sd	s1,64(sp)
    80005f94:	e4aa                	sd	a0,72(sp)
    80005f96:	e8ae                	sd	a1,80(sp)
    80005f98:	ecb2                	sd	a2,88(sp)
    80005f9a:	f0b6                	sd	a3,96(sp)
    80005f9c:	f4ba                	sd	a4,104(sp)
    80005f9e:	f8be                	sd	a5,112(sp)
    80005fa0:	fcc2                	sd	a6,120(sp)
    80005fa2:	e146                	sd	a7,128(sp)
    80005fa4:	e54a                	sd	s2,136(sp)
    80005fa6:	e94e                	sd	s3,144(sp)
    80005fa8:	ed52                	sd	s4,152(sp)
    80005faa:	f156                	sd	s5,160(sp)
    80005fac:	f55a                	sd	s6,168(sp)
    80005fae:	f95e                	sd	s7,176(sp)
    80005fb0:	fd62                	sd	s8,184(sp)
    80005fb2:	e1e6                	sd	s9,192(sp)
    80005fb4:	e5ea                	sd	s10,200(sp)
    80005fb6:	e9ee                	sd	s11,208(sp)
    80005fb8:	edf2                	sd	t3,216(sp)
    80005fba:	f1f6                	sd	t4,224(sp)
    80005fbc:	f5fa                	sd	t5,232(sp)
    80005fbe:	f9fe                	sd	t6,240(sp)
    80005fc0:	c0ffc0ef          	jal	ra,80002bce <kerneltrap>
    80005fc4:	6082                	ld	ra,0(sp)
    80005fc6:	6122                	ld	sp,8(sp)
    80005fc8:	61c2                	ld	gp,16(sp)
    80005fca:	7282                	ld	t0,32(sp)
    80005fcc:	7322                	ld	t1,40(sp)
    80005fce:	73c2                	ld	t2,48(sp)
    80005fd0:	7462                	ld	s0,56(sp)
    80005fd2:	6486                	ld	s1,64(sp)
    80005fd4:	6526                	ld	a0,72(sp)
    80005fd6:	65c6                	ld	a1,80(sp)
    80005fd8:	6666                	ld	a2,88(sp)
    80005fda:	7686                	ld	a3,96(sp)
    80005fdc:	7726                	ld	a4,104(sp)
    80005fde:	77c6                	ld	a5,112(sp)
    80005fe0:	7866                	ld	a6,120(sp)
    80005fe2:	688a                	ld	a7,128(sp)
    80005fe4:	692a                	ld	s2,136(sp)
    80005fe6:	69ca                	ld	s3,144(sp)
    80005fe8:	6a6a                	ld	s4,152(sp)
    80005fea:	7a8a                	ld	s5,160(sp)
    80005fec:	7b2a                	ld	s6,168(sp)
    80005fee:	7bca                	ld	s7,176(sp)
    80005ff0:	7c6a                	ld	s8,184(sp)
    80005ff2:	6c8e                	ld	s9,192(sp)
    80005ff4:	6d2e                	ld	s10,200(sp)
    80005ff6:	6dce                	ld	s11,208(sp)
    80005ff8:	6e6e                	ld	t3,216(sp)
    80005ffa:	7e8e                	ld	t4,224(sp)
    80005ffc:	7f2e                	ld	t5,232(sp)
    80005ffe:	7fce                	ld	t6,240(sp)
    80006000:	6111                	addi	sp,sp,256
    80006002:	10200073          	sret
    80006006:	00000013          	nop
    8000600a:	00000013          	nop
    8000600e:	0001                	nop

0000000080006010 <timervec>:
    80006010:	34051573          	csrrw	a0,mscratch,a0
    80006014:	e10c                	sd	a1,0(a0)
    80006016:	e510                	sd	a2,8(a0)
    80006018:	e914                	sd	a3,16(a0)
    8000601a:	6d0c                	ld	a1,24(a0)
    8000601c:	7110                	ld	a2,32(a0)
    8000601e:	6194                	ld	a3,0(a1)
    80006020:	96b2                	add	a3,a3,a2
    80006022:	e194                	sd	a3,0(a1)
    80006024:	4589                	li	a1,2
    80006026:	14459073          	csrw	sip,a1
    8000602a:	6914                	ld	a3,16(a0)
    8000602c:	6510                	ld	a2,8(a0)
    8000602e:	610c                	ld	a1,0(a0)
    80006030:	34051573          	csrrw	a0,mscratch,a0
    80006034:	30200073          	mret
	...

000000008000603a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000603a:	1141                	addi	sp,sp,-16
    8000603c:	e422                	sd	s0,8(sp)
    8000603e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006040:	0c0007b7          	lui	a5,0xc000
    80006044:	4705                	li	a4,1
    80006046:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006048:	c3d8                	sw	a4,4(a5)
}
    8000604a:	6422                	ld	s0,8(sp)
    8000604c:	0141                	addi	sp,sp,16
    8000604e:	8082                	ret

0000000080006050 <plicinithart>:

void
plicinithart(void)
{
    80006050:	1141                	addi	sp,sp,-16
    80006052:	e406                	sd	ra,8(sp)
    80006054:	e022                	sd	s0,0(sp)
    80006056:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	928080e7          	jalr	-1752(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006060:	0085171b          	slliw	a4,a0,0x8
    80006064:	0c0027b7          	lui	a5,0xc002
    80006068:	97ba                	add	a5,a5,a4
    8000606a:	40200713          	li	a4,1026
    8000606e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006072:	00d5151b          	slliw	a0,a0,0xd
    80006076:	0c2017b7          	lui	a5,0xc201
    8000607a:	953e                	add	a0,a0,a5
    8000607c:	00052023          	sw	zero,0(a0)
}
    80006080:	60a2                	ld	ra,8(sp)
    80006082:	6402                	ld	s0,0(sp)
    80006084:	0141                	addi	sp,sp,16
    80006086:	8082                	ret

0000000080006088 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006088:	1141                	addi	sp,sp,-16
    8000608a:	e406                	sd	ra,8(sp)
    8000608c:	e022                	sd	s0,0(sp)
    8000608e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006090:	ffffc097          	auipc	ra,0xffffc
    80006094:	8f0080e7          	jalr	-1808(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006098:	00d5179b          	slliw	a5,a0,0xd
    8000609c:	0c201537          	lui	a0,0xc201
    800060a0:	953e                	add	a0,a0,a5
  return irq;
}
    800060a2:	4148                	lw	a0,4(a0)
    800060a4:	60a2                	ld	ra,8(sp)
    800060a6:	6402                	ld	s0,0(sp)
    800060a8:	0141                	addi	sp,sp,16
    800060aa:	8082                	ret

00000000800060ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060ac:	1101                	addi	sp,sp,-32
    800060ae:	ec06                	sd	ra,24(sp)
    800060b0:	e822                	sd	s0,16(sp)
    800060b2:	e426                	sd	s1,8(sp)
    800060b4:	1000                	addi	s0,sp,32
    800060b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060b8:	ffffc097          	auipc	ra,0xffffc
    800060bc:	8c8080e7          	jalr	-1848(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060c0:	00d5151b          	slliw	a0,a0,0xd
    800060c4:	0c2017b7          	lui	a5,0xc201
    800060c8:	97aa                	add	a5,a5,a0
    800060ca:	c3c4                	sw	s1,4(a5)
}
    800060cc:	60e2                	ld	ra,24(sp)
    800060ce:	6442                	ld	s0,16(sp)
    800060d0:	64a2                	ld	s1,8(sp)
    800060d2:	6105                	addi	sp,sp,32
    800060d4:	8082                	ret

00000000800060d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060d6:	1141                	addi	sp,sp,-16
    800060d8:	e406                	sd	ra,8(sp)
    800060da:	e022                	sd	s0,0(sp)
    800060dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060de:	479d                	li	a5,7
    800060e0:	04a7cc63          	blt	a5,a0,80006138 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800060e4:	0001d797          	auipc	a5,0x1d
    800060e8:	d4c78793          	addi	a5,a5,-692 # 80022e30 <disk>
    800060ec:	97aa                	add	a5,a5,a0
    800060ee:	0187c783          	lbu	a5,24(a5)
    800060f2:	ebb9                	bnez	a5,80006148 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060f4:	00451613          	slli	a2,a0,0x4
    800060f8:	0001d797          	auipc	a5,0x1d
    800060fc:	d3878793          	addi	a5,a5,-712 # 80022e30 <disk>
    80006100:	6394                	ld	a3,0(a5)
    80006102:	96b2                	add	a3,a3,a2
    80006104:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006108:	6398                	ld	a4,0(a5)
    8000610a:	9732                	add	a4,a4,a2
    8000610c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006110:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006114:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006118:	953e                	add	a0,a0,a5
    8000611a:	4785                	li	a5,1
    8000611c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006120:	0001d517          	auipc	a0,0x1d
    80006124:	d2850513          	addi	a0,a0,-728 # 80022e48 <disk+0x18>
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	fee080e7          	jalr	-18(ra) # 80002116 <wakeup>
}
    80006130:	60a2                	ld	ra,8(sp)
    80006132:	6402                	ld	s0,0(sp)
    80006134:	0141                	addi	sp,sp,16
    80006136:	8082                	ret
    panic("free_desc 1");
    80006138:	00002517          	auipc	a0,0x2
    8000613c:	62850513          	addi	a0,a0,1576 # 80008760 <syscalls+0x310>
    80006140:	ffffa097          	auipc	ra,0xffffa
    80006144:	3fe080e7          	jalr	1022(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006148:	00002517          	auipc	a0,0x2
    8000614c:	62850513          	addi	a0,a0,1576 # 80008770 <syscalls+0x320>
    80006150:	ffffa097          	auipc	ra,0xffffa
    80006154:	3ee080e7          	jalr	1006(ra) # 8000053e <panic>

0000000080006158 <virtio_disk_init>:
{
    80006158:	1101                	addi	sp,sp,-32
    8000615a:	ec06                	sd	ra,24(sp)
    8000615c:	e822                	sd	s0,16(sp)
    8000615e:	e426                	sd	s1,8(sp)
    80006160:	e04a                	sd	s2,0(sp)
    80006162:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006164:	00002597          	auipc	a1,0x2
    80006168:	61c58593          	addi	a1,a1,1564 # 80008780 <syscalls+0x330>
    8000616c:	0001d517          	auipc	a0,0x1d
    80006170:	dec50513          	addi	a0,a0,-532 # 80022f58 <disk+0x128>
    80006174:	ffffb097          	auipc	ra,0xffffb
    80006178:	9d2080e7          	jalr	-1582(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000617c:	100017b7          	lui	a5,0x10001
    80006180:	4398                	lw	a4,0(a5)
    80006182:	2701                	sext.w	a4,a4
    80006184:	747277b7          	lui	a5,0x74727
    80006188:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000618c:	14f71c63          	bne	a4,a5,800062e4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006190:	100017b7          	lui	a5,0x10001
    80006194:	43dc                	lw	a5,4(a5)
    80006196:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006198:	4709                	li	a4,2
    8000619a:	14e79563          	bne	a5,a4,800062e4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000619e:	100017b7          	lui	a5,0x10001
    800061a2:	479c                	lw	a5,8(a5)
    800061a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061a6:	12e79f63          	bne	a5,a4,800062e4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061aa:	100017b7          	lui	a5,0x10001
    800061ae:	47d8                	lw	a4,12(a5)
    800061b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061b2:	554d47b7          	lui	a5,0x554d4
    800061b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061ba:	12f71563          	bne	a4,a5,800062e4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061be:	100017b7          	lui	a5,0x10001
    800061c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c6:	4705                	li	a4,1
    800061c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061ca:	470d                	li	a4,3
    800061cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061ce:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061d0:	c7ffe737          	lui	a4,0xc7ffe
    800061d4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb7ef>
    800061d8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061da:	2701                	sext.w	a4,a4
    800061dc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061de:	472d                	li	a4,11
    800061e0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800061e2:	5bbc                	lw	a5,112(a5)
    800061e4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800061e8:	8ba1                	andi	a5,a5,8
    800061ea:	10078563          	beqz	a5,800062f4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061ee:	100017b7          	lui	a5,0x10001
    800061f2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800061f6:	43fc                	lw	a5,68(a5)
    800061f8:	2781                	sext.w	a5,a5
    800061fa:	10079563          	bnez	a5,80006304 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061fe:	100017b7          	lui	a5,0x10001
    80006202:	5bdc                	lw	a5,52(a5)
    80006204:	2781                	sext.w	a5,a5
  if(max == 0)
    80006206:	10078763          	beqz	a5,80006314 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000620a:	471d                	li	a4,7
    8000620c:	10f77c63          	bgeu	a4,a5,80006324 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006210:	ffffb097          	auipc	ra,0xffffb
    80006214:	8d6080e7          	jalr	-1834(ra) # 80000ae6 <kalloc>
    80006218:	0001d497          	auipc	s1,0x1d
    8000621c:	c1848493          	addi	s1,s1,-1000 # 80022e30 <disk>
    80006220:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006222:	ffffb097          	auipc	ra,0xffffb
    80006226:	8c4080e7          	jalr	-1852(ra) # 80000ae6 <kalloc>
    8000622a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000622c:	ffffb097          	auipc	ra,0xffffb
    80006230:	8ba080e7          	jalr	-1862(ra) # 80000ae6 <kalloc>
    80006234:	87aa                	mv	a5,a0
    80006236:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006238:	6088                	ld	a0,0(s1)
    8000623a:	cd6d                	beqz	a0,80006334 <virtio_disk_init+0x1dc>
    8000623c:	0001d717          	auipc	a4,0x1d
    80006240:	bfc73703          	ld	a4,-1028(a4) # 80022e38 <disk+0x8>
    80006244:	cb65                	beqz	a4,80006334 <virtio_disk_init+0x1dc>
    80006246:	c7fd                	beqz	a5,80006334 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006248:	6605                	lui	a2,0x1
    8000624a:	4581                	li	a1,0
    8000624c:	ffffb097          	auipc	ra,0xffffb
    80006250:	a86080e7          	jalr	-1402(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006254:	0001d497          	auipc	s1,0x1d
    80006258:	bdc48493          	addi	s1,s1,-1060 # 80022e30 <disk>
    8000625c:	6605                	lui	a2,0x1
    8000625e:	4581                	li	a1,0
    80006260:	6488                	ld	a0,8(s1)
    80006262:	ffffb097          	auipc	ra,0xffffb
    80006266:	a70080e7          	jalr	-1424(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000626a:	6605                	lui	a2,0x1
    8000626c:	4581                	li	a1,0
    8000626e:	6888                	ld	a0,16(s1)
    80006270:	ffffb097          	auipc	ra,0xffffb
    80006274:	a62080e7          	jalr	-1438(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006278:	100017b7          	lui	a5,0x10001
    8000627c:	4721                	li	a4,8
    8000627e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006280:	4098                	lw	a4,0(s1)
    80006282:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006286:	40d8                	lw	a4,4(s1)
    80006288:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000628c:	6498                	ld	a4,8(s1)
    8000628e:	0007069b          	sext.w	a3,a4
    80006292:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006296:	9701                	srai	a4,a4,0x20
    80006298:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000629c:	6898                	ld	a4,16(s1)
    8000629e:	0007069b          	sext.w	a3,a4
    800062a2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800062a6:	9701                	srai	a4,a4,0x20
    800062a8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800062ac:	4705                	li	a4,1
    800062ae:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800062b0:	00e48c23          	sb	a4,24(s1)
    800062b4:	00e48ca3          	sb	a4,25(s1)
    800062b8:	00e48d23          	sb	a4,26(s1)
    800062bc:	00e48da3          	sb	a4,27(s1)
    800062c0:	00e48e23          	sb	a4,28(s1)
    800062c4:	00e48ea3          	sb	a4,29(s1)
    800062c8:	00e48f23          	sb	a4,30(s1)
    800062cc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800062d0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800062d4:	0727a823          	sw	s2,112(a5)
}
    800062d8:	60e2                	ld	ra,24(sp)
    800062da:	6442                	ld	s0,16(sp)
    800062dc:	64a2                	ld	s1,8(sp)
    800062de:	6902                	ld	s2,0(sp)
    800062e0:	6105                	addi	sp,sp,32
    800062e2:	8082                	ret
    panic("could not find virtio disk");
    800062e4:	00002517          	auipc	a0,0x2
    800062e8:	4ac50513          	addi	a0,a0,1196 # 80008790 <syscalls+0x340>
    800062ec:	ffffa097          	auipc	ra,0xffffa
    800062f0:	252080e7          	jalr	594(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800062f4:	00002517          	auipc	a0,0x2
    800062f8:	4bc50513          	addi	a0,a0,1212 # 800087b0 <syscalls+0x360>
    800062fc:	ffffa097          	auipc	ra,0xffffa
    80006300:	242080e7          	jalr	578(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006304:	00002517          	auipc	a0,0x2
    80006308:	4cc50513          	addi	a0,a0,1228 # 800087d0 <syscalls+0x380>
    8000630c:	ffffa097          	auipc	ra,0xffffa
    80006310:	232080e7          	jalr	562(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006314:	00002517          	auipc	a0,0x2
    80006318:	4dc50513          	addi	a0,a0,1244 # 800087f0 <syscalls+0x3a0>
    8000631c:	ffffa097          	auipc	ra,0xffffa
    80006320:	222080e7          	jalr	546(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006324:	00002517          	auipc	a0,0x2
    80006328:	4ec50513          	addi	a0,a0,1260 # 80008810 <syscalls+0x3c0>
    8000632c:	ffffa097          	auipc	ra,0xffffa
    80006330:	212080e7          	jalr	530(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006334:	00002517          	auipc	a0,0x2
    80006338:	4fc50513          	addi	a0,a0,1276 # 80008830 <syscalls+0x3e0>
    8000633c:	ffffa097          	auipc	ra,0xffffa
    80006340:	202080e7          	jalr	514(ra) # 8000053e <panic>

0000000080006344 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006344:	7119                	addi	sp,sp,-128
    80006346:	fc86                	sd	ra,120(sp)
    80006348:	f8a2                	sd	s0,112(sp)
    8000634a:	f4a6                	sd	s1,104(sp)
    8000634c:	f0ca                	sd	s2,96(sp)
    8000634e:	ecce                	sd	s3,88(sp)
    80006350:	e8d2                	sd	s4,80(sp)
    80006352:	e4d6                	sd	s5,72(sp)
    80006354:	e0da                	sd	s6,64(sp)
    80006356:	fc5e                	sd	s7,56(sp)
    80006358:	f862                	sd	s8,48(sp)
    8000635a:	f466                	sd	s9,40(sp)
    8000635c:	f06a                	sd	s10,32(sp)
    8000635e:	ec6e                	sd	s11,24(sp)
    80006360:	0100                	addi	s0,sp,128
    80006362:	8aaa                	mv	s5,a0
    80006364:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006366:	00c52d03          	lw	s10,12(a0)
    8000636a:	001d1d1b          	slliw	s10,s10,0x1
    8000636e:	1d02                	slli	s10,s10,0x20
    80006370:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006374:	0001d517          	auipc	a0,0x1d
    80006378:	be450513          	addi	a0,a0,-1052 # 80022f58 <disk+0x128>
    8000637c:	ffffb097          	auipc	ra,0xffffb
    80006380:	85a080e7          	jalr	-1958(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006384:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006386:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006388:	0001db97          	auipc	s7,0x1d
    8000638c:	aa8b8b93          	addi	s7,s7,-1368 # 80022e30 <disk>
  for(int i = 0; i < 3; i++){
    80006390:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006392:	0001dc97          	auipc	s9,0x1d
    80006396:	bc6c8c93          	addi	s9,s9,-1082 # 80022f58 <disk+0x128>
    8000639a:	a08d                	j	800063fc <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000639c:	00fb8733          	add	a4,s7,a5
    800063a0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800063a4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800063a6:	0207c563          	bltz	a5,800063d0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800063aa:	2905                	addiw	s2,s2,1
    800063ac:	0611                	addi	a2,a2,4
    800063ae:	05690c63          	beq	s2,s6,80006406 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800063b2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800063b4:	0001d717          	auipc	a4,0x1d
    800063b8:	a7c70713          	addi	a4,a4,-1412 # 80022e30 <disk>
    800063bc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800063be:	01874683          	lbu	a3,24(a4)
    800063c2:	fee9                	bnez	a3,8000639c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800063c4:	2785                	addiw	a5,a5,1
    800063c6:	0705                	addi	a4,a4,1
    800063c8:	fe979be3          	bne	a5,s1,800063be <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800063cc:	57fd                	li	a5,-1
    800063ce:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800063d0:	01205d63          	blez	s2,800063ea <virtio_disk_rw+0xa6>
    800063d4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800063d6:	000a2503          	lw	a0,0(s4)
    800063da:	00000097          	auipc	ra,0x0
    800063de:	cfc080e7          	jalr	-772(ra) # 800060d6 <free_desc>
      for(int j = 0; j < i; j++)
    800063e2:	2d85                	addiw	s11,s11,1
    800063e4:	0a11                	addi	s4,s4,4
    800063e6:	ffb918e3          	bne	s2,s11,800063d6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063ea:	85e6                	mv	a1,s9
    800063ec:	0001d517          	auipc	a0,0x1d
    800063f0:	a5c50513          	addi	a0,a0,-1444 # 80022e48 <disk+0x18>
    800063f4:	ffffc097          	auipc	ra,0xffffc
    800063f8:	cbe080e7          	jalr	-834(ra) # 800020b2 <sleep>
  for(int i = 0; i < 3; i++){
    800063fc:	f8040a13          	addi	s4,s0,-128
{
    80006400:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006402:	894e                	mv	s2,s3
    80006404:	b77d                	j	800063b2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006406:	f8042583          	lw	a1,-128(s0)
    8000640a:	00a58793          	addi	a5,a1,10
    8000640e:	0792                	slli	a5,a5,0x4

  if(write)
    80006410:	0001d617          	auipc	a2,0x1d
    80006414:	a2060613          	addi	a2,a2,-1504 # 80022e30 <disk>
    80006418:	00f60733          	add	a4,a2,a5
    8000641c:	018036b3          	snez	a3,s8
    80006420:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006422:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006426:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000642a:	f6078693          	addi	a3,a5,-160
    8000642e:	6218                	ld	a4,0(a2)
    80006430:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006432:	00878513          	addi	a0,a5,8
    80006436:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006438:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000643a:	6208                	ld	a0,0(a2)
    8000643c:	96aa                	add	a3,a3,a0
    8000643e:	4741                	li	a4,16
    80006440:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006442:	4705                	li	a4,1
    80006444:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006448:	f8442703          	lw	a4,-124(s0)
    8000644c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006450:	0712                	slli	a4,a4,0x4
    80006452:	953a                	add	a0,a0,a4
    80006454:	058a8693          	addi	a3,s5,88
    80006458:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000645a:	6208                	ld	a0,0(a2)
    8000645c:	972a                	add	a4,a4,a0
    8000645e:	40000693          	li	a3,1024
    80006462:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006464:	001c3c13          	seqz	s8,s8
    80006468:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000646a:	001c6c13          	ori	s8,s8,1
    8000646e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006472:	f8842603          	lw	a2,-120(s0)
    80006476:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000647a:	0001d697          	auipc	a3,0x1d
    8000647e:	9b668693          	addi	a3,a3,-1610 # 80022e30 <disk>
    80006482:	00258713          	addi	a4,a1,2
    80006486:	0712                	slli	a4,a4,0x4
    80006488:	9736                	add	a4,a4,a3
    8000648a:	587d                	li	a6,-1
    8000648c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006490:	0612                	slli	a2,a2,0x4
    80006492:	9532                	add	a0,a0,a2
    80006494:	f9078793          	addi	a5,a5,-112
    80006498:	97b6                	add	a5,a5,a3
    8000649a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000649c:	629c                	ld	a5,0(a3)
    8000649e:	97b2                	add	a5,a5,a2
    800064a0:	4605                	li	a2,1
    800064a2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800064a4:	4509                	li	a0,2
    800064a6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800064aa:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800064ae:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800064b2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800064b6:	6698                	ld	a4,8(a3)
    800064b8:	00275783          	lhu	a5,2(a4)
    800064bc:	8b9d                	andi	a5,a5,7
    800064be:	0786                	slli	a5,a5,0x1
    800064c0:	97ba                	add	a5,a5,a4
    800064c2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800064c6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800064ca:	6698                	ld	a4,8(a3)
    800064cc:	00275783          	lhu	a5,2(a4)
    800064d0:	2785                	addiw	a5,a5,1
    800064d2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800064d6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800064da:	100017b7          	lui	a5,0x10001
    800064de:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800064e2:	004aa783          	lw	a5,4(s5)
    800064e6:	02c79163          	bne	a5,a2,80006508 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800064ea:	0001d917          	auipc	s2,0x1d
    800064ee:	a6e90913          	addi	s2,s2,-1426 # 80022f58 <disk+0x128>
  while(b->disk == 1) {
    800064f2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800064f4:	85ca                	mv	a1,s2
    800064f6:	8556                	mv	a0,s5
    800064f8:	ffffc097          	auipc	ra,0xffffc
    800064fc:	bba080e7          	jalr	-1094(ra) # 800020b2 <sleep>
  while(b->disk == 1) {
    80006500:	004aa783          	lw	a5,4(s5)
    80006504:	fe9788e3          	beq	a5,s1,800064f4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006508:	f8042903          	lw	s2,-128(s0)
    8000650c:	00290793          	addi	a5,s2,2
    80006510:	00479713          	slli	a4,a5,0x4
    80006514:	0001d797          	auipc	a5,0x1d
    80006518:	91c78793          	addi	a5,a5,-1764 # 80022e30 <disk>
    8000651c:	97ba                	add	a5,a5,a4
    8000651e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006522:	0001d997          	auipc	s3,0x1d
    80006526:	90e98993          	addi	s3,s3,-1778 # 80022e30 <disk>
    8000652a:	00491713          	slli	a4,s2,0x4
    8000652e:	0009b783          	ld	a5,0(s3)
    80006532:	97ba                	add	a5,a5,a4
    80006534:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006538:	854a                	mv	a0,s2
    8000653a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000653e:	00000097          	auipc	ra,0x0
    80006542:	b98080e7          	jalr	-1128(ra) # 800060d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006546:	8885                	andi	s1,s1,1
    80006548:	f0ed                	bnez	s1,8000652a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000654a:	0001d517          	auipc	a0,0x1d
    8000654e:	a0e50513          	addi	a0,a0,-1522 # 80022f58 <disk+0x128>
    80006552:	ffffa097          	auipc	ra,0xffffa
    80006556:	738080e7          	jalr	1848(ra) # 80000c8a <release>
}
    8000655a:	70e6                	ld	ra,120(sp)
    8000655c:	7446                	ld	s0,112(sp)
    8000655e:	74a6                	ld	s1,104(sp)
    80006560:	7906                	ld	s2,96(sp)
    80006562:	69e6                	ld	s3,88(sp)
    80006564:	6a46                	ld	s4,80(sp)
    80006566:	6aa6                	ld	s5,72(sp)
    80006568:	6b06                	ld	s6,64(sp)
    8000656a:	7be2                	ld	s7,56(sp)
    8000656c:	7c42                	ld	s8,48(sp)
    8000656e:	7ca2                	ld	s9,40(sp)
    80006570:	7d02                	ld	s10,32(sp)
    80006572:	6de2                	ld	s11,24(sp)
    80006574:	6109                	addi	sp,sp,128
    80006576:	8082                	ret

0000000080006578 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006578:	1101                	addi	sp,sp,-32
    8000657a:	ec06                	sd	ra,24(sp)
    8000657c:	e822                	sd	s0,16(sp)
    8000657e:	e426                	sd	s1,8(sp)
    80006580:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006582:	0001d497          	auipc	s1,0x1d
    80006586:	8ae48493          	addi	s1,s1,-1874 # 80022e30 <disk>
    8000658a:	0001d517          	auipc	a0,0x1d
    8000658e:	9ce50513          	addi	a0,a0,-1586 # 80022f58 <disk+0x128>
    80006592:	ffffa097          	auipc	ra,0xffffa
    80006596:	644080e7          	jalr	1604(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000659a:	10001737          	lui	a4,0x10001
    8000659e:	533c                	lw	a5,96(a4)
    800065a0:	8b8d                	andi	a5,a5,3
    800065a2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800065a4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800065a8:	689c                	ld	a5,16(s1)
    800065aa:	0204d703          	lhu	a4,32(s1)
    800065ae:	0027d783          	lhu	a5,2(a5)
    800065b2:	04f70863          	beq	a4,a5,80006602 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800065b6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065ba:	6898                	ld	a4,16(s1)
    800065bc:	0204d783          	lhu	a5,32(s1)
    800065c0:	8b9d                	andi	a5,a5,7
    800065c2:	078e                	slli	a5,a5,0x3
    800065c4:	97ba                	add	a5,a5,a4
    800065c6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800065c8:	00278713          	addi	a4,a5,2
    800065cc:	0712                	slli	a4,a4,0x4
    800065ce:	9726                	add	a4,a4,s1
    800065d0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800065d4:	e721                	bnez	a4,8000661c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065d6:	0789                	addi	a5,a5,2
    800065d8:	0792                	slli	a5,a5,0x4
    800065da:	97a6                	add	a5,a5,s1
    800065dc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800065de:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065e2:	ffffc097          	auipc	ra,0xffffc
    800065e6:	b34080e7          	jalr	-1228(ra) # 80002116 <wakeup>

    disk.used_idx += 1;
    800065ea:	0204d783          	lhu	a5,32(s1)
    800065ee:	2785                	addiw	a5,a5,1
    800065f0:	17c2                	slli	a5,a5,0x30
    800065f2:	93c1                	srli	a5,a5,0x30
    800065f4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065f8:	6898                	ld	a4,16(s1)
    800065fa:	00275703          	lhu	a4,2(a4)
    800065fe:	faf71ce3          	bne	a4,a5,800065b6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006602:	0001d517          	auipc	a0,0x1d
    80006606:	95650513          	addi	a0,a0,-1706 # 80022f58 <disk+0x128>
    8000660a:	ffffa097          	auipc	ra,0xffffa
    8000660e:	680080e7          	jalr	1664(ra) # 80000c8a <release>
}
    80006612:	60e2                	ld	ra,24(sp)
    80006614:	6442                	ld	s0,16(sp)
    80006616:	64a2                	ld	s1,8(sp)
    80006618:	6105                	addi	sp,sp,32
    8000661a:	8082                	ret
      panic("virtio_disk_intr status");
    8000661c:	00002517          	auipc	a0,0x2
    80006620:	22c50513          	addi	a0,a0,556 # 80008848 <syscalls+0x3f8>
    80006624:	ffffa097          	auipc	ra,0xffffa
    80006628:	f1a080e7          	jalr	-230(ra) # 8000053e <panic>
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
