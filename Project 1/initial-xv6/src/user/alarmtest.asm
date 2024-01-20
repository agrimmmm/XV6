
user/_alarmtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <periodic>:
}

volatile static int count;

void periodic()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    count = count + 1;
   8:	00001797          	auipc	a5,0x1
   c:	ff87a783          	lw	a5,-8(a5) # 1000 <count>
  10:	2785                	addiw	a5,a5,1
  12:	00001717          	auipc	a4,0x1
  16:	fef72723          	sw	a5,-18(a4) # 1000 <count>
    printf("alarm!\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	c1650513          	addi	a0,a0,-1002 # c30 <malloc+0xee>
  22:	00001097          	auipc	ra,0x1
  26:	a62080e7          	jalr	-1438(ra) # a84 <printf>
    sigreturn();
  2a:	00000097          	auipc	ra,0x0
  2e:	77a080e7          	jalr	1914(ra) # 7a4 <sigreturn>
}
  32:	60a2                	ld	ra,8(sp)
  34:	6402                	ld	s0,0(sp)
  36:	0141                	addi	sp,sp,16
  38:	8082                	ret

000000000000003a <slow_handler>:
        printf("test2 passed\n");
    }
}

void slow_handler()
{
  3a:	1101                	addi	sp,sp,-32
  3c:	ec06                	sd	ra,24(sp)
  3e:	e822                	sd	s0,16(sp)
  40:	e426                	sd	s1,8(sp)
  42:	1000                	addi	s0,sp,32
    count++;
  44:	00001497          	auipc	s1,0x1
  48:	fbc48493          	addi	s1,s1,-68 # 1000 <count>
  4c:	00001797          	auipc	a5,0x1
  50:	fb47a783          	lw	a5,-76(a5) # 1000 <count>
  54:	2785                	addiw	a5,a5,1
  56:	c09c                	sw	a5,0(s1)
    printf("alarm!\n");
  58:	00001517          	auipc	a0,0x1
  5c:	bd850513          	addi	a0,a0,-1064 # c30 <malloc+0xee>
  60:	00001097          	auipc	ra,0x1
  64:	a24080e7          	jalr	-1500(ra) # a84 <printf>
    if (count > 1)
  68:	4098                	lw	a4,0(s1)
  6a:	2701                	sext.w	a4,a4
  6c:	4685                	li	a3,1
  6e:	1dcd67b7          	lui	a5,0x1dcd6
  72:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
  76:	02e6c463          	blt	a3,a4,9e <slow_handler+0x64>
        printf("test2 failed: alarm handler called more than once\n");
        exit(1);
    }
    for (int i = 0; i < 1000 * 500000; i++)
    {
        asm volatile("nop"); // avoid compiler optimizing away loop
  7a:	0001                	nop
    for (int i = 0; i < 1000 * 500000; i++)
  7c:	37fd                	addiw	a5,a5,-1
  7e:	fff5                	bnez	a5,7a <slow_handler+0x40>
    }
    sigalarm(0, 0);
  80:	4581                	li	a1,0
  82:	4501                	li	a0,0
  84:	00000097          	auipc	ra,0x0
  88:	718080e7          	jalr	1816(ra) # 79c <sigalarm>
    sigreturn();
  8c:	00000097          	auipc	ra,0x0
  90:	718080e7          	jalr	1816(ra) # 7a4 <sigreturn>
}
  94:	60e2                	ld	ra,24(sp)
  96:	6442                	ld	s0,16(sp)
  98:	64a2                	ld	s1,8(sp)
  9a:	6105                	addi	sp,sp,32
  9c:	8082                	ret
        printf("test2 failed: alarm handler called more than once\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	b9a50513          	addi	a0,a0,-1126 # c38 <malloc+0xf6>
  a6:	00001097          	auipc	ra,0x1
  aa:	9de080e7          	jalr	-1570(ra) # a84 <printf>
        exit(1);
  ae:	4505                	li	a0,1
  b0:	00000097          	auipc	ra,0x0
  b4:	63c080e7          	jalr	1596(ra) # 6ec <exit>

00000000000000b8 <dummy_handler>:

//
// dummy alarm handler; after running immediately uninstall
// itself and finish signal handling
void dummy_handler()
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e406                	sd	ra,8(sp)
  bc:	e022                	sd	s0,0(sp)
  be:	0800                	addi	s0,sp,16
    sigalarm(0, 0);
  c0:	4581                	li	a1,0
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	6d8080e7          	jalr	1752(ra) # 79c <sigalarm>
    sigreturn();
  cc:	00000097          	auipc	ra,0x0
  d0:	6d8080e7          	jalr	1752(ra) # 7a4 <sigreturn>
}
  d4:	60a2                	ld	ra,8(sp)
  d6:	6402                	ld	s0,0(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <test0>:
{
  dc:	7139                	addi	sp,sp,-64
  de:	fc06                	sd	ra,56(sp)
  e0:	f822                	sd	s0,48(sp)
  e2:	f426                	sd	s1,40(sp)
  e4:	f04a                	sd	s2,32(sp)
  e6:	ec4e                	sd	s3,24(sp)
  e8:	e852                	sd	s4,16(sp)
  ea:	e456                	sd	s5,8(sp)
  ec:	0080                	addi	s0,sp,64
    printf("test0 start\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	b8250513          	addi	a0,a0,-1150 # c70 <malloc+0x12e>
  f6:	00001097          	auipc	ra,0x1
  fa:	98e080e7          	jalr	-1650(ra) # a84 <printf>
    count = 0;
  fe:	00001797          	auipc	a5,0x1
 102:	f007a123          	sw	zero,-254(a5) # 1000 <count>
    sigalarm(2, periodic);
 106:	00000597          	auipc	a1,0x0
 10a:	efa58593          	addi	a1,a1,-262 # 0 <periodic>
 10e:	4509                	li	a0,2
 110:	00000097          	auipc	ra,0x0
 114:	68c080e7          	jalr	1676(ra) # 79c <sigalarm>
    for (i = 0; i < 1000 * 500000; i++)
 118:	4481                	li	s1,0
        if ((i % 1000000) == 0)
 11a:	000f4937          	lui	s2,0xf4
 11e:	2409091b          	addiw	s2,s2,576
            write(2, ".", 1);
 122:	00001a97          	auipc	s5,0x1
 126:	b5ea8a93          	addi	s5,s5,-1186 # c80 <malloc+0x13e>
        if (count > 0)
 12a:	00001a17          	auipc	s4,0x1
 12e:	ed6a0a13          	addi	s4,s4,-298 # 1000 <count>
    for (i = 0; i < 1000 * 500000; i++)
 132:	1dcd69b7          	lui	s3,0x1dcd6
 136:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 13a:	a809                	j	14c <test0+0x70>
        if (count > 0)
 13c:	000a2783          	lw	a5,0(s4)
 140:	2781                	sext.w	a5,a5
 142:	02f04063          	bgtz	a5,162 <test0+0x86>
    for (i = 0; i < 1000 * 500000; i++)
 146:	2485                	addiw	s1,s1,1
 148:	01348d63          	beq	s1,s3,162 <test0+0x86>
        if ((i % 1000000) == 0)
 14c:	0324e7bb          	remw	a5,s1,s2
 150:	f7f5                	bnez	a5,13c <test0+0x60>
            write(2, ".", 1);
 152:	4605                	li	a2,1
 154:	85d6                	mv	a1,s5
 156:	4509                	li	a0,2
 158:	00000097          	auipc	ra,0x0
 15c:	5b4080e7          	jalr	1460(ra) # 70c <write>
 160:	bff1                	j	13c <test0+0x60>
    sigalarm(0, 0);
 162:	4581                	li	a1,0
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	636080e7          	jalr	1590(ra) # 79c <sigalarm>
    if (count > 0)
 16e:	00001797          	auipc	a5,0x1
 172:	e927a783          	lw	a5,-366(a5) # 1000 <count>
 176:	02f05363          	blez	a5,19c <test0+0xc0>
        printf("test0 passed\n");
 17a:	00001517          	auipc	a0,0x1
 17e:	b0e50513          	addi	a0,a0,-1266 # c88 <malloc+0x146>
 182:	00001097          	auipc	ra,0x1
 186:	902080e7          	jalr	-1790(ra) # a84 <printf>
}
 18a:	70e2                	ld	ra,56(sp)
 18c:	7442                	ld	s0,48(sp)
 18e:	74a2                	ld	s1,40(sp)
 190:	7902                	ld	s2,32(sp)
 192:	69e2                	ld	s3,24(sp)
 194:	6a42                	ld	s4,16(sp)
 196:	6aa2                	ld	s5,8(sp)
 198:	6121                	addi	sp,sp,64
 19a:	8082                	ret
        printf("\ntest0 failed: the kernel never called the alarm handler\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	afc50513          	addi	a0,a0,-1284 # c98 <malloc+0x156>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	8e0080e7          	jalr	-1824(ra) # a84 <printf>
}
 1ac:	bff9                	j	18a <test0+0xae>

00000000000001ae <foo>:
{
 1ae:	1101                	addi	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e426                	sd	s1,8(sp)
 1b6:	1000                	addi	s0,sp,32
 1b8:	84ae                	mv	s1,a1
    if ((i % 2500000) == 0)
 1ba:	002627b7          	lui	a5,0x262
 1be:	5a07879b          	addiw	a5,a5,1440
 1c2:	02f5653b          	remw	a0,a0,a5
 1c6:	c909                	beqz	a0,1d8 <foo+0x2a>
    *j += 1;
 1c8:	409c                	lw	a5,0(s1)
 1ca:	2785                	addiw	a5,a5,1
 1cc:	c09c                	sw	a5,0(s1)
}
 1ce:	60e2                	ld	ra,24(sp)
 1d0:	6442                	ld	s0,16(sp)
 1d2:	64a2                	ld	s1,8(sp)
 1d4:	6105                	addi	sp,sp,32
 1d6:	8082                	ret
        write(2, ".", 1);
 1d8:	4605                	li	a2,1
 1da:	00001597          	auipc	a1,0x1
 1de:	aa658593          	addi	a1,a1,-1370 # c80 <malloc+0x13e>
 1e2:	4509                	li	a0,2
 1e4:	00000097          	auipc	ra,0x0
 1e8:	528080e7          	jalr	1320(ra) # 70c <write>
 1ec:	bff1                	j	1c8 <foo+0x1a>

00000000000001ee <test1>:
{
 1ee:	7139                	addi	sp,sp,-64
 1f0:	fc06                	sd	ra,56(sp)
 1f2:	f822                	sd	s0,48(sp)
 1f4:	f426                	sd	s1,40(sp)
 1f6:	f04a                	sd	s2,32(sp)
 1f8:	ec4e                	sd	s3,24(sp)
 1fa:	e852                	sd	s4,16(sp)
 1fc:	0080                	addi	s0,sp,64
    printf("test1 start\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	ada50513          	addi	a0,a0,-1318 # cd8 <malloc+0x196>
 206:	00001097          	auipc	ra,0x1
 20a:	87e080e7          	jalr	-1922(ra) # a84 <printf>
    count = 0;
 20e:	00001797          	auipc	a5,0x1
 212:	de07a923          	sw	zero,-526(a5) # 1000 <count>
    j = 0;
 216:	fc042623          	sw	zero,-52(s0)
    sigalarm(2, periodic);
 21a:	00000597          	auipc	a1,0x0
 21e:	de658593          	addi	a1,a1,-538 # 0 <periodic>
 222:	4509                	li	a0,2
 224:	00000097          	auipc	ra,0x0
 228:	578080e7          	jalr	1400(ra) # 79c <sigalarm>
    for (i = 0; i < 500000000; i++)
 22c:	4481                	li	s1,0
        if (count >= 10)
 22e:	00001a17          	auipc	s4,0x1
 232:	dd2a0a13          	addi	s4,s4,-558 # 1000 <count>
 236:	49a5                	li	s3,9
    for (i = 0; i < 500000000; i++)
 238:	1dcd6937          	lui	s2,0x1dcd6
 23c:	50090913          	addi	s2,s2,1280 # 1dcd6500 <base+0x1dcd54f0>
        if (count >= 10)
 240:	000a2783          	lw	a5,0(s4)
 244:	2781                	sext.w	a5,a5
 246:	00f9cc63          	blt	s3,a5,25e <test1+0x70>
        foo(i, &j);
 24a:	fcc40593          	addi	a1,s0,-52
 24e:	8526                	mv	a0,s1
 250:	00000097          	auipc	ra,0x0
 254:	f5e080e7          	jalr	-162(ra) # 1ae <foo>
    for (i = 0; i < 500000000; i++)
 258:	2485                	addiw	s1,s1,1
 25a:	ff2493e3          	bne	s1,s2,240 <test1+0x52>
    if (count < 10)
 25e:	00001717          	auipc	a4,0x1
 262:	da272703          	lw	a4,-606(a4) # 1000 <count>
 266:	47a5                	li	a5,9
 268:	02e7d663          	bge	a5,a4,294 <test1+0xa6>
    else if (i != j)
 26c:	fcc42783          	lw	a5,-52(s0)
 270:	02978b63          	beq	a5,s1,2a6 <test1+0xb8>
        printf("\ntest1 failed: foo() executed fewer times than it was called\n");
 274:	00001517          	auipc	a0,0x1
 278:	aa450513          	addi	a0,a0,-1372 # d18 <malloc+0x1d6>
 27c:	00001097          	auipc	ra,0x1
 280:	808080e7          	jalr	-2040(ra) # a84 <printf>
}
 284:	70e2                	ld	ra,56(sp)
 286:	7442                	ld	s0,48(sp)
 288:	74a2                	ld	s1,40(sp)
 28a:	7902                	ld	s2,32(sp)
 28c:	69e2                	ld	s3,24(sp)
 28e:	6a42                	ld	s4,16(sp)
 290:	6121                	addi	sp,sp,64
 292:	8082                	ret
        printf("\ntest1 failed: too few calls to the handler\n");
 294:	00001517          	auipc	a0,0x1
 298:	a5450513          	addi	a0,a0,-1452 # ce8 <malloc+0x1a6>
 29c:	00000097          	auipc	ra,0x0
 2a0:	7e8080e7          	jalr	2024(ra) # a84 <printf>
 2a4:	b7c5                	j	284 <test1+0x96>
        printf("test1 passed\n");
 2a6:	00001517          	auipc	a0,0x1
 2aa:	ab250513          	addi	a0,a0,-1358 # d58 <malloc+0x216>
 2ae:	00000097          	auipc	ra,0x0
 2b2:	7d6080e7          	jalr	2006(ra) # a84 <printf>
}
 2b6:	b7f9                	j	284 <test1+0x96>

00000000000002b8 <test2>:
{
 2b8:	715d                	addi	sp,sp,-80
 2ba:	e486                	sd	ra,72(sp)
 2bc:	e0a2                	sd	s0,64(sp)
 2be:	fc26                	sd	s1,56(sp)
 2c0:	f84a                	sd	s2,48(sp)
 2c2:	f44e                	sd	s3,40(sp)
 2c4:	f052                	sd	s4,32(sp)
 2c6:	ec56                	sd	s5,24(sp)
 2c8:	0880                	addi	s0,sp,80
    printf("test2 start\n");
 2ca:	00001517          	auipc	a0,0x1
 2ce:	a9e50513          	addi	a0,a0,-1378 # d68 <malloc+0x226>
 2d2:	00000097          	auipc	ra,0x0
 2d6:	7b2080e7          	jalr	1970(ra) # a84 <printf>
    if ((pid = fork()) < 0)
 2da:	00000097          	auipc	ra,0x0
 2de:	40a080e7          	jalr	1034(ra) # 6e4 <fork>
 2e2:	04054263          	bltz	a0,326 <test2+0x6e>
 2e6:	84aa                	mv	s1,a0
    if (pid == 0)
 2e8:	e539                	bnez	a0,336 <test2+0x7e>
        count = 0;
 2ea:	00001797          	auipc	a5,0x1
 2ee:	d007ab23          	sw	zero,-746(a5) # 1000 <count>
        sigalarm(2, slow_handler);
 2f2:	00000597          	auipc	a1,0x0
 2f6:	d4858593          	addi	a1,a1,-696 # 3a <slow_handler>
 2fa:	4509                	li	a0,2
 2fc:	00000097          	auipc	ra,0x0
 300:	4a0080e7          	jalr	1184(ra) # 79c <sigalarm>
            if ((i % 1000000) == 0)
 304:	000f4937          	lui	s2,0xf4
 308:	2409091b          	addiw	s2,s2,576
                write(2, ".", 1);
 30c:	00001a97          	auipc	s5,0x1
 310:	974a8a93          	addi	s5,s5,-1676 # c80 <malloc+0x13e>
            if (count > 0)
 314:	00001a17          	auipc	s4,0x1
 318:	ceca0a13          	addi	s4,s4,-788 # 1000 <count>
        for (i = 0; i < 1000 * 500000; i++)
 31c:	1dcd69b7          	lui	s3,0x1dcd6
 320:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 324:	a099                	j	36a <test2+0xb2>
        printf("test2: fork failed\n");
 326:	00001517          	auipc	a0,0x1
 32a:	a5250513          	addi	a0,a0,-1454 # d78 <malloc+0x236>
 32e:	00000097          	auipc	ra,0x0
 332:	756080e7          	jalr	1878(ra) # a84 <printf>
    wait(&status);
 336:	fbc40513          	addi	a0,s0,-68
 33a:	00000097          	auipc	ra,0x0
 33e:	3ba080e7          	jalr	954(ra) # 6f4 <wait>
    if (status == 0)
 342:	fbc42783          	lw	a5,-68(s0)
 346:	c7a5                	beqz	a5,3ae <test2+0xf6>
}
 348:	60a6                	ld	ra,72(sp)
 34a:	6406                	ld	s0,64(sp)
 34c:	74e2                	ld	s1,56(sp)
 34e:	7942                	ld	s2,48(sp)
 350:	79a2                	ld	s3,40(sp)
 352:	7a02                	ld	s4,32(sp)
 354:	6ae2                	ld	s5,24(sp)
 356:	6161                	addi	sp,sp,80
 358:	8082                	ret
            if (count > 0)
 35a:	000a2783          	lw	a5,0(s4)
 35e:	2781                	sext.w	a5,a5
 360:	02f04063          	bgtz	a5,380 <test2+0xc8>
        for (i = 0; i < 1000 * 500000; i++)
 364:	2485                	addiw	s1,s1,1
 366:	01348d63          	beq	s1,s3,380 <test2+0xc8>
            if ((i % 1000000) == 0)
 36a:	0324e7bb          	remw	a5,s1,s2
 36e:	f7f5                	bnez	a5,35a <test2+0xa2>
                write(2, ".", 1);
 370:	4605                	li	a2,1
 372:	85d6                	mv	a1,s5
 374:	4509                	li	a0,2
 376:	00000097          	auipc	ra,0x0
 37a:	396080e7          	jalr	918(ra) # 70c <write>
 37e:	bff1                	j	35a <test2+0xa2>
        if (count == 0)
 380:	00001797          	auipc	a5,0x1
 384:	c807a783          	lw	a5,-896(a5) # 1000 <count>
 388:	ef91                	bnez	a5,3a4 <test2+0xec>
            printf("\ntest2 failed: alarm not called\n");
 38a:	00001517          	auipc	a0,0x1
 38e:	a0650513          	addi	a0,a0,-1530 # d90 <malloc+0x24e>
 392:	00000097          	auipc	ra,0x0
 396:	6f2080e7          	jalr	1778(ra) # a84 <printf>
            exit(1);
 39a:	4505                	li	a0,1
 39c:	00000097          	auipc	ra,0x0
 3a0:	350080e7          	jalr	848(ra) # 6ec <exit>
        exit(0);
 3a4:	4501                	li	a0,0
 3a6:	00000097          	auipc	ra,0x0
 3aa:	346080e7          	jalr	838(ra) # 6ec <exit>
        printf("test2 passed\n");
 3ae:	00001517          	auipc	a0,0x1
 3b2:	a0a50513          	addi	a0,a0,-1526 # db8 <malloc+0x276>
 3b6:	00000097          	auipc	ra,0x0
 3ba:	6ce080e7          	jalr	1742(ra) # a84 <printf>
}
 3be:	b769                	j	348 <test2+0x90>

00000000000003c0 <test3>:

//
// tests that the return from sys_sigreturn() does not
// modify the a0 register
void test3()
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
    uint64 a0;

    sigalarm(1, dummy_handler);
 3c8:	00000597          	auipc	a1,0x0
 3cc:	cf058593          	addi	a1,a1,-784 # b8 <dummy_handler>
 3d0:	4505                	li	a0,1
 3d2:	00000097          	auipc	ra,0x0
 3d6:	3ca080e7          	jalr	970(ra) # 79c <sigalarm>
    printf("test3 start\n");
 3da:	00001517          	auipc	a0,0x1
 3de:	9ee50513          	addi	a0,a0,-1554 # dc8 <malloc+0x286>
 3e2:	00000097          	auipc	ra,0x0
 3e6:	6a2080e7          	jalr	1698(ra) # a84 <printf>

    asm volatile("lui a5, 0");
 3ea:	000007b7          	lui	a5,0x0
    asm volatile("addi a0, a5, 0xac" : : : "a0");
 3ee:	0ac78513          	addi	a0,a5,172 # ac <slow_handler+0x72>
 3f2:	1dcd67b7          	lui	a5,0x1dcd6
 3f6:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
    for (int i = 0; i < 500000000; i++)
 3fa:	37fd                	addiw	a5,a5,-1
 3fc:	fffd                	bnez	a5,3fa <test3+0x3a>
        ;
    asm volatile("mv %0, a0" : "=r"(a0));
 3fe:	872a                	mv	a4,a0

    if (a0 != 0xac)
 400:	0ac00793          	li	a5,172
 404:	00f70e63          	beq	a4,a5,420 <test3+0x60>
        printf("test3 failed: register a0 changed\n");
 408:	00001517          	auipc	a0,0x1
 40c:	9d050513          	addi	a0,a0,-1584 # dd8 <malloc+0x296>
 410:	00000097          	auipc	ra,0x0
 414:	674080e7          	jalr	1652(ra) # a84 <printf>
    else
        printf("test3 passed\n");
 418:	60a2                	ld	ra,8(sp)
 41a:	6402                	ld	s0,0(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
        printf("test3 passed\n");
 420:	00001517          	auipc	a0,0x1
 424:	9e050513          	addi	a0,a0,-1568 # e00 <malloc+0x2be>
 428:	00000097          	auipc	ra,0x0
 42c:	65c080e7          	jalr	1628(ra) # a84 <printf>
 430:	b7e5                	j	418 <test3+0x58>

0000000000000432 <main>:
{
 432:	1141                	addi	sp,sp,-16
 434:	e406                	sd	ra,8(sp)
 436:	e022                	sd	s0,0(sp)
 438:	0800                	addi	s0,sp,16
    test0();
 43a:	00000097          	auipc	ra,0x0
 43e:	ca2080e7          	jalr	-862(ra) # dc <test0>
    test1();
 442:	00000097          	auipc	ra,0x0
 446:	dac080e7          	jalr	-596(ra) # 1ee <test1>
    test2();
 44a:	00000097          	auipc	ra,0x0
 44e:	e6e080e7          	jalr	-402(ra) # 2b8 <test2>
    test3();
 452:	00000097          	auipc	ra,0x0
 456:	f6e080e7          	jalr	-146(ra) # 3c0 <test3>
    exit(0);
 45a:	4501                	li	a0,0
 45c:	00000097          	auipc	ra,0x0
 460:	290080e7          	jalr	656(ra) # 6ec <exit>

0000000000000464 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 464:	1141                	addi	sp,sp,-16
 466:	e406                	sd	ra,8(sp)
 468:	e022                	sd	s0,0(sp)
 46a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 46c:	00000097          	auipc	ra,0x0
 470:	fc6080e7          	jalr	-58(ra) # 432 <main>
  exit(0);
 474:	4501                	li	a0,0
 476:	00000097          	auipc	ra,0x0
 47a:	276080e7          	jalr	630(ra) # 6ec <exit>

000000000000047e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 484:	87aa                	mv	a5,a0
 486:	0585                	addi	a1,a1,1
 488:	0785                	addi	a5,a5,1
 48a:	fff5c703          	lbu	a4,-1(a1)
 48e:	fee78fa3          	sb	a4,-1(a5)
 492:	fb75                	bnez	a4,486 <strcpy+0x8>
    ;
  return os;
}
 494:	6422                	ld	s0,8(sp)
 496:	0141                	addi	sp,sp,16
 498:	8082                	ret

000000000000049a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 49a:	1141                	addi	sp,sp,-16
 49c:	e422                	sd	s0,8(sp)
 49e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4a0:	00054783          	lbu	a5,0(a0)
 4a4:	cb91                	beqz	a5,4b8 <strcmp+0x1e>
 4a6:	0005c703          	lbu	a4,0(a1)
 4aa:	00f71763          	bne	a4,a5,4b8 <strcmp+0x1e>
    p++, q++;
 4ae:	0505                	addi	a0,a0,1
 4b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4b2:	00054783          	lbu	a5,0(a0)
 4b6:	fbe5                	bnez	a5,4a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4b8:	0005c503          	lbu	a0,0(a1)
}
 4bc:	40a7853b          	subw	a0,a5,a0
 4c0:	6422                	ld	s0,8(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret

00000000000004c6 <strlen>:

uint
strlen(const char *s)
{
 4c6:	1141                	addi	sp,sp,-16
 4c8:	e422                	sd	s0,8(sp)
 4ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4cc:	00054783          	lbu	a5,0(a0)
 4d0:	cf91                	beqz	a5,4ec <strlen+0x26>
 4d2:	0505                	addi	a0,a0,1
 4d4:	87aa                	mv	a5,a0
 4d6:	4685                	li	a3,1
 4d8:	9e89                	subw	a3,a3,a0
 4da:	00f6853b          	addw	a0,a3,a5
 4de:	0785                	addi	a5,a5,1
 4e0:	fff7c703          	lbu	a4,-1(a5)
 4e4:	fb7d                	bnez	a4,4da <strlen+0x14>
    ;
  return n;
}
 4e6:	6422                	ld	s0,8(sp)
 4e8:	0141                	addi	sp,sp,16
 4ea:	8082                	ret
  for(n = 0; s[n]; n++)
 4ec:	4501                	li	a0,0
 4ee:	bfe5                	j	4e6 <strlen+0x20>

00000000000004f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4f0:	1141                	addi	sp,sp,-16
 4f2:	e422                	sd	s0,8(sp)
 4f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4f6:	ca19                	beqz	a2,50c <memset+0x1c>
 4f8:	87aa                	mv	a5,a0
 4fa:	1602                	slli	a2,a2,0x20
 4fc:	9201                	srli	a2,a2,0x20
 4fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 502:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 506:	0785                	addi	a5,a5,1
 508:	fee79de3          	bne	a5,a4,502 <memset+0x12>
  }
  return dst;
}
 50c:	6422                	ld	s0,8(sp)
 50e:	0141                	addi	sp,sp,16
 510:	8082                	ret

0000000000000512 <strchr>:

char*
strchr(const char *s, char c)
{
 512:	1141                	addi	sp,sp,-16
 514:	e422                	sd	s0,8(sp)
 516:	0800                	addi	s0,sp,16
  for(; *s; s++)
 518:	00054783          	lbu	a5,0(a0)
 51c:	cb99                	beqz	a5,532 <strchr+0x20>
    if(*s == c)
 51e:	00f58763          	beq	a1,a5,52c <strchr+0x1a>
  for(; *s; s++)
 522:	0505                	addi	a0,a0,1
 524:	00054783          	lbu	a5,0(a0)
 528:	fbfd                	bnez	a5,51e <strchr+0xc>
      return (char*)s;
  return 0;
 52a:	4501                	li	a0,0
}
 52c:	6422                	ld	s0,8(sp)
 52e:	0141                	addi	sp,sp,16
 530:	8082                	ret
  return 0;
 532:	4501                	li	a0,0
 534:	bfe5                	j	52c <strchr+0x1a>

0000000000000536 <gets>:

char*
gets(char *buf, int max)
{
 536:	711d                	addi	sp,sp,-96
 538:	ec86                	sd	ra,88(sp)
 53a:	e8a2                	sd	s0,80(sp)
 53c:	e4a6                	sd	s1,72(sp)
 53e:	e0ca                	sd	s2,64(sp)
 540:	fc4e                	sd	s3,56(sp)
 542:	f852                	sd	s4,48(sp)
 544:	f456                	sd	s5,40(sp)
 546:	f05a                	sd	s6,32(sp)
 548:	ec5e                	sd	s7,24(sp)
 54a:	1080                	addi	s0,sp,96
 54c:	8baa                	mv	s7,a0
 54e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 550:	892a                	mv	s2,a0
 552:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 554:	4aa9                	li	s5,10
 556:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 558:	89a6                	mv	s3,s1
 55a:	2485                	addiw	s1,s1,1
 55c:	0344d863          	bge	s1,s4,58c <gets+0x56>
    cc = read(0, &c, 1);
 560:	4605                	li	a2,1
 562:	faf40593          	addi	a1,s0,-81
 566:	4501                	li	a0,0
 568:	00000097          	auipc	ra,0x0
 56c:	19c080e7          	jalr	412(ra) # 704 <read>
    if(cc < 1)
 570:	00a05e63          	blez	a0,58c <gets+0x56>
    buf[i++] = c;
 574:	faf44783          	lbu	a5,-81(s0)
 578:	00f90023          	sb	a5,0(s2) # f4000 <base+0xf2ff0>
    if(c == '\n' || c == '\r')
 57c:	01578763          	beq	a5,s5,58a <gets+0x54>
 580:	0905                	addi	s2,s2,1
 582:	fd679be3          	bne	a5,s6,558 <gets+0x22>
  for(i=0; i+1 < max; ){
 586:	89a6                	mv	s3,s1
 588:	a011                	j	58c <gets+0x56>
 58a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 58c:	99de                	add	s3,s3,s7
 58e:	00098023          	sb	zero,0(s3)
  return buf;
}
 592:	855e                	mv	a0,s7
 594:	60e6                	ld	ra,88(sp)
 596:	6446                	ld	s0,80(sp)
 598:	64a6                	ld	s1,72(sp)
 59a:	6906                	ld	s2,64(sp)
 59c:	79e2                	ld	s3,56(sp)
 59e:	7a42                	ld	s4,48(sp)
 5a0:	7aa2                	ld	s5,40(sp)
 5a2:	7b02                	ld	s6,32(sp)
 5a4:	6be2                	ld	s7,24(sp)
 5a6:	6125                	addi	sp,sp,96
 5a8:	8082                	ret

00000000000005aa <stat>:

int
stat(const char *n, struct stat *st)
{
 5aa:	1101                	addi	sp,sp,-32
 5ac:	ec06                	sd	ra,24(sp)
 5ae:	e822                	sd	s0,16(sp)
 5b0:	e426                	sd	s1,8(sp)
 5b2:	e04a                	sd	s2,0(sp)
 5b4:	1000                	addi	s0,sp,32
 5b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5b8:	4581                	li	a1,0
 5ba:	00000097          	auipc	ra,0x0
 5be:	172080e7          	jalr	370(ra) # 72c <open>
  if(fd < 0)
 5c2:	02054563          	bltz	a0,5ec <stat+0x42>
 5c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5c8:	85ca                	mv	a1,s2
 5ca:	00000097          	auipc	ra,0x0
 5ce:	17a080e7          	jalr	378(ra) # 744 <fstat>
 5d2:	892a                	mv	s2,a0
  close(fd);
 5d4:	8526                	mv	a0,s1
 5d6:	00000097          	auipc	ra,0x0
 5da:	13e080e7          	jalr	318(ra) # 714 <close>
  return r;
}
 5de:	854a                	mv	a0,s2
 5e0:	60e2                	ld	ra,24(sp)
 5e2:	6442                	ld	s0,16(sp)
 5e4:	64a2                	ld	s1,8(sp)
 5e6:	6902                	ld	s2,0(sp)
 5e8:	6105                	addi	sp,sp,32
 5ea:	8082                	ret
    return -1;
 5ec:	597d                	li	s2,-1
 5ee:	bfc5                	j	5de <stat+0x34>

00000000000005f0 <atoi>:

int
atoi(const char *s)
{
 5f0:	1141                	addi	sp,sp,-16
 5f2:	e422                	sd	s0,8(sp)
 5f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5f6:	00054603          	lbu	a2,0(a0)
 5fa:	fd06079b          	addiw	a5,a2,-48
 5fe:	0ff7f793          	andi	a5,a5,255
 602:	4725                	li	a4,9
 604:	02f76963          	bltu	a4,a5,636 <atoi+0x46>
 608:	86aa                	mv	a3,a0
  n = 0;
 60a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 60c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 60e:	0685                	addi	a3,a3,1
 610:	0025179b          	slliw	a5,a0,0x2
 614:	9fa9                	addw	a5,a5,a0
 616:	0017979b          	slliw	a5,a5,0x1
 61a:	9fb1                	addw	a5,a5,a2
 61c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 620:	0006c603          	lbu	a2,0(a3)
 624:	fd06071b          	addiw	a4,a2,-48
 628:	0ff77713          	andi	a4,a4,255
 62c:	fee5f1e3          	bgeu	a1,a4,60e <atoi+0x1e>
  return n;
}
 630:	6422                	ld	s0,8(sp)
 632:	0141                	addi	sp,sp,16
 634:	8082                	ret
  n = 0;
 636:	4501                	li	a0,0
 638:	bfe5                	j	630 <atoi+0x40>

000000000000063a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 63a:	1141                	addi	sp,sp,-16
 63c:	e422                	sd	s0,8(sp)
 63e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 640:	02b57463          	bgeu	a0,a1,668 <memmove+0x2e>
    while(n-- > 0)
 644:	00c05f63          	blez	a2,662 <memmove+0x28>
 648:	1602                	slli	a2,a2,0x20
 64a:	9201                	srli	a2,a2,0x20
 64c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 650:	872a                	mv	a4,a0
      *dst++ = *src++;
 652:	0585                	addi	a1,a1,1
 654:	0705                	addi	a4,a4,1
 656:	fff5c683          	lbu	a3,-1(a1)
 65a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 65e:	fee79ae3          	bne	a5,a4,652 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 662:	6422                	ld	s0,8(sp)
 664:	0141                	addi	sp,sp,16
 666:	8082                	ret
    dst += n;
 668:	00c50733          	add	a4,a0,a2
    src += n;
 66c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 66e:	fec05ae3          	blez	a2,662 <memmove+0x28>
 672:	fff6079b          	addiw	a5,a2,-1
 676:	1782                	slli	a5,a5,0x20
 678:	9381                	srli	a5,a5,0x20
 67a:	fff7c793          	not	a5,a5
 67e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 680:	15fd                	addi	a1,a1,-1
 682:	177d                	addi	a4,a4,-1
 684:	0005c683          	lbu	a3,0(a1)
 688:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 68c:	fee79ae3          	bne	a5,a4,680 <memmove+0x46>
 690:	bfc9                	j	662 <memmove+0x28>

0000000000000692 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 692:	1141                	addi	sp,sp,-16
 694:	e422                	sd	s0,8(sp)
 696:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 698:	ca05                	beqz	a2,6c8 <memcmp+0x36>
 69a:	fff6069b          	addiw	a3,a2,-1
 69e:	1682                	slli	a3,a3,0x20
 6a0:	9281                	srli	a3,a3,0x20
 6a2:	0685                	addi	a3,a3,1
 6a4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6a6:	00054783          	lbu	a5,0(a0)
 6aa:	0005c703          	lbu	a4,0(a1)
 6ae:	00e79863          	bne	a5,a4,6be <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6b2:	0505                	addi	a0,a0,1
    p2++;
 6b4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6b6:	fed518e3          	bne	a0,a3,6a6 <memcmp+0x14>
  }
  return 0;
 6ba:	4501                	li	a0,0
 6bc:	a019                	j	6c2 <memcmp+0x30>
      return *p1 - *p2;
 6be:	40e7853b          	subw	a0,a5,a4
}
 6c2:	6422                	ld	s0,8(sp)
 6c4:	0141                	addi	sp,sp,16
 6c6:	8082                	ret
  return 0;
 6c8:	4501                	li	a0,0
 6ca:	bfe5                	j	6c2 <memcmp+0x30>

00000000000006cc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6cc:	1141                	addi	sp,sp,-16
 6ce:	e406                	sd	ra,8(sp)
 6d0:	e022                	sd	s0,0(sp)
 6d2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6d4:	00000097          	auipc	ra,0x0
 6d8:	f66080e7          	jalr	-154(ra) # 63a <memmove>
}
 6dc:	60a2                	ld	ra,8(sp)
 6de:	6402                	ld	s0,0(sp)
 6e0:	0141                	addi	sp,sp,16
 6e2:	8082                	ret

00000000000006e4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6e4:	4885                	li	a7,1
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <exit>:
.global exit
exit:
 li a7, SYS_exit
 6ec:	4889                	li	a7,2
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 6f4:	488d                	li	a7,3
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6fc:	4891                	li	a7,4
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <read>:
.global read
read:
 li a7, SYS_read
 704:	4895                	li	a7,5
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <write>:
.global write
write:
 li a7, SYS_write
 70c:	48c1                	li	a7,16
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <close>:
.global close
close:
 li a7, SYS_close
 714:	48d5                	li	a7,21
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <kill>:
.global kill
kill:
 li a7, SYS_kill
 71c:	4899                	li	a7,6
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <exec>:
.global exec
exec:
 li a7, SYS_exec
 724:	489d                	li	a7,7
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <open>:
.global open
open:
 li a7, SYS_open
 72c:	48bd                	li	a7,15
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 734:	48c5                	li	a7,17
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 73c:	48c9                	li	a7,18
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 744:	48a1                	li	a7,8
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <link>:
.global link
link:
 li a7, SYS_link
 74c:	48cd                	li	a7,19
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 754:	48d1                	li	a7,20
 ecall
 756:	00000073          	ecall
 ret
 75a:	8082                	ret

000000000000075c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 75c:	48a5                	li	a7,9
 ecall
 75e:	00000073          	ecall
 ret
 762:	8082                	ret

0000000000000764 <dup>:
.global dup
dup:
 li a7, SYS_dup
 764:	48a9                	li	a7,10
 ecall
 766:	00000073          	ecall
 ret
 76a:	8082                	ret

000000000000076c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 76c:	48ad                	li	a7,11
 ecall
 76e:	00000073          	ecall
 ret
 772:	8082                	ret

0000000000000774 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 774:	48b1                	li	a7,12
 ecall
 776:	00000073          	ecall
 ret
 77a:	8082                	ret

000000000000077c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 77c:	48b5                	li	a7,13
 ecall
 77e:	00000073          	ecall
 ret
 782:	8082                	ret

0000000000000784 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 784:	48b9                	li	a7,14
 ecall
 786:	00000073          	ecall
 ret
 78a:	8082                	ret

000000000000078c <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 78c:	48d9                	li	a7,22
 ecall
 78e:	00000073          	ecall
 ret
 792:	8082                	ret

0000000000000794 <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 794:	48dd                	li	a7,23
 ecall
 796:	00000073          	ecall
 ret
 79a:	8082                	ret

000000000000079c <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 79c:	48e1                	li	a7,24
 ecall
 79e:	00000073          	ecall
 ret
 7a2:	8082                	ret

00000000000007a4 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 7a4:	48e5                	li	a7,25
 ecall
 7a6:	00000073          	ecall
 ret
 7aa:	8082                	ret

00000000000007ac <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7ac:	1101                	addi	sp,sp,-32
 7ae:	ec06                	sd	ra,24(sp)
 7b0:	e822                	sd	s0,16(sp)
 7b2:	1000                	addi	s0,sp,32
 7b4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7b8:	4605                	li	a2,1
 7ba:	fef40593          	addi	a1,s0,-17
 7be:	00000097          	auipc	ra,0x0
 7c2:	f4e080e7          	jalr	-178(ra) # 70c <write>
}
 7c6:	60e2                	ld	ra,24(sp)
 7c8:	6442                	ld	s0,16(sp)
 7ca:	6105                	addi	sp,sp,32
 7cc:	8082                	ret

00000000000007ce <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7ce:	7139                	addi	sp,sp,-64
 7d0:	fc06                	sd	ra,56(sp)
 7d2:	f822                	sd	s0,48(sp)
 7d4:	f426                	sd	s1,40(sp)
 7d6:	f04a                	sd	s2,32(sp)
 7d8:	ec4e                	sd	s3,24(sp)
 7da:	0080                	addi	s0,sp,64
 7dc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7de:	c299                	beqz	a3,7e4 <printint+0x16>
 7e0:	0805c863          	bltz	a1,870 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7e4:	2581                	sext.w	a1,a1
  neg = 0;
 7e6:	4881                	li	a7,0
 7e8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7ec:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7ee:	2601                	sext.w	a2,a2
 7f0:	00000517          	auipc	a0,0x0
 7f4:	62850513          	addi	a0,a0,1576 # e18 <digits>
 7f8:	883a                	mv	a6,a4
 7fa:	2705                	addiw	a4,a4,1
 7fc:	02c5f7bb          	remuw	a5,a1,a2
 800:	1782                	slli	a5,a5,0x20
 802:	9381                	srli	a5,a5,0x20
 804:	97aa                	add	a5,a5,a0
 806:	0007c783          	lbu	a5,0(a5)
 80a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 80e:	0005879b          	sext.w	a5,a1
 812:	02c5d5bb          	divuw	a1,a1,a2
 816:	0685                	addi	a3,a3,1
 818:	fec7f0e3          	bgeu	a5,a2,7f8 <printint+0x2a>
  if(neg)
 81c:	00088b63          	beqz	a7,832 <printint+0x64>
    buf[i++] = '-';
 820:	fd040793          	addi	a5,s0,-48
 824:	973e                	add	a4,a4,a5
 826:	02d00793          	li	a5,45
 82a:	fef70823          	sb	a5,-16(a4)
 82e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 832:	02e05863          	blez	a4,862 <printint+0x94>
 836:	fc040793          	addi	a5,s0,-64
 83a:	00e78933          	add	s2,a5,a4
 83e:	fff78993          	addi	s3,a5,-1
 842:	99ba                	add	s3,s3,a4
 844:	377d                	addiw	a4,a4,-1
 846:	1702                	slli	a4,a4,0x20
 848:	9301                	srli	a4,a4,0x20
 84a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 84e:	fff94583          	lbu	a1,-1(s2)
 852:	8526                	mv	a0,s1
 854:	00000097          	auipc	ra,0x0
 858:	f58080e7          	jalr	-168(ra) # 7ac <putc>
  while(--i >= 0)
 85c:	197d                	addi	s2,s2,-1
 85e:	ff3918e3          	bne	s2,s3,84e <printint+0x80>
}
 862:	70e2                	ld	ra,56(sp)
 864:	7442                	ld	s0,48(sp)
 866:	74a2                	ld	s1,40(sp)
 868:	7902                	ld	s2,32(sp)
 86a:	69e2                	ld	s3,24(sp)
 86c:	6121                	addi	sp,sp,64
 86e:	8082                	ret
    x = -xx;
 870:	40b005bb          	negw	a1,a1
    neg = 1;
 874:	4885                	li	a7,1
    x = -xx;
 876:	bf8d                	j	7e8 <printint+0x1a>

0000000000000878 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 878:	7119                	addi	sp,sp,-128
 87a:	fc86                	sd	ra,120(sp)
 87c:	f8a2                	sd	s0,112(sp)
 87e:	f4a6                	sd	s1,104(sp)
 880:	f0ca                	sd	s2,96(sp)
 882:	ecce                	sd	s3,88(sp)
 884:	e8d2                	sd	s4,80(sp)
 886:	e4d6                	sd	s5,72(sp)
 888:	e0da                	sd	s6,64(sp)
 88a:	fc5e                	sd	s7,56(sp)
 88c:	f862                	sd	s8,48(sp)
 88e:	f466                	sd	s9,40(sp)
 890:	f06a                	sd	s10,32(sp)
 892:	ec6e                	sd	s11,24(sp)
 894:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 896:	0005c903          	lbu	s2,0(a1)
 89a:	18090f63          	beqz	s2,a38 <vprintf+0x1c0>
 89e:	8aaa                	mv	s5,a0
 8a0:	8b32                	mv	s6,a2
 8a2:	00158493          	addi	s1,a1,1
  state = 0;
 8a6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8a8:	02500a13          	li	s4,37
      if(c == 'd'){
 8ac:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 8b0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 8b4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 8b8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8bc:	00000b97          	auipc	s7,0x0
 8c0:	55cb8b93          	addi	s7,s7,1372 # e18 <digits>
 8c4:	a839                	j	8e2 <vprintf+0x6a>
        putc(fd, c);
 8c6:	85ca                	mv	a1,s2
 8c8:	8556                	mv	a0,s5
 8ca:	00000097          	auipc	ra,0x0
 8ce:	ee2080e7          	jalr	-286(ra) # 7ac <putc>
 8d2:	a019                	j	8d8 <vprintf+0x60>
    } else if(state == '%'){
 8d4:	01498f63          	beq	s3,s4,8f2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 8d8:	0485                	addi	s1,s1,1
 8da:	fff4c903          	lbu	s2,-1(s1)
 8de:	14090d63          	beqz	s2,a38 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 8e2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 8e6:	fe0997e3          	bnez	s3,8d4 <vprintf+0x5c>
      if(c == '%'){
 8ea:	fd479ee3          	bne	a5,s4,8c6 <vprintf+0x4e>
        state = '%';
 8ee:	89be                	mv	s3,a5
 8f0:	b7e5                	j	8d8 <vprintf+0x60>
      if(c == 'd'){
 8f2:	05878063          	beq	a5,s8,932 <vprintf+0xba>
      } else if(c == 'l') {
 8f6:	05978c63          	beq	a5,s9,94e <vprintf+0xd6>
      } else if(c == 'x') {
 8fa:	07a78863          	beq	a5,s10,96a <vprintf+0xf2>
      } else if(c == 'p') {
 8fe:	09b78463          	beq	a5,s11,986 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 902:	07300713          	li	a4,115
 906:	0ce78663          	beq	a5,a4,9d2 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 90a:	06300713          	li	a4,99
 90e:	0ee78e63          	beq	a5,a4,a0a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 912:	11478863          	beq	a5,s4,a22 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 916:	85d2                	mv	a1,s4
 918:	8556                	mv	a0,s5
 91a:	00000097          	auipc	ra,0x0
 91e:	e92080e7          	jalr	-366(ra) # 7ac <putc>
        putc(fd, c);
 922:	85ca                	mv	a1,s2
 924:	8556                	mv	a0,s5
 926:	00000097          	auipc	ra,0x0
 92a:	e86080e7          	jalr	-378(ra) # 7ac <putc>
      }
      state = 0;
 92e:	4981                	li	s3,0
 930:	b765                	j	8d8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 932:	008b0913          	addi	s2,s6,8
 936:	4685                	li	a3,1
 938:	4629                	li	a2,10
 93a:	000b2583          	lw	a1,0(s6)
 93e:	8556                	mv	a0,s5
 940:	00000097          	auipc	ra,0x0
 944:	e8e080e7          	jalr	-370(ra) # 7ce <printint>
 948:	8b4a                	mv	s6,s2
      state = 0;
 94a:	4981                	li	s3,0
 94c:	b771                	j	8d8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 94e:	008b0913          	addi	s2,s6,8
 952:	4681                	li	a3,0
 954:	4629                	li	a2,10
 956:	000b2583          	lw	a1,0(s6)
 95a:	8556                	mv	a0,s5
 95c:	00000097          	auipc	ra,0x0
 960:	e72080e7          	jalr	-398(ra) # 7ce <printint>
 964:	8b4a                	mv	s6,s2
      state = 0;
 966:	4981                	li	s3,0
 968:	bf85                	j	8d8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 96a:	008b0913          	addi	s2,s6,8
 96e:	4681                	li	a3,0
 970:	4641                	li	a2,16
 972:	000b2583          	lw	a1,0(s6)
 976:	8556                	mv	a0,s5
 978:	00000097          	auipc	ra,0x0
 97c:	e56080e7          	jalr	-426(ra) # 7ce <printint>
 980:	8b4a                	mv	s6,s2
      state = 0;
 982:	4981                	li	s3,0
 984:	bf91                	j	8d8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 986:	008b0793          	addi	a5,s6,8
 98a:	f8f43423          	sd	a5,-120(s0)
 98e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 992:	03000593          	li	a1,48
 996:	8556                	mv	a0,s5
 998:	00000097          	auipc	ra,0x0
 99c:	e14080e7          	jalr	-492(ra) # 7ac <putc>
  putc(fd, 'x');
 9a0:	85ea                	mv	a1,s10
 9a2:	8556                	mv	a0,s5
 9a4:	00000097          	auipc	ra,0x0
 9a8:	e08080e7          	jalr	-504(ra) # 7ac <putc>
 9ac:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9ae:	03c9d793          	srli	a5,s3,0x3c
 9b2:	97de                	add	a5,a5,s7
 9b4:	0007c583          	lbu	a1,0(a5)
 9b8:	8556                	mv	a0,s5
 9ba:	00000097          	auipc	ra,0x0
 9be:	df2080e7          	jalr	-526(ra) # 7ac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9c2:	0992                	slli	s3,s3,0x4
 9c4:	397d                	addiw	s2,s2,-1
 9c6:	fe0914e3          	bnez	s2,9ae <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 9ca:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 9ce:	4981                	li	s3,0
 9d0:	b721                	j	8d8 <vprintf+0x60>
        s = va_arg(ap, char*);
 9d2:	008b0993          	addi	s3,s6,8
 9d6:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 9da:	02090163          	beqz	s2,9fc <vprintf+0x184>
        while(*s != 0){
 9de:	00094583          	lbu	a1,0(s2)
 9e2:	c9a1                	beqz	a1,a32 <vprintf+0x1ba>
          putc(fd, *s);
 9e4:	8556                	mv	a0,s5
 9e6:	00000097          	auipc	ra,0x0
 9ea:	dc6080e7          	jalr	-570(ra) # 7ac <putc>
          s++;
 9ee:	0905                	addi	s2,s2,1
        while(*s != 0){
 9f0:	00094583          	lbu	a1,0(s2)
 9f4:	f9e5                	bnez	a1,9e4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 9f6:	8b4e                	mv	s6,s3
      state = 0;
 9f8:	4981                	li	s3,0
 9fa:	bdf9                	j	8d8 <vprintf+0x60>
          s = "(null)";
 9fc:	00000917          	auipc	s2,0x0
 a00:	41490913          	addi	s2,s2,1044 # e10 <malloc+0x2ce>
        while(*s != 0){
 a04:	02800593          	li	a1,40
 a08:	bff1                	j	9e4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a0a:	008b0913          	addi	s2,s6,8
 a0e:	000b4583          	lbu	a1,0(s6)
 a12:	8556                	mv	a0,s5
 a14:	00000097          	auipc	ra,0x0
 a18:	d98080e7          	jalr	-616(ra) # 7ac <putc>
 a1c:	8b4a                	mv	s6,s2
      state = 0;
 a1e:	4981                	li	s3,0
 a20:	bd65                	j	8d8 <vprintf+0x60>
        putc(fd, c);
 a22:	85d2                	mv	a1,s4
 a24:	8556                	mv	a0,s5
 a26:	00000097          	auipc	ra,0x0
 a2a:	d86080e7          	jalr	-634(ra) # 7ac <putc>
      state = 0;
 a2e:	4981                	li	s3,0
 a30:	b565                	j	8d8 <vprintf+0x60>
        s = va_arg(ap, char*);
 a32:	8b4e                	mv	s6,s3
      state = 0;
 a34:	4981                	li	s3,0
 a36:	b54d                	j	8d8 <vprintf+0x60>
    }
  }
}
 a38:	70e6                	ld	ra,120(sp)
 a3a:	7446                	ld	s0,112(sp)
 a3c:	74a6                	ld	s1,104(sp)
 a3e:	7906                	ld	s2,96(sp)
 a40:	69e6                	ld	s3,88(sp)
 a42:	6a46                	ld	s4,80(sp)
 a44:	6aa6                	ld	s5,72(sp)
 a46:	6b06                	ld	s6,64(sp)
 a48:	7be2                	ld	s7,56(sp)
 a4a:	7c42                	ld	s8,48(sp)
 a4c:	7ca2                	ld	s9,40(sp)
 a4e:	7d02                	ld	s10,32(sp)
 a50:	6de2                	ld	s11,24(sp)
 a52:	6109                	addi	sp,sp,128
 a54:	8082                	ret

0000000000000a56 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a56:	715d                	addi	sp,sp,-80
 a58:	ec06                	sd	ra,24(sp)
 a5a:	e822                	sd	s0,16(sp)
 a5c:	1000                	addi	s0,sp,32
 a5e:	e010                	sd	a2,0(s0)
 a60:	e414                	sd	a3,8(s0)
 a62:	e818                	sd	a4,16(s0)
 a64:	ec1c                	sd	a5,24(s0)
 a66:	03043023          	sd	a6,32(s0)
 a6a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a6e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a72:	8622                	mv	a2,s0
 a74:	00000097          	auipc	ra,0x0
 a78:	e04080e7          	jalr	-508(ra) # 878 <vprintf>
}
 a7c:	60e2                	ld	ra,24(sp)
 a7e:	6442                	ld	s0,16(sp)
 a80:	6161                	addi	sp,sp,80
 a82:	8082                	ret

0000000000000a84 <printf>:

void
printf(const char *fmt, ...)
{
 a84:	711d                	addi	sp,sp,-96
 a86:	ec06                	sd	ra,24(sp)
 a88:	e822                	sd	s0,16(sp)
 a8a:	1000                	addi	s0,sp,32
 a8c:	e40c                	sd	a1,8(s0)
 a8e:	e810                	sd	a2,16(s0)
 a90:	ec14                	sd	a3,24(s0)
 a92:	f018                	sd	a4,32(s0)
 a94:	f41c                	sd	a5,40(s0)
 a96:	03043823          	sd	a6,48(s0)
 a9a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a9e:	00840613          	addi	a2,s0,8
 aa2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 aa6:	85aa                	mv	a1,a0
 aa8:	4505                	li	a0,1
 aaa:	00000097          	auipc	ra,0x0
 aae:	dce080e7          	jalr	-562(ra) # 878 <vprintf>
}
 ab2:	60e2                	ld	ra,24(sp)
 ab4:	6442                	ld	s0,16(sp)
 ab6:	6125                	addi	sp,sp,96
 ab8:	8082                	ret

0000000000000aba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 aba:	1141                	addi	sp,sp,-16
 abc:	e422                	sd	s0,8(sp)
 abe:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ac0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ac4:	00000797          	auipc	a5,0x0
 ac8:	5447b783          	ld	a5,1348(a5) # 1008 <freep>
 acc:	a805                	j	afc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 ace:	4618                	lw	a4,8(a2)
 ad0:	9db9                	addw	a1,a1,a4
 ad2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ad6:	6398                	ld	a4,0(a5)
 ad8:	6318                	ld	a4,0(a4)
 ada:	fee53823          	sd	a4,-16(a0)
 ade:	a091                	j	b22 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 ae0:	ff852703          	lw	a4,-8(a0)
 ae4:	9e39                	addw	a2,a2,a4
 ae6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 ae8:	ff053703          	ld	a4,-16(a0)
 aec:	e398                	sd	a4,0(a5)
 aee:	a099                	j	b34 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 af0:	6398                	ld	a4,0(a5)
 af2:	00e7e463          	bltu	a5,a4,afa <free+0x40>
 af6:	00e6ea63          	bltu	a3,a4,b0a <free+0x50>
{
 afa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 afc:	fed7fae3          	bgeu	a5,a3,af0 <free+0x36>
 b00:	6398                	ld	a4,0(a5)
 b02:	00e6e463          	bltu	a3,a4,b0a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b06:	fee7eae3          	bltu	a5,a4,afa <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b0a:	ff852583          	lw	a1,-8(a0)
 b0e:	6390                	ld	a2,0(a5)
 b10:	02059713          	slli	a4,a1,0x20
 b14:	9301                	srli	a4,a4,0x20
 b16:	0712                	slli	a4,a4,0x4
 b18:	9736                	add	a4,a4,a3
 b1a:	fae60ae3          	beq	a2,a4,ace <free+0x14>
    bp->s.ptr = p->s.ptr;
 b1e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b22:	4790                	lw	a2,8(a5)
 b24:	02061713          	slli	a4,a2,0x20
 b28:	9301                	srli	a4,a4,0x20
 b2a:	0712                	slli	a4,a4,0x4
 b2c:	973e                	add	a4,a4,a5
 b2e:	fae689e3          	beq	a3,a4,ae0 <free+0x26>
  } else
    p->s.ptr = bp;
 b32:	e394                	sd	a3,0(a5)
  freep = p;
 b34:	00000717          	auipc	a4,0x0
 b38:	4cf73a23          	sd	a5,1236(a4) # 1008 <freep>
}
 b3c:	6422                	ld	s0,8(sp)
 b3e:	0141                	addi	sp,sp,16
 b40:	8082                	ret

0000000000000b42 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b42:	7139                	addi	sp,sp,-64
 b44:	fc06                	sd	ra,56(sp)
 b46:	f822                	sd	s0,48(sp)
 b48:	f426                	sd	s1,40(sp)
 b4a:	f04a                	sd	s2,32(sp)
 b4c:	ec4e                	sd	s3,24(sp)
 b4e:	e852                	sd	s4,16(sp)
 b50:	e456                	sd	s5,8(sp)
 b52:	e05a                	sd	s6,0(sp)
 b54:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b56:	02051493          	slli	s1,a0,0x20
 b5a:	9081                	srli	s1,s1,0x20
 b5c:	04bd                	addi	s1,s1,15
 b5e:	8091                	srli	s1,s1,0x4
 b60:	0014899b          	addiw	s3,s1,1
 b64:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b66:	00000517          	auipc	a0,0x0
 b6a:	4a253503          	ld	a0,1186(a0) # 1008 <freep>
 b6e:	c515                	beqz	a0,b9a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b70:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b72:	4798                	lw	a4,8(a5)
 b74:	02977f63          	bgeu	a4,s1,bb2 <malloc+0x70>
 b78:	8a4e                	mv	s4,s3
 b7a:	0009871b          	sext.w	a4,s3
 b7e:	6685                	lui	a3,0x1
 b80:	00d77363          	bgeu	a4,a3,b86 <malloc+0x44>
 b84:	6a05                	lui	s4,0x1
 b86:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b8a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b8e:	00000917          	auipc	s2,0x0
 b92:	47a90913          	addi	s2,s2,1146 # 1008 <freep>
  if(p == (char*)-1)
 b96:	5afd                	li	s5,-1
 b98:	a88d                	j	c0a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 b9a:	00000797          	auipc	a5,0x0
 b9e:	47678793          	addi	a5,a5,1142 # 1010 <base>
 ba2:	00000717          	auipc	a4,0x0
 ba6:	46f73323          	sd	a5,1126(a4) # 1008 <freep>
 baa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bb0:	b7e1                	j	b78 <malloc+0x36>
      if(p->s.size == nunits)
 bb2:	02e48b63          	beq	s1,a4,be8 <malloc+0xa6>
        p->s.size -= nunits;
 bb6:	4137073b          	subw	a4,a4,s3
 bba:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bbc:	1702                	slli	a4,a4,0x20
 bbe:	9301                	srli	a4,a4,0x20
 bc0:	0712                	slli	a4,a4,0x4
 bc2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bc4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bc8:	00000717          	auipc	a4,0x0
 bcc:	44a73023          	sd	a0,1088(a4) # 1008 <freep>
      return (void*)(p + 1);
 bd0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 bd4:	70e2                	ld	ra,56(sp)
 bd6:	7442                	ld	s0,48(sp)
 bd8:	74a2                	ld	s1,40(sp)
 bda:	7902                	ld	s2,32(sp)
 bdc:	69e2                	ld	s3,24(sp)
 bde:	6a42                	ld	s4,16(sp)
 be0:	6aa2                	ld	s5,8(sp)
 be2:	6b02                	ld	s6,0(sp)
 be4:	6121                	addi	sp,sp,64
 be6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 be8:	6398                	ld	a4,0(a5)
 bea:	e118                	sd	a4,0(a0)
 bec:	bff1                	j	bc8 <malloc+0x86>
  hp->s.size = nu;
 bee:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bf2:	0541                	addi	a0,a0,16
 bf4:	00000097          	auipc	ra,0x0
 bf8:	ec6080e7          	jalr	-314(ra) # aba <free>
  return freep;
 bfc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c00:	d971                	beqz	a0,bd4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c02:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c04:	4798                	lw	a4,8(a5)
 c06:	fa9776e3          	bgeu	a4,s1,bb2 <malloc+0x70>
    if(p == freep)
 c0a:	00093703          	ld	a4,0(s2)
 c0e:	853e                	mv	a0,a5
 c10:	fef719e3          	bne	a4,a5,c02 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c14:	8552                	mv	a0,s4
 c16:	00000097          	auipc	ra,0x0
 c1a:	b5e080e7          	jalr	-1186(ra) # 774 <sbrk>
  if(p == (char*)-1)
 c1e:	fd5518e3          	bne	a0,s5,bee <malloc+0xac>
        return 0;
 c22:	4501                	li	a0,0
 c24:	bf45                	j	bd4 <malloc+0x92>
