
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	ad8080e7          	jalr	-1320(ra) # 5ae8 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	ac6080e7          	jalr	-1338(ra) # 5ae8 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	fc250513          	addi	a0,a0,-62 # 6000 <malloc+0x10a>
      46:	00006097          	auipc	ra,0x6
      4a:	df2080e7          	jalr	-526(ra) # 5e38 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	a58080e7          	jalr	-1448(ra) # 5aa8 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	0000a797          	auipc	a5,0xa
      5c:	4f078793          	addi	a5,a5,1264 # a548 <uninit>
      60:	0000d697          	auipc	a3,0xd
      64:	bf868693          	addi	a3,a3,-1032 # cc58 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	fa050513          	addi	a0,a0,-96 # 6020 <malloc+0x12a>
      88:	00006097          	auipc	ra,0x6
      8c:	db0080e7          	jalr	-592(ra) # 5e38 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00006097          	auipc	ra,0x6
      96:	a16080e7          	jalr	-1514(ra) # 5aa8 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	f9050513          	addi	a0,a0,-112 # 6038 <malloc+0x142>
      b0:	00006097          	auipc	ra,0x6
      b4:	a38080e7          	jalr	-1480(ra) # 5ae8 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00006097          	auipc	ra,0x6
      c0:	a14080e7          	jalr	-1516(ra) # 5ad0 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	f9250513          	addi	a0,a0,-110 # 6058 <malloc+0x162>
      ce:	00006097          	auipc	ra,0x6
      d2:	a1a080e7          	jalr	-1510(ra) # 5ae8 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	f5a50513          	addi	a0,a0,-166 # 6040 <malloc+0x14a>
      ee:	00006097          	auipc	ra,0x6
      f2:	d4a080e7          	jalr	-694(ra) # 5e38 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00006097          	auipc	ra,0x6
      fc:	9b0080e7          	jalr	-1616(ra) # 5aa8 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	f6650513          	addi	a0,a0,-154 # 6068 <malloc+0x172>
     10a:	00006097          	auipc	ra,0x6
     10e:	d2e080e7          	jalr	-722(ra) # 5e38 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00006097          	auipc	ra,0x6
     118:	994080e7          	jalr	-1644(ra) # 5aa8 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	f6450513          	addi	a0,a0,-156 # 6090 <malloc+0x19a>
     134:	00006097          	auipc	ra,0x6
     138:	9c4080e7          	jalr	-1596(ra) # 5af8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	f5050513          	addi	a0,a0,-176 # 6090 <malloc+0x19a>
     148:	00006097          	auipc	ra,0x6
     14c:	9a0080e7          	jalr	-1632(ra) # 5ae8 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	f4c58593          	addi	a1,a1,-180 # 60a0 <malloc+0x1aa>
     15c:	00006097          	auipc	ra,0x6
     160:	96c080e7          	jalr	-1684(ra) # 5ac8 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	f2850513          	addi	a0,a0,-216 # 6090 <malloc+0x19a>
     170:	00006097          	auipc	ra,0x6
     174:	978080e7          	jalr	-1672(ra) # 5ae8 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	f2c58593          	addi	a1,a1,-212 # 60a8 <malloc+0x1b2>
     184:	8526                	mv	a0,s1
     186:	00006097          	auipc	ra,0x6
     18a:	942080e7          	jalr	-1726(ra) # 5ac8 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	efc50513          	addi	a0,a0,-260 # 6090 <malloc+0x19a>
     19c:	00006097          	auipc	ra,0x6
     1a0:	95c080e7          	jalr	-1700(ra) # 5af8 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00006097          	auipc	ra,0x6
     1aa:	92a080e7          	jalr	-1750(ra) # 5ad0 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00006097          	auipc	ra,0x6
     1b4:	920080e7          	jalr	-1760(ra) # 5ad0 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	ee650513          	addi	a0,a0,-282 # 60b0 <malloc+0x1ba>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	c66080e7          	jalr	-922(ra) # 5e38 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00006097          	auipc	ra,0x6
     1e0:	8cc080e7          	jalr	-1844(ra) # 5aa8 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00006097          	auipc	ra,0x6
     214:	8d8080e7          	jalr	-1832(ra) # 5ae8 <open>
    close(fd);
     218:	00006097          	auipc	ra,0x6
     21c:	8b8080e7          	jalr	-1864(ra) # 5ad0 <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00006097          	auipc	ra,0x6
     24a:	8b2080e7          	jalr	-1870(ra) # 5af8 <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	e5c50513          	addi	a0,a0,-420 # 60d8 <malloc+0x1e2>
     284:	00006097          	auipc	ra,0x6
     288:	874080e7          	jalr	-1932(ra) # 5af8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	e48a8a93          	addi	s5,s5,-440 # 60d8 <malloc+0x1e2>
      int cc = write(fd, buf, sz);
     298:	0000da17          	auipc	s4,0xd
     29c:	9c0a0a13          	addi	s4,s4,-1600 # cc58 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <diskfull+0x6f>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00006097          	auipc	ra,0x6
     2b0:	83c080e7          	jalr	-1988(ra) # 5ae8 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00006097          	auipc	ra,0x6
     2c2:	80a080e7          	jalr	-2038(ra) # 5ac8 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00005097          	auipc	ra,0x5
     2d6:	7f6080e7          	jalr	2038(ra) # 5ac8 <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00005097          	auipc	ra,0x5
     2e4:	7f0080e7          	jalr	2032(ra) # 5ad0 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00006097          	auipc	ra,0x6
     2ee:	80e080e7          	jalr	-2034(ra) # 5af8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	dd650513          	addi	a0,a0,-554 # 60e8 <malloc+0x1f2>
     31a:	00006097          	auipc	ra,0x6
     31e:	b1e080e7          	jalr	-1250(ra) # 5e38 <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	784080e7          	jalr	1924(ra) # 5aa8 <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	dd250513          	addi	a0,a0,-558 # 6108 <malloc+0x212>
     33e:	00006097          	auipc	ra,0x6
     342:	afa080e7          	jalr	-1286(ra) # 5e38 <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	760080e7          	jalr	1888(ra) # 5aa8 <exit>

0000000000000350 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     350:	7179                	addi	sp,sp,-48
     352:	f406                	sd	ra,40(sp)
     354:	f022                	sd	s0,32(sp)
     356:	ec26                	sd	s1,24(sp)
     358:	e84a                	sd	s2,16(sp)
     35a:	e44e                	sd	s3,8(sp)
     35c:	e052                	sd	s4,0(sp)
     35e:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     360:	00006517          	auipc	a0,0x6
     364:	dc050513          	addi	a0,a0,-576 # 6120 <malloc+0x22a>
     368:	00005097          	auipc	ra,0x5
     36c:	790080e7          	jalr	1936(ra) # 5af8 <unlink>
     370:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     374:	00006997          	auipc	s3,0x6
     378:	dac98993          	addi	s3,s3,-596 # 6120 <malloc+0x22a>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     37c:	5a7d                	li	s4,-1
     37e:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     382:	20100593          	li	a1,513
     386:	854e                	mv	a0,s3
     388:	00005097          	auipc	ra,0x5
     38c:	760080e7          	jalr	1888(ra) # 5ae8 <open>
     390:	84aa                	mv	s1,a0
    if(fd < 0){
     392:	06054b63          	bltz	a0,408 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
     396:	4605                	li	a2,1
     398:	85d2                	mv	a1,s4
     39a:	00005097          	auipc	ra,0x5
     39e:	72e080e7          	jalr	1838(ra) # 5ac8 <write>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00005097          	auipc	ra,0x5
     3a8:	72c080e7          	jalr	1836(ra) # 5ad0 <close>
    unlink("junk");
     3ac:	854e                	mv	a0,s3
     3ae:	00005097          	auipc	ra,0x5
     3b2:	74a080e7          	jalr	1866(ra) # 5af8 <unlink>
  for(int i = 0; i < assumed_free; i++){
     3b6:	397d                	addiw	s2,s2,-1
     3b8:	fc0915e3          	bnez	s2,382 <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     3bc:	20100593          	li	a1,513
     3c0:	00006517          	auipc	a0,0x6
     3c4:	d6050513          	addi	a0,a0,-672 # 6120 <malloc+0x22a>
     3c8:	00005097          	auipc	ra,0x5
     3cc:	720080e7          	jalr	1824(ra) # 5ae8 <open>
     3d0:	84aa                	mv	s1,a0
  if(fd < 0){
     3d2:	04054863          	bltz	a0,422 <badwrite+0xd2>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     3d6:	4605                	li	a2,1
     3d8:	00006597          	auipc	a1,0x6
     3dc:	cd058593          	addi	a1,a1,-816 # 60a8 <malloc+0x1b2>
     3e0:	00005097          	auipc	ra,0x5
     3e4:	6e8080e7          	jalr	1768(ra) # 5ac8 <write>
     3e8:	4785                	li	a5,1
     3ea:	04f50963          	beq	a0,a5,43c <badwrite+0xec>
    printf("write failed\n");
     3ee:	00006517          	auipc	a0,0x6
     3f2:	d5250513          	addi	a0,a0,-686 # 6140 <malloc+0x24a>
     3f6:	00006097          	auipc	ra,0x6
     3fa:	a42080e7          	jalr	-1470(ra) # 5e38 <printf>
    exit(1);
     3fe:	4505                	li	a0,1
     400:	00005097          	auipc	ra,0x5
     404:	6a8080e7          	jalr	1704(ra) # 5aa8 <exit>
      printf("open junk failed\n");
     408:	00006517          	auipc	a0,0x6
     40c:	d2050513          	addi	a0,a0,-736 # 6128 <malloc+0x232>
     410:	00006097          	auipc	ra,0x6
     414:	a28080e7          	jalr	-1496(ra) # 5e38 <printf>
      exit(1);
     418:	4505                	li	a0,1
     41a:	00005097          	auipc	ra,0x5
     41e:	68e080e7          	jalr	1678(ra) # 5aa8 <exit>
    printf("open junk failed\n");
     422:	00006517          	auipc	a0,0x6
     426:	d0650513          	addi	a0,a0,-762 # 6128 <malloc+0x232>
     42a:	00006097          	auipc	ra,0x6
     42e:	a0e080e7          	jalr	-1522(ra) # 5e38 <printf>
    exit(1);
     432:	4505                	li	a0,1
     434:	00005097          	auipc	ra,0x5
     438:	674080e7          	jalr	1652(ra) # 5aa8 <exit>
  }
  close(fd);
     43c:	8526                	mv	a0,s1
     43e:	00005097          	auipc	ra,0x5
     442:	692080e7          	jalr	1682(ra) # 5ad0 <close>
  unlink("junk");
     446:	00006517          	auipc	a0,0x6
     44a:	cda50513          	addi	a0,a0,-806 # 6120 <malloc+0x22a>
     44e:	00005097          	auipc	ra,0x5
     452:	6aa080e7          	jalr	1706(ra) # 5af8 <unlink>

  exit(0);
     456:	4501                	li	a0,0
     458:	00005097          	auipc	ra,0x5
     45c:	650080e7          	jalr	1616(ra) # 5aa8 <exit>

0000000000000460 <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     460:	715d                	addi	sp,sp,-80
     462:	e486                	sd	ra,72(sp)
     464:	e0a2                	sd	s0,64(sp)
     466:	fc26                	sd	s1,56(sp)
     468:	f84a                	sd	s2,48(sp)
     46a:	f44e                	sd	s3,40(sp)
     46c:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     46e:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     470:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     474:	40000993          	li	s3,1024
    name[0] = 'z';
     478:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     47c:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     480:	41f4d79b          	sraiw	a5,s1,0x1f
     484:	01b7d71b          	srliw	a4,a5,0x1b
     488:	009707bb          	addw	a5,a4,s1
     48c:	4057d69b          	sraiw	a3,a5,0x5
     490:	0306869b          	addiw	a3,a3,48
     494:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     498:	8bfd                	andi	a5,a5,31
     49a:	9f99                	subw	a5,a5,a4
     49c:	0307879b          	addiw	a5,a5,48
     4a0:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4a4:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     4a8:	fb040513          	addi	a0,s0,-80
     4ac:	00005097          	auipc	ra,0x5
     4b0:	64c080e7          	jalr	1612(ra) # 5af8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     4b4:	60200593          	li	a1,1538
     4b8:	fb040513          	addi	a0,s0,-80
     4bc:	00005097          	auipc	ra,0x5
     4c0:	62c080e7          	jalr	1580(ra) # 5ae8 <open>
    if(fd < 0){
     4c4:	00054963          	bltz	a0,4d6 <outofinodes+0x76>
      // failure is eventually expected.
      break;
    }
    close(fd);
     4c8:	00005097          	auipc	ra,0x5
     4cc:	608080e7          	jalr	1544(ra) # 5ad0 <close>
  for(int i = 0; i < nzz; i++){
     4d0:	2485                	addiw	s1,s1,1
     4d2:	fb3493e3          	bne	s1,s3,478 <outofinodes+0x18>
     4d6:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     4d8:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     4dc:	40000993          	li	s3,1024
    name[0] = 'z';
     4e0:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     4e4:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4e8:	41f4d79b          	sraiw	a5,s1,0x1f
     4ec:	01b7d71b          	srliw	a4,a5,0x1b
     4f0:	009707bb          	addw	a5,a4,s1
     4f4:	4057d69b          	sraiw	a3,a5,0x5
     4f8:	0306869b          	addiw	a3,a3,48
     4fc:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     500:	8bfd                	andi	a5,a5,31
     502:	9f99                	subw	a5,a5,a4
     504:	0307879b          	addiw	a5,a5,48
     508:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     50c:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     510:	fb040513          	addi	a0,s0,-80
     514:	00005097          	auipc	ra,0x5
     518:	5e4080e7          	jalr	1508(ra) # 5af8 <unlink>
  for(int i = 0; i < nzz; i++){
     51c:	2485                	addiw	s1,s1,1
     51e:	fd3491e3          	bne	s1,s3,4e0 <outofinodes+0x80>
  }
}
     522:	60a6                	ld	ra,72(sp)
     524:	6406                	ld	s0,64(sp)
     526:	74e2                	ld	s1,56(sp)
     528:	7942                	ld	s2,48(sp)
     52a:	79a2                	ld	s3,40(sp)
     52c:	6161                	addi	sp,sp,80
     52e:	8082                	ret

0000000000000530 <copyin>:
{
     530:	715d                	addi	sp,sp,-80
     532:	e486                	sd	ra,72(sp)
     534:	e0a2                	sd	s0,64(sp)
     536:	fc26                	sd	s1,56(sp)
     538:	f84a                	sd	s2,48(sp)
     53a:	f44e                	sd	s3,40(sp)
     53c:	f052                	sd	s4,32(sp)
     53e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     540:	4785                	li	a5,1
     542:	07fe                	slli	a5,a5,0x1f
     544:	fcf43023          	sd	a5,-64(s0)
     548:	57fd                	li	a5,-1
     54a:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     54e:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     552:	00006a17          	auipc	s4,0x6
     556:	bfea0a13          	addi	s4,s4,-1026 # 6150 <malloc+0x25a>
    uint64 addr = addrs[ai];
     55a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     55e:	20100593          	li	a1,513
     562:	8552                	mv	a0,s4
     564:	00005097          	auipc	ra,0x5
     568:	584080e7          	jalr	1412(ra) # 5ae8 <open>
     56c:	84aa                	mv	s1,a0
    if(fd < 0){
     56e:	08054863          	bltz	a0,5fe <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     572:	6609                	lui	a2,0x2
     574:	85ce                	mv	a1,s3
     576:	00005097          	auipc	ra,0x5
     57a:	552080e7          	jalr	1362(ra) # 5ac8 <write>
    if(n >= 0){
     57e:	08055d63          	bgez	a0,618 <copyin+0xe8>
    close(fd);
     582:	8526                	mv	a0,s1
     584:	00005097          	auipc	ra,0x5
     588:	54c080e7          	jalr	1356(ra) # 5ad0 <close>
    unlink("copyin1");
     58c:	8552                	mv	a0,s4
     58e:	00005097          	auipc	ra,0x5
     592:	56a080e7          	jalr	1386(ra) # 5af8 <unlink>
    n = write(1, (char*)addr, 8192);
     596:	6609                	lui	a2,0x2
     598:	85ce                	mv	a1,s3
     59a:	4505                	li	a0,1
     59c:	00005097          	auipc	ra,0x5
     5a0:	52c080e7          	jalr	1324(ra) # 5ac8 <write>
    if(n > 0){
     5a4:	08a04963          	bgtz	a0,636 <copyin+0x106>
    if(pipe(fds) < 0){
     5a8:	fb840513          	addi	a0,s0,-72
     5ac:	00005097          	auipc	ra,0x5
     5b0:	50c080e7          	jalr	1292(ra) # 5ab8 <pipe>
     5b4:	0a054063          	bltz	a0,654 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     5b8:	6609                	lui	a2,0x2
     5ba:	85ce                	mv	a1,s3
     5bc:	fbc42503          	lw	a0,-68(s0)
     5c0:	00005097          	auipc	ra,0x5
     5c4:	508080e7          	jalr	1288(ra) # 5ac8 <write>
    if(n > 0){
     5c8:	0aa04363          	bgtz	a0,66e <copyin+0x13e>
    close(fds[0]);
     5cc:	fb842503          	lw	a0,-72(s0)
     5d0:	00005097          	auipc	ra,0x5
     5d4:	500080e7          	jalr	1280(ra) # 5ad0 <close>
    close(fds[1]);
     5d8:	fbc42503          	lw	a0,-68(s0)
     5dc:	00005097          	auipc	ra,0x5
     5e0:	4f4080e7          	jalr	1268(ra) # 5ad0 <close>
  for(int ai = 0; ai < 2; ai++){
     5e4:	0921                	addi	s2,s2,8
     5e6:	fd040793          	addi	a5,s0,-48
     5ea:	f6f918e3          	bne	s2,a5,55a <copyin+0x2a>
}
     5ee:	60a6                	ld	ra,72(sp)
     5f0:	6406                	ld	s0,64(sp)
     5f2:	74e2                	ld	s1,56(sp)
     5f4:	7942                	ld	s2,48(sp)
     5f6:	79a2                	ld	s3,40(sp)
     5f8:	7a02                	ld	s4,32(sp)
     5fa:	6161                	addi	sp,sp,80
     5fc:	8082                	ret
      printf("open(copyin1) failed\n");
     5fe:	00006517          	auipc	a0,0x6
     602:	b5a50513          	addi	a0,a0,-1190 # 6158 <malloc+0x262>
     606:	00006097          	auipc	ra,0x6
     60a:	832080e7          	jalr	-1998(ra) # 5e38 <printf>
      exit(1);
     60e:	4505                	li	a0,1
     610:	00005097          	auipc	ra,0x5
     614:	498080e7          	jalr	1176(ra) # 5aa8 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     618:	862a                	mv	a2,a0
     61a:	85ce                	mv	a1,s3
     61c:	00006517          	auipc	a0,0x6
     620:	b5450513          	addi	a0,a0,-1196 # 6170 <malloc+0x27a>
     624:	00006097          	auipc	ra,0x6
     628:	814080e7          	jalr	-2028(ra) # 5e38 <printf>
      exit(1);
     62c:	4505                	li	a0,1
     62e:	00005097          	auipc	ra,0x5
     632:	47a080e7          	jalr	1146(ra) # 5aa8 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     636:	862a                	mv	a2,a0
     638:	85ce                	mv	a1,s3
     63a:	00006517          	auipc	a0,0x6
     63e:	b6650513          	addi	a0,a0,-1178 # 61a0 <malloc+0x2aa>
     642:	00005097          	auipc	ra,0x5
     646:	7f6080e7          	jalr	2038(ra) # 5e38 <printf>
      exit(1);
     64a:	4505                	li	a0,1
     64c:	00005097          	auipc	ra,0x5
     650:	45c080e7          	jalr	1116(ra) # 5aa8 <exit>
      printf("pipe() failed\n");
     654:	00006517          	auipc	a0,0x6
     658:	b7c50513          	addi	a0,a0,-1156 # 61d0 <malloc+0x2da>
     65c:	00005097          	auipc	ra,0x5
     660:	7dc080e7          	jalr	2012(ra) # 5e38 <printf>
      exit(1);
     664:	4505                	li	a0,1
     666:	00005097          	auipc	ra,0x5
     66a:	442080e7          	jalr	1090(ra) # 5aa8 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     66e:	862a                	mv	a2,a0
     670:	85ce                	mv	a1,s3
     672:	00006517          	auipc	a0,0x6
     676:	b6e50513          	addi	a0,a0,-1170 # 61e0 <malloc+0x2ea>
     67a:	00005097          	auipc	ra,0x5
     67e:	7be080e7          	jalr	1982(ra) # 5e38 <printf>
      exit(1);
     682:	4505                	li	a0,1
     684:	00005097          	auipc	ra,0x5
     688:	424080e7          	jalr	1060(ra) # 5aa8 <exit>

000000000000068c <copyout>:
{
     68c:	711d                	addi	sp,sp,-96
     68e:	ec86                	sd	ra,88(sp)
     690:	e8a2                	sd	s0,80(sp)
     692:	e4a6                	sd	s1,72(sp)
     694:	e0ca                	sd	s2,64(sp)
     696:	fc4e                	sd	s3,56(sp)
     698:	f852                	sd	s4,48(sp)
     69a:	f456                	sd	s5,40(sp)
     69c:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     69e:	4785                	li	a5,1
     6a0:	07fe                	slli	a5,a5,0x1f
     6a2:	faf43823          	sd	a5,-80(s0)
     6a6:	57fd                	li	a5,-1
     6a8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     6ac:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     6b0:	00006a17          	auipc	s4,0x6
     6b4:	b60a0a13          	addi	s4,s4,-1184 # 6210 <malloc+0x31a>
    n = write(fds[1], "x", 1);
     6b8:	00006a97          	auipc	s5,0x6
     6bc:	9f0a8a93          	addi	s5,s5,-1552 # 60a8 <malloc+0x1b2>
    uint64 addr = addrs[ai];
     6c0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     6c4:	4581                	li	a1,0
     6c6:	8552                	mv	a0,s4
     6c8:	00005097          	auipc	ra,0x5
     6cc:	420080e7          	jalr	1056(ra) # 5ae8 <open>
     6d0:	84aa                	mv	s1,a0
    if(fd < 0){
     6d2:	08054663          	bltz	a0,75e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     6d6:	6609                	lui	a2,0x2
     6d8:	85ce                	mv	a1,s3
     6da:	00005097          	auipc	ra,0x5
     6de:	3e6080e7          	jalr	998(ra) # 5ac0 <read>
    if(n > 0){
     6e2:	08a04b63          	bgtz	a0,778 <copyout+0xec>
    close(fd);
     6e6:	8526                	mv	a0,s1
     6e8:	00005097          	auipc	ra,0x5
     6ec:	3e8080e7          	jalr	1000(ra) # 5ad0 <close>
    if(pipe(fds) < 0){
     6f0:	fa840513          	addi	a0,s0,-88
     6f4:	00005097          	auipc	ra,0x5
     6f8:	3c4080e7          	jalr	964(ra) # 5ab8 <pipe>
     6fc:	08054d63          	bltz	a0,796 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     700:	4605                	li	a2,1
     702:	85d6                	mv	a1,s5
     704:	fac42503          	lw	a0,-84(s0)
     708:	00005097          	auipc	ra,0x5
     70c:	3c0080e7          	jalr	960(ra) # 5ac8 <write>
    if(n != 1){
     710:	4785                	li	a5,1
     712:	08f51f63          	bne	a0,a5,7b0 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     716:	6609                	lui	a2,0x2
     718:	85ce                	mv	a1,s3
     71a:	fa842503          	lw	a0,-88(s0)
     71e:	00005097          	auipc	ra,0x5
     722:	3a2080e7          	jalr	930(ra) # 5ac0 <read>
    if(n > 0){
     726:	0aa04263          	bgtz	a0,7ca <copyout+0x13e>
    close(fds[0]);
     72a:	fa842503          	lw	a0,-88(s0)
     72e:	00005097          	auipc	ra,0x5
     732:	3a2080e7          	jalr	930(ra) # 5ad0 <close>
    close(fds[1]);
     736:	fac42503          	lw	a0,-84(s0)
     73a:	00005097          	auipc	ra,0x5
     73e:	396080e7          	jalr	918(ra) # 5ad0 <close>
  for(int ai = 0; ai < 2; ai++){
     742:	0921                	addi	s2,s2,8
     744:	fc040793          	addi	a5,s0,-64
     748:	f6f91ce3          	bne	s2,a5,6c0 <copyout+0x34>
}
     74c:	60e6                	ld	ra,88(sp)
     74e:	6446                	ld	s0,80(sp)
     750:	64a6                	ld	s1,72(sp)
     752:	6906                	ld	s2,64(sp)
     754:	79e2                	ld	s3,56(sp)
     756:	7a42                	ld	s4,48(sp)
     758:	7aa2                	ld	s5,40(sp)
     75a:	6125                	addi	sp,sp,96
     75c:	8082                	ret
      printf("open(README) failed\n");
     75e:	00006517          	auipc	a0,0x6
     762:	aba50513          	addi	a0,a0,-1350 # 6218 <malloc+0x322>
     766:	00005097          	auipc	ra,0x5
     76a:	6d2080e7          	jalr	1746(ra) # 5e38 <printf>
      exit(1);
     76e:	4505                	li	a0,1
     770:	00005097          	auipc	ra,0x5
     774:	338080e7          	jalr	824(ra) # 5aa8 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     778:	862a                	mv	a2,a0
     77a:	85ce                	mv	a1,s3
     77c:	00006517          	auipc	a0,0x6
     780:	ab450513          	addi	a0,a0,-1356 # 6230 <malloc+0x33a>
     784:	00005097          	auipc	ra,0x5
     788:	6b4080e7          	jalr	1716(ra) # 5e38 <printf>
      exit(1);
     78c:	4505                	li	a0,1
     78e:	00005097          	auipc	ra,0x5
     792:	31a080e7          	jalr	794(ra) # 5aa8 <exit>
      printf("pipe() failed\n");
     796:	00006517          	auipc	a0,0x6
     79a:	a3a50513          	addi	a0,a0,-1478 # 61d0 <malloc+0x2da>
     79e:	00005097          	auipc	ra,0x5
     7a2:	69a080e7          	jalr	1690(ra) # 5e38 <printf>
      exit(1);
     7a6:	4505                	li	a0,1
     7a8:	00005097          	auipc	ra,0x5
     7ac:	300080e7          	jalr	768(ra) # 5aa8 <exit>
      printf("pipe write failed\n");
     7b0:	00006517          	auipc	a0,0x6
     7b4:	ab050513          	addi	a0,a0,-1360 # 6260 <malloc+0x36a>
     7b8:	00005097          	auipc	ra,0x5
     7bc:	680080e7          	jalr	1664(ra) # 5e38 <printf>
      exit(1);
     7c0:	4505                	li	a0,1
     7c2:	00005097          	auipc	ra,0x5
     7c6:	2e6080e7          	jalr	742(ra) # 5aa8 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     7ca:	862a                	mv	a2,a0
     7cc:	85ce                	mv	a1,s3
     7ce:	00006517          	auipc	a0,0x6
     7d2:	aaa50513          	addi	a0,a0,-1366 # 6278 <malloc+0x382>
     7d6:	00005097          	auipc	ra,0x5
     7da:	662080e7          	jalr	1634(ra) # 5e38 <printf>
      exit(1);
     7de:	4505                	li	a0,1
     7e0:	00005097          	auipc	ra,0x5
     7e4:	2c8080e7          	jalr	712(ra) # 5aa8 <exit>

00000000000007e8 <truncate1>:
{
     7e8:	711d                	addi	sp,sp,-96
     7ea:	ec86                	sd	ra,88(sp)
     7ec:	e8a2                	sd	s0,80(sp)
     7ee:	e4a6                	sd	s1,72(sp)
     7f0:	e0ca                	sd	s2,64(sp)
     7f2:	fc4e                	sd	s3,56(sp)
     7f4:	f852                	sd	s4,48(sp)
     7f6:	f456                	sd	s5,40(sp)
     7f8:	1080                	addi	s0,sp,96
     7fa:	8aaa                	mv	s5,a0
  unlink("truncfile");
     7fc:	00006517          	auipc	a0,0x6
     800:	89450513          	addi	a0,a0,-1900 # 6090 <malloc+0x19a>
     804:	00005097          	auipc	ra,0x5
     808:	2f4080e7          	jalr	756(ra) # 5af8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     80c:	60100593          	li	a1,1537
     810:	00006517          	auipc	a0,0x6
     814:	88050513          	addi	a0,a0,-1920 # 6090 <malloc+0x19a>
     818:	00005097          	auipc	ra,0x5
     81c:	2d0080e7          	jalr	720(ra) # 5ae8 <open>
     820:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     822:	4611                	li	a2,4
     824:	00006597          	auipc	a1,0x6
     828:	87c58593          	addi	a1,a1,-1924 # 60a0 <malloc+0x1aa>
     82c:	00005097          	auipc	ra,0x5
     830:	29c080e7          	jalr	668(ra) # 5ac8 <write>
  close(fd1);
     834:	8526                	mv	a0,s1
     836:	00005097          	auipc	ra,0x5
     83a:	29a080e7          	jalr	666(ra) # 5ad0 <close>
  int fd2 = open("truncfile", O_RDONLY);
     83e:	4581                	li	a1,0
     840:	00006517          	auipc	a0,0x6
     844:	85050513          	addi	a0,a0,-1968 # 6090 <malloc+0x19a>
     848:	00005097          	auipc	ra,0x5
     84c:	2a0080e7          	jalr	672(ra) # 5ae8 <open>
     850:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     852:	02000613          	li	a2,32
     856:	fa040593          	addi	a1,s0,-96
     85a:	00005097          	auipc	ra,0x5
     85e:	266080e7          	jalr	614(ra) # 5ac0 <read>
  if(n != 4){
     862:	4791                	li	a5,4
     864:	0cf51e63          	bne	a0,a5,940 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     868:	40100593          	li	a1,1025
     86c:	00006517          	auipc	a0,0x6
     870:	82450513          	addi	a0,a0,-2012 # 6090 <malloc+0x19a>
     874:	00005097          	auipc	ra,0x5
     878:	274080e7          	jalr	628(ra) # 5ae8 <open>
     87c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     87e:	4581                	li	a1,0
     880:	00006517          	auipc	a0,0x6
     884:	81050513          	addi	a0,a0,-2032 # 6090 <malloc+0x19a>
     888:	00005097          	auipc	ra,0x5
     88c:	260080e7          	jalr	608(ra) # 5ae8 <open>
     890:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     892:	02000613          	li	a2,32
     896:	fa040593          	addi	a1,s0,-96
     89a:	00005097          	auipc	ra,0x5
     89e:	226080e7          	jalr	550(ra) # 5ac0 <read>
     8a2:	8a2a                	mv	s4,a0
  if(n != 0){
     8a4:	ed4d                	bnez	a0,95e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8a6:	02000613          	li	a2,32
     8aa:	fa040593          	addi	a1,s0,-96
     8ae:	8526                	mv	a0,s1
     8b0:	00005097          	auipc	ra,0x5
     8b4:	210080e7          	jalr	528(ra) # 5ac0 <read>
     8b8:	8a2a                	mv	s4,a0
  if(n != 0){
     8ba:	e971                	bnez	a0,98e <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     8bc:	4619                	li	a2,6
     8be:	00006597          	auipc	a1,0x6
     8c2:	a4a58593          	addi	a1,a1,-1462 # 6308 <malloc+0x412>
     8c6:	854e                	mv	a0,s3
     8c8:	00005097          	auipc	ra,0x5
     8cc:	200080e7          	jalr	512(ra) # 5ac8 <write>
  n = read(fd3, buf, sizeof(buf));
     8d0:	02000613          	li	a2,32
     8d4:	fa040593          	addi	a1,s0,-96
     8d8:	854a                	mv	a0,s2
     8da:	00005097          	auipc	ra,0x5
     8de:	1e6080e7          	jalr	486(ra) # 5ac0 <read>
  if(n != 6){
     8e2:	4799                	li	a5,6
     8e4:	0cf51d63          	bne	a0,a5,9be <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     8e8:	02000613          	li	a2,32
     8ec:	fa040593          	addi	a1,s0,-96
     8f0:	8526                	mv	a0,s1
     8f2:	00005097          	auipc	ra,0x5
     8f6:	1ce080e7          	jalr	462(ra) # 5ac0 <read>
  if(n != 2){
     8fa:	4789                	li	a5,2
     8fc:	0ef51063          	bne	a0,a5,9dc <truncate1+0x1f4>
  unlink("truncfile");
     900:	00005517          	auipc	a0,0x5
     904:	79050513          	addi	a0,a0,1936 # 6090 <malloc+0x19a>
     908:	00005097          	auipc	ra,0x5
     90c:	1f0080e7          	jalr	496(ra) # 5af8 <unlink>
  close(fd1);
     910:	854e                	mv	a0,s3
     912:	00005097          	auipc	ra,0x5
     916:	1be080e7          	jalr	446(ra) # 5ad0 <close>
  close(fd2);
     91a:	8526                	mv	a0,s1
     91c:	00005097          	auipc	ra,0x5
     920:	1b4080e7          	jalr	436(ra) # 5ad0 <close>
  close(fd3);
     924:	854a                	mv	a0,s2
     926:	00005097          	auipc	ra,0x5
     92a:	1aa080e7          	jalr	426(ra) # 5ad0 <close>
}
     92e:	60e6                	ld	ra,88(sp)
     930:	6446                	ld	s0,80(sp)
     932:	64a6                	ld	s1,72(sp)
     934:	6906                	ld	s2,64(sp)
     936:	79e2                	ld	s3,56(sp)
     938:	7a42                	ld	s4,48(sp)
     93a:	7aa2                	ld	s5,40(sp)
     93c:	6125                	addi	sp,sp,96
     93e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     940:	862a                	mv	a2,a0
     942:	85d6                	mv	a1,s5
     944:	00006517          	auipc	a0,0x6
     948:	96450513          	addi	a0,a0,-1692 # 62a8 <malloc+0x3b2>
     94c:	00005097          	auipc	ra,0x5
     950:	4ec080e7          	jalr	1260(ra) # 5e38 <printf>
    exit(1);
     954:	4505                	li	a0,1
     956:	00005097          	auipc	ra,0x5
     95a:	152080e7          	jalr	338(ra) # 5aa8 <exit>
    printf("aaa fd3=%d\n", fd3);
     95e:	85ca                	mv	a1,s2
     960:	00006517          	auipc	a0,0x6
     964:	96850513          	addi	a0,a0,-1688 # 62c8 <malloc+0x3d2>
     968:	00005097          	auipc	ra,0x5
     96c:	4d0080e7          	jalr	1232(ra) # 5e38 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     970:	8652                	mv	a2,s4
     972:	85d6                	mv	a1,s5
     974:	00006517          	auipc	a0,0x6
     978:	96450513          	addi	a0,a0,-1692 # 62d8 <malloc+0x3e2>
     97c:	00005097          	auipc	ra,0x5
     980:	4bc080e7          	jalr	1212(ra) # 5e38 <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	122080e7          	jalr	290(ra) # 5aa8 <exit>
    printf("bbb fd2=%d\n", fd2);
     98e:	85a6                	mv	a1,s1
     990:	00006517          	auipc	a0,0x6
     994:	96850513          	addi	a0,a0,-1688 # 62f8 <malloc+0x402>
     998:	00005097          	auipc	ra,0x5
     99c:	4a0080e7          	jalr	1184(ra) # 5e38 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9a0:	8652                	mv	a2,s4
     9a2:	85d6                	mv	a1,s5
     9a4:	00006517          	auipc	a0,0x6
     9a8:	93450513          	addi	a0,a0,-1740 # 62d8 <malloc+0x3e2>
     9ac:	00005097          	auipc	ra,0x5
     9b0:	48c080e7          	jalr	1164(ra) # 5e38 <printf>
    exit(1);
     9b4:	4505                	li	a0,1
     9b6:	00005097          	auipc	ra,0x5
     9ba:	0f2080e7          	jalr	242(ra) # 5aa8 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     9be:	862a                	mv	a2,a0
     9c0:	85d6                	mv	a1,s5
     9c2:	00006517          	auipc	a0,0x6
     9c6:	94e50513          	addi	a0,a0,-1714 # 6310 <malloc+0x41a>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	46e080e7          	jalr	1134(ra) # 5e38 <printf>
    exit(1);
     9d2:	4505                	li	a0,1
     9d4:	00005097          	auipc	ra,0x5
     9d8:	0d4080e7          	jalr	212(ra) # 5aa8 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     9dc:	862a                	mv	a2,a0
     9de:	85d6                	mv	a1,s5
     9e0:	00006517          	auipc	a0,0x6
     9e4:	95050513          	addi	a0,a0,-1712 # 6330 <malloc+0x43a>
     9e8:	00005097          	auipc	ra,0x5
     9ec:	450080e7          	jalr	1104(ra) # 5e38 <printf>
    exit(1);
     9f0:	4505                	li	a0,1
     9f2:	00005097          	auipc	ra,0x5
     9f6:	0b6080e7          	jalr	182(ra) # 5aa8 <exit>

00000000000009fa <writetest>:
{
     9fa:	7139                	addi	sp,sp,-64
     9fc:	fc06                	sd	ra,56(sp)
     9fe:	f822                	sd	s0,48(sp)
     a00:	f426                	sd	s1,40(sp)
     a02:	f04a                	sd	s2,32(sp)
     a04:	ec4e                	sd	s3,24(sp)
     a06:	e852                	sd	s4,16(sp)
     a08:	e456                	sd	s5,8(sp)
     a0a:	e05a                	sd	s6,0(sp)
     a0c:	0080                	addi	s0,sp,64
     a0e:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     a10:	20200593          	li	a1,514
     a14:	00006517          	auipc	a0,0x6
     a18:	93c50513          	addi	a0,a0,-1732 # 6350 <malloc+0x45a>
     a1c:	00005097          	auipc	ra,0x5
     a20:	0cc080e7          	jalr	204(ra) # 5ae8 <open>
  if(fd < 0){
     a24:	0a054d63          	bltz	a0,ade <writetest+0xe4>
     a28:	892a                	mv	s2,a0
     a2a:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a2c:	00006997          	auipc	s3,0x6
     a30:	94c98993          	addi	s3,s3,-1716 # 6378 <malloc+0x482>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a34:	00006a97          	auipc	s5,0x6
     a38:	97ca8a93          	addi	s5,s5,-1668 # 63b0 <malloc+0x4ba>
  for(i = 0; i < N; i++){
     a3c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a40:	4629                	li	a2,10
     a42:	85ce                	mv	a1,s3
     a44:	854a                	mv	a0,s2
     a46:	00005097          	auipc	ra,0x5
     a4a:	082080e7          	jalr	130(ra) # 5ac8 <write>
     a4e:	47a9                	li	a5,10
     a50:	0af51563          	bne	a0,a5,afa <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a54:	4629                	li	a2,10
     a56:	85d6                	mv	a1,s5
     a58:	854a                	mv	a0,s2
     a5a:	00005097          	auipc	ra,0x5
     a5e:	06e080e7          	jalr	110(ra) # 5ac8 <write>
     a62:	47a9                	li	a5,10
     a64:	0af51a63          	bne	a0,a5,b18 <writetest+0x11e>
  for(i = 0; i < N; i++){
     a68:	2485                	addiw	s1,s1,1
     a6a:	fd449be3          	bne	s1,s4,a40 <writetest+0x46>
  close(fd);
     a6e:	854a                	mv	a0,s2
     a70:	00005097          	auipc	ra,0x5
     a74:	060080e7          	jalr	96(ra) # 5ad0 <close>
  fd = open("small", O_RDONLY);
     a78:	4581                	li	a1,0
     a7a:	00006517          	auipc	a0,0x6
     a7e:	8d650513          	addi	a0,a0,-1834 # 6350 <malloc+0x45a>
     a82:	00005097          	auipc	ra,0x5
     a86:	066080e7          	jalr	102(ra) # 5ae8 <open>
     a8a:	84aa                	mv	s1,a0
  if(fd < 0){
     a8c:	0a054563          	bltz	a0,b36 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     a90:	7d000613          	li	a2,2000
     a94:	0000c597          	auipc	a1,0xc
     a98:	1c458593          	addi	a1,a1,452 # cc58 <buf>
     a9c:	00005097          	auipc	ra,0x5
     aa0:	024080e7          	jalr	36(ra) # 5ac0 <read>
  if(i != N*SZ*2){
     aa4:	7d000793          	li	a5,2000
     aa8:	0af51563          	bne	a0,a5,b52 <writetest+0x158>
  close(fd);
     aac:	8526                	mv	a0,s1
     aae:	00005097          	auipc	ra,0x5
     ab2:	022080e7          	jalr	34(ra) # 5ad0 <close>
  if(unlink("small") < 0){
     ab6:	00006517          	auipc	a0,0x6
     aba:	89a50513          	addi	a0,a0,-1894 # 6350 <malloc+0x45a>
     abe:	00005097          	auipc	ra,0x5
     ac2:	03a080e7          	jalr	58(ra) # 5af8 <unlink>
     ac6:	0a054463          	bltz	a0,b6e <writetest+0x174>
}
     aca:	70e2                	ld	ra,56(sp)
     acc:	7442                	ld	s0,48(sp)
     ace:	74a2                	ld	s1,40(sp)
     ad0:	7902                	ld	s2,32(sp)
     ad2:	69e2                	ld	s3,24(sp)
     ad4:	6a42                	ld	s4,16(sp)
     ad6:	6aa2                	ld	s5,8(sp)
     ad8:	6b02                	ld	s6,0(sp)
     ada:	6121                	addi	sp,sp,64
     adc:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     ade:	85da                	mv	a1,s6
     ae0:	00006517          	auipc	a0,0x6
     ae4:	87850513          	addi	a0,a0,-1928 # 6358 <malloc+0x462>
     ae8:	00005097          	auipc	ra,0x5
     aec:	350080e7          	jalr	848(ra) # 5e38 <printf>
    exit(1);
     af0:	4505                	li	a0,1
     af2:	00005097          	auipc	ra,0x5
     af6:	fb6080e7          	jalr	-74(ra) # 5aa8 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     afa:	8626                	mv	a2,s1
     afc:	85da                	mv	a1,s6
     afe:	00006517          	auipc	a0,0x6
     b02:	88a50513          	addi	a0,a0,-1910 # 6388 <malloc+0x492>
     b06:	00005097          	auipc	ra,0x5
     b0a:	332080e7          	jalr	818(ra) # 5e38 <printf>
      exit(1);
     b0e:	4505                	li	a0,1
     b10:	00005097          	auipc	ra,0x5
     b14:	f98080e7          	jalr	-104(ra) # 5aa8 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     b18:	8626                	mv	a2,s1
     b1a:	85da                	mv	a1,s6
     b1c:	00006517          	auipc	a0,0x6
     b20:	8a450513          	addi	a0,a0,-1884 # 63c0 <malloc+0x4ca>
     b24:	00005097          	auipc	ra,0x5
     b28:	314080e7          	jalr	788(ra) # 5e38 <printf>
      exit(1);
     b2c:	4505                	li	a0,1
     b2e:	00005097          	auipc	ra,0x5
     b32:	f7a080e7          	jalr	-134(ra) # 5aa8 <exit>
    printf("%s: error: open small failed!\n", s);
     b36:	85da                	mv	a1,s6
     b38:	00006517          	auipc	a0,0x6
     b3c:	8b050513          	addi	a0,a0,-1872 # 63e8 <malloc+0x4f2>
     b40:	00005097          	auipc	ra,0x5
     b44:	2f8080e7          	jalr	760(ra) # 5e38 <printf>
    exit(1);
     b48:	4505                	li	a0,1
     b4a:	00005097          	auipc	ra,0x5
     b4e:	f5e080e7          	jalr	-162(ra) # 5aa8 <exit>
    printf("%s: read failed\n", s);
     b52:	85da                	mv	a1,s6
     b54:	00006517          	auipc	a0,0x6
     b58:	8b450513          	addi	a0,a0,-1868 # 6408 <malloc+0x512>
     b5c:	00005097          	auipc	ra,0x5
     b60:	2dc080e7          	jalr	732(ra) # 5e38 <printf>
    exit(1);
     b64:	4505                	li	a0,1
     b66:	00005097          	auipc	ra,0x5
     b6a:	f42080e7          	jalr	-190(ra) # 5aa8 <exit>
    printf("%s: unlink small failed\n", s);
     b6e:	85da                	mv	a1,s6
     b70:	00006517          	auipc	a0,0x6
     b74:	8b050513          	addi	a0,a0,-1872 # 6420 <malloc+0x52a>
     b78:	00005097          	auipc	ra,0x5
     b7c:	2c0080e7          	jalr	704(ra) # 5e38 <printf>
    exit(1);
     b80:	4505                	li	a0,1
     b82:	00005097          	auipc	ra,0x5
     b86:	f26080e7          	jalr	-218(ra) # 5aa8 <exit>

0000000000000b8a <writebig>:
{
     b8a:	7139                	addi	sp,sp,-64
     b8c:	fc06                	sd	ra,56(sp)
     b8e:	f822                	sd	s0,48(sp)
     b90:	f426                	sd	s1,40(sp)
     b92:	f04a                	sd	s2,32(sp)
     b94:	ec4e                	sd	s3,24(sp)
     b96:	e852                	sd	s4,16(sp)
     b98:	e456                	sd	s5,8(sp)
     b9a:	0080                	addi	s0,sp,64
     b9c:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     b9e:	20200593          	li	a1,514
     ba2:	00006517          	auipc	a0,0x6
     ba6:	89e50513          	addi	a0,a0,-1890 # 6440 <malloc+0x54a>
     baa:	00005097          	auipc	ra,0x5
     bae:	f3e080e7          	jalr	-194(ra) # 5ae8 <open>
     bb2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     bb4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     bb6:	0000c917          	auipc	s2,0xc
     bba:	0a290913          	addi	s2,s2,162 # cc58 <buf>
  for(i = 0; i < MAXFILE; i++){
     bbe:	10c00a13          	li	s4,268
  if(fd < 0){
     bc2:	06054c63          	bltz	a0,c3a <writebig+0xb0>
    ((int*)buf)[0] = i;
     bc6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     bca:	40000613          	li	a2,1024
     bce:	85ca                	mv	a1,s2
     bd0:	854e                	mv	a0,s3
     bd2:	00005097          	auipc	ra,0x5
     bd6:	ef6080e7          	jalr	-266(ra) # 5ac8 <write>
     bda:	40000793          	li	a5,1024
     bde:	06f51c63          	bne	a0,a5,c56 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     be2:	2485                	addiw	s1,s1,1
     be4:	ff4491e3          	bne	s1,s4,bc6 <writebig+0x3c>
  close(fd);
     be8:	854e                	mv	a0,s3
     bea:	00005097          	auipc	ra,0x5
     bee:	ee6080e7          	jalr	-282(ra) # 5ad0 <close>
  fd = open("big", O_RDONLY);
     bf2:	4581                	li	a1,0
     bf4:	00006517          	auipc	a0,0x6
     bf8:	84c50513          	addi	a0,a0,-1972 # 6440 <malloc+0x54a>
     bfc:	00005097          	auipc	ra,0x5
     c00:	eec080e7          	jalr	-276(ra) # 5ae8 <open>
     c04:	89aa                	mv	s3,a0
  n = 0;
     c06:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c08:	0000c917          	auipc	s2,0xc
     c0c:	05090913          	addi	s2,s2,80 # cc58 <buf>
  if(fd < 0){
     c10:	06054263          	bltz	a0,c74 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     c14:	40000613          	li	a2,1024
     c18:	85ca                	mv	a1,s2
     c1a:	854e                	mv	a0,s3
     c1c:	00005097          	auipc	ra,0x5
     c20:	ea4080e7          	jalr	-348(ra) # 5ac0 <read>
    if(i == 0){
     c24:	c535                	beqz	a0,c90 <writebig+0x106>
    } else if(i != BSIZE){
     c26:	40000793          	li	a5,1024
     c2a:	0af51f63          	bne	a0,a5,ce8 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     c2e:	00092683          	lw	a3,0(s2)
     c32:	0c969a63          	bne	a3,s1,d06 <writebig+0x17c>
    n++;
     c36:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c38:	bff1                	j	c14 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     c3a:	85d6                	mv	a1,s5
     c3c:	00006517          	auipc	a0,0x6
     c40:	80c50513          	addi	a0,a0,-2036 # 6448 <malloc+0x552>
     c44:	00005097          	auipc	ra,0x5
     c48:	1f4080e7          	jalr	500(ra) # 5e38 <printf>
    exit(1);
     c4c:	4505                	li	a0,1
     c4e:	00005097          	auipc	ra,0x5
     c52:	e5a080e7          	jalr	-422(ra) # 5aa8 <exit>
      printf("%s: error: write big file failed\n", s, i);
     c56:	8626                	mv	a2,s1
     c58:	85d6                	mv	a1,s5
     c5a:	00006517          	auipc	a0,0x6
     c5e:	80e50513          	addi	a0,a0,-2034 # 6468 <malloc+0x572>
     c62:	00005097          	auipc	ra,0x5
     c66:	1d6080e7          	jalr	470(ra) # 5e38 <printf>
      exit(1);
     c6a:	4505                	li	a0,1
     c6c:	00005097          	auipc	ra,0x5
     c70:	e3c080e7          	jalr	-452(ra) # 5aa8 <exit>
    printf("%s: error: open big failed!\n", s);
     c74:	85d6                	mv	a1,s5
     c76:	00006517          	auipc	a0,0x6
     c7a:	81a50513          	addi	a0,a0,-2022 # 6490 <malloc+0x59a>
     c7e:	00005097          	auipc	ra,0x5
     c82:	1ba080e7          	jalr	442(ra) # 5e38 <printf>
    exit(1);
     c86:	4505                	li	a0,1
     c88:	00005097          	auipc	ra,0x5
     c8c:	e20080e7          	jalr	-480(ra) # 5aa8 <exit>
      if(n == MAXFILE - 1){
     c90:	10b00793          	li	a5,267
     c94:	02f48a63          	beq	s1,a5,cc8 <writebig+0x13e>
  close(fd);
     c98:	854e                	mv	a0,s3
     c9a:	00005097          	auipc	ra,0x5
     c9e:	e36080e7          	jalr	-458(ra) # 5ad0 <close>
  if(unlink("big") < 0){
     ca2:	00005517          	auipc	a0,0x5
     ca6:	79e50513          	addi	a0,a0,1950 # 6440 <malloc+0x54a>
     caa:	00005097          	auipc	ra,0x5
     cae:	e4e080e7          	jalr	-434(ra) # 5af8 <unlink>
     cb2:	06054963          	bltz	a0,d24 <writebig+0x19a>
}
     cb6:	70e2                	ld	ra,56(sp)
     cb8:	7442                	ld	s0,48(sp)
     cba:	74a2                	ld	s1,40(sp)
     cbc:	7902                	ld	s2,32(sp)
     cbe:	69e2                	ld	s3,24(sp)
     cc0:	6a42                	ld	s4,16(sp)
     cc2:	6aa2                	ld	s5,8(sp)
     cc4:	6121                	addi	sp,sp,64
     cc6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     cc8:	10b00613          	li	a2,267
     ccc:	85d6                	mv	a1,s5
     cce:	00005517          	auipc	a0,0x5
     cd2:	7e250513          	addi	a0,a0,2018 # 64b0 <malloc+0x5ba>
     cd6:	00005097          	auipc	ra,0x5
     cda:	162080e7          	jalr	354(ra) # 5e38 <printf>
        exit(1);
     cde:	4505                	li	a0,1
     ce0:	00005097          	auipc	ra,0x5
     ce4:	dc8080e7          	jalr	-568(ra) # 5aa8 <exit>
      printf("%s: read failed %d\n", s, i);
     ce8:	862a                	mv	a2,a0
     cea:	85d6                	mv	a1,s5
     cec:	00005517          	auipc	a0,0x5
     cf0:	7ec50513          	addi	a0,a0,2028 # 64d8 <malloc+0x5e2>
     cf4:	00005097          	auipc	ra,0x5
     cf8:	144080e7          	jalr	324(ra) # 5e38 <printf>
      exit(1);
     cfc:	4505                	li	a0,1
     cfe:	00005097          	auipc	ra,0x5
     d02:	daa080e7          	jalr	-598(ra) # 5aa8 <exit>
      printf("%s: read content of block %d is %d\n", s,
     d06:	8626                	mv	a2,s1
     d08:	85d6                	mv	a1,s5
     d0a:	00005517          	auipc	a0,0x5
     d0e:	7e650513          	addi	a0,a0,2022 # 64f0 <malloc+0x5fa>
     d12:	00005097          	auipc	ra,0x5
     d16:	126080e7          	jalr	294(ra) # 5e38 <printf>
      exit(1);
     d1a:	4505                	li	a0,1
     d1c:	00005097          	auipc	ra,0x5
     d20:	d8c080e7          	jalr	-628(ra) # 5aa8 <exit>
    printf("%s: unlink big failed\n", s);
     d24:	85d6                	mv	a1,s5
     d26:	00005517          	auipc	a0,0x5
     d2a:	7f250513          	addi	a0,a0,2034 # 6518 <malloc+0x622>
     d2e:	00005097          	auipc	ra,0x5
     d32:	10a080e7          	jalr	266(ra) # 5e38 <printf>
    exit(1);
     d36:	4505                	li	a0,1
     d38:	00005097          	auipc	ra,0x5
     d3c:	d70080e7          	jalr	-656(ra) # 5aa8 <exit>

0000000000000d40 <unlinkread>:
{
     d40:	7179                	addi	sp,sp,-48
     d42:	f406                	sd	ra,40(sp)
     d44:	f022                	sd	s0,32(sp)
     d46:	ec26                	sd	s1,24(sp)
     d48:	e84a                	sd	s2,16(sp)
     d4a:	e44e                	sd	s3,8(sp)
     d4c:	1800                	addi	s0,sp,48
     d4e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     d50:	20200593          	li	a1,514
     d54:	00005517          	auipc	a0,0x5
     d58:	7dc50513          	addi	a0,a0,2012 # 6530 <malloc+0x63a>
     d5c:	00005097          	auipc	ra,0x5
     d60:	d8c080e7          	jalr	-628(ra) # 5ae8 <open>
  if(fd < 0){
     d64:	0e054563          	bltz	a0,e4e <unlinkread+0x10e>
     d68:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     d6a:	4615                	li	a2,5
     d6c:	00005597          	auipc	a1,0x5
     d70:	7f458593          	addi	a1,a1,2036 # 6560 <malloc+0x66a>
     d74:	00005097          	auipc	ra,0x5
     d78:	d54080e7          	jalr	-684(ra) # 5ac8 <write>
  close(fd);
     d7c:	8526                	mv	a0,s1
     d7e:	00005097          	auipc	ra,0x5
     d82:	d52080e7          	jalr	-686(ra) # 5ad0 <close>
  fd = open("unlinkread", O_RDWR);
     d86:	4589                	li	a1,2
     d88:	00005517          	auipc	a0,0x5
     d8c:	7a850513          	addi	a0,a0,1960 # 6530 <malloc+0x63a>
     d90:	00005097          	auipc	ra,0x5
     d94:	d58080e7          	jalr	-680(ra) # 5ae8 <open>
     d98:	84aa                	mv	s1,a0
  if(fd < 0){
     d9a:	0c054863          	bltz	a0,e6a <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     d9e:	00005517          	auipc	a0,0x5
     da2:	79250513          	addi	a0,a0,1938 # 6530 <malloc+0x63a>
     da6:	00005097          	auipc	ra,0x5
     daa:	d52080e7          	jalr	-686(ra) # 5af8 <unlink>
     dae:	ed61                	bnez	a0,e86 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     db0:	20200593          	li	a1,514
     db4:	00005517          	auipc	a0,0x5
     db8:	77c50513          	addi	a0,a0,1916 # 6530 <malloc+0x63a>
     dbc:	00005097          	auipc	ra,0x5
     dc0:	d2c080e7          	jalr	-724(ra) # 5ae8 <open>
     dc4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     dc6:	460d                	li	a2,3
     dc8:	00005597          	auipc	a1,0x5
     dcc:	7e058593          	addi	a1,a1,2016 # 65a8 <malloc+0x6b2>
     dd0:	00005097          	auipc	ra,0x5
     dd4:	cf8080e7          	jalr	-776(ra) # 5ac8 <write>
  close(fd1);
     dd8:	854a                	mv	a0,s2
     dda:	00005097          	auipc	ra,0x5
     dde:	cf6080e7          	jalr	-778(ra) # 5ad0 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     de2:	660d                	lui	a2,0x3
     de4:	0000c597          	auipc	a1,0xc
     de8:	e7458593          	addi	a1,a1,-396 # cc58 <buf>
     dec:	8526                	mv	a0,s1
     dee:	00005097          	auipc	ra,0x5
     df2:	cd2080e7          	jalr	-814(ra) # 5ac0 <read>
     df6:	4795                	li	a5,5
     df8:	0af51563          	bne	a0,a5,ea2 <unlinkread+0x162>
  if(buf[0] != 'h'){
     dfc:	0000c717          	auipc	a4,0xc
     e00:	e5c74703          	lbu	a4,-420(a4) # cc58 <buf>
     e04:	06800793          	li	a5,104
     e08:	0af71b63          	bne	a4,a5,ebe <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     e0c:	4629                	li	a2,10
     e0e:	0000c597          	auipc	a1,0xc
     e12:	e4a58593          	addi	a1,a1,-438 # cc58 <buf>
     e16:	8526                	mv	a0,s1
     e18:	00005097          	auipc	ra,0x5
     e1c:	cb0080e7          	jalr	-848(ra) # 5ac8 <write>
     e20:	47a9                	li	a5,10
     e22:	0af51c63          	bne	a0,a5,eda <unlinkread+0x19a>
  close(fd);
     e26:	8526                	mv	a0,s1
     e28:	00005097          	auipc	ra,0x5
     e2c:	ca8080e7          	jalr	-856(ra) # 5ad0 <close>
  unlink("unlinkread");
     e30:	00005517          	auipc	a0,0x5
     e34:	70050513          	addi	a0,a0,1792 # 6530 <malloc+0x63a>
     e38:	00005097          	auipc	ra,0x5
     e3c:	cc0080e7          	jalr	-832(ra) # 5af8 <unlink>
}
     e40:	70a2                	ld	ra,40(sp)
     e42:	7402                	ld	s0,32(sp)
     e44:	64e2                	ld	s1,24(sp)
     e46:	6942                	ld	s2,16(sp)
     e48:	69a2                	ld	s3,8(sp)
     e4a:	6145                	addi	sp,sp,48
     e4c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     e4e:	85ce                	mv	a1,s3
     e50:	00005517          	auipc	a0,0x5
     e54:	6f050513          	addi	a0,a0,1776 # 6540 <malloc+0x64a>
     e58:	00005097          	auipc	ra,0x5
     e5c:	fe0080e7          	jalr	-32(ra) # 5e38 <printf>
    exit(1);
     e60:	4505                	li	a0,1
     e62:	00005097          	auipc	ra,0x5
     e66:	c46080e7          	jalr	-954(ra) # 5aa8 <exit>
    printf("%s: open unlinkread failed\n", s);
     e6a:	85ce                	mv	a1,s3
     e6c:	00005517          	auipc	a0,0x5
     e70:	6fc50513          	addi	a0,a0,1788 # 6568 <malloc+0x672>
     e74:	00005097          	auipc	ra,0x5
     e78:	fc4080e7          	jalr	-60(ra) # 5e38 <printf>
    exit(1);
     e7c:	4505                	li	a0,1
     e7e:	00005097          	auipc	ra,0x5
     e82:	c2a080e7          	jalr	-982(ra) # 5aa8 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     e86:	85ce                	mv	a1,s3
     e88:	00005517          	auipc	a0,0x5
     e8c:	70050513          	addi	a0,a0,1792 # 6588 <malloc+0x692>
     e90:	00005097          	auipc	ra,0x5
     e94:	fa8080e7          	jalr	-88(ra) # 5e38 <printf>
    exit(1);
     e98:	4505                	li	a0,1
     e9a:	00005097          	auipc	ra,0x5
     e9e:	c0e080e7          	jalr	-1010(ra) # 5aa8 <exit>
    printf("%s: unlinkread read failed", s);
     ea2:	85ce                	mv	a1,s3
     ea4:	00005517          	auipc	a0,0x5
     ea8:	70c50513          	addi	a0,a0,1804 # 65b0 <malloc+0x6ba>
     eac:	00005097          	auipc	ra,0x5
     eb0:	f8c080e7          	jalr	-116(ra) # 5e38 <printf>
    exit(1);
     eb4:	4505                	li	a0,1
     eb6:	00005097          	auipc	ra,0x5
     eba:	bf2080e7          	jalr	-1038(ra) # 5aa8 <exit>
    printf("%s: unlinkread wrong data\n", s);
     ebe:	85ce                	mv	a1,s3
     ec0:	00005517          	auipc	a0,0x5
     ec4:	71050513          	addi	a0,a0,1808 # 65d0 <malloc+0x6da>
     ec8:	00005097          	auipc	ra,0x5
     ecc:	f70080e7          	jalr	-144(ra) # 5e38 <printf>
    exit(1);
     ed0:	4505                	li	a0,1
     ed2:	00005097          	auipc	ra,0x5
     ed6:	bd6080e7          	jalr	-1066(ra) # 5aa8 <exit>
    printf("%s: unlinkread write failed\n", s);
     eda:	85ce                	mv	a1,s3
     edc:	00005517          	auipc	a0,0x5
     ee0:	71450513          	addi	a0,a0,1812 # 65f0 <malloc+0x6fa>
     ee4:	00005097          	auipc	ra,0x5
     ee8:	f54080e7          	jalr	-172(ra) # 5e38 <printf>
    exit(1);
     eec:	4505                	li	a0,1
     eee:	00005097          	auipc	ra,0x5
     ef2:	bba080e7          	jalr	-1094(ra) # 5aa8 <exit>

0000000000000ef6 <linktest>:
{
     ef6:	1101                	addi	sp,sp,-32
     ef8:	ec06                	sd	ra,24(sp)
     efa:	e822                	sd	s0,16(sp)
     efc:	e426                	sd	s1,8(sp)
     efe:	e04a                	sd	s2,0(sp)
     f00:	1000                	addi	s0,sp,32
     f02:	892a                	mv	s2,a0
  unlink("lf1");
     f04:	00005517          	auipc	a0,0x5
     f08:	70c50513          	addi	a0,a0,1804 # 6610 <malloc+0x71a>
     f0c:	00005097          	auipc	ra,0x5
     f10:	bec080e7          	jalr	-1044(ra) # 5af8 <unlink>
  unlink("lf2");
     f14:	00005517          	auipc	a0,0x5
     f18:	70450513          	addi	a0,a0,1796 # 6618 <malloc+0x722>
     f1c:	00005097          	auipc	ra,0x5
     f20:	bdc080e7          	jalr	-1060(ra) # 5af8 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     f24:	20200593          	li	a1,514
     f28:	00005517          	auipc	a0,0x5
     f2c:	6e850513          	addi	a0,a0,1768 # 6610 <malloc+0x71a>
     f30:	00005097          	auipc	ra,0x5
     f34:	bb8080e7          	jalr	-1096(ra) # 5ae8 <open>
  if(fd < 0){
     f38:	10054763          	bltz	a0,1046 <linktest+0x150>
     f3c:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     f3e:	4615                	li	a2,5
     f40:	00005597          	auipc	a1,0x5
     f44:	62058593          	addi	a1,a1,1568 # 6560 <malloc+0x66a>
     f48:	00005097          	auipc	ra,0x5
     f4c:	b80080e7          	jalr	-1152(ra) # 5ac8 <write>
     f50:	4795                	li	a5,5
     f52:	10f51863          	bne	a0,a5,1062 <linktest+0x16c>
  close(fd);
     f56:	8526                	mv	a0,s1
     f58:	00005097          	auipc	ra,0x5
     f5c:	b78080e7          	jalr	-1160(ra) # 5ad0 <close>
  if(link("lf1", "lf2") < 0){
     f60:	00005597          	auipc	a1,0x5
     f64:	6b858593          	addi	a1,a1,1720 # 6618 <malloc+0x722>
     f68:	00005517          	auipc	a0,0x5
     f6c:	6a850513          	addi	a0,a0,1704 # 6610 <malloc+0x71a>
     f70:	00005097          	auipc	ra,0x5
     f74:	b98080e7          	jalr	-1128(ra) # 5b08 <link>
     f78:	10054363          	bltz	a0,107e <linktest+0x188>
  unlink("lf1");
     f7c:	00005517          	auipc	a0,0x5
     f80:	69450513          	addi	a0,a0,1684 # 6610 <malloc+0x71a>
     f84:	00005097          	auipc	ra,0x5
     f88:	b74080e7          	jalr	-1164(ra) # 5af8 <unlink>
  if(open("lf1", 0) >= 0){
     f8c:	4581                	li	a1,0
     f8e:	00005517          	auipc	a0,0x5
     f92:	68250513          	addi	a0,a0,1666 # 6610 <malloc+0x71a>
     f96:	00005097          	auipc	ra,0x5
     f9a:	b52080e7          	jalr	-1198(ra) # 5ae8 <open>
     f9e:	0e055e63          	bgez	a0,109a <linktest+0x1a4>
  fd = open("lf2", 0);
     fa2:	4581                	li	a1,0
     fa4:	00005517          	auipc	a0,0x5
     fa8:	67450513          	addi	a0,a0,1652 # 6618 <malloc+0x722>
     fac:	00005097          	auipc	ra,0x5
     fb0:	b3c080e7          	jalr	-1220(ra) # 5ae8 <open>
     fb4:	84aa                	mv	s1,a0
  if(fd < 0){
     fb6:	10054063          	bltz	a0,10b6 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     fba:	660d                	lui	a2,0x3
     fbc:	0000c597          	auipc	a1,0xc
     fc0:	c9c58593          	addi	a1,a1,-868 # cc58 <buf>
     fc4:	00005097          	auipc	ra,0x5
     fc8:	afc080e7          	jalr	-1284(ra) # 5ac0 <read>
     fcc:	4795                	li	a5,5
     fce:	10f51263          	bne	a0,a5,10d2 <linktest+0x1dc>
  close(fd);
     fd2:	8526                	mv	a0,s1
     fd4:	00005097          	auipc	ra,0x5
     fd8:	afc080e7          	jalr	-1284(ra) # 5ad0 <close>
  if(link("lf2", "lf2") >= 0){
     fdc:	00005597          	auipc	a1,0x5
     fe0:	63c58593          	addi	a1,a1,1596 # 6618 <malloc+0x722>
     fe4:	852e                	mv	a0,a1
     fe6:	00005097          	auipc	ra,0x5
     fea:	b22080e7          	jalr	-1246(ra) # 5b08 <link>
     fee:	10055063          	bgez	a0,10ee <linktest+0x1f8>
  unlink("lf2");
     ff2:	00005517          	auipc	a0,0x5
     ff6:	62650513          	addi	a0,a0,1574 # 6618 <malloc+0x722>
     ffa:	00005097          	auipc	ra,0x5
     ffe:	afe080e7          	jalr	-1282(ra) # 5af8 <unlink>
  if(link("lf2", "lf1") >= 0){
    1002:	00005597          	auipc	a1,0x5
    1006:	60e58593          	addi	a1,a1,1550 # 6610 <malloc+0x71a>
    100a:	00005517          	auipc	a0,0x5
    100e:	60e50513          	addi	a0,a0,1550 # 6618 <malloc+0x722>
    1012:	00005097          	auipc	ra,0x5
    1016:	af6080e7          	jalr	-1290(ra) # 5b08 <link>
    101a:	0e055863          	bgez	a0,110a <linktest+0x214>
  if(link(".", "lf1") >= 0){
    101e:	00005597          	auipc	a1,0x5
    1022:	5f258593          	addi	a1,a1,1522 # 6610 <malloc+0x71a>
    1026:	00005517          	auipc	a0,0x5
    102a:	6fa50513          	addi	a0,a0,1786 # 6720 <malloc+0x82a>
    102e:	00005097          	auipc	ra,0x5
    1032:	ada080e7          	jalr	-1318(ra) # 5b08 <link>
    1036:	0e055863          	bgez	a0,1126 <linktest+0x230>
}
    103a:	60e2                	ld	ra,24(sp)
    103c:	6442                	ld	s0,16(sp)
    103e:	64a2                	ld	s1,8(sp)
    1040:	6902                	ld	s2,0(sp)
    1042:	6105                	addi	sp,sp,32
    1044:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    1046:	85ca                	mv	a1,s2
    1048:	00005517          	auipc	a0,0x5
    104c:	5d850513          	addi	a0,a0,1496 # 6620 <malloc+0x72a>
    1050:	00005097          	auipc	ra,0x5
    1054:	de8080e7          	jalr	-536(ra) # 5e38 <printf>
    exit(1);
    1058:	4505                	li	a0,1
    105a:	00005097          	auipc	ra,0x5
    105e:	a4e080e7          	jalr	-1458(ra) # 5aa8 <exit>
    printf("%s: write lf1 failed\n", s);
    1062:	85ca                	mv	a1,s2
    1064:	00005517          	auipc	a0,0x5
    1068:	5d450513          	addi	a0,a0,1492 # 6638 <malloc+0x742>
    106c:	00005097          	auipc	ra,0x5
    1070:	dcc080e7          	jalr	-564(ra) # 5e38 <printf>
    exit(1);
    1074:	4505                	li	a0,1
    1076:	00005097          	auipc	ra,0x5
    107a:	a32080e7          	jalr	-1486(ra) # 5aa8 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    107e:	85ca                	mv	a1,s2
    1080:	00005517          	auipc	a0,0x5
    1084:	5d050513          	addi	a0,a0,1488 # 6650 <malloc+0x75a>
    1088:	00005097          	auipc	ra,0x5
    108c:	db0080e7          	jalr	-592(ra) # 5e38 <printf>
    exit(1);
    1090:	4505                	li	a0,1
    1092:	00005097          	auipc	ra,0x5
    1096:	a16080e7          	jalr	-1514(ra) # 5aa8 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    109a:	85ca                	mv	a1,s2
    109c:	00005517          	auipc	a0,0x5
    10a0:	5d450513          	addi	a0,a0,1492 # 6670 <malloc+0x77a>
    10a4:	00005097          	auipc	ra,0x5
    10a8:	d94080e7          	jalr	-620(ra) # 5e38 <printf>
    exit(1);
    10ac:	4505                	li	a0,1
    10ae:	00005097          	auipc	ra,0x5
    10b2:	9fa080e7          	jalr	-1542(ra) # 5aa8 <exit>
    printf("%s: open lf2 failed\n", s);
    10b6:	85ca                	mv	a1,s2
    10b8:	00005517          	auipc	a0,0x5
    10bc:	5e850513          	addi	a0,a0,1512 # 66a0 <malloc+0x7aa>
    10c0:	00005097          	auipc	ra,0x5
    10c4:	d78080e7          	jalr	-648(ra) # 5e38 <printf>
    exit(1);
    10c8:	4505                	li	a0,1
    10ca:	00005097          	auipc	ra,0x5
    10ce:	9de080e7          	jalr	-1570(ra) # 5aa8 <exit>
    printf("%s: read lf2 failed\n", s);
    10d2:	85ca                	mv	a1,s2
    10d4:	00005517          	auipc	a0,0x5
    10d8:	5e450513          	addi	a0,a0,1508 # 66b8 <malloc+0x7c2>
    10dc:	00005097          	auipc	ra,0x5
    10e0:	d5c080e7          	jalr	-676(ra) # 5e38 <printf>
    exit(1);
    10e4:	4505                	li	a0,1
    10e6:	00005097          	auipc	ra,0x5
    10ea:	9c2080e7          	jalr	-1598(ra) # 5aa8 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    10ee:	85ca                	mv	a1,s2
    10f0:	00005517          	auipc	a0,0x5
    10f4:	5e050513          	addi	a0,a0,1504 # 66d0 <malloc+0x7da>
    10f8:	00005097          	auipc	ra,0x5
    10fc:	d40080e7          	jalr	-704(ra) # 5e38 <printf>
    exit(1);
    1100:	4505                	li	a0,1
    1102:	00005097          	auipc	ra,0x5
    1106:	9a6080e7          	jalr	-1626(ra) # 5aa8 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    110a:	85ca                	mv	a1,s2
    110c:	00005517          	auipc	a0,0x5
    1110:	5ec50513          	addi	a0,a0,1516 # 66f8 <malloc+0x802>
    1114:	00005097          	auipc	ra,0x5
    1118:	d24080e7          	jalr	-732(ra) # 5e38 <printf>
    exit(1);
    111c:	4505                	li	a0,1
    111e:	00005097          	auipc	ra,0x5
    1122:	98a080e7          	jalr	-1654(ra) # 5aa8 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    1126:	85ca                	mv	a1,s2
    1128:	00005517          	auipc	a0,0x5
    112c:	60050513          	addi	a0,a0,1536 # 6728 <malloc+0x832>
    1130:	00005097          	auipc	ra,0x5
    1134:	d08080e7          	jalr	-760(ra) # 5e38 <printf>
    exit(1);
    1138:	4505                	li	a0,1
    113a:	00005097          	auipc	ra,0x5
    113e:	96e080e7          	jalr	-1682(ra) # 5aa8 <exit>

0000000000001142 <validatetest>:
{
    1142:	7139                	addi	sp,sp,-64
    1144:	fc06                	sd	ra,56(sp)
    1146:	f822                	sd	s0,48(sp)
    1148:	f426                	sd	s1,40(sp)
    114a:	f04a                	sd	s2,32(sp)
    114c:	ec4e                	sd	s3,24(sp)
    114e:	e852                	sd	s4,16(sp)
    1150:	e456                	sd	s5,8(sp)
    1152:	e05a                	sd	s6,0(sp)
    1154:	0080                	addi	s0,sp,64
    1156:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1158:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    115a:	00005997          	auipc	s3,0x5
    115e:	5ee98993          	addi	s3,s3,1518 # 6748 <malloc+0x852>
    1162:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1164:	6a85                	lui	s5,0x1
    1166:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    116a:	85a6                	mv	a1,s1
    116c:	854e                	mv	a0,s3
    116e:	00005097          	auipc	ra,0x5
    1172:	99a080e7          	jalr	-1638(ra) # 5b08 <link>
    1176:	01251f63          	bne	a0,s2,1194 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    117a:	94d6                	add	s1,s1,s5
    117c:	ff4497e3          	bne	s1,s4,116a <validatetest+0x28>
}
    1180:	70e2                	ld	ra,56(sp)
    1182:	7442                	ld	s0,48(sp)
    1184:	74a2                	ld	s1,40(sp)
    1186:	7902                	ld	s2,32(sp)
    1188:	69e2                	ld	s3,24(sp)
    118a:	6a42                	ld	s4,16(sp)
    118c:	6aa2                	ld	s5,8(sp)
    118e:	6b02                	ld	s6,0(sp)
    1190:	6121                	addi	sp,sp,64
    1192:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1194:	85da                	mv	a1,s6
    1196:	00005517          	auipc	a0,0x5
    119a:	5c250513          	addi	a0,a0,1474 # 6758 <malloc+0x862>
    119e:	00005097          	auipc	ra,0x5
    11a2:	c9a080e7          	jalr	-870(ra) # 5e38 <printf>
      exit(1);
    11a6:	4505                	li	a0,1
    11a8:	00005097          	auipc	ra,0x5
    11ac:	900080e7          	jalr	-1792(ra) # 5aa8 <exit>

00000000000011b0 <bigdir>:
{
    11b0:	715d                	addi	sp,sp,-80
    11b2:	e486                	sd	ra,72(sp)
    11b4:	e0a2                	sd	s0,64(sp)
    11b6:	fc26                	sd	s1,56(sp)
    11b8:	f84a                	sd	s2,48(sp)
    11ba:	f44e                	sd	s3,40(sp)
    11bc:	f052                	sd	s4,32(sp)
    11be:	ec56                	sd	s5,24(sp)
    11c0:	e85a                	sd	s6,16(sp)
    11c2:	0880                	addi	s0,sp,80
    11c4:	89aa                	mv	s3,a0
  unlink("bd");
    11c6:	00005517          	auipc	a0,0x5
    11ca:	5b250513          	addi	a0,a0,1458 # 6778 <malloc+0x882>
    11ce:	00005097          	auipc	ra,0x5
    11d2:	92a080e7          	jalr	-1750(ra) # 5af8 <unlink>
  fd = open("bd", O_CREATE);
    11d6:	20000593          	li	a1,512
    11da:	00005517          	auipc	a0,0x5
    11de:	59e50513          	addi	a0,a0,1438 # 6778 <malloc+0x882>
    11e2:	00005097          	auipc	ra,0x5
    11e6:	906080e7          	jalr	-1786(ra) # 5ae8 <open>
  if(fd < 0){
    11ea:	0c054963          	bltz	a0,12bc <bigdir+0x10c>
  close(fd);
    11ee:	00005097          	auipc	ra,0x5
    11f2:	8e2080e7          	jalr	-1822(ra) # 5ad0 <close>
  for(i = 0; i < N; i++){
    11f6:	4901                	li	s2,0
    name[0] = 'x';
    11f8:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    11fc:	00005a17          	auipc	s4,0x5
    1200:	57ca0a13          	addi	s4,s4,1404 # 6778 <malloc+0x882>
  for(i = 0; i < N; i++){
    1204:	1f400b13          	li	s6,500
    name[0] = 'x';
    1208:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    120c:	41f9579b          	sraiw	a5,s2,0x1f
    1210:	01a7d71b          	srliw	a4,a5,0x1a
    1214:	012707bb          	addw	a5,a4,s2
    1218:	4067d69b          	sraiw	a3,a5,0x6
    121c:	0306869b          	addiw	a3,a3,48
    1220:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1224:	03f7f793          	andi	a5,a5,63
    1228:	9f99                	subw	a5,a5,a4
    122a:	0307879b          	addiw	a5,a5,48
    122e:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1232:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    1236:	fb040593          	addi	a1,s0,-80
    123a:	8552                	mv	a0,s4
    123c:	00005097          	auipc	ra,0x5
    1240:	8cc080e7          	jalr	-1844(ra) # 5b08 <link>
    1244:	84aa                	mv	s1,a0
    1246:	e949                	bnez	a0,12d8 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1248:	2905                	addiw	s2,s2,1
    124a:	fb691fe3          	bne	s2,s6,1208 <bigdir+0x58>
  unlink("bd");
    124e:	00005517          	auipc	a0,0x5
    1252:	52a50513          	addi	a0,a0,1322 # 6778 <malloc+0x882>
    1256:	00005097          	auipc	ra,0x5
    125a:	8a2080e7          	jalr	-1886(ra) # 5af8 <unlink>
    name[0] = 'x';
    125e:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1262:	1f400a13          	li	s4,500
    name[0] = 'x';
    1266:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    126a:	41f4d79b          	sraiw	a5,s1,0x1f
    126e:	01a7d71b          	srliw	a4,a5,0x1a
    1272:	009707bb          	addw	a5,a4,s1
    1276:	4067d69b          	sraiw	a3,a5,0x6
    127a:	0306869b          	addiw	a3,a3,48
    127e:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1282:	03f7f793          	andi	a5,a5,63
    1286:	9f99                	subw	a5,a5,a4
    1288:	0307879b          	addiw	a5,a5,48
    128c:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1290:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1294:	fb040513          	addi	a0,s0,-80
    1298:	00005097          	auipc	ra,0x5
    129c:	860080e7          	jalr	-1952(ra) # 5af8 <unlink>
    12a0:	ed21                	bnez	a0,12f8 <bigdir+0x148>
  for(i = 0; i < N; i++){
    12a2:	2485                	addiw	s1,s1,1
    12a4:	fd4491e3          	bne	s1,s4,1266 <bigdir+0xb6>
}
    12a8:	60a6                	ld	ra,72(sp)
    12aa:	6406                	ld	s0,64(sp)
    12ac:	74e2                	ld	s1,56(sp)
    12ae:	7942                	ld	s2,48(sp)
    12b0:	79a2                	ld	s3,40(sp)
    12b2:	7a02                	ld	s4,32(sp)
    12b4:	6ae2                	ld	s5,24(sp)
    12b6:	6b42                	ld	s6,16(sp)
    12b8:	6161                	addi	sp,sp,80
    12ba:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    12bc:	85ce                	mv	a1,s3
    12be:	00005517          	auipc	a0,0x5
    12c2:	4c250513          	addi	a0,a0,1218 # 6780 <malloc+0x88a>
    12c6:	00005097          	auipc	ra,0x5
    12ca:	b72080e7          	jalr	-1166(ra) # 5e38 <printf>
    exit(1);
    12ce:	4505                	li	a0,1
    12d0:	00004097          	auipc	ra,0x4
    12d4:	7d8080e7          	jalr	2008(ra) # 5aa8 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    12d8:	fb040613          	addi	a2,s0,-80
    12dc:	85ce                	mv	a1,s3
    12de:	00005517          	auipc	a0,0x5
    12e2:	4c250513          	addi	a0,a0,1218 # 67a0 <malloc+0x8aa>
    12e6:	00005097          	auipc	ra,0x5
    12ea:	b52080e7          	jalr	-1198(ra) # 5e38 <printf>
      exit(1);
    12ee:	4505                	li	a0,1
    12f0:	00004097          	auipc	ra,0x4
    12f4:	7b8080e7          	jalr	1976(ra) # 5aa8 <exit>
      printf("%s: bigdir unlink failed", s);
    12f8:	85ce                	mv	a1,s3
    12fa:	00005517          	auipc	a0,0x5
    12fe:	4c650513          	addi	a0,a0,1222 # 67c0 <malloc+0x8ca>
    1302:	00005097          	auipc	ra,0x5
    1306:	b36080e7          	jalr	-1226(ra) # 5e38 <printf>
      exit(1);
    130a:	4505                	li	a0,1
    130c:	00004097          	auipc	ra,0x4
    1310:	79c080e7          	jalr	1948(ra) # 5aa8 <exit>

0000000000001314 <pgbug>:
{
    1314:	7179                	addi	sp,sp,-48
    1316:	f406                	sd	ra,40(sp)
    1318:	f022                	sd	s0,32(sp)
    131a:	ec26                	sd	s1,24(sp)
    131c:	1800                	addi	s0,sp,48
  argv[0] = 0;
    131e:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1322:	00008497          	auipc	s1,0x8
    1326:	cde48493          	addi	s1,s1,-802 # 9000 <big>
    132a:	fd840593          	addi	a1,s0,-40
    132e:	6088                	ld	a0,0(s1)
    1330:	00004097          	auipc	ra,0x4
    1334:	7b0080e7          	jalr	1968(ra) # 5ae0 <exec>
  pipe(big);
    1338:	6088                	ld	a0,0(s1)
    133a:	00004097          	auipc	ra,0x4
    133e:	77e080e7          	jalr	1918(ra) # 5ab8 <pipe>
  exit(0);
    1342:	4501                	li	a0,0
    1344:	00004097          	auipc	ra,0x4
    1348:	764080e7          	jalr	1892(ra) # 5aa8 <exit>

000000000000134c <badarg>:
{
    134c:	7139                	addi	sp,sp,-64
    134e:	fc06                	sd	ra,56(sp)
    1350:	f822                	sd	s0,48(sp)
    1352:	f426                	sd	s1,40(sp)
    1354:	f04a                	sd	s2,32(sp)
    1356:	ec4e                	sd	s3,24(sp)
    1358:	0080                	addi	s0,sp,64
    135a:	64b1                	lui	s1,0xc
    135c:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1e08>
    argv[0] = (char*)0xffffffff;
    1360:	597d                	li	s2,-1
    1362:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    1366:	00005997          	auipc	s3,0x5
    136a:	cd298993          	addi	s3,s3,-814 # 6038 <malloc+0x142>
    argv[0] = (char*)0xffffffff;
    136e:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1372:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1376:	fc040593          	addi	a1,s0,-64
    137a:	854e                	mv	a0,s3
    137c:	00004097          	auipc	ra,0x4
    1380:	764080e7          	jalr	1892(ra) # 5ae0 <exec>
  for(int i = 0; i < 50000; i++){
    1384:	34fd                	addiw	s1,s1,-1
    1386:	f4e5                	bnez	s1,136e <badarg+0x22>
  exit(0);
    1388:	4501                	li	a0,0
    138a:	00004097          	auipc	ra,0x4
    138e:	71e080e7          	jalr	1822(ra) # 5aa8 <exit>

0000000000001392 <copyinstr2>:
{
    1392:	7155                	addi	sp,sp,-208
    1394:	e586                	sd	ra,200(sp)
    1396:	e1a2                	sd	s0,192(sp)
    1398:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    139a:	f6840793          	addi	a5,s0,-152
    139e:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    13a2:	07800713          	li	a4,120
    13a6:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    13aa:	0785                	addi	a5,a5,1
    13ac:	fed79de3          	bne	a5,a3,13a6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    13b0:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    13b4:	f6840513          	addi	a0,s0,-152
    13b8:	00004097          	auipc	ra,0x4
    13bc:	740080e7          	jalr	1856(ra) # 5af8 <unlink>
  if(ret != -1){
    13c0:	57fd                	li	a5,-1
    13c2:	0ef51063          	bne	a0,a5,14a2 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    13c6:	20100593          	li	a1,513
    13ca:	f6840513          	addi	a0,s0,-152
    13ce:	00004097          	auipc	ra,0x4
    13d2:	71a080e7          	jalr	1818(ra) # 5ae8 <open>
  if(fd != -1){
    13d6:	57fd                	li	a5,-1
    13d8:	0ef51563          	bne	a0,a5,14c2 <copyinstr2+0x130>
  ret = link(b, b);
    13dc:	f6840593          	addi	a1,s0,-152
    13e0:	852e                	mv	a0,a1
    13e2:	00004097          	auipc	ra,0x4
    13e6:	726080e7          	jalr	1830(ra) # 5b08 <link>
  if(ret != -1){
    13ea:	57fd                	li	a5,-1
    13ec:	0ef51b63          	bne	a0,a5,14e2 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    13f0:	00006797          	auipc	a5,0x6
    13f4:	62878793          	addi	a5,a5,1576 # 7a18 <malloc+0x1b22>
    13f8:	f4f43c23          	sd	a5,-168(s0)
    13fc:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1400:	f5840593          	addi	a1,s0,-168
    1404:	f6840513          	addi	a0,s0,-152
    1408:	00004097          	auipc	ra,0x4
    140c:	6d8080e7          	jalr	1752(ra) # 5ae0 <exec>
  if(ret != -1){
    1410:	57fd                	li	a5,-1
    1412:	0ef51963          	bne	a0,a5,1504 <copyinstr2+0x172>
  int pid = fork();
    1416:	00004097          	auipc	ra,0x4
    141a:	68a080e7          	jalr	1674(ra) # 5aa0 <fork>
  if(pid < 0){
    141e:	10054363          	bltz	a0,1524 <copyinstr2+0x192>
  if(pid == 0){
    1422:	12051463          	bnez	a0,154a <copyinstr2+0x1b8>
    1426:	00008797          	auipc	a5,0x8
    142a:	11a78793          	addi	a5,a5,282 # 9540 <big.0>
    142e:	00009697          	auipc	a3,0x9
    1432:	11268693          	addi	a3,a3,274 # a540 <big.0+0x1000>
      big[i] = 'x';
    1436:	07800713          	li	a4,120
    143a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    143e:	0785                	addi	a5,a5,1
    1440:	fed79de3          	bne	a5,a3,143a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1444:	00009797          	auipc	a5,0x9
    1448:	0e078e23          	sb	zero,252(a5) # a540 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    144c:	00007797          	auipc	a5,0x7
    1450:	fcc78793          	addi	a5,a5,-52 # 8418 <malloc+0x2522>
    1454:	6390                	ld	a2,0(a5)
    1456:	6794                	ld	a3,8(a5)
    1458:	6b98                	ld	a4,16(a5)
    145a:	6f9c                	ld	a5,24(a5)
    145c:	f2c43823          	sd	a2,-208(s0)
    1460:	f2d43c23          	sd	a3,-200(s0)
    1464:	f4e43023          	sd	a4,-192(s0)
    1468:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    146c:	f3040593          	addi	a1,s0,-208
    1470:	00005517          	auipc	a0,0x5
    1474:	bc850513          	addi	a0,a0,-1080 # 6038 <malloc+0x142>
    1478:	00004097          	auipc	ra,0x4
    147c:	668080e7          	jalr	1640(ra) # 5ae0 <exec>
    if(ret != -1){
    1480:	57fd                	li	a5,-1
    1482:	0af50e63          	beq	a0,a5,153e <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1486:	55fd                	li	a1,-1
    1488:	00005517          	auipc	a0,0x5
    148c:	3e050513          	addi	a0,a0,992 # 6868 <malloc+0x972>
    1490:	00005097          	auipc	ra,0x5
    1494:	9a8080e7          	jalr	-1624(ra) # 5e38 <printf>
      exit(1);
    1498:	4505                	li	a0,1
    149a:	00004097          	auipc	ra,0x4
    149e:	60e080e7          	jalr	1550(ra) # 5aa8 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    14a2:	862a                	mv	a2,a0
    14a4:	f6840593          	addi	a1,s0,-152
    14a8:	00005517          	auipc	a0,0x5
    14ac:	33850513          	addi	a0,a0,824 # 67e0 <malloc+0x8ea>
    14b0:	00005097          	auipc	ra,0x5
    14b4:	988080e7          	jalr	-1656(ra) # 5e38 <printf>
    exit(1);
    14b8:	4505                	li	a0,1
    14ba:	00004097          	auipc	ra,0x4
    14be:	5ee080e7          	jalr	1518(ra) # 5aa8 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    14c2:	862a                	mv	a2,a0
    14c4:	f6840593          	addi	a1,s0,-152
    14c8:	00005517          	auipc	a0,0x5
    14cc:	33850513          	addi	a0,a0,824 # 6800 <malloc+0x90a>
    14d0:	00005097          	auipc	ra,0x5
    14d4:	968080e7          	jalr	-1688(ra) # 5e38 <printf>
    exit(1);
    14d8:	4505                	li	a0,1
    14da:	00004097          	auipc	ra,0x4
    14de:	5ce080e7          	jalr	1486(ra) # 5aa8 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    14e2:	86aa                	mv	a3,a0
    14e4:	f6840613          	addi	a2,s0,-152
    14e8:	85b2                	mv	a1,a2
    14ea:	00005517          	auipc	a0,0x5
    14ee:	33650513          	addi	a0,a0,822 # 6820 <malloc+0x92a>
    14f2:	00005097          	auipc	ra,0x5
    14f6:	946080e7          	jalr	-1722(ra) # 5e38 <printf>
    exit(1);
    14fa:	4505                	li	a0,1
    14fc:	00004097          	auipc	ra,0x4
    1500:	5ac080e7          	jalr	1452(ra) # 5aa8 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1504:	567d                	li	a2,-1
    1506:	f6840593          	addi	a1,s0,-152
    150a:	00005517          	auipc	a0,0x5
    150e:	33e50513          	addi	a0,a0,830 # 6848 <malloc+0x952>
    1512:	00005097          	auipc	ra,0x5
    1516:	926080e7          	jalr	-1754(ra) # 5e38 <printf>
    exit(1);
    151a:	4505                	li	a0,1
    151c:	00004097          	auipc	ra,0x4
    1520:	58c080e7          	jalr	1420(ra) # 5aa8 <exit>
    printf("fork failed\n");
    1524:	00005517          	auipc	a0,0x5
    1528:	7a450513          	addi	a0,a0,1956 # 6cc8 <malloc+0xdd2>
    152c:	00005097          	auipc	ra,0x5
    1530:	90c080e7          	jalr	-1780(ra) # 5e38 <printf>
    exit(1);
    1534:	4505                	li	a0,1
    1536:	00004097          	auipc	ra,0x4
    153a:	572080e7          	jalr	1394(ra) # 5aa8 <exit>
    exit(747); // OK
    153e:	2eb00513          	li	a0,747
    1542:	00004097          	auipc	ra,0x4
    1546:	566080e7          	jalr	1382(ra) # 5aa8 <exit>
  int st = 0;
    154a:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    154e:	f5440513          	addi	a0,s0,-172
    1552:	00004097          	auipc	ra,0x4
    1556:	55e080e7          	jalr	1374(ra) # 5ab0 <wait>
  if(st != 747){
    155a:	f5442703          	lw	a4,-172(s0)
    155e:	2eb00793          	li	a5,747
    1562:	00f71663          	bne	a4,a5,156e <copyinstr2+0x1dc>
}
    1566:	60ae                	ld	ra,200(sp)
    1568:	640e                	ld	s0,192(sp)
    156a:	6169                	addi	sp,sp,208
    156c:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    156e:	00005517          	auipc	a0,0x5
    1572:	32250513          	addi	a0,a0,802 # 6890 <malloc+0x99a>
    1576:	00005097          	auipc	ra,0x5
    157a:	8c2080e7          	jalr	-1854(ra) # 5e38 <printf>
    exit(1);
    157e:	4505                	li	a0,1
    1580:	00004097          	auipc	ra,0x4
    1584:	528080e7          	jalr	1320(ra) # 5aa8 <exit>

0000000000001588 <truncate3>:
{
    1588:	7159                	addi	sp,sp,-112
    158a:	f486                	sd	ra,104(sp)
    158c:	f0a2                	sd	s0,96(sp)
    158e:	eca6                	sd	s1,88(sp)
    1590:	e8ca                	sd	s2,80(sp)
    1592:	e4ce                	sd	s3,72(sp)
    1594:	e0d2                	sd	s4,64(sp)
    1596:	fc56                	sd	s5,56(sp)
    1598:	1880                	addi	s0,sp,112
    159a:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    159c:	60100593          	li	a1,1537
    15a0:	00005517          	auipc	a0,0x5
    15a4:	af050513          	addi	a0,a0,-1296 # 6090 <malloc+0x19a>
    15a8:	00004097          	auipc	ra,0x4
    15ac:	540080e7          	jalr	1344(ra) # 5ae8 <open>
    15b0:	00004097          	auipc	ra,0x4
    15b4:	520080e7          	jalr	1312(ra) # 5ad0 <close>
  pid = fork();
    15b8:	00004097          	auipc	ra,0x4
    15bc:	4e8080e7          	jalr	1256(ra) # 5aa0 <fork>
  if(pid < 0){
    15c0:	08054063          	bltz	a0,1640 <truncate3+0xb8>
  if(pid == 0){
    15c4:	e969                	bnez	a0,1696 <truncate3+0x10e>
    15c6:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    15ca:	00005a17          	auipc	s4,0x5
    15ce:	ac6a0a13          	addi	s4,s4,-1338 # 6090 <malloc+0x19a>
      int n = write(fd, "1234567890", 10);
    15d2:	00005a97          	auipc	s5,0x5
    15d6:	31ea8a93          	addi	s5,s5,798 # 68f0 <malloc+0x9fa>
      int fd = open("truncfile", O_WRONLY);
    15da:	4585                	li	a1,1
    15dc:	8552                	mv	a0,s4
    15de:	00004097          	auipc	ra,0x4
    15e2:	50a080e7          	jalr	1290(ra) # 5ae8 <open>
    15e6:	84aa                	mv	s1,a0
      if(fd < 0){
    15e8:	06054a63          	bltz	a0,165c <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    15ec:	4629                	li	a2,10
    15ee:	85d6                	mv	a1,s5
    15f0:	00004097          	auipc	ra,0x4
    15f4:	4d8080e7          	jalr	1240(ra) # 5ac8 <write>
      if(n != 10){
    15f8:	47a9                	li	a5,10
    15fa:	06f51f63          	bne	a0,a5,1678 <truncate3+0xf0>
      close(fd);
    15fe:	8526                	mv	a0,s1
    1600:	00004097          	auipc	ra,0x4
    1604:	4d0080e7          	jalr	1232(ra) # 5ad0 <close>
      fd = open("truncfile", O_RDONLY);
    1608:	4581                	li	a1,0
    160a:	8552                	mv	a0,s4
    160c:	00004097          	auipc	ra,0x4
    1610:	4dc080e7          	jalr	1244(ra) # 5ae8 <open>
    1614:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1616:	02000613          	li	a2,32
    161a:	f9840593          	addi	a1,s0,-104
    161e:	00004097          	auipc	ra,0x4
    1622:	4a2080e7          	jalr	1186(ra) # 5ac0 <read>
      close(fd);
    1626:	8526                	mv	a0,s1
    1628:	00004097          	auipc	ra,0x4
    162c:	4a8080e7          	jalr	1192(ra) # 5ad0 <close>
    for(int i = 0; i < 100; i++){
    1630:	39fd                	addiw	s3,s3,-1
    1632:	fa0994e3          	bnez	s3,15da <truncate3+0x52>
    exit(0);
    1636:	4501                	li	a0,0
    1638:	00004097          	auipc	ra,0x4
    163c:	470080e7          	jalr	1136(ra) # 5aa8 <exit>
    printf("%s: fork failed\n", s);
    1640:	85ca                	mv	a1,s2
    1642:	00005517          	auipc	a0,0x5
    1646:	27e50513          	addi	a0,a0,638 # 68c0 <malloc+0x9ca>
    164a:	00004097          	auipc	ra,0x4
    164e:	7ee080e7          	jalr	2030(ra) # 5e38 <printf>
    exit(1);
    1652:	4505                	li	a0,1
    1654:	00004097          	auipc	ra,0x4
    1658:	454080e7          	jalr	1108(ra) # 5aa8 <exit>
        printf("%s: open failed\n", s);
    165c:	85ca                	mv	a1,s2
    165e:	00005517          	auipc	a0,0x5
    1662:	27a50513          	addi	a0,a0,634 # 68d8 <malloc+0x9e2>
    1666:	00004097          	auipc	ra,0x4
    166a:	7d2080e7          	jalr	2002(ra) # 5e38 <printf>
        exit(1);
    166e:	4505                	li	a0,1
    1670:	00004097          	auipc	ra,0x4
    1674:	438080e7          	jalr	1080(ra) # 5aa8 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1678:	862a                	mv	a2,a0
    167a:	85ca                	mv	a1,s2
    167c:	00005517          	auipc	a0,0x5
    1680:	28450513          	addi	a0,a0,644 # 6900 <malloc+0xa0a>
    1684:	00004097          	auipc	ra,0x4
    1688:	7b4080e7          	jalr	1972(ra) # 5e38 <printf>
        exit(1);
    168c:	4505                	li	a0,1
    168e:	00004097          	auipc	ra,0x4
    1692:	41a080e7          	jalr	1050(ra) # 5aa8 <exit>
    1696:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    169a:	00005a17          	auipc	s4,0x5
    169e:	9f6a0a13          	addi	s4,s4,-1546 # 6090 <malloc+0x19a>
    int n = write(fd, "xxx", 3);
    16a2:	00005a97          	auipc	s5,0x5
    16a6:	27ea8a93          	addi	s5,s5,638 # 6920 <malloc+0xa2a>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    16aa:	60100593          	li	a1,1537
    16ae:	8552                	mv	a0,s4
    16b0:	00004097          	auipc	ra,0x4
    16b4:	438080e7          	jalr	1080(ra) # 5ae8 <open>
    16b8:	84aa                	mv	s1,a0
    if(fd < 0){
    16ba:	04054763          	bltz	a0,1708 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    16be:	460d                	li	a2,3
    16c0:	85d6                	mv	a1,s5
    16c2:	00004097          	auipc	ra,0x4
    16c6:	406080e7          	jalr	1030(ra) # 5ac8 <write>
    if(n != 3){
    16ca:	478d                	li	a5,3
    16cc:	04f51c63          	bne	a0,a5,1724 <truncate3+0x19c>
    close(fd);
    16d0:	8526                	mv	a0,s1
    16d2:	00004097          	auipc	ra,0x4
    16d6:	3fe080e7          	jalr	1022(ra) # 5ad0 <close>
  for(int i = 0; i < 150; i++){
    16da:	39fd                	addiw	s3,s3,-1
    16dc:	fc0997e3          	bnez	s3,16aa <truncate3+0x122>
  wait(&xstatus);
    16e0:	fbc40513          	addi	a0,s0,-68
    16e4:	00004097          	auipc	ra,0x4
    16e8:	3cc080e7          	jalr	972(ra) # 5ab0 <wait>
  unlink("truncfile");
    16ec:	00005517          	auipc	a0,0x5
    16f0:	9a450513          	addi	a0,a0,-1628 # 6090 <malloc+0x19a>
    16f4:	00004097          	auipc	ra,0x4
    16f8:	404080e7          	jalr	1028(ra) # 5af8 <unlink>
  exit(xstatus);
    16fc:	fbc42503          	lw	a0,-68(s0)
    1700:	00004097          	auipc	ra,0x4
    1704:	3a8080e7          	jalr	936(ra) # 5aa8 <exit>
      printf("%s: open failed\n", s);
    1708:	85ca                	mv	a1,s2
    170a:	00005517          	auipc	a0,0x5
    170e:	1ce50513          	addi	a0,a0,462 # 68d8 <malloc+0x9e2>
    1712:	00004097          	auipc	ra,0x4
    1716:	726080e7          	jalr	1830(ra) # 5e38 <printf>
      exit(1);
    171a:	4505                	li	a0,1
    171c:	00004097          	auipc	ra,0x4
    1720:	38c080e7          	jalr	908(ra) # 5aa8 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1724:	862a                	mv	a2,a0
    1726:	85ca                	mv	a1,s2
    1728:	00005517          	auipc	a0,0x5
    172c:	20050513          	addi	a0,a0,512 # 6928 <malloc+0xa32>
    1730:	00004097          	auipc	ra,0x4
    1734:	708080e7          	jalr	1800(ra) # 5e38 <printf>
      exit(1);
    1738:	4505                	li	a0,1
    173a:	00004097          	auipc	ra,0x4
    173e:	36e080e7          	jalr	878(ra) # 5aa8 <exit>

0000000000001742 <exectest>:
{
    1742:	715d                	addi	sp,sp,-80
    1744:	e486                	sd	ra,72(sp)
    1746:	e0a2                	sd	s0,64(sp)
    1748:	fc26                	sd	s1,56(sp)
    174a:	f84a                	sd	s2,48(sp)
    174c:	0880                	addi	s0,sp,80
    174e:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1750:	00005797          	auipc	a5,0x5
    1754:	8e878793          	addi	a5,a5,-1816 # 6038 <malloc+0x142>
    1758:	fcf43023          	sd	a5,-64(s0)
    175c:	00005797          	auipc	a5,0x5
    1760:	1ec78793          	addi	a5,a5,492 # 6948 <malloc+0xa52>
    1764:	fcf43423          	sd	a5,-56(s0)
    1768:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    176c:	00005517          	auipc	a0,0x5
    1770:	1e450513          	addi	a0,a0,484 # 6950 <malloc+0xa5a>
    1774:	00004097          	auipc	ra,0x4
    1778:	384080e7          	jalr	900(ra) # 5af8 <unlink>
  pid = fork();
    177c:	00004097          	auipc	ra,0x4
    1780:	324080e7          	jalr	804(ra) # 5aa0 <fork>
  if(pid < 0) {
    1784:	04054663          	bltz	a0,17d0 <exectest+0x8e>
    1788:	84aa                	mv	s1,a0
  if(pid == 0) {
    178a:	e959                	bnez	a0,1820 <exectest+0xde>
    close(1);
    178c:	4505                	li	a0,1
    178e:	00004097          	auipc	ra,0x4
    1792:	342080e7          	jalr	834(ra) # 5ad0 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1796:	20100593          	li	a1,513
    179a:	00005517          	auipc	a0,0x5
    179e:	1b650513          	addi	a0,a0,438 # 6950 <malloc+0xa5a>
    17a2:	00004097          	auipc	ra,0x4
    17a6:	346080e7          	jalr	838(ra) # 5ae8 <open>
    if(fd < 0) {
    17aa:	04054163          	bltz	a0,17ec <exectest+0xaa>
    if(fd != 1) {
    17ae:	4785                	li	a5,1
    17b0:	04f50c63          	beq	a0,a5,1808 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    17b4:	85ca                	mv	a1,s2
    17b6:	00005517          	auipc	a0,0x5
    17ba:	1ba50513          	addi	a0,a0,442 # 6970 <malloc+0xa7a>
    17be:	00004097          	auipc	ra,0x4
    17c2:	67a080e7          	jalr	1658(ra) # 5e38 <printf>
      exit(1);
    17c6:	4505                	li	a0,1
    17c8:	00004097          	auipc	ra,0x4
    17cc:	2e0080e7          	jalr	736(ra) # 5aa8 <exit>
     printf("%s: fork failed\n", s);
    17d0:	85ca                	mv	a1,s2
    17d2:	00005517          	auipc	a0,0x5
    17d6:	0ee50513          	addi	a0,a0,238 # 68c0 <malloc+0x9ca>
    17da:	00004097          	auipc	ra,0x4
    17de:	65e080e7          	jalr	1630(ra) # 5e38 <printf>
     exit(1);
    17e2:	4505                	li	a0,1
    17e4:	00004097          	auipc	ra,0x4
    17e8:	2c4080e7          	jalr	708(ra) # 5aa8 <exit>
      printf("%s: create failed\n", s);
    17ec:	85ca                	mv	a1,s2
    17ee:	00005517          	auipc	a0,0x5
    17f2:	16a50513          	addi	a0,a0,362 # 6958 <malloc+0xa62>
    17f6:	00004097          	auipc	ra,0x4
    17fa:	642080e7          	jalr	1602(ra) # 5e38 <printf>
      exit(1);
    17fe:	4505                	li	a0,1
    1800:	00004097          	auipc	ra,0x4
    1804:	2a8080e7          	jalr	680(ra) # 5aa8 <exit>
    if(exec("echo", echoargv) < 0){
    1808:	fc040593          	addi	a1,s0,-64
    180c:	00005517          	auipc	a0,0x5
    1810:	82c50513          	addi	a0,a0,-2004 # 6038 <malloc+0x142>
    1814:	00004097          	auipc	ra,0x4
    1818:	2cc080e7          	jalr	716(ra) # 5ae0 <exec>
    181c:	02054163          	bltz	a0,183e <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1820:	fdc40513          	addi	a0,s0,-36
    1824:	00004097          	auipc	ra,0x4
    1828:	28c080e7          	jalr	652(ra) # 5ab0 <wait>
    182c:	02951763          	bne	a0,s1,185a <exectest+0x118>
  if(xstatus != 0)
    1830:	fdc42503          	lw	a0,-36(s0)
    1834:	cd0d                	beqz	a0,186e <exectest+0x12c>
    exit(xstatus);
    1836:	00004097          	auipc	ra,0x4
    183a:	272080e7          	jalr	626(ra) # 5aa8 <exit>
      printf("%s: exec echo failed\n", s);
    183e:	85ca                	mv	a1,s2
    1840:	00005517          	auipc	a0,0x5
    1844:	14050513          	addi	a0,a0,320 # 6980 <malloc+0xa8a>
    1848:	00004097          	auipc	ra,0x4
    184c:	5f0080e7          	jalr	1520(ra) # 5e38 <printf>
      exit(1);
    1850:	4505                	li	a0,1
    1852:	00004097          	auipc	ra,0x4
    1856:	256080e7          	jalr	598(ra) # 5aa8 <exit>
    printf("%s: wait failed!\n", s);
    185a:	85ca                	mv	a1,s2
    185c:	00005517          	auipc	a0,0x5
    1860:	13c50513          	addi	a0,a0,316 # 6998 <malloc+0xaa2>
    1864:	00004097          	auipc	ra,0x4
    1868:	5d4080e7          	jalr	1492(ra) # 5e38 <printf>
    186c:	b7d1                	j	1830 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    186e:	4581                	li	a1,0
    1870:	00005517          	auipc	a0,0x5
    1874:	0e050513          	addi	a0,a0,224 # 6950 <malloc+0xa5a>
    1878:	00004097          	auipc	ra,0x4
    187c:	270080e7          	jalr	624(ra) # 5ae8 <open>
  if(fd < 0) {
    1880:	02054a63          	bltz	a0,18b4 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1884:	4609                	li	a2,2
    1886:	fb840593          	addi	a1,s0,-72
    188a:	00004097          	auipc	ra,0x4
    188e:	236080e7          	jalr	566(ra) # 5ac0 <read>
    1892:	4789                	li	a5,2
    1894:	02f50e63          	beq	a0,a5,18d0 <exectest+0x18e>
    printf("%s: read failed\n", s);
    1898:	85ca                	mv	a1,s2
    189a:	00005517          	auipc	a0,0x5
    189e:	b6e50513          	addi	a0,a0,-1170 # 6408 <malloc+0x512>
    18a2:	00004097          	auipc	ra,0x4
    18a6:	596080e7          	jalr	1430(ra) # 5e38 <printf>
    exit(1);
    18aa:	4505                	li	a0,1
    18ac:	00004097          	auipc	ra,0x4
    18b0:	1fc080e7          	jalr	508(ra) # 5aa8 <exit>
    printf("%s: open failed\n", s);
    18b4:	85ca                	mv	a1,s2
    18b6:	00005517          	auipc	a0,0x5
    18ba:	02250513          	addi	a0,a0,34 # 68d8 <malloc+0x9e2>
    18be:	00004097          	auipc	ra,0x4
    18c2:	57a080e7          	jalr	1402(ra) # 5e38 <printf>
    exit(1);
    18c6:	4505                	li	a0,1
    18c8:	00004097          	auipc	ra,0x4
    18cc:	1e0080e7          	jalr	480(ra) # 5aa8 <exit>
  unlink("echo-ok");
    18d0:	00005517          	auipc	a0,0x5
    18d4:	08050513          	addi	a0,a0,128 # 6950 <malloc+0xa5a>
    18d8:	00004097          	auipc	ra,0x4
    18dc:	220080e7          	jalr	544(ra) # 5af8 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    18e0:	fb844703          	lbu	a4,-72(s0)
    18e4:	04f00793          	li	a5,79
    18e8:	00f71863          	bne	a4,a5,18f8 <exectest+0x1b6>
    18ec:	fb944703          	lbu	a4,-71(s0)
    18f0:	04b00793          	li	a5,75
    18f4:	02f70063          	beq	a4,a5,1914 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    18f8:	85ca                	mv	a1,s2
    18fa:	00005517          	auipc	a0,0x5
    18fe:	0b650513          	addi	a0,a0,182 # 69b0 <malloc+0xaba>
    1902:	00004097          	auipc	ra,0x4
    1906:	536080e7          	jalr	1334(ra) # 5e38 <printf>
    exit(1);
    190a:	4505                	li	a0,1
    190c:	00004097          	auipc	ra,0x4
    1910:	19c080e7          	jalr	412(ra) # 5aa8 <exit>
    exit(0);
    1914:	4501                	li	a0,0
    1916:	00004097          	auipc	ra,0x4
    191a:	192080e7          	jalr	402(ra) # 5aa8 <exit>

000000000000191e <pipe1>:
{
    191e:	711d                	addi	sp,sp,-96
    1920:	ec86                	sd	ra,88(sp)
    1922:	e8a2                	sd	s0,80(sp)
    1924:	e4a6                	sd	s1,72(sp)
    1926:	e0ca                	sd	s2,64(sp)
    1928:	fc4e                	sd	s3,56(sp)
    192a:	f852                	sd	s4,48(sp)
    192c:	f456                	sd	s5,40(sp)
    192e:	f05a                	sd	s6,32(sp)
    1930:	ec5e                	sd	s7,24(sp)
    1932:	1080                	addi	s0,sp,96
    1934:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1936:	fa840513          	addi	a0,s0,-88
    193a:	00004097          	auipc	ra,0x4
    193e:	17e080e7          	jalr	382(ra) # 5ab8 <pipe>
    1942:	ed25                	bnez	a0,19ba <pipe1+0x9c>
    1944:	84aa                	mv	s1,a0
  pid = fork();
    1946:	00004097          	auipc	ra,0x4
    194a:	15a080e7          	jalr	346(ra) # 5aa0 <fork>
    194e:	8a2a                	mv	s4,a0
  if(pid == 0){
    1950:	c159                	beqz	a0,19d6 <pipe1+0xb8>
  } else if(pid > 0){
    1952:	16a05e63          	blez	a0,1ace <pipe1+0x1b0>
    close(fds[1]);
    1956:	fac42503          	lw	a0,-84(s0)
    195a:	00004097          	auipc	ra,0x4
    195e:	176080e7          	jalr	374(ra) # 5ad0 <close>
    total = 0;
    1962:	8a26                	mv	s4,s1
    cc = 1;
    1964:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1966:	0000ba97          	auipc	s5,0xb
    196a:	2f2a8a93          	addi	s5,s5,754 # cc58 <buf>
      if(cc > sizeof(buf))
    196e:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1970:	864e                	mv	a2,s3
    1972:	85d6                	mv	a1,s5
    1974:	fa842503          	lw	a0,-88(s0)
    1978:	00004097          	auipc	ra,0x4
    197c:	148080e7          	jalr	328(ra) # 5ac0 <read>
    1980:	10a05263          	blez	a0,1a84 <pipe1+0x166>
      for(i = 0; i < n; i++){
    1984:	0000b717          	auipc	a4,0xb
    1988:	2d470713          	addi	a4,a4,724 # cc58 <buf>
    198c:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1990:	00074683          	lbu	a3,0(a4)
    1994:	0ff4f793          	andi	a5,s1,255
    1998:	2485                	addiw	s1,s1,1
    199a:	0cf69163          	bne	a3,a5,1a5c <pipe1+0x13e>
      for(i = 0; i < n; i++){
    199e:	0705                	addi	a4,a4,1
    19a0:	fec498e3          	bne	s1,a2,1990 <pipe1+0x72>
      total += n;
    19a4:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    19a8:	0019979b          	slliw	a5,s3,0x1
    19ac:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    19b0:	013b7363          	bgeu	s6,s3,19b6 <pipe1+0x98>
        cc = sizeof(buf);
    19b4:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    19b6:	84b2                	mv	s1,a2
    19b8:	bf65                	j	1970 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    19ba:	85ca                	mv	a1,s2
    19bc:	00005517          	auipc	a0,0x5
    19c0:	00c50513          	addi	a0,a0,12 # 69c8 <malloc+0xad2>
    19c4:	00004097          	auipc	ra,0x4
    19c8:	474080e7          	jalr	1140(ra) # 5e38 <printf>
    exit(1);
    19cc:	4505                	li	a0,1
    19ce:	00004097          	auipc	ra,0x4
    19d2:	0da080e7          	jalr	218(ra) # 5aa8 <exit>
    close(fds[0]);
    19d6:	fa842503          	lw	a0,-88(s0)
    19da:	00004097          	auipc	ra,0x4
    19de:	0f6080e7          	jalr	246(ra) # 5ad0 <close>
    for(n = 0; n < N; n++){
    19e2:	0000bb17          	auipc	s6,0xb
    19e6:	276b0b13          	addi	s6,s6,630 # cc58 <buf>
    19ea:	416004bb          	negw	s1,s6
    19ee:	0ff4f493          	andi	s1,s1,255
    19f2:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    19f6:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    19f8:	6a85                	lui	s5,0x1
    19fa:	42da8a93          	addi	s5,s5,1069 # 142d <copyinstr2+0x9b>
{
    19fe:	87da                	mv	a5,s6
        buf[i] = seq++;
    1a00:	0097873b          	addw	a4,a5,s1
    1a04:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1a08:	0785                	addi	a5,a5,1
    1a0a:	fef99be3          	bne	s3,a5,1a00 <pipe1+0xe2>
        buf[i] = seq++;
    1a0e:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a12:	40900613          	li	a2,1033
    1a16:	85de                	mv	a1,s7
    1a18:	fac42503          	lw	a0,-84(s0)
    1a1c:	00004097          	auipc	ra,0x4
    1a20:	0ac080e7          	jalr	172(ra) # 5ac8 <write>
    1a24:	40900793          	li	a5,1033
    1a28:	00f51c63          	bne	a0,a5,1a40 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1a2c:	24a5                	addiw	s1,s1,9
    1a2e:	0ff4f493          	andi	s1,s1,255
    1a32:	fd5a16e3          	bne	s4,s5,19fe <pipe1+0xe0>
    exit(0);
    1a36:	4501                	li	a0,0
    1a38:	00004097          	auipc	ra,0x4
    1a3c:	070080e7          	jalr	112(ra) # 5aa8 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1a40:	85ca                	mv	a1,s2
    1a42:	00005517          	auipc	a0,0x5
    1a46:	f9e50513          	addi	a0,a0,-98 # 69e0 <malloc+0xaea>
    1a4a:	00004097          	auipc	ra,0x4
    1a4e:	3ee080e7          	jalr	1006(ra) # 5e38 <printf>
        exit(1);
    1a52:	4505                	li	a0,1
    1a54:	00004097          	auipc	ra,0x4
    1a58:	054080e7          	jalr	84(ra) # 5aa8 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1a5c:	85ca                	mv	a1,s2
    1a5e:	00005517          	auipc	a0,0x5
    1a62:	f9a50513          	addi	a0,a0,-102 # 69f8 <malloc+0xb02>
    1a66:	00004097          	auipc	ra,0x4
    1a6a:	3d2080e7          	jalr	978(ra) # 5e38 <printf>
}
    1a6e:	60e6                	ld	ra,88(sp)
    1a70:	6446                	ld	s0,80(sp)
    1a72:	64a6                	ld	s1,72(sp)
    1a74:	6906                	ld	s2,64(sp)
    1a76:	79e2                	ld	s3,56(sp)
    1a78:	7a42                	ld	s4,48(sp)
    1a7a:	7aa2                	ld	s5,40(sp)
    1a7c:	7b02                	ld	s6,32(sp)
    1a7e:	6be2                	ld	s7,24(sp)
    1a80:	6125                	addi	sp,sp,96
    1a82:	8082                	ret
    if(total != N * SZ){
    1a84:	6785                	lui	a5,0x1
    1a86:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x9b>
    1a8a:	02fa0063          	beq	s4,a5,1aaa <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1a8e:	85d2                	mv	a1,s4
    1a90:	00005517          	auipc	a0,0x5
    1a94:	f8050513          	addi	a0,a0,-128 # 6a10 <malloc+0xb1a>
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	3a0080e7          	jalr	928(ra) # 5e38 <printf>
      exit(1);
    1aa0:	4505                	li	a0,1
    1aa2:	00004097          	auipc	ra,0x4
    1aa6:	006080e7          	jalr	6(ra) # 5aa8 <exit>
    close(fds[0]);
    1aaa:	fa842503          	lw	a0,-88(s0)
    1aae:	00004097          	auipc	ra,0x4
    1ab2:	022080e7          	jalr	34(ra) # 5ad0 <close>
    wait(&xstatus);
    1ab6:	fa440513          	addi	a0,s0,-92
    1aba:	00004097          	auipc	ra,0x4
    1abe:	ff6080e7          	jalr	-10(ra) # 5ab0 <wait>
    exit(xstatus);
    1ac2:	fa442503          	lw	a0,-92(s0)
    1ac6:	00004097          	auipc	ra,0x4
    1aca:	fe2080e7          	jalr	-30(ra) # 5aa8 <exit>
    printf("%s: fork() failed\n", s);
    1ace:	85ca                	mv	a1,s2
    1ad0:	00005517          	auipc	a0,0x5
    1ad4:	f6050513          	addi	a0,a0,-160 # 6a30 <malloc+0xb3a>
    1ad8:	00004097          	auipc	ra,0x4
    1adc:	360080e7          	jalr	864(ra) # 5e38 <printf>
    exit(1);
    1ae0:	4505                	li	a0,1
    1ae2:	00004097          	auipc	ra,0x4
    1ae6:	fc6080e7          	jalr	-58(ra) # 5aa8 <exit>

0000000000001aea <exitwait>:
{
    1aea:	7139                	addi	sp,sp,-64
    1aec:	fc06                	sd	ra,56(sp)
    1aee:	f822                	sd	s0,48(sp)
    1af0:	f426                	sd	s1,40(sp)
    1af2:	f04a                	sd	s2,32(sp)
    1af4:	ec4e                	sd	s3,24(sp)
    1af6:	e852                	sd	s4,16(sp)
    1af8:	0080                	addi	s0,sp,64
    1afa:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1afc:	4901                	li	s2,0
    1afe:	06400993          	li	s3,100
    pid = fork();
    1b02:	00004097          	auipc	ra,0x4
    1b06:	f9e080e7          	jalr	-98(ra) # 5aa0 <fork>
    1b0a:	84aa                	mv	s1,a0
    if(pid < 0){
    1b0c:	02054a63          	bltz	a0,1b40 <exitwait+0x56>
    if(pid){
    1b10:	c151                	beqz	a0,1b94 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1b12:	fcc40513          	addi	a0,s0,-52
    1b16:	00004097          	auipc	ra,0x4
    1b1a:	f9a080e7          	jalr	-102(ra) # 5ab0 <wait>
    1b1e:	02951f63          	bne	a0,s1,1b5c <exitwait+0x72>
      if(i != xstate) {
    1b22:	fcc42783          	lw	a5,-52(s0)
    1b26:	05279963          	bne	a5,s2,1b78 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1b2a:	2905                	addiw	s2,s2,1
    1b2c:	fd391be3          	bne	s2,s3,1b02 <exitwait+0x18>
}
    1b30:	70e2                	ld	ra,56(sp)
    1b32:	7442                	ld	s0,48(sp)
    1b34:	74a2                	ld	s1,40(sp)
    1b36:	7902                	ld	s2,32(sp)
    1b38:	69e2                	ld	s3,24(sp)
    1b3a:	6a42                	ld	s4,16(sp)
    1b3c:	6121                	addi	sp,sp,64
    1b3e:	8082                	ret
      printf("%s: fork failed\n", s);
    1b40:	85d2                	mv	a1,s4
    1b42:	00005517          	auipc	a0,0x5
    1b46:	d7e50513          	addi	a0,a0,-642 # 68c0 <malloc+0x9ca>
    1b4a:	00004097          	auipc	ra,0x4
    1b4e:	2ee080e7          	jalr	750(ra) # 5e38 <printf>
      exit(1);
    1b52:	4505                	li	a0,1
    1b54:	00004097          	auipc	ra,0x4
    1b58:	f54080e7          	jalr	-172(ra) # 5aa8 <exit>
        printf("%s: wait wrong pid\n", s);
    1b5c:	85d2                	mv	a1,s4
    1b5e:	00005517          	auipc	a0,0x5
    1b62:	eea50513          	addi	a0,a0,-278 # 6a48 <malloc+0xb52>
    1b66:	00004097          	auipc	ra,0x4
    1b6a:	2d2080e7          	jalr	722(ra) # 5e38 <printf>
        exit(1);
    1b6e:	4505                	li	a0,1
    1b70:	00004097          	auipc	ra,0x4
    1b74:	f38080e7          	jalr	-200(ra) # 5aa8 <exit>
        printf("%s: wait wrong exit status\n", s);
    1b78:	85d2                	mv	a1,s4
    1b7a:	00005517          	auipc	a0,0x5
    1b7e:	ee650513          	addi	a0,a0,-282 # 6a60 <malloc+0xb6a>
    1b82:	00004097          	auipc	ra,0x4
    1b86:	2b6080e7          	jalr	694(ra) # 5e38 <printf>
        exit(1);
    1b8a:	4505                	li	a0,1
    1b8c:	00004097          	auipc	ra,0x4
    1b90:	f1c080e7          	jalr	-228(ra) # 5aa8 <exit>
      exit(i);
    1b94:	854a                	mv	a0,s2
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	f12080e7          	jalr	-238(ra) # 5aa8 <exit>

0000000000001b9e <twochildren>:
{
    1b9e:	1101                	addi	sp,sp,-32
    1ba0:	ec06                	sd	ra,24(sp)
    1ba2:	e822                	sd	s0,16(sp)
    1ba4:	e426                	sd	s1,8(sp)
    1ba6:	e04a                	sd	s2,0(sp)
    1ba8:	1000                	addi	s0,sp,32
    1baa:	892a                	mv	s2,a0
    1bac:	3e800493          	li	s1,1000
    int pid1 = fork();
    1bb0:	00004097          	auipc	ra,0x4
    1bb4:	ef0080e7          	jalr	-272(ra) # 5aa0 <fork>
    if(pid1 < 0){
    1bb8:	02054c63          	bltz	a0,1bf0 <twochildren+0x52>
    if(pid1 == 0){
    1bbc:	c921                	beqz	a0,1c0c <twochildren+0x6e>
      int pid2 = fork();
    1bbe:	00004097          	auipc	ra,0x4
    1bc2:	ee2080e7          	jalr	-286(ra) # 5aa0 <fork>
      if(pid2 < 0){
    1bc6:	04054763          	bltz	a0,1c14 <twochildren+0x76>
      if(pid2 == 0){
    1bca:	c13d                	beqz	a0,1c30 <twochildren+0x92>
        wait(0);
    1bcc:	4501                	li	a0,0
    1bce:	00004097          	auipc	ra,0x4
    1bd2:	ee2080e7          	jalr	-286(ra) # 5ab0 <wait>
        wait(0);
    1bd6:	4501                	li	a0,0
    1bd8:	00004097          	auipc	ra,0x4
    1bdc:	ed8080e7          	jalr	-296(ra) # 5ab0 <wait>
  for(int i = 0; i < 1000; i++){
    1be0:	34fd                	addiw	s1,s1,-1
    1be2:	f4f9                	bnez	s1,1bb0 <twochildren+0x12>
}
    1be4:	60e2                	ld	ra,24(sp)
    1be6:	6442                	ld	s0,16(sp)
    1be8:	64a2                	ld	s1,8(sp)
    1bea:	6902                	ld	s2,0(sp)
    1bec:	6105                	addi	sp,sp,32
    1bee:	8082                	ret
      printf("%s: fork failed\n", s);
    1bf0:	85ca                	mv	a1,s2
    1bf2:	00005517          	auipc	a0,0x5
    1bf6:	cce50513          	addi	a0,a0,-818 # 68c0 <malloc+0x9ca>
    1bfa:	00004097          	auipc	ra,0x4
    1bfe:	23e080e7          	jalr	574(ra) # 5e38 <printf>
      exit(1);
    1c02:	4505                	li	a0,1
    1c04:	00004097          	auipc	ra,0x4
    1c08:	ea4080e7          	jalr	-348(ra) # 5aa8 <exit>
      exit(0);
    1c0c:	00004097          	auipc	ra,0x4
    1c10:	e9c080e7          	jalr	-356(ra) # 5aa8 <exit>
        printf("%s: fork failed\n", s);
    1c14:	85ca                	mv	a1,s2
    1c16:	00005517          	auipc	a0,0x5
    1c1a:	caa50513          	addi	a0,a0,-854 # 68c0 <malloc+0x9ca>
    1c1e:	00004097          	auipc	ra,0x4
    1c22:	21a080e7          	jalr	538(ra) # 5e38 <printf>
        exit(1);
    1c26:	4505                	li	a0,1
    1c28:	00004097          	auipc	ra,0x4
    1c2c:	e80080e7          	jalr	-384(ra) # 5aa8 <exit>
        exit(0);
    1c30:	00004097          	auipc	ra,0x4
    1c34:	e78080e7          	jalr	-392(ra) # 5aa8 <exit>

0000000000001c38 <forkfork>:
{
    1c38:	7179                	addi	sp,sp,-48
    1c3a:	f406                	sd	ra,40(sp)
    1c3c:	f022                	sd	s0,32(sp)
    1c3e:	ec26                	sd	s1,24(sp)
    1c40:	1800                	addi	s0,sp,48
    1c42:	84aa                	mv	s1,a0
    int pid = fork();
    1c44:	00004097          	auipc	ra,0x4
    1c48:	e5c080e7          	jalr	-420(ra) # 5aa0 <fork>
    if(pid < 0){
    1c4c:	04054163          	bltz	a0,1c8e <forkfork+0x56>
    if(pid == 0){
    1c50:	cd29                	beqz	a0,1caa <forkfork+0x72>
    int pid = fork();
    1c52:	00004097          	auipc	ra,0x4
    1c56:	e4e080e7          	jalr	-434(ra) # 5aa0 <fork>
    if(pid < 0){
    1c5a:	02054a63          	bltz	a0,1c8e <forkfork+0x56>
    if(pid == 0){
    1c5e:	c531                	beqz	a0,1caa <forkfork+0x72>
    wait(&xstatus);
    1c60:	fdc40513          	addi	a0,s0,-36
    1c64:	00004097          	auipc	ra,0x4
    1c68:	e4c080e7          	jalr	-436(ra) # 5ab0 <wait>
    if(xstatus != 0) {
    1c6c:	fdc42783          	lw	a5,-36(s0)
    1c70:	ebbd                	bnez	a5,1ce6 <forkfork+0xae>
    wait(&xstatus);
    1c72:	fdc40513          	addi	a0,s0,-36
    1c76:	00004097          	auipc	ra,0x4
    1c7a:	e3a080e7          	jalr	-454(ra) # 5ab0 <wait>
    if(xstatus != 0) {
    1c7e:	fdc42783          	lw	a5,-36(s0)
    1c82:	e3b5                	bnez	a5,1ce6 <forkfork+0xae>
}
    1c84:	70a2                	ld	ra,40(sp)
    1c86:	7402                	ld	s0,32(sp)
    1c88:	64e2                	ld	s1,24(sp)
    1c8a:	6145                	addi	sp,sp,48
    1c8c:	8082                	ret
      printf("%s: fork failed", s);
    1c8e:	85a6                	mv	a1,s1
    1c90:	00005517          	auipc	a0,0x5
    1c94:	df050513          	addi	a0,a0,-528 # 6a80 <malloc+0xb8a>
    1c98:	00004097          	auipc	ra,0x4
    1c9c:	1a0080e7          	jalr	416(ra) # 5e38 <printf>
      exit(1);
    1ca0:	4505                	li	a0,1
    1ca2:	00004097          	auipc	ra,0x4
    1ca6:	e06080e7          	jalr	-506(ra) # 5aa8 <exit>
{
    1caa:	0c800493          	li	s1,200
        int pid1 = fork();
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	df2080e7          	jalr	-526(ra) # 5aa0 <fork>
        if(pid1 < 0){
    1cb6:	00054f63          	bltz	a0,1cd4 <forkfork+0x9c>
        if(pid1 == 0){
    1cba:	c115                	beqz	a0,1cde <forkfork+0xa6>
        wait(0);
    1cbc:	4501                	li	a0,0
    1cbe:	00004097          	auipc	ra,0x4
    1cc2:	df2080e7          	jalr	-526(ra) # 5ab0 <wait>
      for(int j = 0; j < 200; j++){
    1cc6:	34fd                	addiw	s1,s1,-1
    1cc8:	f0fd                	bnez	s1,1cae <forkfork+0x76>
      exit(0);
    1cca:	4501                	li	a0,0
    1ccc:	00004097          	auipc	ra,0x4
    1cd0:	ddc080e7          	jalr	-548(ra) # 5aa8 <exit>
          exit(1);
    1cd4:	4505                	li	a0,1
    1cd6:	00004097          	auipc	ra,0x4
    1cda:	dd2080e7          	jalr	-558(ra) # 5aa8 <exit>
          exit(0);
    1cde:	00004097          	auipc	ra,0x4
    1ce2:	dca080e7          	jalr	-566(ra) # 5aa8 <exit>
      printf("%s: fork in child failed", s);
    1ce6:	85a6                	mv	a1,s1
    1ce8:	00005517          	auipc	a0,0x5
    1cec:	da850513          	addi	a0,a0,-600 # 6a90 <malloc+0xb9a>
    1cf0:	00004097          	auipc	ra,0x4
    1cf4:	148080e7          	jalr	328(ra) # 5e38 <printf>
      exit(1);
    1cf8:	4505                	li	a0,1
    1cfa:	00004097          	auipc	ra,0x4
    1cfe:	dae080e7          	jalr	-594(ra) # 5aa8 <exit>

0000000000001d02 <reparent2>:
{
    1d02:	1101                	addi	sp,sp,-32
    1d04:	ec06                	sd	ra,24(sp)
    1d06:	e822                	sd	s0,16(sp)
    1d08:	e426                	sd	s1,8(sp)
    1d0a:	1000                	addi	s0,sp,32
    1d0c:	32000493          	li	s1,800
    int pid1 = fork();
    1d10:	00004097          	auipc	ra,0x4
    1d14:	d90080e7          	jalr	-624(ra) # 5aa0 <fork>
    if(pid1 < 0){
    1d18:	00054f63          	bltz	a0,1d36 <reparent2+0x34>
    if(pid1 == 0){
    1d1c:	c915                	beqz	a0,1d50 <reparent2+0x4e>
    wait(0);
    1d1e:	4501                	li	a0,0
    1d20:	00004097          	auipc	ra,0x4
    1d24:	d90080e7          	jalr	-624(ra) # 5ab0 <wait>
  for(int i = 0; i < 800; i++){
    1d28:	34fd                	addiw	s1,s1,-1
    1d2a:	f0fd                	bnez	s1,1d10 <reparent2+0xe>
  exit(0);
    1d2c:	4501                	li	a0,0
    1d2e:	00004097          	auipc	ra,0x4
    1d32:	d7a080e7          	jalr	-646(ra) # 5aa8 <exit>
      printf("fork failed\n");
    1d36:	00005517          	auipc	a0,0x5
    1d3a:	f9250513          	addi	a0,a0,-110 # 6cc8 <malloc+0xdd2>
    1d3e:	00004097          	auipc	ra,0x4
    1d42:	0fa080e7          	jalr	250(ra) # 5e38 <printf>
      exit(1);
    1d46:	4505                	li	a0,1
    1d48:	00004097          	auipc	ra,0x4
    1d4c:	d60080e7          	jalr	-672(ra) # 5aa8 <exit>
      fork();
    1d50:	00004097          	auipc	ra,0x4
    1d54:	d50080e7          	jalr	-688(ra) # 5aa0 <fork>
      fork();
    1d58:	00004097          	auipc	ra,0x4
    1d5c:	d48080e7          	jalr	-696(ra) # 5aa0 <fork>
      exit(0);
    1d60:	4501                	li	a0,0
    1d62:	00004097          	auipc	ra,0x4
    1d66:	d46080e7          	jalr	-698(ra) # 5aa8 <exit>

0000000000001d6a <createdelete>:
{
    1d6a:	7175                	addi	sp,sp,-144
    1d6c:	e506                	sd	ra,136(sp)
    1d6e:	e122                	sd	s0,128(sp)
    1d70:	fca6                	sd	s1,120(sp)
    1d72:	f8ca                	sd	s2,112(sp)
    1d74:	f4ce                	sd	s3,104(sp)
    1d76:	f0d2                	sd	s4,96(sp)
    1d78:	ecd6                	sd	s5,88(sp)
    1d7a:	e8da                	sd	s6,80(sp)
    1d7c:	e4de                	sd	s7,72(sp)
    1d7e:	e0e2                	sd	s8,64(sp)
    1d80:	fc66                	sd	s9,56(sp)
    1d82:	0900                	addi	s0,sp,144
    1d84:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1d86:	4901                	li	s2,0
    1d88:	4991                	li	s3,4
    pid = fork();
    1d8a:	00004097          	auipc	ra,0x4
    1d8e:	d16080e7          	jalr	-746(ra) # 5aa0 <fork>
    1d92:	84aa                	mv	s1,a0
    if(pid < 0){
    1d94:	02054f63          	bltz	a0,1dd2 <createdelete+0x68>
    if(pid == 0){
    1d98:	c939                	beqz	a0,1dee <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1d9a:	2905                	addiw	s2,s2,1
    1d9c:	ff3917e3          	bne	s2,s3,1d8a <createdelete+0x20>
    1da0:	4491                	li	s1,4
    wait(&xstatus);
    1da2:	f7c40513          	addi	a0,s0,-132
    1da6:	00004097          	auipc	ra,0x4
    1daa:	d0a080e7          	jalr	-758(ra) # 5ab0 <wait>
    if(xstatus != 0)
    1dae:	f7c42903          	lw	s2,-132(s0)
    1db2:	0e091263          	bnez	s2,1e96 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1db6:	34fd                	addiw	s1,s1,-1
    1db8:	f4ed                	bnez	s1,1da2 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1dba:	f8040123          	sb	zero,-126(s0)
    1dbe:	03000993          	li	s3,48
    1dc2:	5a7d                	li	s4,-1
    1dc4:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1dc8:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1dca:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1dcc:	07400a93          	li	s5,116
    1dd0:	a29d                	j	1f36 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1dd2:	85e6                	mv	a1,s9
    1dd4:	00005517          	auipc	a0,0x5
    1dd8:	ef450513          	addi	a0,a0,-268 # 6cc8 <malloc+0xdd2>
    1ddc:	00004097          	auipc	ra,0x4
    1de0:	05c080e7          	jalr	92(ra) # 5e38 <printf>
      exit(1);
    1de4:	4505                	li	a0,1
    1de6:	00004097          	auipc	ra,0x4
    1dea:	cc2080e7          	jalr	-830(ra) # 5aa8 <exit>
      name[0] = 'p' + pi;
    1dee:	0709091b          	addiw	s2,s2,112
    1df2:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1df6:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1dfa:	4951                	li	s2,20
    1dfc:	a015                	j	1e20 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1dfe:	85e6                	mv	a1,s9
    1e00:	00005517          	auipc	a0,0x5
    1e04:	b5850513          	addi	a0,a0,-1192 # 6958 <malloc+0xa62>
    1e08:	00004097          	auipc	ra,0x4
    1e0c:	030080e7          	jalr	48(ra) # 5e38 <printf>
          exit(1);
    1e10:	4505                	li	a0,1
    1e12:	00004097          	auipc	ra,0x4
    1e16:	c96080e7          	jalr	-874(ra) # 5aa8 <exit>
      for(i = 0; i < N; i++){
    1e1a:	2485                	addiw	s1,s1,1
    1e1c:	07248863          	beq	s1,s2,1e8c <createdelete+0x122>
        name[1] = '0' + i;
    1e20:	0304879b          	addiw	a5,s1,48
    1e24:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1e28:	20200593          	li	a1,514
    1e2c:	f8040513          	addi	a0,s0,-128
    1e30:	00004097          	auipc	ra,0x4
    1e34:	cb8080e7          	jalr	-840(ra) # 5ae8 <open>
        if(fd < 0){
    1e38:	fc0543e3          	bltz	a0,1dfe <createdelete+0x94>
        close(fd);
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	c94080e7          	jalr	-876(ra) # 5ad0 <close>
        if(i > 0 && (i % 2 ) == 0){
    1e44:	fc905be3          	blez	s1,1e1a <createdelete+0xb0>
    1e48:	0014f793          	andi	a5,s1,1
    1e4c:	f7f9                	bnez	a5,1e1a <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1e4e:	01f4d79b          	srliw	a5,s1,0x1f
    1e52:	9fa5                	addw	a5,a5,s1
    1e54:	4017d79b          	sraiw	a5,a5,0x1
    1e58:	0307879b          	addiw	a5,a5,48
    1e5c:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1e60:	f8040513          	addi	a0,s0,-128
    1e64:	00004097          	auipc	ra,0x4
    1e68:	c94080e7          	jalr	-876(ra) # 5af8 <unlink>
    1e6c:	fa0557e3          	bgez	a0,1e1a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1e70:	85e6                	mv	a1,s9
    1e72:	00005517          	auipc	a0,0x5
    1e76:	c3e50513          	addi	a0,a0,-962 # 6ab0 <malloc+0xbba>
    1e7a:	00004097          	auipc	ra,0x4
    1e7e:	fbe080e7          	jalr	-66(ra) # 5e38 <printf>
            exit(1);
    1e82:	4505                	li	a0,1
    1e84:	00004097          	auipc	ra,0x4
    1e88:	c24080e7          	jalr	-988(ra) # 5aa8 <exit>
      exit(0);
    1e8c:	4501                	li	a0,0
    1e8e:	00004097          	auipc	ra,0x4
    1e92:	c1a080e7          	jalr	-998(ra) # 5aa8 <exit>
      exit(1);
    1e96:	4505                	li	a0,1
    1e98:	00004097          	auipc	ra,0x4
    1e9c:	c10080e7          	jalr	-1008(ra) # 5aa8 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1ea0:	f8040613          	addi	a2,s0,-128
    1ea4:	85e6                	mv	a1,s9
    1ea6:	00005517          	auipc	a0,0x5
    1eaa:	c2250513          	addi	a0,a0,-990 # 6ac8 <malloc+0xbd2>
    1eae:	00004097          	auipc	ra,0x4
    1eb2:	f8a080e7          	jalr	-118(ra) # 5e38 <printf>
        exit(1);
    1eb6:	4505                	li	a0,1
    1eb8:	00004097          	auipc	ra,0x4
    1ebc:	bf0080e7          	jalr	-1040(ra) # 5aa8 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ec0:	054b7163          	bgeu	s6,s4,1f02 <createdelete+0x198>
      if(fd >= 0)
    1ec4:	02055a63          	bgez	a0,1ef8 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1ec8:	2485                	addiw	s1,s1,1
    1eca:	0ff4f493          	andi	s1,s1,255
    1ece:	05548c63          	beq	s1,s5,1f26 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1ed2:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1ed6:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1eda:	4581                	li	a1,0
    1edc:	f8040513          	addi	a0,s0,-128
    1ee0:	00004097          	auipc	ra,0x4
    1ee4:	c08080e7          	jalr	-1016(ra) # 5ae8 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1ee8:	00090463          	beqz	s2,1ef0 <createdelete+0x186>
    1eec:	fd2bdae3          	bge	s7,s2,1ec0 <createdelete+0x156>
    1ef0:	fa0548e3          	bltz	a0,1ea0 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ef4:	014b7963          	bgeu	s6,s4,1f06 <createdelete+0x19c>
        close(fd);
    1ef8:	00004097          	auipc	ra,0x4
    1efc:	bd8080e7          	jalr	-1064(ra) # 5ad0 <close>
    1f00:	b7e1                	j	1ec8 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1f02:	fc0543e3          	bltz	a0,1ec8 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1f06:	f8040613          	addi	a2,s0,-128
    1f0a:	85e6                	mv	a1,s9
    1f0c:	00005517          	auipc	a0,0x5
    1f10:	be450513          	addi	a0,a0,-1052 # 6af0 <malloc+0xbfa>
    1f14:	00004097          	auipc	ra,0x4
    1f18:	f24080e7          	jalr	-220(ra) # 5e38 <printf>
        exit(1);
    1f1c:	4505                	li	a0,1
    1f1e:	00004097          	auipc	ra,0x4
    1f22:	b8a080e7          	jalr	-1142(ra) # 5aa8 <exit>
  for(i = 0; i < N; i++){
    1f26:	2905                	addiw	s2,s2,1
    1f28:	2a05                	addiw	s4,s4,1
    1f2a:	2985                	addiw	s3,s3,1
    1f2c:	0ff9f993          	andi	s3,s3,255
    1f30:	47d1                	li	a5,20
    1f32:	02f90a63          	beq	s2,a5,1f66 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1f36:	84e2                	mv	s1,s8
    1f38:	bf69                	j	1ed2 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1f3a:	2905                	addiw	s2,s2,1
    1f3c:	0ff97913          	andi	s2,s2,255
    1f40:	2985                	addiw	s3,s3,1
    1f42:	0ff9f993          	andi	s3,s3,255
    1f46:	03490863          	beq	s2,s4,1f76 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1f4a:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1f4c:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1f50:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1f54:	f8040513          	addi	a0,s0,-128
    1f58:	00004097          	auipc	ra,0x4
    1f5c:	ba0080e7          	jalr	-1120(ra) # 5af8 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1f60:	34fd                	addiw	s1,s1,-1
    1f62:	f4ed                	bnez	s1,1f4c <createdelete+0x1e2>
    1f64:	bfd9                	j	1f3a <createdelete+0x1d0>
    1f66:	03000993          	li	s3,48
    1f6a:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1f6e:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1f70:	08400a13          	li	s4,132
    1f74:	bfd9                	j	1f4a <createdelete+0x1e0>
}
    1f76:	60aa                	ld	ra,136(sp)
    1f78:	640a                	ld	s0,128(sp)
    1f7a:	74e6                	ld	s1,120(sp)
    1f7c:	7946                	ld	s2,112(sp)
    1f7e:	79a6                	ld	s3,104(sp)
    1f80:	7a06                	ld	s4,96(sp)
    1f82:	6ae6                	ld	s5,88(sp)
    1f84:	6b46                	ld	s6,80(sp)
    1f86:	6ba6                	ld	s7,72(sp)
    1f88:	6c06                	ld	s8,64(sp)
    1f8a:	7ce2                	ld	s9,56(sp)
    1f8c:	6149                	addi	sp,sp,144
    1f8e:	8082                	ret

0000000000001f90 <linkunlink>:
{
    1f90:	711d                	addi	sp,sp,-96
    1f92:	ec86                	sd	ra,88(sp)
    1f94:	e8a2                	sd	s0,80(sp)
    1f96:	e4a6                	sd	s1,72(sp)
    1f98:	e0ca                	sd	s2,64(sp)
    1f9a:	fc4e                	sd	s3,56(sp)
    1f9c:	f852                	sd	s4,48(sp)
    1f9e:	f456                	sd	s5,40(sp)
    1fa0:	f05a                	sd	s6,32(sp)
    1fa2:	ec5e                	sd	s7,24(sp)
    1fa4:	e862                	sd	s8,16(sp)
    1fa6:	e466                	sd	s9,8(sp)
    1fa8:	1080                	addi	s0,sp,96
    1faa:	84aa                	mv	s1,a0
  unlink("x");
    1fac:	00004517          	auipc	a0,0x4
    1fb0:	0fc50513          	addi	a0,a0,252 # 60a8 <malloc+0x1b2>
    1fb4:	00004097          	auipc	ra,0x4
    1fb8:	b44080e7          	jalr	-1212(ra) # 5af8 <unlink>
  pid = fork();
    1fbc:	00004097          	auipc	ra,0x4
    1fc0:	ae4080e7          	jalr	-1308(ra) # 5aa0 <fork>
  if(pid < 0){
    1fc4:	02054b63          	bltz	a0,1ffa <linkunlink+0x6a>
    1fc8:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1fca:	4c85                	li	s9,1
    1fcc:	e119                	bnez	a0,1fd2 <linkunlink+0x42>
    1fce:	06100c93          	li	s9,97
    1fd2:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1fd6:	41c659b7          	lui	s3,0x41c65
    1fda:	e6d9899b          	addiw	s3,s3,-403
    1fde:	690d                	lui	s2,0x3
    1fe0:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1fe4:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1fe6:	4b05                	li	s6,1
      unlink("x");
    1fe8:	00004a97          	auipc	s5,0x4
    1fec:	0c0a8a93          	addi	s5,s5,192 # 60a8 <malloc+0x1b2>
      link("cat", "x");
    1ff0:	00005b97          	auipc	s7,0x5
    1ff4:	b28b8b93          	addi	s7,s7,-1240 # 6b18 <malloc+0xc22>
    1ff8:	a825                	j	2030 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1ffa:	85a6                	mv	a1,s1
    1ffc:	00005517          	auipc	a0,0x5
    2000:	8c450513          	addi	a0,a0,-1852 # 68c0 <malloc+0x9ca>
    2004:	00004097          	auipc	ra,0x4
    2008:	e34080e7          	jalr	-460(ra) # 5e38 <printf>
    exit(1);
    200c:	4505                	li	a0,1
    200e:	00004097          	auipc	ra,0x4
    2012:	a9a080e7          	jalr	-1382(ra) # 5aa8 <exit>
      close(open("x", O_RDWR | O_CREATE));
    2016:	20200593          	li	a1,514
    201a:	8556                	mv	a0,s5
    201c:	00004097          	auipc	ra,0x4
    2020:	acc080e7          	jalr	-1332(ra) # 5ae8 <open>
    2024:	00004097          	auipc	ra,0x4
    2028:	aac080e7          	jalr	-1364(ra) # 5ad0 <close>
  for(i = 0; i < 100; i++){
    202c:	34fd                	addiw	s1,s1,-1
    202e:	c88d                	beqz	s1,2060 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    2030:	033c87bb          	mulw	a5,s9,s3
    2034:	012787bb          	addw	a5,a5,s2
    2038:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    203c:	0347f7bb          	remuw	a5,a5,s4
    2040:	dbf9                	beqz	a5,2016 <linkunlink+0x86>
    } else if((x % 3) == 1){
    2042:	01678863          	beq	a5,s6,2052 <linkunlink+0xc2>
      unlink("x");
    2046:	8556                	mv	a0,s5
    2048:	00004097          	auipc	ra,0x4
    204c:	ab0080e7          	jalr	-1360(ra) # 5af8 <unlink>
    2050:	bff1                	j	202c <linkunlink+0x9c>
      link("cat", "x");
    2052:	85d6                	mv	a1,s5
    2054:	855e                	mv	a0,s7
    2056:	00004097          	auipc	ra,0x4
    205a:	ab2080e7          	jalr	-1358(ra) # 5b08 <link>
    205e:	b7f9                	j	202c <linkunlink+0x9c>
  if(pid)
    2060:	020c0463          	beqz	s8,2088 <linkunlink+0xf8>
    wait(0);
    2064:	4501                	li	a0,0
    2066:	00004097          	auipc	ra,0x4
    206a:	a4a080e7          	jalr	-1462(ra) # 5ab0 <wait>
}
    206e:	60e6                	ld	ra,88(sp)
    2070:	6446                	ld	s0,80(sp)
    2072:	64a6                	ld	s1,72(sp)
    2074:	6906                	ld	s2,64(sp)
    2076:	79e2                	ld	s3,56(sp)
    2078:	7a42                	ld	s4,48(sp)
    207a:	7aa2                	ld	s5,40(sp)
    207c:	7b02                	ld	s6,32(sp)
    207e:	6be2                	ld	s7,24(sp)
    2080:	6c42                	ld	s8,16(sp)
    2082:	6ca2                	ld	s9,8(sp)
    2084:	6125                	addi	sp,sp,96
    2086:	8082                	ret
    exit(0);
    2088:	4501                	li	a0,0
    208a:	00004097          	auipc	ra,0x4
    208e:	a1e080e7          	jalr	-1506(ra) # 5aa8 <exit>

0000000000002092 <forktest>:
{
    2092:	7179                	addi	sp,sp,-48
    2094:	f406                	sd	ra,40(sp)
    2096:	f022                	sd	s0,32(sp)
    2098:	ec26                	sd	s1,24(sp)
    209a:	e84a                	sd	s2,16(sp)
    209c:	e44e                	sd	s3,8(sp)
    209e:	1800                	addi	s0,sp,48
    20a0:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    20a2:	4481                	li	s1,0
    20a4:	3e800913          	li	s2,1000
    pid = fork();
    20a8:	00004097          	auipc	ra,0x4
    20ac:	9f8080e7          	jalr	-1544(ra) # 5aa0 <fork>
    if(pid < 0)
    20b0:	02054863          	bltz	a0,20e0 <forktest+0x4e>
    if(pid == 0)
    20b4:	c115                	beqz	a0,20d8 <forktest+0x46>
  for(n=0; n<N; n++){
    20b6:	2485                	addiw	s1,s1,1
    20b8:	ff2498e3          	bne	s1,s2,20a8 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    20bc:	85ce                	mv	a1,s3
    20be:	00005517          	auipc	a0,0x5
    20c2:	a7a50513          	addi	a0,a0,-1414 # 6b38 <malloc+0xc42>
    20c6:	00004097          	auipc	ra,0x4
    20ca:	d72080e7          	jalr	-654(ra) # 5e38 <printf>
    exit(1);
    20ce:	4505                	li	a0,1
    20d0:	00004097          	auipc	ra,0x4
    20d4:	9d8080e7          	jalr	-1576(ra) # 5aa8 <exit>
      exit(0);
    20d8:	00004097          	auipc	ra,0x4
    20dc:	9d0080e7          	jalr	-1584(ra) # 5aa8 <exit>
  if (n == 0) {
    20e0:	cc9d                	beqz	s1,211e <forktest+0x8c>
  if(n == N){
    20e2:	3e800793          	li	a5,1000
    20e6:	fcf48be3          	beq	s1,a5,20bc <forktest+0x2a>
  for(; n > 0; n--){
    20ea:	00905b63          	blez	s1,2100 <forktest+0x6e>
    if(wait(0) < 0){
    20ee:	4501                	li	a0,0
    20f0:	00004097          	auipc	ra,0x4
    20f4:	9c0080e7          	jalr	-1600(ra) # 5ab0 <wait>
    20f8:	04054163          	bltz	a0,213a <forktest+0xa8>
  for(; n > 0; n--){
    20fc:	34fd                	addiw	s1,s1,-1
    20fe:	f8e5                	bnez	s1,20ee <forktest+0x5c>
  if(wait(0) != -1){
    2100:	4501                	li	a0,0
    2102:	00004097          	auipc	ra,0x4
    2106:	9ae080e7          	jalr	-1618(ra) # 5ab0 <wait>
    210a:	57fd                	li	a5,-1
    210c:	04f51563          	bne	a0,a5,2156 <forktest+0xc4>
}
    2110:	70a2                	ld	ra,40(sp)
    2112:	7402                	ld	s0,32(sp)
    2114:	64e2                	ld	s1,24(sp)
    2116:	6942                	ld	s2,16(sp)
    2118:	69a2                	ld	s3,8(sp)
    211a:	6145                	addi	sp,sp,48
    211c:	8082                	ret
    printf("%s: no fork at all!\n", s);
    211e:	85ce                	mv	a1,s3
    2120:	00005517          	auipc	a0,0x5
    2124:	a0050513          	addi	a0,a0,-1536 # 6b20 <malloc+0xc2a>
    2128:	00004097          	auipc	ra,0x4
    212c:	d10080e7          	jalr	-752(ra) # 5e38 <printf>
    exit(1);
    2130:	4505                	li	a0,1
    2132:	00004097          	auipc	ra,0x4
    2136:	976080e7          	jalr	-1674(ra) # 5aa8 <exit>
      printf("%s: wait stopped early\n", s);
    213a:	85ce                	mv	a1,s3
    213c:	00005517          	auipc	a0,0x5
    2140:	a2450513          	addi	a0,a0,-1500 # 6b60 <malloc+0xc6a>
    2144:	00004097          	auipc	ra,0x4
    2148:	cf4080e7          	jalr	-780(ra) # 5e38 <printf>
      exit(1);
    214c:	4505                	li	a0,1
    214e:	00004097          	auipc	ra,0x4
    2152:	95a080e7          	jalr	-1702(ra) # 5aa8 <exit>
    printf("%s: wait got too many\n", s);
    2156:	85ce                	mv	a1,s3
    2158:	00005517          	auipc	a0,0x5
    215c:	a2050513          	addi	a0,a0,-1504 # 6b78 <malloc+0xc82>
    2160:	00004097          	auipc	ra,0x4
    2164:	cd8080e7          	jalr	-808(ra) # 5e38 <printf>
    exit(1);
    2168:	4505                	li	a0,1
    216a:	00004097          	auipc	ra,0x4
    216e:	93e080e7          	jalr	-1730(ra) # 5aa8 <exit>

0000000000002172 <kernmem>:
{
    2172:	715d                	addi	sp,sp,-80
    2174:	e486                	sd	ra,72(sp)
    2176:	e0a2                	sd	s0,64(sp)
    2178:	fc26                	sd	s1,56(sp)
    217a:	f84a                	sd	s2,48(sp)
    217c:	f44e                	sd	s3,40(sp)
    217e:	f052                	sd	s4,32(sp)
    2180:	ec56                	sd	s5,24(sp)
    2182:	0880                	addi	s0,sp,80
    2184:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2186:	4485                	li	s1,1
    2188:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    218a:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    218c:	69b1                	lui	s3,0xc
    218e:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1e08>
    2192:	1003d937          	lui	s2,0x1003d
    2196:	090e                	slli	s2,s2,0x3
    2198:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d828>
    pid = fork();
    219c:	00004097          	auipc	ra,0x4
    21a0:	904080e7          	jalr	-1788(ra) # 5aa0 <fork>
    if(pid < 0){
    21a4:	02054963          	bltz	a0,21d6 <kernmem+0x64>
    if(pid == 0){
    21a8:	c529                	beqz	a0,21f2 <kernmem+0x80>
    wait(&xstatus);
    21aa:	fbc40513          	addi	a0,s0,-68
    21ae:	00004097          	auipc	ra,0x4
    21b2:	902080e7          	jalr	-1790(ra) # 5ab0 <wait>
    if(xstatus != -1)  // did kernel kill child?
    21b6:	fbc42783          	lw	a5,-68(s0)
    21ba:	05579d63          	bne	a5,s5,2214 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    21be:	94ce                	add	s1,s1,s3
    21c0:	fd249ee3          	bne	s1,s2,219c <kernmem+0x2a>
}
    21c4:	60a6                	ld	ra,72(sp)
    21c6:	6406                	ld	s0,64(sp)
    21c8:	74e2                	ld	s1,56(sp)
    21ca:	7942                	ld	s2,48(sp)
    21cc:	79a2                	ld	s3,40(sp)
    21ce:	7a02                	ld	s4,32(sp)
    21d0:	6ae2                	ld	s5,24(sp)
    21d2:	6161                	addi	sp,sp,80
    21d4:	8082                	ret
      printf("%s: fork failed\n", s);
    21d6:	85d2                	mv	a1,s4
    21d8:	00004517          	auipc	a0,0x4
    21dc:	6e850513          	addi	a0,a0,1768 # 68c0 <malloc+0x9ca>
    21e0:	00004097          	auipc	ra,0x4
    21e4:	c58080e7          	jalr	-936(ra) # 5e38 <printf>
      exit(1);
    21e8:	4505                	li	a0,1
    21ea:	00004097          	auipc	ra,0x4
    21ee:	8be080e7          	jalr	-1858(ra) # 5aa8 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    21f2:	0004c683          	lbu	a3,0(s1)
    21f6:	8626                	mv	a2,s1
    21f8:	85d2                	mv	a1,s4
    21fa:	00005517          	auipc	a0,0x5
    21fe:	99650513          	addi	a0,a0,-1642 # 6b90 <malloc+0xc9a>
    2202:	00004097          	auipc	ra,0x4
    2206:	c36080e7          	jalr	-970(ra) # 5e38 <printf>
      exit(1);
    220a:	4505                	li	a0,1
    220c:	00004097          	auipc	ra,0x4
    2210:	89c080e7          	jalr	-1892(ra) # 5aa8 <exit>
      exit(1);
    2214:	4505                	li	a0,1
    2216:	00004097          	auipc	ra,0x4
    221a:	892080e7          	jalr	-1902(ra) # 5aa8 <exit>

000000000000221e <MAXVAplus>:
{
    221e:	7179                	addi	sp,sp,-48
    2220:	f406                	sd	ra,40(sp)
    2222:	f022                	sd	s0,32(sp)
    2224:	ec26                	sd	s1,24(sp)
    2226:	e84a                	sd	s2,16(sp)
    2228:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    222a:	4785                	li	a5,1
    222c:	179a                	slli	a5,a5,0x26
    222e:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    2232:	fd843783          	ld	a5,-40(s0)
    2236:	cf85                	beqz	a5,226e <MAXVAplus+0x50>
    2238:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    223a:	54fd                	li	s1,-1
    pid = fork();
    223c:	00004097          	auipc	ra,0x4
    2240:	864080e7          	jalr	-1948(ra) # 5aa0 <fork>
    if(pid < 0){
    2244:	02054b63          	bltz	a0,227a <MAXVAplus+0x5c>
    if(pid == 0){
    2248:	c539                	beqz	a0,2296 <MAXVAplus+0x78>
    wait(&xstatus);
    224a:	fd440513          	addi	a0,s0,-44
    224e:	00004097          	auipc	ra,0x4
    2252:	862080e7          	jalr	-1950(ra) # 5ab0 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2256:	fd442783          	lw	a5,-44(s0)
    225a:	06979463          	bne	a5,s1,22c2 <MAXVAplus+0xa4>
  for( ; a != 0; a <<= 1){
    225e:	fd843783          	ld	a5,-40(s0)
    2262:	0786                	slli	a5,a5,0x1
    2264:	fcf43c23          	sd	a5,-40(s0)
    2268:	fd843783          	ld	a5,-40(s0)
    226c:	fbe1                	bnez	a5,223c <MAXVAplus+0x1e>
}
    226e:	70a2                	ld	ra,40(sp)
    2270:	7402                	ld	s0,32(sp)
    2272:	64e2                	ld	s1,24(sp)
    2274:	6942                	ld	s2,16(sp)
    2276:	6145                	addi	sp,sp,48
    2278:	8082                	ret
      printf("%s: fork failed\n", s);
    227a:	85ca                	mv	a1,s2
    227c:	00004517          	auipc	a0,0x4
    2280:	64450513          	addi	a0,a0,1604 # 68c0 <malloc+0x9ca>
    2284:	00004097          	auipc	ra,0x4
    2288:	bb4080e7          	jalr	-1100(ra) # 5e38 <printf>
      exit(1);
    228c:	4505                	li	a0,1
    228e:	00004097          	auipc	ra,0x4
    2292:	81a080e7          	jalr	-2022(ra) # 5aa8 <exit>
      *(char*)a = 99;
    2296:	fd843783          	ld	a5,-40(s0)
    229a:	06300713          	li	a4,99
    229e:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    22a2:	fd843603          	ld	a2,-40(s0)
    22a6:	85ca                	mv	a1,s2
    22a8:	00005517          	auipc	a0,0x5
    22ac:	90850513          	addi	a0,a0,-1784 # 6bb0 <malloc+0xcba>
    22b0:	00004097          	auipc	ra,0x4
    22b4:	b88080e7          	jalr	-1144(ra) # 5e38 <printf>
      exit(1);
    22b8:	4505                	li	a0,1
    22ba:	00003097          	auipc	ra,0x3
    22be:	7ee080e7          	jalr	2030(ra) # 5aa8 <exit>
      exit(1);
    22c2:	4505                	li	a0,1
    22c4:	00003097          	auipc	ra,0x3
    22c8:	7e4080e7          	jalr	2020(ra) # 5aa8 <exit>

00000000000022cc <bigargtest>:
{
    22cc:	7179                	addi	sp,sp,-48
    22ce:	f406                	sd	ra,40(sp)
    22d0:	f022                	sd	s0,32(sp)
    22d2:	ec26                	sd	s1,24(sp)
    22d4:	1800                	addi	s0,sp,48
    22d6:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    22d8:	00005517          	auipc	a0,0x5
    22dc:	8f050513          	addi	a0,a0,-1808 # 6bc8 <malloc+0xcd2>
    22e0:	00004097          	auipc	ra,0x4
    22e4:	818080e7          	jalr	-2024(ra) # 5af8 <unlink>
  pid = fork();
    22e8:	00003097          	auipc	ra,0x3
    22ec:	7b8080e7          	jalr	1976(ra) # 5aa0 <fork>
  if(pid == 0){
    22f0:	c121                	beqz	a0,2330 <bigargtest+0x64>
  } else if(pid < 0){
    22f2:	0a054063          	bltz	a0,2392 <bigargtest+0xc6>
  wait(&xstatus);
    22f6:	fdc40513          	addi	a0,s0,-36
    22fa:	00003097          	auipc	ra,0x3
    22fe:	7b6080e7          	jalr	1974(ra) # 5ab0 <wait>
  if(xstatus != 0)
    2302:	fdc42503          	lw	a0,-36(s0)
    2306:	e545                	bnez	a0,23ae <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    2308:	4581                	li	a1,0
    230a:	00005517          	auipc	a0,0x5
    230e:	8be50513          	addi	a0,a0,-1858 # 6bc8 <malloc+0xcd2>
    2312:	00003097          	auipc	ra,0x3
    2316:	7d6080e7          	jalr	2006(ra) # 5ae8 <open>
  if(fd < 0){
    231a:	08054e63          	bltz	a0,23b6 <bigargtest+0xea>
  close(fd);
    231e:	00003097          	auipc	ra,0x3
    2322:	7b2080e7          	jalr	1970(ra) # 5ad0 <close>
}
    2326:	70a2                	ld	ra,40(sp)
    2328:	7402                	ld	s0,32(sp)
    232a:	64e2                	ld	s1,24(sp)
    232c:	6145                	addi	sp,sp,48
    232e:	8082                	ret
    2330:	00007797          	auipc	a5,0x7
    2334:	11078793          	addi	a5,a5,272 # 9440 <args.1>
    2338:	00007697          	auipc	a3,0x7
    233c:	20068693          	addi	a3,a3,512 # 9538 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    2340:	00005717          	auipc	a4,0x5
    2344:	89870713          	addi	a4,a4,-1896 # 6bd8 <malloc+0xce2>
    2348:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    234a:	07a1                	addi	a5,a5,8
    234c:	fed79ee3          	bne	a5,a3,2348 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    2350:	00007597          	auipc	a1,0x7
    2354:	0f058593          	addi	a1,a1,240 # 9440 <args.1>
    2358:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    235c:	00004517          	auipc	a0,0x4
    2360:	cdc50513          	addi	a0,a0,-804 # 6038 <malloc+0x142>
    2364:	00003097          	auipc	ra,0x3
    2368:	77c080e7          	jalr	1916(ra) # 5ae0 <exec>
    fd = open("bigarg-ok", O_CREATE);
    236c:	20000593          	li	a1,512
    2370:	00005517          	auipc	a0,0x5
    2374:	85850513          	addi	a0,a0,-1960 # 6bc8 <malloc+0xcd2>
    2378:	00003097          	auipc	ra,0x3
    237c:	770080e7          	jalr	1904(ra) # 5ae8 <open>
    close(fd);
    2380:	00003097          	auipc	ra,0x3
    2384:	750080e7          	jalr	1872(ra) # 5ad0 <close>
    exit(0);
    2388:	4501                	li	a0,0
    238a:	00003097          	auipc	ra,0x3
    238e:	71e080e7          	jalr	1822(ra) # 5aa8 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2392:	85a6                	mv	a1,s1
    2394:	00005517          	auipc	a0,0x5
    2398:	92450513          	addi	a0,a0,-1756 # 6cb8 <malloc+0xdc2>
    239c:	00004097          	auipc	ra,0x4
    23a0:	a9c080e7          	jalr	-1380(ra) # 5e38 <printf>
    exit(1);
    23a4:	4505                	li	a0,1
    23a6:	00003097          	auipc	ra,0x3
    23aa:	702080e7          	jalr	1794(ra) # 5aa8 <exit>
    exit(xstatus);
    23ae:	00003097          	auipc	ra,0x3
    23b2:	6fa080e7          	jalr	1786(ra) # 5aa8 <exit>
    printf("%s: bigarg test failed!\n", s);
    23b6:	85a6                	mv	a1,s1
    23b8:	00005517          	auipc	a0,0x5
    23bc:	92050513          	addi	a0,a0,-1760 # 6cd8 <malloc+0xde2>
    23c0:	00004097          	auipc	ra,0x4
    23c4:	a78080e7          	jalr	-1416(ra) # 5e38 <printf>
    exit(1);
    23c8:	4505                	li	a0,1
    23ca:	00003097          	auipc	ra,0x3
    23ce:	6de080e7          	jalr	1758(ra) # 5aa8 <exit>

00000000000023d2 <stacktest>:
{
    23d2:	7179                	addi	sp,sp,-48
    23d4:	f406                	sd	ra,40(sp)
    23d6:	f022                	sd	s0,32(sp)
    23d8:	ec26                	sd	s1,24(sp)
    23da:	1800                	addi	s0,sp,48
    23dc:	84aa                	mv	s1,a0
  pid = fork();
    23de:	00003097          	auipc	ra,0x3
    23e2:	6c2080e7          	jalr	1730(ra) # 5aa0 <fork>
  if(pid == 0) {
    23e6:	c115                	beqz	a0,240a <stacktest+0x38>
  } else if(pid < 0){
    23e8:	04054463          	bltz	a0,2430 <stacktest+0x5e>
  wait(&xstatus);
    23ec:	fdc40513          	addi	a0,s0,-36
    23f0:	00003097          	auipc	ra,0x3
    23f4:	6c0080e7          	jalr	1728(ra) # 5ab0 <wait>
  if(xstatus == -1)  // kernel killed child?
    23f8:	fdc42503          	lw	a0,-36(s0)
    23fc:	57fd                	li	a5,-1
    23fe:	04f50763          	beq	a0,a5,244c <stacktest+0x7a>
    exit(xstatus);
    2402:	00003097          	auipc	ra,0x3
    2406:	6a6080e7          	jalr	1702(ra) # 5aa8 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    240a:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    240c:	77fd                	lui	a5,0xfffff
    240e:	97ba                	add	a5,a5,a4
    2410:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef3a8>
    2414:	85a6                	mv	a1,s1
    2416:	00005517          	auipc	a0,0x5
    241a:	8e250513          	addi	a0,a0,-1822 # 6cf8 <malloc+0xe02>
    241e:	00004097          	auipc	ra,0x4
    2422:	a1a080e7          	jalr	-1510(ra) # 5e38 <printf>
    exit(1);
    2426:	4505                	li	a0,1
    2428:	00003097          	auipc	ra,0x3
    242c:	680080e7          	jalr	1664(ra) # 5aa8 <exit>
    printf("%s: fork failed\n", s);
    2430:	85a6                	mv	a1,s1
    2432:	00004517          	auipc	a0,0x4
    2436:	48e50513          	addi	a0,a0,1166 # 68c0 <malloc+0x9ca>
    243a:	00004097          	auipc	ra,0x4
    243e:	9fe080e7          	jalr	-1538(ra) # 5e38 <printf>
    exit(1);
    2442:	4505                	li	a0,1
    2444:	00003097          	auipc	ra,0x3
    2448:	664080e7          	jalr	1636(ra) # 5aa8 <exit>
    exit(0);
    244c:	4501                	li	a0,0
    244e:	00003097          	auipc	ra,0x3
    2452:	65a080e7          	jalr	1626(ra) # 5aa8 <exit>

0000000000002456 <manywrites>:
{
    2456:	711d                	addi	sp,sp,-96
    2458:	ec86                	sd	ra,88(sp)
    245a:	e8a2                	sd	s0,80(sp)
    245c:	e4a6                	sd	s1,72(sp)
    245e:	e0ca                	sd	s2,64(sp)
    2460:	fc4e                	sd	s3,56(sp)
    2462:	f852                	sd	s4,48(sp)
    2464:	f456                	sd	s5,40(sp)
    2466:	f05a                	sd	s6,32(sp)
    2468:	ec5e                	sd	s7,24(sp)
    246a:	1080                	addi	s0,sp,96
    246c:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    246e:	4981                	li	s3,0
    2470:	4911                	li	s2,4
    int pid = fork();
    2472:	00003097          	auipc	ra,0x3
    2476:	62e080e7          	jalr	1582(ra) # 5aa0 <fork>
    247a:	84aa                	mv	s1,a0
    if(pid < 0){
    247c:	02054963          	bltz	a0,24ae <manywrites+0x58>
    if(pid == 0){
    2480:	c521                	beqz	a0,24c8 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    2482:	2985                	addiw	s3,s3,1
    2484:	ff2997e3          	bne	s3,s2,2472 <manywrites+0x1c>
    2488:	4491                	li	s1,4
    int st = 0;
    248a:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    248e:	fa840513          	addi	a0,s0,-88
    2492:	00003097          	auipc	ra,0x3
    2496:	61e080e7          	jalr	1566(ra) # 5ab0 <wait>
    if(st != 0)
    249a:	fa842503          	lw	a0,-88(s0)
    249e:	ed6d                	bnez	a0,2598 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    24a0:	34fd                	addiw	s1,s1,-1
    24a2:	f4e5                	bnez	s1,248a <manywrites+0x34>
  exit(0);
    24a4:	4501                	li	a0,0
    24a6:	00003097          	auipc	ra,0x3
    24aa:	602080e7          	jalr	1538(ra) # 5aa8 <exit>
      printf("fork failed\n");
    24ae:	00005517          	auipc	a0,0x5
    24b2:	81a50513          	addi	a0,a0,-2022 # 6cc8 <malloc+0xdd2>
    24b6:	00004097          	auipc	ra,0x4
    24ba:	982080e7          	jalr	-1662(ra) # 5e38 <printf>
      exit(1);
    24be:	4505                	li	a0,1
    24c0:	00003097          	auipc	ra,0x3
    24c4:	5e8080e7          	jalr	1512(ra) # 5aa8 <exit>
      name[0] = 'b';
    24c8:	06200793          	li	a5,98
    24cc:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    24d0:	0619879b          	addiw	a5,s3,97
    24d4:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    24d8:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    24dc:	fa840513          	addi	a0,s0,-88
    24e0:	00003097          	auipc	ra,0x3
    24e4:	618080e7          	jalr	1560(ra) # 5af8 <unlink>
    24e8:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    24ea:	0000ab17          	auipc	s6,0xa
    24ee:	76eb0b13          	addi	s6,s6,1902 # cc58 <buf>
        for(int i = 0; i < ci+1; i++){
    24f2:	8a26                	mv	s4,s1
    24f4:	0209ce63          	bltz	s3,2530 <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    24f8:	20200593          	li	a1,514
    24fc:	fa840513          	addi	a0,s0,-88
    2500:	00003097          	auipc	ra,0x3
    2504:	5e8080e7          	jalr	1512(ra) # 5ae8 <open>
    2508:	892a                	mv	s2,a0
          if(fd < 0){
    250a:	04054763          	bltz	a0,2558 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    250e:	660d                	lui	a2,0x3
    2510:	85da                	mv	a1,s6
    2512:	00003097          	auipc	ra,0x3
    2516:	5b6080e7          	jalr	1462(ra) # 5ac8 <write>
          if(cc != sz){
    251a:	678d                	lui	a5,0x3
    251c:	04f51e63          	bne	a0,a5,2578 <manywrites+0x122>
          close(fd);
    2520:	854a                	mv	a0,s2
    2522:	00003097          	auipc	ra,0x3
    2526:	5ae080e7          	jalr	1454(ra) # 5ad0 <close>
        for(int i = 0; i < ci+1; i++){
    252a:	2a05                	addiw	s4,s4,1
    252c:	fd49d6e3          	bge	s3,s4,24f8 <manywrites+0xa2>
        unlink(name);
    2530:	fa840513          	addi	a0,s0,-88
    2534:	00003097          	auipc	ra,0x3
    2538:	5c4080e7          	jalr	1476(ra) # 5af8 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    253c:	3bfd                	addiw	s7,s7,-1
    253e:	fa0b9ae3          	bnez	s7,24f2 <manywrites+0x9c>
      unlink(name);
    2542:	fa840513          	addi	a0,s0,-88
    2546:	00003097          	auipc	ra,0x3
    254a:	5b2080e7          	jalr	1458(ra) # 5af8 <unlink>
      exit(0);
    254e:	4501                	li	a0,0
    2550:	00003097          	auipc	ra,0x3
    2554:	558080e7          	jalr	1368(ra) # 5aa8 <exit>
            printf("%s: cannot create %s\n", s, name);
    2558:	fa840613          	addi	a2,s0,-88
    255c:	85d6                	mv	a1,s5
    255e:	00004517          	auipc	a0,0x4
    2562:	7c250513          	addi	a0,a0,1986 # 6d20 <malloc+0xe2a>
    2566:	00004097          	auipc	ra,0x4
    256a:	8d2080e7          	jalr	-1838(ra) # 5e38 <printf>
            exit(1);
    256e:	4505                	li	a0,1
    2570:	00003097          	auipc	ra,0x3
    2574:	538080e7          	jalr	1336(ra) # 5aa8 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    2578:	86aa                	mv	a3,a0
    257a:	660d                	lui	a2,0x3
    257c:	85d6                	mv	a1,s5
    257e:	00004517          	auipc	a0,0x4
    2582:	b8a50513          	addi	a0,a0,-1142 # 6108 <malloc+0x212>
    2586:	00004097          	auipc	ra,0x4
    258a:	8b2080e7          	jalr	-1870(ra) # 5e38 <printf>
            exit(1);
    258e:	4505                	li	a0,1
    2590:	00003097          	auipc	ra,0x3
    2594:	518080e7          	jalr	1304(ra) # 5aa8 <exit>
      exit(st);
    2598:	00003097          	auipc	ra,0x3
    259c:	510080e7          	jalr	1296(ra) # 5aa8 <exit>

00000000000025a0 <copyinstr3>:
{
    25a0:	7179                	addi	sp,sp,-48
    25a2:	f406                	sd	ra,40(sp)
    25a4:	f022                	sd	s0,32(sp)
    25a6:	ec26                	sd	s1,24(sp)
    25a8:	1800                	addi	s0,sp,48
  sbrk(8192);
    25aa:	6509                	lui	a0,0x2
    25ac:	00003097          	auipc	ra,0x3
    25b0:	584080e7          	jalr	1412(ra) # 5b30 <sbrk>
  uint64 top = (uint64) sbrk(0);
    25b4:	4501                	li	a0,0
    25b6:	00003097          	auipc	ra,0x3
    25ba:	57a080e7          	jalr	1402(ra) # 5b30 <sbrk>
  if((top % PGSIZE) != 0){
    25be:	03451793          	slli	a5,a0,0x34
    25c2:	e3c9                	bnez	a5,2644 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    25c4:	4501                	li	a0,0
    25c6:	00003097          	auipc	ra,0x3
    25ca:	56a080e7          	jalr	1386(ra) # 5b30 <sbrk>
  if(top % PGSIZE){
    25ce:	03451793          	slli	a5,a0,0x34
    25d2:	e3d9                	bnez	a5,2658 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    25d4:	fff50493          	addi	s1,a0,-1 # 1fff <linkunlink+0x6f>
  *b = 'x';
    25d8:	07800793          	li	a5,120
    25dc:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    25e0:	8526                	mv	a0,s1
    25e2:	00003097          	auipc	ra,0x3
    25e6:	516080e7          	jalr	1302(ra) # 5af8 <unlink>
  if(ret != -1){
    25ea:	57fd                	li	a5,-1
    25ec:	08f51363          	bne	a0,a5,2672 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    25f0:	20100593          	li	a1,513
    25f4:	8526                	mv	a0,s1
    25f6:	00003097          	auipc	ra,0x3
    25fa:	4f2080e7          	jalr	1266(ra) # 5ae8 <open>
  if(fd != -1){
    25fe:	57fd                	li	a5,-1
    2600:	08f51863          	bne	a0,a5,2690 <copyinstr3+0xf0>
  ret = link(b, b);
    2604:	85a6                	mv	a1,s1
    2606:	8526                	mv	a0,s1
    2608:	00003097          	auipc	ra,0x3
    260c:	500080e7          	jalr	1280(ra) # 5b08 <link>
  if(ret != -1){
    2610:	57fd                	li	a5,-1
    2612:	08f51e63          	bne	a0,a5,26ae <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2616:	00005797          	auipc	a5,0x5
    261a:	40278793          	addi	a5,a5,1026 # 7a18 <malloc+0x1b22>
    261e:	fcf43823          	sd	a5,-48(s0)
    2622:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2626:	fd040593          	addi	a1,s0,-48
    262a:	8526                	mv	a0,s1
    262c:	00003097          	auipc	ra,0x3
    2630:	4b4080e7          	jalr	1204(ra) # 5ae0 <exec>
  if(ret != -1){
    2634:	57fd                	li	a5,-1
    2636:	08f51c63          	bne	a0,a5,26ce <copyinstr3+0x12e>
}
    263a:	70a2                	ld	ra,40(sp)
    263c:	7402                	ld	s0,32(sp)
    263e:	64e2                	ld	s1,24(sp)
    2640:	6145                	addi	sp,sp,48
    2642:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2644:	0347d513          	srli	a0,a5,0x34
    2648:	6785                	lui	a5,0x1
    264a:	40a7853b          	subw	a0,a5,a0
    264e:	00003097          	auipc	ra,0x3
    2652:	4e2080e7          	jalr	1250(ra) # 5b30 <sbrk>
    2656:	b7bd                	j	25c4 <copyinstr3+0x24>
    printf("oops\n");
    2658:	00004517          	auipc	a0,0x4
    265c:	6e050513          	addi	a0,a0,1760 # 6d38 <malloc+0xe42>
    2660:	00003097          	auipc	ra,0x3
    2664:	7d8080e7          	jalr	2008(ra) # 5e38 <printf>
    exit(1);
    2668:	4505                	li	a0,1
    266a:	00003097          	auipc	ra,0x3
    266e:	43e080e7          	jalr	1086(ra) # 5aa8 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    2672:	862a                	mv	a2,a0
    2674:	85a6                	mv	a1,s1
    2676:	00004517          	auipc	a0,0x4
    267a:	16a50513          	addi	a0,a0,362 # 67e0 <malloc+0x8ea>
    267e:	00003097          	auipc	ra,0x3
    2682:	7ba080e7          	jalr	1978(ra) # 5e38 <printf>
    exit(1);
    2686:	4505                	li	a0,1
    2688:	00003097          	auipc	ra,0x3
    268c:	420080e7          	jalr	1056(ra) # 5aa8 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2690:	862a                	mv	a2,a0
    2692:	85a6                	mv	a1,s1
    2694:	00004517          	auipc	a0,0x4
    2698:	16c50513          	addi	a0,a0,364 # 6800 <malloc+0x90a>
    269c:	00003097          	auipc	ra,0x3
    26a0:	79c080e7          	jalr	1948(ra) # 5e38 <printf>
    exit(1);
    26a4:	4505                	li	a0,1
    26a6:	00003097          	auipc	ra,0x3
    26aa:	402080e7          	jalr	1026(ra) # 5aa8 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    26ae:	86aa                	mv	a3,a0
    26b0:	8626                	mv	a2,s1
    26b2:	85a6                	mv	a1,s1
    26b4:	00004517          	auipc	a0,0x4
    26b8:	16c50513          	addi	a0,a0,364 # 6820 <malloc+0x92a>
    26bc:	00003097          	auipc	ra,0x3
    26c0:	77c080e7          	jalr	1916(ra) # 5e38 <printf>
    exit(1);
    26c4:	4505                	li	a0,1
    26c6:	00003097          	auipc	ra,0x3
    26ca:	3e2080e7          	jalr	994(ra) # 5aa8 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    26ce:	567d                	li	a2,-1
    26d0:	85a6                	mv	a1,s1
    26d2:	00004517          	auipc	a0,0x4
    26d6:	17650513          	addi	a0,a0,374 # 6848 <malloc+0x952>
    26da:	00003097          	auipc	ra,0x3
    26de:	75e080e7          	jalr	1886(ra) # 5e38 <printf>
    exit(1);
    26e2:	4505                	li	a0,1
    26e4:	00003097          	auipc	ra,0x3
    26e8:	3c4080e7          	jalr	964(ra) # 5aa8 <exit>

00000000000026ec <rwsbrk>:
{
    26ec:	1101                	addi	sp,sp,-32
    26ee:	ec06                	sd	ra,24(sp)
    26f0:	e822                	sd	s0,16(sp)
    26f2:	e426                	sd	s1,8(sp)
    26f4:	e04a                	sd	s2,0(sp)
    26f6:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    26f8:	6509                	lui	a0,0x2
    26fa:	00003097          	auipc	ra,0x3
    26fe:	436080e7          	jalr	1078(ra) # 5b30 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2702:	57fd                	li	a5,-1
    2704:	06f50363          	beq	a0,a5,276a <rwsbrk+0x7e>
    2708:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    270a:	7579                	lui	a0,0xffffe
    270c:	00003097          	auipc	ra,0x3
    2710:	424080e7          	jalr	1060(ra) # 5b30 <sbrk>
    2714:	57fd                	li	a5,-1
    2716:	06f50763          	beq	a0,a5,2784 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    271a:	20100593          	li	a1,513
    271e:	00004517          	auipc	a0,0x4
    2722:	65a50513          	addi	a0,a0,1626 # 6d78 <malloc+0xe82>
    2726:	00003097          	auipc	ra,0x3
    272a:	3c2080e7          	jalr	962(ra) # 5ae8 <open>
    272e:	892a                	mv	s2,a0
  if(fd < 0){
    2730:	06054763          	bltz	a0,279e <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    2734:	6505                	lui	a0,0x1
    2736:	94aa                	add	s1,s1,a0
    2738:	40000613          	li	a2,1024
    273c:	85a6                	mv	a1,s1
    273e:	854a                	mv	a0,s2
    2740:	00003097          	auipc	ra,0x3
    2744:	388080e7          	jalr	904(ra) # 5ac8 <write>
    2748:	862a                	mv	a2,a0
  if(n >= 0){
    274a:	06054763          	bltz	a0,27b8 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    274e:	85a6                	mv	a1,s1
    2750:	00004517          	auipc	a0,0x4
    2754:	64850513          	addi	a0,a0,1608 # 6d98 <malloc+0xea2>
    2758:	00003097          	auipc	ra,0x3
    275c:	6e0080e7          	jalr	1760(ra) # 5e38 <printf>
    exit(1);
    2760:	4505                	li	a0,1
    2762:	00003097          	auipc	ra,0x3
    2766:	346080e7          	jalr	838(ra) # 5aa8 <exit>
    printf("sbrk(rwsbrk) failed\n");
    276a:	00004517          	auipc	a0,0x4
    276e:	5d650513          	addi	a0,a0,1494 # 6d40 <malloc+0xe4a>
    2772:	00003097          	auipc	ra,0x3
    2776:	6c6080e7          	jalr	1734(ra) # 5e38 <printf>
    exit(1);
    277a:	4505                	li	a0,1
    277c:	00003097          	auipc	ra,0x3
    2780:	32c080e7          	jalr	812(ra) # 5aa8 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    2784:	00004517          	auipc	a0,0x4
    2788:	5d450513          	addi	a0,a0,1492 # 6d58 <malloc+0xe62>
    278c:	00003097          	auipc	ra,0x3
    2790:	6ac080e7          	jalr	1708(ra) # 5e38 <printf>
    exit(1);
    2794:	4505                	li	a0,1
    2796:	00003097          	auipc	ra,0x3
    279a:	312080e7          	jalr	786(ra) # 5aa8 <exit>
    printf("open(rwsbrk) failed\n");
    279e:	00004517          	auipc	a0,0x4
    27a2:	5e250513          	addi	a0,a0,1506 # 6d80 <malloc+0xe8a>
    27a6:	00003097          	auipc	ra,0x3
    27aa:	692080e7          	jalr	1682(ra) # 5e38 <printf>
    exit(1);
    27ae:	4505                	li	a0,1
    27b0:	00003097          	auipc	ra,0x3
    27b4:	2f8080e7          	jalr	760(ra) # 5aa8 <exit>
  close(fd);
    27b8:	854a                	mv	a0,s2
    27ba:	00003097          	auipc	ra,0x3
    27be:	316080e7          	jalr	790(ra) # 5ad0 <close>
  unlink("rwsbrk");
    27c2:	00004517          	auipc	a0,0x4
    27c6:	5b650513          	addi	a0,a0,1462 # 6d78 <malloc+0xe82>
    27ca:	00003097          	auipc	ra,0x3
    27ce:	32e080e7          	jalr	814(ra) # 5af8 <unlink>
  fd = open("README", O_RDONLY);
    27d2:	4581                	li	a1,0
    27d4:	00004517          	auipc	a0,0x4
    27d8:	a3c50513          	addi	a0,a0,-1476 # 6210 <malloc+0x31a>
    27dc:	00003097          	auipc	ra,0x3
    27e0:	30c080e7          	jalr	780(ra) # 5ae8 <open>
    27e4:	892a                	mv	s2,a0
  if(fd < 0){
    27e6:	02054963          	bltz	a0,2818 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    27ea:	4629                	li	a2,10
    27ec:	85a6                	mv	a1,s1
    27ee:	00003097          	auipc	ra,0x3
    27f2:	2d2080e7          	jalr	722(ra) # 5ac0 <read>
    27f6:	862a                	mv	a2,a0
  if(n >= 0){
    27f8:	02054d63          	bltz	a0,2832 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    27fc:	85a6                	mv	a1,s1
    27fe:	00004517          	auipc	a0,0x4
    2802:	5ca50513          	addi	a0,a0,1482 # 6dc8 <malloc+0xed2>
    2806:	00003097          	auipc	ra,0x3
    280a:	632080e7          	jalr	1586(ra) # 5e38 <printf>
    exit(1);
    280e:	4505                	li	a0,1
    2810:	00003097          	auipc	ra,0x3
    2814:	298080e7          	jalr	664(ra) # 5aa8 <exit>
    printf("open(rwsbrk) failed\n");
    2818:	00004517          	auipc	a0,0x4
    281c:	56850513          	addi	a0,a0,1384 # 6d80 <malloc+0xe8a>
    2820:	00003097          	auipc	ra,0x3
    2824:	618080e7          	jalr	1560(ra) # 5e38 <printf>
    exit(1);
    2828:	4505                	li	a0,1
    282a:	00003097          	auipc	ra,0x3
    282e:	27e080e7          	jalr	638(ra) # 5aa8 <exit>
  close(fd);
    2832:	854a                	mv	a0,s2
    2834:	00003097          	auipc	ra,0x3
    2838:	29c080e7          	jalr	668(ra) # 5ad0 <close>
  exit(0);
    283c:	4501                	li	a0,0
    283e:	00003097          	auipc	ra,0x3
    2842:	26a080e7          	jalr	618(ra) # 5aa8 <exit>

0000000000002846 <sbrkbasic>:
{
    2846:	7139                	addi	sp,sp,-64
    2848:	fc06                	sd	ra,56(sp)
    284a:	f822                	sd	s0,48(sp)
    284c:	f426                	sd	s1,40(sp)
    284e:	f04a                	sd	s2,32(sp)
    2850:	ec4e                	sd	s3,24(sp)
    2852:	e852                	sd	s4,16(sp)
    2854:	0080                	addi	s0,sp,64
    2856:	8a2a                	mv	s4,a0
  pid = fork();
    2858:	00003097          	auipc	ra,0x3
    285c:	248080e7          	jalr	584(ra) # 5aa0 <fork>
  if(pid < 0){
    2860:	02054c63          	bltz	a0,2898 <sbrkbasic+0x52>
  if(pid == 0){
    2864:	ed21                	bnez	a0,28bc <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    2866:	40000537          	lui	a0,0x40000
    286a:	00003097          	auipc	ra,0x3
    286e:	2c6080e7          	jalr	710(ra) # 5b30 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    2872:	57fd                	li	a5,-1
    2874:	02f50f63          	beq	a0,a5,28b2 <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2878:	400007b7          	lui	a5,0x40000
    287c:	97aa                	add	a5,a5,a0
      *b = 99;
    287e:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    2882:	6705                	lui	a4,0x1
      *b = 99;
    2884:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff03a8>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2888:	953a                	add	a0,a0,a4
    288a:	fef51de3          	bne	a0,a5,2884 <sbrkbasic+0x3e>
    exit(1);
    288e:	4505                	li	a0,1
    2890:	00003097          	auipc	ra,0x3
    2894:	218080e7          	jalr	536(ra) # 5aa8 <exit>
    printf("fork failed in sbrkbasic\n");
    2898:	00004517          	auipc	a0,0x4
    289c:	55850513          	addi	a0,a0,1368 # 6df0 <malloc+0xefa>
    28a0:	00003097          	auipc	ra,0x3
    28a4:	598080e7          	jalr	1432(ra) # 5e38 <printf>
    exit(1);
    28a8:	4505                	li	a0,1
    28aa:	00003097          	auipc	ra,0x3
    28ae:	1fe080e7          	jalr	510(ra) # 5aa8 <exit>
      exit(0);
    28b2:	4501                	li	a0,0
    28b4:	00003097          	auipc	ra,0x3
    28b8:	1f4080e7          	jalr	500(ra) # 5aa8 <exit>
  wait(&xstatus);
    28bc:	fcc40513          	addi	a0,s0,-52
    28c0:	00003097          	auipc	ra,0x3
    28c4:	1f0080e7          	jalr	496(ra) # 5ab0 <wait>
  if(xstatus == 1){
    28c8:	fcc42703          	lw	a4,-52(s0)
    28cc:	4785                	li	a5,1
    28ce:	00f70d63          	beq	a4,a5,28e8 <sbrkbasic+0xa2>
  a = sbrk(0);
    28d2:	4501                	li	a0,0
    28d4:	00003097          	auipc	ra,0x3
    28d8:	25c080e7          	jalr	604(ra) # 5b30 <sbrk>
    28dc:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    28de:	4901                	li	s2,0
    28e0:	6985                	lui	s3,0x1
    28e2:	38898993          	addi	s3,s3,904 # 1388 <badarg+0x3c>
    28e6:	a005                	j	2906 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    28e8:	85d2                	mv	a1,s4
    28ea:	00004517          	auipc	a0,0x4
    28ee:	52650513          	addi	a0,a0,1318 # 6e10 <malloc+0xf1a>
    28f2:	00003097          	auipc	ra,0x3
    28f6:	546080e7          	jalr	1350(ra) # 5e38 <printf>
    exit(1);
    28fa:	4505                	li	a0,1
    28fc:	00003097          	auipc	ra,0x3
    2900:	1ac080e7          	jalr	428(ra) # 5aa8 <exit>
    a = b + 1;
    2904:	84be                	mv	s1,a5
    b = sbrk(1);
    2906:	4505                	li	a0,1
    2908:	00003097          	auipc	ra,0x3
    290c:	228080e7          	jalr	552(ra) # 5b30 <sbrk>
    if(b != a){
    2910:	04951c63          	bne	a0,s1,2968 <sbrkbasic+0x122>
    *b = 1;
    2914:	4785                	li	a5,1
    2916:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    291a:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    291e:	2905                	addiw	s2,s2,1
    2920:	ff3912e3          	bne	s2,s3,2904 <sbrkbasic+0xbe>
  pid = fork();
    2924:	00003097          	auipc	ra,0x3
    2928:	17c080e7          	jalr	380(ra) # 5aa0 <fork>
    292c:	892a                	mv	s2,a0
  if(pid < 0){
    292e:	04054e63          	bltz	a0,298a <sbrkbasic+0x144>
  c = sbrk(1);
    2932:	4505                	li	a0,1
    2934:	00003097          	auipc	ra,0x3
    2938:	1fc080e7          	jalr	508(ra) # 5b30 <sbrk>
  c = sbrk(1);
    293c:	4505                	li	a0,1
    293e:	00003097          	auipc	ra,0x3
    2942:	1f2080e7          	jalr	498(ra) # 5b30 <sbrk>
  if(c != a + 1){
    2946:	0489                	addi	s1,s1,2
    2948:	04a48f63          	beq	s1,a0,29a6 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    294c:	85d2                	mv	a1,s4
    294e:	00004517          	auipc	a0,0x4
    2952:	52250513          	addi	a0,a0,1314 # 6e70 <malloc+0xf7a>
    2956:	00003097          	auipc	ra,0x3
    295a:	4e2080e7          	jalr	1250(ra) # 5e38 <printf>
    exit(1);
    295e:	4505                	li	a0,1
    2960:	00003097          	auipc	ra,0x3
    2964:	148080e7          	jalr	328(ra) # 5aa8 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    2968:	872a                	mv	a4,a0
    296a:	86a6                	mv	a3,s1
    296c:	864a                	mv	a2,s2
    296e:	85d2                	mv	a1,s4
    2970:	00004517          	auipc	a0,0x4
    2974:	4c050513          	addi	a0,a0,1216 # 6e30 <malloc+0xf3a>
    2978:	00003097          	auipc	ra,0x3
    297c:	4c0080e7          	jalr	1216(ra) # 5e38 <printf>
      exit(1);
    2980:	4505                	li	a0,1
    2982:	00003097          	auipc	ra,0x3
    2986:	126080e7          	jalr	294(ra) # 5aa8 <exit>
    printf("%s: sbrk test fork failed\n", s);
    298a:	85d2                	mv	a1,s4
    298c:	00004517          	auipc	a0,0x4
    2990:	4c450513          	addi	a0,a0,1220 # 6e50 <malloc+0xf5a>
    2994:	00003097          	auipc	ra,0x3
    2998:	4a4080e7          	jalr	1188(ra) # 5e38 <printf>
    exit(1);
    299c:	4505                	li	a0,1
    299e:	00003097          	auipc	ra,0x3
    29a2:	10a080e7          	jalr	266(ra) # 5aa8 <exit>
  if(pid == 0)
    29a6:	00091763          	bnez	s2,29b4 <sbrkbasic+0x16e>
    exit(0);
    29aa:	4501                	li	a0,0
    29ac:	00003097          	auipc	ra,0x3
    29b0:	0fc080e7          	jalr	252(ra) # 5aa8 <exit>
  wait(&xstatus);
    29b4:	fcc40513          	addi	a0,s0,-52
    29b8:	00003097          	auipc	ra,0x3
    29bc:	0f8080e7          	jalr	248(ra) # 5ab0 <wait>
  exit(xstatus);
    29c0:	fcc42503          	lw	a0,-52(s0)
    29c4:	00003097          	auipc	ra,0x3
    29c8:	0e4080e7          	jalr	228(ra) # 5aa8 <exit>

00000000000029cc <sbrkmuch>:
{
    29cc:	7179                	addi	sp,sp,-48
    29ce:	f406                	sd	ra,40(sp)
    29d0:	f022                	sd	s0,32(sp)
    29d2:	ec26                	sd	s1,24(sp)
    29d4:	e84a                	sd	s2,16(sp)
    29d6:	e44e                	sd	s3,8(sp)
    29d8:	e052                	sd	s4,0(sp)
    29da:	1800                	addi	s0,sp,48
    29dc:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    29de:	4501                	li	a0,0
    29e0:	00003097          	auipc	ra,0x3
    29e4:	150080e7          	jalr	336(ra) # 5b30 <sbrk>
    29e8:	892a                	mv	s2,a0
  a = sbrk(0);
    29ea:	4501                	li	a0,0
    29ec:	00003097          	auipc	ra,0x3
    29f0:	144080e7          	jalr	324(ra) # 5b30 <sbrk>
    29f4:	84aa                	mv	s1,a0
  p = sbrk(amt);
    29f6:	06400537          	lui	a0,0x6400
    29fa:	9d05                	subw	a0,a0,s1
    29fc:	00003097          	auipc	ra,0x3
    2a00:	134080e7          	jalr	308(ra) # 5b30 <sbrk>
  if (p != a) {
    2a04:	0ca49863          	bne	s1,a0,2ad4 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2a08:	4501                	li	a0,0
    2a0a:	00003097          	auipc	ra,0x3
    2a0e:	126080e7          	jalr	294(ra) # 5b30 <sbrk>
    2a12:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2a14:	00a4f963          	bgeu	s1,a0,2a26 <sbrkmuch+0x5a>
    *pp = 1;
    2a18:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2a1a:	6705                	lui	a4,0x1
    *pp = 1;
    2a1c:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2a20:	94ba                	add	s1,s1,a4
    2a22:	fef4ede3          	bltu	s1,a5,2a1c <sbrkmuch+0x50>
  *lastaddr = 99;
    2a26:	064007b7          	lui	a5,0x6400
    2a2a:	06300713          	li	a4,99
    2a2e:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f03a7>
  a = sbrk(0);
    2a32:	4501                	li	a0,0
    2a34:	00003097          	auipc	ra,0x3
    2a38:	0fc080e7          	jalr	252(ra) # 5b30 <sbrk>
    2a3c:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2a3e:	757d                	lui	a0,0xfffff
    2a40:	00003097          	auipc	ra,0x3
    2a44:	0f0080e7          	jalr	240(ra) # 5b30 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2a48:	57fd                	li	a5,-1
    2a4a:	0af50363          	beq	a0,a5,2af0 <sbrkmuch+0x124>
  c = sbrk(0);
    2a4e:	4501                	li	a0,0
    2a50:	00003097          	auipc	ra,0x3
    2a54:	0e0080e7          	jalr	224(ra) # 5b30 <sbrk>
  if(c != a - PGSIZE){
    2a58:	77fd                	lui	a5,0xfffff
    2a5a:	97a6                	add	a5,a5,s1
    2a5c:	0af51863          	bne	a0,a5,2b0c <sbrkmuch+0x140>
  a = sbrk(0);
    2a60:	4501                	li	a0,0
    2a62:	00003097          	auipc	ra,0x3
    2a66:	0ce080e7          	jalr	206(ra) # 5b30 <sbrk>
    2a6a:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2a6c:	6505                	lui	a0,0x1
    2a6e:	00003097          	auipc	ra,0x3
    2a72:	0c2080e7          	jalr	194(ra) # 5b30 <sbrk>
    2a76:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2a78:	0aa49a63          	bne	s1,a0,2b2c <sbrkmuch+0x160>
    2a7c:	4501                	li	a0,0
    2a7e:	00003097          	auipc	ra,0x3
    2a82:	0b2080e7          	jalr	178(ra) # 5b30 <sbrk>
    2a86:	6785                	lui	a5,0x1
    2a88:	97a6                	add	a5,a5,s1
    2a8a:	0af51163          	bne	a0,a5,2b2c <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2a8e:	064007b7          	lui	a5,0x6400
    2a92:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f03a7>
    2a96:	06300793          	li	a5,99
    2a9a:	0af70963          	beq	a4,a5,2b4c <sbrkmuch+0x180>
  a = sbrk(0);
    2a9e:	4501                	li	a0,0
    2aa0:	00003097          	auipc	ra,0x3
    2aa4:	090080e7          	jalr	144(ra) # 5b30 <sbrk>
    2aa8:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2aaa:	4501                	li	a0,0
    2aac:	00003097          	auipc	ra,0x3
    2ab0:	084080e7          	jalr	132(ra) # 5b30 <sbrk>
    2ab4:	40a9053b          	subw	a0,s2,a0
    2ab8:	00003097          	auipc	ra,0x3
    2abc:	078080e7          	jalr	120(ra) # 5b30 <sbrk>
  if(c != a){
    2ac0:	0aa49463          	bne	s1,a0,2b68 <sbrkmuch+0x19c>
}
    2ac4:	70a2                	ld	ra,40(sp)
    2ac6:	7402                	ld	s0,32(sp)
    2ac8:	64e2                	ld	s1,24(sp)
    2aca:	6942                	ld	s2,16(sp)
    2acc:	69a2                	ld	s3,8(sp)
    2ace:	6a02                	ld	s4,0(sp)
    2ad0:	6145                	addi	sp,sp,48
    2ad2:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2ad4:	85ce                	mv	a1,s3
    2ad6:	00004517          	auipc	a0,0x4
    2ada:	3ba50513          	addi	a0,a0,954 # 6e90 <malloc+0xf9a>
    2ade:	00003097          	auipc	ra,0x3
    2ae2:	35a080e7          	jalr	858(ra) # 5e38 <printf>
    exit(1);
    2ae6:	4505                	li	a0,1
    2ae8:	00003097          	auipc	ra,0x3
    2aec:	fc0080e7          	jalr	-64(ra) # 5aa8 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2af0:	85ce                	mv	a1,s3
    2af2:	00004517          	auipc	a0,0x4
    2af6:	3e650513          	addi	a0,a0,998 # 6ed8 <malloc+0xfe2>
    2afa:	00003097          	auipc	ra,0x3
    2afe:	33e080e7          	jalr	830(ra) # 5e38 <printf>
    exit(1);
    2b02:	4505                	li	a0,1
    2b04:	00003097          	auipc	ra,0x3
    2b08:	fa4080e7          	jalr	-92(ra) # 5aa8 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2b0c:	86aa                	mv	a3,a0
    2b0e:	8626                	mv	a2,s1
    2b10:	85ce                	mv	a1,s3
    2b12:	00004517          	auipc	a0,0x4
    2b16:	3e650513          	addi	a0,a0,998 # 6ef8 <malloc+0x1002>
    2b1a:	00003097          	auipc	ra,0x3
    2b1e:	31e080e7          	jalr	798(ra) # 5e38 <printf>
    exit(1);
    2b22:	4505                	li	a0,1
    2b24:	00003097          	auipc	ra,0x3
    2b28:	f84080e7          	jalr	-124(ra) # 5aa8 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2b2c:	86d2                	mv	a3,s4
    2b2e:	8626                	mv	a2,s1
    2b30:	85ce                	mv	a1,s3
    2b32:	00004517          	auipc	a0,0x4
    2b36:	40650513          	addi	a0,a0,1030 # 6f38 <malloc+0x1042>
    2b3a:	00003097          	auipc	ra,0x3
    2b3e:	2fe080e7          	jalr	766(ra) # 5e38 <printf>
    exit(1);
    2b42:	4505                	li	a0,1
    2b44:	00003097          	auipc	ra,0x3
    2b48:	f64080e7          	jalr	-156(ra) # 5aa8 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2b4c:	85ce                	mv	a1,s3
    2b4e:	00004517          	auipc	a0,0x4
    2b52:	41a50513          	addi	a0,a0,1050 # 6f68 <malloc+0x1072>
    2b56:	00003097          	auipc	ra,0x3
    2b5a:	2e2080e7          	jalr	738(ra) # 5e38 <printf>
    exit(1);
    2b5e:	4505                	li	a0,1
    2b60:	00003097          	auipc	ra,0x3
    2b64:	f48080e7          	jalr	-184(ra) # 5aa8 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2b68:	86aa                	mv	a3,a0
    2b6a:	8626                	mv	a2,s1
    2b6c:	85ce                	mv	a1,s3
    2b6e:	00004517          	auipc	a0,0x4
    2b72:	43250513          	addi	a0,a0,1074 # 6fa0 <malloc+0x10aa>
    2b76:	00003097          	auipc	ra,0x3
    2b7a:	2c2080e7          	jalr	706(ra) # 5e38 <printf>
    exit(1);
    2b7e:	4505                	li	a0,1
    2b80:	00003097          	auipc	ra,0x3
    2b84:	f28080e7          	jalr	-216(ra) # 5aa8 <exit>

0000000000002b88 <sbrkarg>:
{
    2b88:	7179                	addi	sp,sp,-48
    2b8a:	f406                	sd	ra,40(sp)
    2b8c:	f022                	sd	s0,32(sp)
    2b8e:	ec26                	sd	s1,24(sp)
    2b90:	e84a                	sd	s2,16(sp)
    2b92:	e44e                	sd	s3,8(sp)
    2b94:	1800                	addi	s0,sp,48
    2b96:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2b98:	6505                	lui	a0,0x1
    2b9a:	00003097          	auipc	ra,0x3
    2b9e:	f96080e7          	jalr	-106(ra) # 5b30 <sbrk>
    2ba2:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2ba4:	20100593          	li	a1,513
    2ba8:	00004517          	auipc	a0,0x4
    2bac:	42050513          	addi	a0,a0,1056 # 6fc8 <malloc+0x10d2>
    2bb0:	00003097          	auipc	ra,0x3
    2bb4:	f38080e7          	jalr	-200(ra) # 5ae8 <open>
    2bb8:	84aa                	mv	s1,a0
  unlink("sbrk");
    2bba:	00004517          	auipc	a0,0x4
    2bbe:	40e50513          	addi	a0,a0,1038 # 6fc8 <malloc+0x10d2>
    2bc2:	00003097          	auipc	ra,0x3
    2bc6:	f36080e7          	jalr	-202(ra) # 5af8 <unlink>
  if(fd < 0)  {
    2bca:	0404c163          	bltz	s1,2c0c <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2bce:	6605                	lui	a2,0x1
    2bd0:	85ca                	mv	a1,s2
    2bd2:	8526                	mv	a0,s1
    2bd4:	00003097          	auipc	ra,0x3
    2bd8:	ef4080e7          	jalr	-268(ra) # 5ac8 <write>
    2bdc:	04054663          	bltz	a0,2c28 <sbrkarg+0xa0>
  close(fd);
    2be0:	8526                	mv	a0,s1
    2be2:	00003097          	auipc	ra,0x3
    2be6:	eee080e7          	jalr	-274(ra) # 5ad0 <close>
  a = sbrk(PGSIZE);
    2bea:	6505                	lui	a0,0x1
    2bec:	00003097          	auipc	ra,0x3
    2bf0:	f44080e7          	jalr	-188(ra) # 5b30 <sbrk>
  if(pipe((int *) a) != 0){
    2bf4:	00003097          	auipc	ra,0x3
    2bf8:	ec4080e7          	jalr	-316(ra) # 5ab8 <pipe>
    2bfc:	e521                	bnez	a0,2c44 <sbrkarg+0xbc>
}
    2bfe:	70a2                	ld	ra,40(sp)
    2c00:	7402                	ld	s0,32(sp)
    2c02:	64e2                	ld	s1,24(sp)
    2c04:	6942                	ld	s2,16(sp)
    2c06:	69a2                	ld	s3,8(sp)
    2c08:	6145                	addi	sp,sp,48
    2c0a:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2c0c:	85ce                	mv	a1,s3
    2c0e:	00004517          	auipc	a0,0x4
    2c12:	3c250513          	addi	a0,a0,962 # 6fd0 <malloc+0x10da>
    2c16:	00003097          	auipc	ra,0x3
    2c1a:	222080e7          	jalr	546(ra) # 5e38 <printf>
    exit(1);
    2c1e:	4505                	li	a0,1
    2c20:	00003097          	auipc	ra,0x3
    2c24:	e88080e7          	jalr	-376(ra) # 5aa8 <exit>
    printf("%s: write sbrk failed\n", s);
    2c28:	85ce                	mv	a1,s3
    2c2a:	00004517          	auipc	a0,0x4
    2c2e:	3be50513          	addi	a0,a0,958 # 6fe8 <malloc+0x10f2>
    2c32:	00003097          	auipc	ra,0x3
    2c36:	206080e7          	jalr	518(ra) # 5e38 <printf>
    exit(1);
    2c3a:	4505                	li	a0,1
    2c3c:	00003097          	auipc	ra,0x3
    2c40:	e6c080e7          	jalr	-404(ra) # 5aa8 <exit>
    printf("%s: pipe() failed\n", s);
    2c44:	85ce                	mv	a1,s3
    2c46:	00004517          	auipc	a0,0x4
    2c4a:	d8250513          	addi	a0,a0,-638 # 69c8 <malloc+0xad2>
    2c4e:	00003097          	auipc	ra,0x3
    2c52:	1ea080e7          	jalr	490(ra) # 5e38 <printf>
    exit(1);
    2c56:	4505                	li	a0,1
    2c58:	00003097          	auipc	ra,0x3
    2c5c:	e50080e7          	jalr	-432(ra) # 5aa8 <exit>

0000000000002c60 <argptest>:
{
    2c60:	1101                	addi	sp,sp,-32
    2c62:	ec06                	sd	ra,24(sp)
    2c64:	e822                	sd	s0,16(sp)
    2c66:	e426                	sd	s1,8(sp)
    2c68:	e04a                	sd	s2,0(sp)
    2c6a:	1000                	addi	s0,sp,32
    2c6c:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2c6e:	4581                	li	a1,0
    2c70:	00004517          	auipc	a0,0x4
    2c74:	39050513          	addi	a0,a0,912 # 7000 <malloc+0x110a>
    2c78:	00003097          	auipc	ra,0x3
    2c7c:	e70080e7          	jalr	-400(ra) # 5ae8 <open>
  if (fd < 0) {
    2c80:	02054b63          	bltz	a0,2cb6 <argptest+0x56>
    2c84:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2c86:	4501                	li	a0,0
    2c88:	00003097          	auipc	ra,0x3
    2c8c:	ea8080e7          	jalr	-344(ra) # 5b30 <sbrk>
    2c90:	567d                	li	a2,-1
    2c92:	fff50593          	addi	a1,a0,-1
    2c96:	8526                	mv	a0,s1
    2c98:	00003097          	auipc	ra,0x3
    2c9c:	e28080e7          	jalr	-472(ra) # 5ac0 <read>
  close(fd);
    2ca0:	8526                	mv	a0,s1
    2ca2:	00003097          	auipc	ra,0x3
    2ca6:	e2e080e7          	jalr	-466(ra) # 5ad0 <close>
}
    2caa:	60e2                	ld	ra,24(sp)
    2cac:	6442                	ld	s0,16(sp)
    2cae:	64a2                	ld	s1,8(sp)
    2cb0:	6902                	ld	s2,0(sp)
    2cb2:	6105                	addi	sp,sp,32
    2cb4:	8082                	ret
    printf("%s: open failed\n", s);
    2cb6:	85ca                	mv	a1,s2
    2cb8:	00004517          	auipc	a0,0x4
    2cbc:	c2050513          	addi	a0,a0,-992 # 68d8 <malloc+0x9e2>
    2cc0:	00003097          	auipc	ra,0x3
    2cc4:	178080e7          	jalr	376(ra) # 5e38 <printf>
    exit(1);
    2cc8:	4505                	li	a0,1
    2cca:	00003097          	auipc	ra,0x3
    2cce:	dde080e7          	jalr	-546(ra) # 5aa8 <exit>

0000000000002cd2 <sbrkbugs>:
{
    2cd2:	1141                	addi	sp,sp,-16
    2cd4:	e406                	sd	ra,8(sp)
    2cd6:	e022                	sd	s0,0(sp)
    2cd8:	0800                	addi	s0,sp,16
  int pid = fork();
    2cda:	00003097          	auipc	ra,0x3
    2cde:	dc6080e7          	jalr	-570(ra) # 5aa0 <fork>
  if(pid < 0){
    2ce2:	02054263          	bltz	a0,2d06 <sbrkbugs+0x34>
  if(pid == 0){
    2ce6:	ed0d                	bnez	a0,2d20 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2ce8:	00003097          	auipc	ra,0x3
    2cec:	e48080e7          	jalr	-440(ra) # 5b30 <sbrk>
    sbrk(-sz);
    2cf0:	40a0053b          	negw	a0,a0
    2cf4:	00003097          	auipc	ra,0x3
    2cf8:	e3c080e7          	jalr	-452(ra) # 5b30 <sbrk>
    exit(0);
    2cfc:	4501                	li	a0,0
    2cfe:	00003097          	auipc	ra,0x3
    2d02:	daa080e7          	jalr	-598(ra) # 5aa8 <exit>
    printf("fork failed\n");
    2d06:	00004517          	auipc	a0,0x4
    2d0a:	fc250513          	addi	a0,a0,-62 # 6cc8 <malloc+0xdd2>
    2d0e:	00003097          	auipc	ra,0x3
    2d12:	12a080e7          	jalr	298(ra) # 5e38 <printf>
    exit(1);
    2d16:	4505                	li	a0,1
    2d18:	00003097          	auipc	ra,0x3
    2d1c:	d90080e7          	jalr	-624(ra) # 5aa8 <exit>
  wait(0);
    2d20:	4501                	li	a0,0
    2d22:	00003097          	auipc	ra,0x3
    2d26:	d8e080e7          	jalr	-626(ra) # 5ab0 <wait>
  pid = fork();
    2d2a:	00003097          	auipc	ra,0x3
    2d2e:	d76080e7          	jalr	-650(ra) # 5aa0 <fork>
  if(pid < 0){
    2d32:	02054563          	bltz	a0,2d5c <sbrkbugs+0x8a>
  if(pid == 0){
    2d36:	e121                	bnez	a0,2d76 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2d38:	00003097          	auipc	ra,0x3
    2d3c:	df8080e7          	jalr	-520(ra) # 5b30 <sbrk>
    sbrk(-(sz - 3500));
    2d40:	6785                	lui	a5,0x1
    2d42:	dac7879b          	addiw	a5,a5,-596
    2d46:	40a7853b          	subw	a0,a5,a0
    2d4a:	00003097          	auipc	ra,0x3
    2d4e:	de6080e7          	jalr	-538(ra) # 5b30 <sbrk>
    exit(0);
    2d52:	4501                	li	a0,0
    2d54:	00003097          	auipc	ra,0x3
    2d58:	d54080e7          	jalr	-684(ra) # 5aa8 <exit>
    printf("fork failed\n");
    2d5c:	00004517          	auipc	a0,0x4
    2d60:	f6c50513          	addi	a0,a0,-148 # 6cc8 <malloc+0xdd2>
    2d64:	00003097          	auipc	ra,0x3
    2d68:	0d4080e7          	jalr	212(ra) # 5e38 <printf>
    exit(1);
    2d6c:	4505                	li	a0,1
    2d6e:	00003097          	auipc	ra,0x3
    2d72:	d3a080e7          	jalr	-710(ra) # 5aa8 <exit>
  wait(0);
    2d76:	4501                	li	a0,0
    2d78:	00003097          	auipc	ra,0x3
    2d7c:	d38080e7          	jalr	-712(ra) # 5ab0 <wait>
  pid = fork();
    2d80:	00003097          	auipc	ra,0x3
    2d84:	d20080e7          	jalr	-736(ra) # 5aa0 <fork>
  if(pid < 0){
    2d88:	02054a63          	bltz	a0,2dbc <sbrkbugs+0xea>
  if(pid == 0){
    2d8c:	e529                	bnez	a0,2dd6 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2d8e:	00003097          	auipc	ra,0x3
    2d92:	da2080e7          	jalr	-606(ra) # 5b30 <sbrk>
    2d96:	67ad                	lui	a5,0xb
    2d98:	8007879b          	addiw	a5,a5,-2048
    2d9c:	40a7853b          	subw	a0,a5,a0
    2da0:	00003097          	auipc	ra,0x3
    2da4:	d90080e7          	jalr	-624(ra) # 5b30 <sbrk>
    sbrk(-10);
    2da8:	5559                	li	a0,-10
    2daa:	00003097          	auipc	ra,0x3
    2dae:	d86080e7          	jalr	-634(ra) # 5b30 <sbrk>
    exit(0);
    2db2:	4501                	li	a0,0
    2db4:	00003097          	auipc	ra,0x3
    2db8:	cf4080e7          	jalr	-780(ra) # 5aa8 <exit>
    printf("fork failed\n");
    2dbc:	00004517          	auipc	a0,0x4
    2dc0:	f0c50513          	addi	a0,a0,-244 # 6cc8 <malloc+0xdd2>
    2dc4:	00003097          	auipc	ra,0x3
    2dc8:	074080e7          	jalr	116(ra) # 5e38 <printf>
    exit(1);
    2dcc:	4505                	li	a0,1
    2dce:	00003097          	auipc	ra,0x3
    2dd2:	cda080e7          	jalr	-806(ra) # 5aa8 <exit>
  wait(0);
    2dd6:	4501                	li	a0,0
    2dd8:	00003097          	auipc	ra,0x3
    2ddc:	cd8080e7          	jalr	-808(ra) # 5ab0 <wait>
  exit(0);
    2de0:	4501                	li	a0,0
    2de2:	00003097          	auipc	ra,0x3
    2de6:	cc6080e7          	jalr	-826(ra) # 5aa8 <exit>

0000000000002dea <sbrklast>:
{
    2dea:	7179                	addi	sp,sp,-48
    2dec:	f406                	sd	ra,40(sp)
    2dee:	f022                	sd	s0,32(sp)
    2df0:	ec26                	sd	s1,24(sp)
    2df2:	e84a                	sd	s2,16(sp)
    2df4:	e44e                	sd	s3,8(sp)
    2df6:	e052                	sd	s4,0(sp)
    2df8:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    2dfa:	4501                	li	a0,0
    2dfc:	00003097          	auipc	ra,0x3
    2e00:	d34080e7          	jalr	-716(ra) # 5b30 <sbrk>
  if((top % 4096) != 0)
    2e04:	03451793          	slli	a5,a0,0x34
    2e08:	ebd9                	bnez	a5,2e9e <sbrklast+0xb4>
  sbrk(4096);
    2e0a:	6505                	lui	a0,0x1
    2e0c:	00003097          	auipc	ra,0x3
    2e10:	d24080e7          	jalr	-732(ra) # 5b30 <sbrk>
  sbrk(10);
    2e14:	4529                	li	a0,10
    2e16:	00003097          	auipc	ra,0x3
    2e1a:	d1a080e7          	jalr	-742(ra) # 5b30 <sbrk>
  sbrk(-20);
    2e1e:	5531                	li	a0,-20
    2e20:	00003097          	auipc	ra,0x3
    2e24:	d10080e7          	jalr	-752(ra) # 5b30 <sbrk>
  top = (uint64) sbrk(0);
    2e28:	4501                	li	a0,0
    2e2a:	00003097          	auipc	ra,0x3
    2e2e:	d06080e7          	jalr	-762(ra) # 5b30 <sbrk>
    2e32:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2e34:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0xca>
  p[0] = 'x';
    2e38:	07800a13          	li	s4,120
    2e3c:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2e40:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2e44:	20200593          	li	a1,514
    2e48:	854a                	mv	a0,s2
    2e4a:	00003097          	auipc	ra,0x3
    2e4e:	c9e080e7          	jalr	-866(ra) # 5ae8 <open>
    2e52:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2e54:	4605                	li	a2,1
    2e56:	85ca                	mv	a1,s2
    2e58:	00003097          	auipc	ra,0x3
    2e5c:	c70080e7          	jalr	-912(ra) # 5ac8 <write>
  close(fd);
    2e60:	854e                	mv	a0,s3
    2e62:	00003097          	auipc	ra,0x3
    2e66:	c6e080e7          	jalr	-914(ra) # 5ad0 <close>
  fd = open(p, O_RDWR);
    2e6a:	4589                	li	a1,2
    2e6c:	854a                	mv	a0,s2
    2e6e:	00003097          	auipc	ra,0x3
    2e72:	c7a080e7          	jalr	-902(ra) # 5ae8 <open>
  p[0] = '\0';
    2e76:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2e7a:	4605                	li	a2,1
    2e7c:	85ca                	mv	a1,s2
    2e7e:	00003097          	auipc	ra,0x3
    2e82:	c42080e7          	jalr	-958(ra) # 5ac0 <read>
  if(p[0] != 'x')
    2e86:	fc04c783          	lbu	a5,-64(s1)
    2e8a:	03479463          	bne	a5,s4,2eb2 <sbrklast+0xc8>
}
    2e8e:	70a2                	ld	ra,40(sp)
    2e90:	7402                	ld	s0,32(sp)
    2e92:	64e2                	ld	s1,24(sp)
    2e94:	6942                	ld	s2,16(sp)
    2e96:	69a2                	ld	s3,8(sp)
    2e98:	6a02                	ld	s4,0(sp)
    2e9a:	6145                	addi	sp,sp,48
    2e9c:	8082                	ret
    sbrk(4096 - (top % 4096));
    2e9e:	0347d513          	srli	a0,a5,0x34
    2ea2:	6785                	lui	a5,0x1
    2ea4:	40a7853b          	subw	a0,a5,a0
    2ea8:	00003097          	auipc	ra,0x3
    2eac:	c88080e7          	jalr	-888(ra) # 5b30 <sbrk>
    2eb0:	bfa9                	j	2e0a <sbrklast+0x20>
    exit(1);
    2eb2:	4505                	li	a0,1
    2eb4:	00003097          	auipc	ra,0x3
    2eb8:	bf4080e7          	jalr	-1036(ra) # 5aa8 <exit>

0000000000002ebc <sbrk8000>:
{
    2ebc:	1141                	addi	sp,sp,-16
    2ebe:	e406                	sd	ra,8(sp)
    2ec0:	e022                	sd	s0,0(sp)
    2ec2:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2ec4:	80000537          	lui	a0,0x80000
    2ec8:	0511                	addi	a0,a0,4
    2eca:	00003097          	auipc	ra,0x3
    2ece:	c66080e7          	jalr	-922(ra) # 5b30 <sbrk>
  volatile char *top = sbrk(0);
    2ed2:	4501                	li	a0,0
    2ed4:	00003097          	auipc	ra,0x3
    2ed8:	c5c080e7          	jalr	-932(ra) # 5b30 <sbrk>
  *(top-1) = *(top-1) + 1;
    2edc:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <base+0xffffffff7fff03a7>
    2ee0:	0785                	addi	a5,a5,1
    2ee2:	0ff7f793          	andi	a5,a5,255
    2ee6:	fef50fa3          	sb	a5,-1(a0)
}
    2eea:	60a2                	ld	ra,8(sp)
    2eec:	6402                	ld	s0,0(sp)
    2eee:	0141                	addi	sp,sp,16
    2ef0:	8082                	ret

0000000000002ef2 <execout>:
{
    2ef2:	715d                	addi	sp,sp,-80
    2ef4:	e486                	sd	ra,72(sp)
    2ef6:	e0a2                	sd	s0,64(sp)
    2ef8:	fc26                	sd	s1,56(sp)
    2efa:	f84a                	sd	s2,48(sp)
    2efc:	f44e                	sd	s3,40(sp)
    2efe:	f052                	sd	s4,32(sp)
    2f00:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2f02:	4901                	li	s2,0
    2f04:	49bd                	li	s3,15
    int pid = fork();
    2f06:	00003097          	auipc	ra,0x3
    2f0a:	b9a080e7          	jalr	-1126(ra) # 5aa0 <fork>
    2f0e:	84aa                	mv	s1,a0
    if(pid < 0){
    2f10:	02054063          	bltz	a0,2f30 <execout+0x3e>
    } else if(pid == 0){
    2f14:	c91d                	beqz	a0,2f4a <execout+0x58>
      wait((int*)0);
    2f16:	4501                	li	a0,0
    2f18:	00003097          	auipc	ra,0x3
    2f1c:	b98080e7          	jalr	-1128(ra) # 5ab0 <wait>
  for(int avail = 0; avail < 15; avail++){
    2f20:	2905                	addiw	s2,s2,1
    2f22:	ff3912e3          	bne	s2,s3,2f06 <execout+0x14>
  exit(0);
    2f26:	4501                	li	a0,0
    2f28:	00003097          	auipc	ra,0x3
    2f2c:	b80080e7          	jalr	-1152(ra) # 5aa8 <exit>
      printf("fork failed\n");
    2f30:	00004517          	auipc	a0,0x4
    2f34:	d9850513          	addi	a0,a0,-616 # 6cc8 <malloc+0xdd2>
    2f38:	00003097          	auipc	ra,0x3
    2f3c:	f00080e7          	jalr	-256(ra) # 5e38 <printf>
      exit(1);
    2f40:	4505                	li	a0,1
    2f42:	00003097          	auipc	ra,0x3
    2f46:	b66080e7          	jalr	-1178(ra) # 5aa8 <exit>
        if(a == 0xffffffffffffffffLL)
    2f4a:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2f4c:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2f4e:	6505                	lui	a0,0x1
    2f50:	00003097          	auipc	ra,0x3
    2f54:	be0080e7          	jalr	-1056(ra) # 5b30 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2f58:	01350763          	beq	a0,s3,2f66 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2f5c:	6785                	lui	a5,0x1
    2f5e:	953e                	add	a0,a0,a5
    2f60:	ff450fa3          	sb	s4,-1(a0) # fff <linktest+0x109>
      while(1){
    2f64:	b7ed                	j	2f4e <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2f66:	01205a63          	blez	s2,2f7a <execout+0x88>
        sbrk(-4096);
    2f6a:	757d                	lui	a0,0xfffff
    2f6c:	00003097          	auipc	ra,0x3
    2f70:	bc4080e7          	jalr	-1084(ra) # 5b30 <sbrk>
      for(int i = 0; i < avail; i++)
    2f74:	2485                	addiw	s1,s1,1
    2f76:	ff249ae3          	bne	s1,s2,2f6a <execout+0x78>
      close(1);
    2f7a:	4505                	li	a0,1
    2f7c:	00003097          	auipc	ra,0x3
    2f80:	b54080e7          	jalr	-1196(ra) # 5ad0 <close>
      char *args[] = { "echo", "x", 0 };
    2f84:	00003517          	auipc	a0,0x3
    2f88:	0b450513          	addi	a0,a0,180 # 6038 <malloc+0x142>
    2f8c:	faa43c23          	sd	a0,-72(s0)
    2f90:	00003797          	auipc	a5,0x3
    2f94:	11878793          	addi	a5,a5,280 # 60a8 <malloc+0x1b2>
    2f98:	fcf43023          	sd	a5,-64(s0)
    2f9c:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2fa0:	fb840593          	addi	a1,s0,-72
    2fa4:	00003097          	auipc	ra,0x3
    2fa8:	b3c080e7          	jalr	-1220(ra) # 5ae0 <exec>
      exit(0);
    2fac:	4501                	li	a0,0
    2fae:	00003097          	auipc	ra,0x3
    2fb2:	afa080e7          	jalr	-1286(ra) # 5aa8 <exit>

0000000000002fb6 <fourteen>:
{
    2fb6:	1101                	addi	sp,sp,-32
    2fb8:	ec06                	sd	ra,24(sp)
    2fba:	e822                	sd	s0,16(sp)
    2fbc:	e426                	sd	s1,8(sp)
    2fbe:	1000                	addi	s0,sp,32
    2fc0:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2fc2:	00004517          	auipc	a0,0x4
    2fc6:	21650513          	addi	a0,a0,534 # 71d8 <malloc+0x12e2>
    2fca:	00003097          	auipc	ra,0x3
    2fce:	b46080e7          	jalr	-1210(ra) # 5b10 <mkdir>
    2fd2:	e165                	bnez	a0,30b2 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2fd4:	00004517          	auipc	a0,0x4
    2fd8:	05c50513          	addi	a0,a0,92 # 7030 <malloc+0x113a>
    2fdc:	00003097          	auipc	ra,0x3
    2fe0:	b34080e7          	jalr	-1228(ra) # 5b10 <mkdir>
    2fe4:	e56d                	bnez	a0,30ce <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2fe6:	20000593          	li	a1,512
    2fea:	00004517          	auipc	a0,0x4
    2fee:	09e50513          	addi	a0,a0,158 # 7088 <malloc+0x1192>
    2ff2:	00003097          	auipc	ra,0x3
    2ff6:	af6080e7          	jalr	-1290(ra) # 5ae8 <open>
  if(fd < 0){
    2ffa:	0e054863          	bltz	a0,30ea <fourteen+0x134>
  close(fd);
    2ffe:	00003097          	auipc	ra,0x3
    3002:	ad2080e7          	jalr	-1326(ra) # 5ad0 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3006:	4581                	li	a1,0
    3008:	00004517          	auipc	a0,0x4
    300c:	0f850513          	addi	a0,a0,248 # 7100 <malloc+0x120a>
    3010:	00003097          	auipc	ra,0x3
    3014:	ad8080e7          	jalr	-1320(ra) # 5ae8 <open>
  if(fd < 0){
    3018:	0e054763          	bltz	a0,3106 <fourteen+0x150>
  close(fd);
    301c:	00003097          	auipc	ra,0x3
    3020:	ab4080e7          	jalr	-1356(ra) # 5ad0 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    3024:	00004517          	auipc	a0,0x4
    3028:	14c50513          	addi	a0,a0,332 # 7170 <malloc+0x127a>
    302c:	00003097          	auipc	ra,0x3
    3030:	ae4080e7          	jalr	-1308(ra) # 5b10 <mkdir>
    3034:	c57d                	beqz	a0,3122 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    3036:	00004517          	auipc	a0,0x4
    303a:	19250513          	addi	a0,a0,402 # 71c8 <malloc+0x12d2>
    303e:	00003097          	auipc	ra,0x3
    3042:	ad2080e7          	jalr	-1326(ra) # 5b10 <mkdir>
    3046:	cd65                	beqz	a0,313e <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    3048:	00004517          	auipc	a0,0x4
    304c:	18050513          	addi	a0,a0,384 # 71c8 <malloc+0x12d2>
    3050:	00003097          	auipc	ra,0x3
    3054:	aa8080e7          	jalr	-1368(ra) # 5af8 <unlink>
  unlink("12345678901234/12345678901234");
    3058:	00004517          	auipc	a0,0x4
    305c:	11850513          	addi	a0,a0,280 # 7170 <malloc+0x127a>
    3060:	00003097          	auipc	ra,0x3
    3064:	a98080e7          	jalr	-1384(ra) # 5af8 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    3068:	00004517          	auipc	a0,0x4
    306c:	09850513          	addi	a0,a0,152 # 7100 <malloc+0x120a>
    3070:	00003097          	auipc	ra,0x3
    3074:	a88080e7          	jalr	-1400(ra) # 5af8 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    3078:	00004517          	auipc	a0,0x4
    307c:	01050513          	addi	a0,a0,16 # 7088 <malloc+0x1192>
    3080:	00003097          	auipc	ra,0x3
    3084:	a78080e7          	jalr	-1416(ra) # 5af8 <unlink>
  unlink("12345678901234/123456789012345");
    3088:	00004517          	auipc	a0,0x4
    308c:	fa850513          	addi	a0,a0,-88 # 7030 <malloc+0x113a>
    3090:	00003097          	auipc	ra,0x3
    3094:	a68080e7          	jalr	-1432(ra) # 5af8 <unlink>
  unlink("12345678901234");
    3098:	00004517          	auipc	a0,0x4
    309c:	14050513          	addi	a0,a0,320 # 71d8 <malloc+0x12e2>
    30a0:	00003097          	auipc	ra,0x3
    30a4:	a58080e7          	jalr	-1448(ra) # 5af8 <unlink>
}
    30a8:	60e2                	ld	ra,24(sp)
    30aa:	6442                	ld	s0,16(sp)
    30ac:	64a2                	ld	s1,8(sp)
    30ae:	6105                	addi	sp,sp,32
    30b0:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    30b2:	85a6                	mv	a1,s1
    30b4:	00004517          	auipc	a0,0x4
    30b8:	f5450513          	addi	a0,a0,-172 # 7008 <malloc+0x1112>
    30bc:	00003097          	auipc	ra,0x3
    30c0:	d7c080e7          	jalr	-644(ra) # 5e38 <printf>
    exit(1);
    30c4:	4505                	li	a0,1
    30c6:	00003097          	auipc	ra,0x3
    30ca:	9e2080e7          	jalr	-1566(ra) # 5aa8 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    30ce:	85a6                	mv	a1,s1
    30d0:	00004517          	auipc	a0,0x4
    30d4:	f8050513          	addi	a0,a0,-128 # 7050 <malloc+0x115a>
    30d8:	00003097          	auipc	ra,0x3
    30dc:	d60080e7          	jalr	-672(ra) # 5e38 <printf>
    exit(1);
    30e0:	4505                	li	a0,1
    30e2:	00003097          	auipc	ra,0x3
    30e6:	9c6080e7          	jalr	-1594(ra) # 5aa8 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    30ea:	85a6                	mv	a1,s1
    30ec:	00004517          	auipc	a0,0x4
    30f0:	fcc50513          	addi	a0,a0,-52 # 70b8 <malloc+0x11c2>
    30f4:	00003097          	auipc	ra,0x3
    30f8:	d44080e7          	jalr	-700(ra) # 5e38 <printf>
    exit(1);
    30fc:	4505                	li	a0,1
    30fe:	00003097          	auipc	ra,0x3
    3102:	9aa080e7          	jalr	-1622(ra) # 5aa8 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    3106:	85a6                	mv	a1,s1
    3108:	00004517          	auipc	a0,0x4
    310c:	02850513          	addi	a0,a0,40 # 7130 <malloc+0x123a>
    3110:	00003097          	auipc	ra,0x3
    3114:	d28080e7          	jalr	-728(ra) # 5e38 <printf>
    exit(1);
    3118:	4505                	li	a0,1
    311a:	00003097          	auipc	ra,0x3
    311e:	98e080e7          	jalr	-1650(ra) # 5aa8 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    3122:	85a6                	mv	a1,s1
    3124:	00004517          	auipc	a0,0x4
    3128:	06c50513          	addi	a0,a0,108 # 7190 <malloc+0x129a>
    312c:	00003097          	auipc	ra,0x3
    3130:	d0c080e7          	jalr	-756(ra) # 5e38 <printf>
    exit(1);
    3134:	4505                	li	a0,1
    3136:	00003097          	auipc	ra,0x3
    313a:	972080e7          	jalr	-1678(ra) # 5aa8 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    313e:	85a6                	mv	a1,s1
    3140:	00004517          	auipc	a0,0x4
    3144:	0a850513          	addi	a0,a0,168 # 71e8 <malloc+0x12f2>
    3148:	00003097          	auipc	ra,0x3
    314c:	cf0080e7          	jalr	-784(ra) # 5e38 <printf>
    exit(1);
    3150:	4505                	li	a0,1
    3152:	00003097          	auipc	ra,0x3
    3156:	956080e7          	jalr	-1706(ra) # 5aa8 <exit>

000000000000315a <diskfull>:
{
    315a:	b9010113          	addi	sp,sp,-1136
    315e:	46113423          	sd	ra,1128(sp)
    3162:	46813023          	sd	s0,1120(sp)
    3166:	44913c23          	sd	s1,1112(sp)
    316a:	45213823          	sd	s2,1104(sp)
    316e:	45313423          	sd	s3,1096(sp)
    3172:	45413023          	sd	s4,1088(sp)
    3176:	43513c23          	sd	s5,1080(sp)
    317a:	43613823          	sd	s6,1072(sp)
    317e:	43713423          	sd	s7,1064(sp)
    3182:	43813023          	sd	s8,1056(sp)
    3186:	47010413          	addi	s0,sp,1136
    318a:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
    318c:	00004517          	auipc	a0,0x4
    3190:	09450513          	addi	a0,a0,148 # 7220 <malloc+0x132a>
    3194:	00003097          	auipc	ra,0x3
    3198:	964080e7          	jalr	-1692(ra) # 5af8 <unlink>
  for(fi = 0; done == 0; fi++){
    319c:	4a01                	li	s4,0
    name[0] = 'b';
    319e:	06200b13          	li	s6,98
    name[1] = 'i';
    31a2:	06900a93          	li	s5,105
    name[2] = 'g';
    31a6:	06700993          	li	s3,103
    31aa:	10c00b93          	li	s7,268
    31ae:	aabd                	j	332c <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
    31b0:	b9040613          	addi	a2,s0,-1136
    31b4:	85e2                	mv	a1,s8
    31b6:	00004517          	auipc	a0,0x4
    31ba:	07a50513          	addi	a0,a0,122 # 7230 <malloc+0x133a>
    31be:	00003097          	auipc	ra,0x3
    31c2:	c7a080e7          	jalr	-902(ra) # 5e38 <printf>
      break;
    31c6:	a821                	j	31de <diskfull+0x84>
        close(fd);
    31c8:	854a                	mv	a0,s2
    31ca:	00003097          	auipc	ra,0x3
    31ce:	906080e7          	jalr	-1786(ra) # 5ad0 <close>
    close(fd);
    31d2:	854a                	mv	a0,s2
    31d4:	00003097          	auipc	ra,0x3
    31d8:	8fc080e7          	jalr	-1796(ra) # 5ad0 <close>
  for(fi = 0; done == 0; fi++){
    31dc:	2a05                	addiw	s4,s4,1
  for(int i = 0; i < nzz; i++){
    31de:	4481                	li	s1,0
    name[0] = 'z';
    31e0:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    31e4:	08000993          	li	s3,128
    name[0] = 'z';
    31e8:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    31ec:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    31f0:	41f4d79b          	sraiw	a5,s1,0x1f
    31f4:	01b7d71b          	srliw	a4,a5,0x1b
    31f8:	009707bb          	addw	a5,a4,s1
    31fc:	4057d69b          	sraiw	a3,a5,0x5
    3200:	0306869b          	addiw	a3,a3,48
    3204:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3208:	8bfd                	andi	a5,a5,31
    320a:	9f99                	subw	a5,a5,a4
    320c:	0307879b          	addiw	a5,a5,48
    3210:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3214:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3218:	bb040513          	addi	a0,s0,-1104
    321c:	00003097          	auipc	ra,0x3
    3220:	8dc080e7          	jalr	-1828(ra) # 5af8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    3224:	60200593          	li	a1,1538
    3228:	bb040513          	addi	a0,s0,-1104
    322c:	00003097          	auipc	ra,0x3
    3230:	8bc080e7          	jalr	-1860(ra) # 5ae8 <open>
    if(fd < 0)
    3234:	00054963          	bltz	a0,3246 <diskfull+0xec>
    close(fd);
    3238:	00003097          	auipc	ra,0x3
    323c:	898080e7          	jalr	-1896(ra) # 5ad0 <close>
  for(int i = 0; i < nzz; i++){
    3240:	2485                	addiw	s1,s1,1
    3242:	fb3493e3          	bne	s1,s3,31e8 <diskfull+0x8e>
  if(mkdir("diskfulldir") == 0)
    3246:	00004517          	auipc	a0,0x4
    324a:	fda50513          	addi	a0,a0,-38 # 7220 <malloc+0x132a>
    324e:	00003097          	auipc	ra,0x3
    3252:	8c2080e7          	jalr	-1854(ra) # 5b10 <mkdir>
    3256:	12050963          	beqz	a0,3388 <diskfull+0x22e>
  unlink("diskfulldir");
    325a:	00004517          	auipc	a0,0x4
    325e:	fc650513          	addi	a0,a0,-58 # 7220 <malloc+0x132a>
    3262:	00003097          	auipc	ra,0x3
    3266:	896080e7          	jalr	-1898(ra) # 5af8 <unlink>
  for(int i = 0; i < nzz; i++){
    326a:	4481                	li	s1,0
    name[0] = 'z';
    326c:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    3270:	08000993          	li	s3,128
    name[0] = 'z';
    3274:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    3278:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    327c:	41f4d79b          	sraiw	a5,s1,0x1f
    3280:	01b7d71b          	srliw	a4,a5,0x1b
    3284:	009707bb          	addw	a5,a4,s1
    3288:	4057d69b          	sraiw	a3,a5,0x5
    328c:	0306869b          	addiw	a3,a3,48
    3290:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3294:	8bfd                	andi	a5,a5,31
    3296:	9f99                	subw	a5,a5,a4
    3298:	0307879b          	addiw	a5,a5,48
    329c:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    32a0:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    32a4:	bb040513          	addi	a0,s0,-1104
    32a8:	00003097          	auipc	ra,0x3
    32ac:	850080e7          	jalr	-1968(ra) # 5af8 <unlink>
  for(int i = 0; i < nzz; i++){
    32b0:	2485                	addiw	s1,s1,1
    32b2:	fd3491e3          	bne	s1,s3,3274 <diskfull+0x11a>
  for(int i = 0; i < fi; i++){
    32b6:	03405e63          	blez	s4,32f2 <diskfull+0x198>
    32ba:	4481                	li	s1,0
    name[0] = 'b';
    32bc:	06200a93          	li	s5,98
    name[1] = 'i';
    32c0:	06900993          	li	s3,105
    name[2] = 'g';
    32c4:	06700913          	li	s2,103
    name[0] = 'b';
    32c8:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    32cc:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    32d0:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    32d4:	0304879b          	addiw	a5,s1,48
    32d8:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    32dc:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    32e0:	bb040513          	addi	a0,s0,-1104
    32e4:	00003097          	auipc	ra,0x3
    32e8:	814080e7          	jalr	-2028(ra) # 5af8 <unlink>
  for(int i = 0; i < fi; i++){
    32ec:	2485                	addiw	s1,s1,1
    32ee:	fd449de3          	bne	s1,s4,32c8 <diskfull+0x16e>
}
    32f2:	46813083          	ld	ra,1128(sp)
    32f6:	46013403          	ld	s0,1120(sp)
    32fa:	45813483          	ld	s1,1112(sp)
    32fe:	45013903          	ld	s2,1104(sp)
    3302:	44813983          	ld	s3,1096(sp)
    3306:	44013a03          	ld	s4,1088(sp)
    330a:	43813a83          	ld	s5,1080(sp)
    330e:	43013b03          	ld	s6,1072(sp)
    3312:	42813b83          	ld	s7,1064(sp)
    3316:	42013c03          	ld	s8,1056(sp)
    331a:	47010113          	addi	sp,sp,1136
    331e:	8082                	ret
    close(fd);
    3320:	854a                	mv	a0,s2
    3322:	00002097          	auipc	ra,0x2
    3326:	7ae080e7          	jalr	1966(ra) # 5ad0 <close>
  for(fi = 0; done == 0; fi++){
    332a:	2a05                	addiw	s4,s4,1
    name[0] = 'b';
    332c:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    3330:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    3334:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    3338:	030a079b          	addiw	a5,s4,48
    333c:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    3340:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    3344:	b9040513          	addi	a0,s0,-1136
    3348:	00002097          	auipc	ra,0x2
    334c:	7b0080e7          	jalr	1968(ra) # 5af8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    3350:	60200593          	li	a1,1538
    3354:	b9040513          	addi	a0,s0,-1136
    3358:	00002097          	auipc	ra,0x2
    335c:	790080e7          	jalr	1936(ra) # 5ae8 <open>
    3360:	892a                	mv	s2,a0
    if(fd < 0){
    3362:	e40547e3          	bltz	a0,31b0 <diskfull+0x56>
    3366:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    3368:	40000613          	li	a2,1024
    336c:	bb040593          	addi	a1,s0,-1104
    3370:	854a                	mv	a0,s2
    3372:	00002097          	auipc	ra,0x2
    3376:	756080e7          	jalr	1878(ra) # 5ac8 <write>
    337a:	40000793          	li	a5,1024
    337e:	e4f515e3          	bne	a0,a5,31c8 <diskfull+0x6e>
    for(int i = 0; i < MAXFILE; i++){
    3382:	34fd                	addiw	s1,s1,-1
    3384:	f0f5                	bnez	s1,3368 <diskfull+0x20e>
    3386:	bf69                	j	3320 <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    3388:	00004517          	auipc	a0,0x4
    338c:	ec850513          	addi	a0,a0,-312 # 7250 <malloc+0x135a>
    3390:	00003097          	auipc	ra,0x3
    3394:	aa8080e7          	jalr	-1368(ra) # 5e38 <printf>
    3398:	b5c9                	j	325a <diskfull+0x100>

000000000000339a <iputtest>:
{
    339a:	1101                	addi	sp,sp,-32
    339c:	ec06                	sd	ra,24(sp)
    339e:	e822                	sd	s0,16(sp)
    33a0:	e426                	sd	s1,8(sp)
    33a2:	1000                	addi	s0,sp,32
    33a4:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    33a6:	00004517          	auipc	a0,0x4
    33aa:	eda50513          	addi	a0,a0,-294 # 7280 <malloc+0x138a>
    33ae:	00002097          	auipc	ra,0x2
    33b2:	762080e7          	jalr	1890(ra) # 5b10 <mkdir>
    33b6:	04054563          	bltz	a0,3400 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    33ba:	00004517          	auipc	a0,0x4
    33be:	ec650513          	addi	a0,a0,-314 # 7280 <malloc+0x138a>
    33c2:	00002097          	auipc	ra,0x2
    33c6:	756080e7          	jalr	1878(ra) # 5b18 <chdir>
    33ca:	04054963          	bltz	a0,341c <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    33ce:	00004517          	auipc	a0,0x4
    33d2:	ef250513          	addi	a0,a0,-270 # 72c0 <malloc+0x13ca>
    33d6:	00002097          	auipc	ra,0x2
    33da:	722080e7          	jalr	1826(ra) # 5af8 <unlink>
    33de:	04054d63          	bltz	a0,3438 <iputtest+0x9e>
  if(chdir("/") < 0){
    33e2:	00004517          	auipc	a0,0x4
    33e6:	f0e50513          	addi	a0,a0,-242 # 72f0 <malloc+0x13fa>
    33ea:	00002097          	auipc	ra,0x2
    33ee:	72e080e7          	jalr	1838(ra) # 5b18 <chdir>
    33f2:	06054163          	bltz	a0,3454 <iputtest+0xba>
}
    33f6:	60e2                	ld	ra,24(sp)
    33f8:	6442                	ld	s0,16(sp)
    33fa:	64a2                	ld	s1,8(sp)
    33fc:	6105                	addi	sp,sp,32
    33fe:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3400:	85a6                	mv	a1,s1
    3402:	00004517          	auipc	a0,0x4
    3406:	e8650513          	addi	a0,a0,-378 # 7288 <malloc+0x1392>
    340a:	00003097          	auipc	ra,0x3
    340e:	a2e080e7          	jalr	-1490(ra) # 5e38 <printf>
    exit(1);
    3412:	4505                	li	a0,1
    3414:	00002097          	auipc	ra,0x2
    3418:	694080e7          	jalr	1684(ra) # 5aa8 <exit>
    printf("%s: chdir iputdir failed\n", s);
    341c:	85a6                	mv	a1,s1
    341e:	00004517          	auipc	a0,0x4
    3422:	e8250513          	addi	a0,a0,-382 # 72a0 <malloc+0x13aa>
    3426:	00003097          	auipc	ra,0x3
    342a:	a12080e7          	jalr	-1518(ra) # 5e38 <printf>
    exit(1);
    342e:	4505                	li	a0,1
    3430:	00002097          	auipc	ra,0x2
    3434:	678080e7          	jalr	1656(ra) # 5aa8 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    3438:	85a6                	mv	a1,s1
    343a:	00004517          	auipc	a0,0x4
    343e:	e9650513          	addi	a0,a0,-362 # 72d0 <malloc+0x13da>
    3442:	00003097          	auipc	ra,0x3
    3446:	9f6080e7          	jalr	-1546(ra) # 5e38 <printf>
    exit(1);
    344a:	4505                	li	a0,1
    344c:	00002097          	auipc	ra,0x2
    3450:	65c080e7          	jalr	1628(ra) # 5aa8 <exit>
    printf("%s: chdir / failed\n", s);
    3454:	85a6                	mv	a1,s1
    3456:	00004517          	auipc	a0,0x4
    345a:	ea250513          	addi	a0,a0,-350 # 72f8 <malloc+0x1402>
    345e:	00003097          	auipc	ra,0x3
    3462:	9da080e7          	jalr	-1574(ra) # 5e38 <printf>
    exit(1);
    3466:	4505                	li	a0,1
    3468:	00002097          	auipc	ra,0x2
    346c:	640080e7          	jalr	1600(ra) # 5aa8 <exit>

0000000000003470 <exitiputtest>:
{
    3470:	7179                	addi	sp,sp,-48
    3472:	f406                	sd	ra,40(sp)
    3474:	f022                	sd	s0,32(sp)
    3476:	ec26                	sd	s1,24(sp)
    3478:	1800                	addi	s0,sp,48
    347a:	84aa                	mv	s1,a0
  pid = fork();
    347c:	00002097          	auipc	ra,0x2
    3480:	624080e7          	jalr	1572(ra) # 5aa0 <fork>
  if(pid < 0){
    3484:	04054663          	bltz	a0,34d0 <exitiputtest+0x60>
  if(pid == 0){
    3488:	ed45                	bnez	a0,3540 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    348a:	00004517          	auipc	a0,0x4
    348e:	df650513          	addi	a0,a0,-522 # 7280 <malloc+0x138a>
    3492:	00002097          	auipc	ra,0x2
    3496:	67e080e7          	jalr	1662(ra) # 5b10 <mkdir>
    349a:	04054963          	bltz	a0,34ec <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    349e:	00004517          	auipc	a0,0x4
    34a2:	de250513          	addi	a0,a0,-542 # 7280 <malloc+0x138a>
    34a6:	00002097          	auipc	ra,0x2
    34aa:	672080e7          	jalr	1650(ra) # 5b18 <chdir>
    34ae:	04054d63          	bltz	a0,3508 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    34b2:	00004517          	auipc	a0,0x4
    34b6:	e0e50513          	addi	a0,a0,-498 # 72c0 <malloc+0x13ca>
    34ba:	00002097          	auipc	ra,0x2
    34be:	63e080e7          	jalr	1598(ra) # 5af8 <unlink>
    34c2:	06054163          	bltz	a0,3524 <exitiputtest+0xb4>
    exit(0);
    34c6:	4501                	li	a0,0
    34c8:	00002097          	auipc	ra,0x2
    34cc:	5e0080e7          	jalr	1504(ra) # 5aa8 <exit>
    printf("%s: fork failed\n", s);
    34d0:	85a6                	mv	a1,s1
    34d2:	00003517          	auipc	a0,0x3
    34d6:	3ee50513          	addi	a0,a0,1006 # 68c0 <malloc+0x9ca>
    34da:	00003097          	auipc	ra,0x3
    34de:	95e080e7          	jalr	-1698(ra) # 5e38 <printf>
    exit(1);
    34e2:	4505                	li	a0,1
    34e4:	00002097          	auipc	ra,0x2
    34e8:	5c4080e7          	jalr	1476(ra) # 5aa8 <exit>
      printf("%s: mkdir failed\n", s);
    34ec:	85a6                	mv	a1,s1
    34ee:	00004517          	auipc	a0,0x4
    34f2:	d9a50513          	addi	a0,a0,-614 # 7288 <malloc+0x1392>
    34f6:	00003097          	auipc	ra,0x3
    34fa:	942080e7          	jalr	-1726(ra) # 5e38 <printf>
      exit(1);
    34fe:	4505                	li	a0,1
    3500:	00002097          	auipc	ra,0x2
    3504:	5a8080e7          	jalr	1448(ra) # 5aa8 <exit>
      printf("%s: child chdir failed\n", s);
    3508:	85a6                	mv	a1,s1
    350a:	00004517          	auipc	a0,0x4
    350e:	e0650513          	addi	a0,a0,-506 # 7310 <malloc+0x141a>
    3512:	00003097          	auipc	ra,0x3
    3516:	926080e7          	jalr	-1754(ra) # 5e38 <printf>
      exit(1);
    351a:	4505                	li	a0,1
    351c:	00002097          	auipc	ra,0x2
    3520:	58c080e7          	jalr	1420(ra) # 5aa8 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    3524:	85a6                	mv	a1,s1
    3526:	00004517          	auipc	a0,0x4
    352a:	daa50513          	addi	a0,a0,-598 # 72d0 <malloc+0x13da>
    352e:	00003097          	auipc	ra,0x3
    3532:	90a080e7          	jalr	-1782(ra) # 5e38 <printf>
      exit(1);
    3536:	4505                	li	a0,1
    3538:	00002097          	auipc	ra,0x2
    353c:	570080e7          	jalr	1392(ra) # 5aa8 <exit>
  wait(&xstatus);
    3540:	fdc40513          	addi	a0,s0,-36
    3544:	00002097          	auipc	ra,0x2
    3548:	56c080e7          	jalr	1388(ra) # 5ab0 <wait>
  exit(xstatus);
    354c:	fdc42503          	lw	a0,-36(s0)
    3550:	00002097          	auipc	ra,0x2
    3554:	558080e7          	jalr	1368(ra) # 5aa8 <exit>

0000000000003558 <dirtest>:
{
    3558:	1101                	addi	sp,sp,-32
    355a:	ec06                	sd	ra,24(sp)
    355c:	e822                	sd	s0,16(sp)
    355e:	e426                	sd	s1,8(sp)
    3560:	1000                	addi	s0,sp,32
    3562:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    3564:	00004517          	auipc	a0,0x4
    3568:	dc450513          	addi	a0,a0,-572 # 7328 <malloc+0x1432>
    356c:	00002097          	auipc	ra,0x2
    3570:	5a4080e7          	jalr	1444(ra) # 5b10 <mkdir>
    3574:	04054563          	bltz	a0,35be <dirtest+0x66>
  if(chdir("dir0") < 0){
    3578:	00004517          	auipc	a0,0x4
    357c:	db050513          	addi	a0,a0,-592 # 7328 <malloc+0x1432>
    3580:	00002097          	auipc	ra,0x2
    3584:	598080e7          	jalr	1432(ra) # 5b18 <chdir>
    3588:	04054963          	bltz	a0,35da <dirtest+0x82>
  if(chdir("..") < 0){
    358c:	00004517          	auipc	a0,0x4
    3590:	dbc50513          	addi	a0,a0,-580 # 7348 <malloc+0x1452>
    3594:	00002097          	auipc	ra,0x2
    3598:	584080e7          	jalr	1412(ra) # 5b18 <chdir>
    359c:	04054d63          	bltz	a0,35f6 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    35a0:	00004517          	auipc	a0,0x4
    35a4:	d8850513          	addi	a0,a0,-632 # 7328 <malloc+0x1432>
    35a8:	00002097          	auipc	ra,0x2
    35ac:	550080e7          	jalr	1360(ra) # 5af8 <unlink>
    35b0:	06054163          	bltz	a0,3612 <dirtest+0xba>
}
    35b4:	60e2                	ld	ra,24(sp)
    35b6:	6442                	ld	s0,16(sp)
    35b8:	64a2                	ld	s1,8(sp)
    35ba:	6105                	addi	sp,sp,32
    35bc:	8082                	ret
    printf("%s: mkdir failed\n", s);
    35be:	85a6                	mv	a1,s1
    35c0:	00004517          	auipc	a0,0x4
    35c4:	cc850513          	addi	a0,a0,-824 # 7288 <malloc+0x1392>
    35c8:	00003097          	auipc	ra,0x3
    35cc:	870080e7          	jalr	-1936(ra) # 5e38 <printf>
    exit(1);
    35d0:	4505                	li	a0,1
    35d2:	00002097          	auipc	ra,0x2
    35d6:	4d6080e7          	jalr	1238(ra) # 5aa8 <exit>
    printf("%s: chdir dir0 failed\n", s);
    35da:	85a6                	mv	a1,s1
    35dc:	00004517          	auipc	a0,0x4
    35e0:	d5450513          	addi	a0,a0,-684 # 7330 <malloc+0x143a>
    35e4:	00003097          	auipc	ra,0x3
    35e8:	854080e7          	jalr	-1964(ra) # 5e38 <printf>
    exit(1);
    35ec:	4505                	li	a0,1
    35ee:	00002097          	auipc	ra,0x2
    35f2:	4ba080e7          	jalr	1210(ra) # 5aa8 <exit>
    printf("%s: chdir .. failed\n", s);
    35f6:	85a6                	mv	a1,s1
    35f8:	00004517          	auipc	a0,0x4
    35fc:	d5850513          	addi	a0,a0,-680 # 7350 <malloc+0x145a>
    3600:	00003097          	auipc	ra,0x3
    3604:	838080e7          	jalr	-1992(ra) # 5e38 <printf>
    exit(1);
    3608:	4505                	li	a0,1
    360a:	00002097          	auipc	ra,0x2
    360e:	49e080e7          	jalr	1182(ra) # 5aa8 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3612:	85a6                	mv	a1,s1
    3614:	00004517          	auipc	a0,0x4
    3618:	d5450513          	addi	a0,a0,-684 # 7368 <malloc+0x1472>
    361c:	00003097          	auipc	ra,0x3
    3620:	81c080e7          	jalr	-2020(ra) # 5e38 <printf>
    exit(1);
    3624:	4505                	li	a0,1
    3626:	00002097          	auipc	ra,0x2
    362a:	482080e7          	jalr	1154(ra) # 5aa8 <exit>

000000000000362e <subdir>:
{
    362e:	1101                	addi	sp,sp,-32
    3630:	ec06                	sd	ra,24(sp)
    3632:	e822                	sd	s0,16(sp)
    3634:	e426                	sd	s1,8(sp)
    3636:	e04a                	sd	s2,0(sp)
    3638:	1000                	addi	s0,sp,32
    363a:	892a                	mv	s2,a0
  unlink("ff");
    363c:	00004517          	auipc	a0,0x4
    3640:	e7450513          	addi	a0,a0,-396 # 74b0 <malloc+0x15ba>
    3644:	00002097          	auipc	ra,0x2
    3648:	4b4080e7          	jalr	1204(ra) # 5af8 <unlink>
  if(mkdir("dd") != 0){
    364c:	00004517          	auipc	a0,0x4
    3650:	d3450513          	addi	a0,a0,-716 # 7380 <malloc+0x148a>
    3654:	00002097          	auipc	ra,0x2
    3658:	4bc080e7          	jalr	1212(ra) # 5b10 <mkdir>
    365c:	38051663          	bnez	a0,39e8 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    3660:	20200593          	li	a1,514
    3664:	00004517          	auipc	a0,0x4
    3668:	d3c50513          	addi	a0,a0,-708 # 73a0 <malloc+0x14aa>
    366c:	00002097          	auipc	ra,0x2
    3670:	47c080e7          	jalr	1148(ra) # 5ae8 <open>
    3674:	84aa                	mv	s1,a0
  if(fd < 0){
    3676:	38054763          	bltz	a0,3a04 <subdir+0x3d6>
  write(fd, "ff", 2);
    367a:	4609                	li	a2,2
    367c:	00004597          	auipc	a1,0x4
    3680:	e3458593          	addi	a1,a1,-460 # 74b0 <malloc+0x15ba>
    3684:	00002097          	auipc	ra,0x2
    3688:	444080e7          	jalr	1092(ra) # 5ac8 <write>
  close(fd);
    368c:	8526                	mv	a0,s1
    368e:	00002097          	auipc	ra,0x2
    3692:	442080e7          	jalr	1090(ra) # 5ad0 <close>
  if(unlink("dd") >= 0){
    3696:	00004517          	auipc	a0,0x4
    369a:	cea50513          	addi	a0,a0,-790 # 7380 <malloc+0x148a>
    369e:	00002097          	auipc	ra,0x2
    36a2:	45a080e7          	jalr	1114(ra) # 5af8 <unlink>
    36a6:	36055d63          	bgez	a0,3a20 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    36aa:	00004517          	auipc	a0,0x4
    36ae:	d4e50513          	addi	a0,a0,-690 # 73f8 <malloc+0x1502>
    36b2:	00002097          	auipc	ra,0x2
    36b6:	45e080e7          	jalr	1118(ra) # 5b10 <mkdir>
    36ba:	38051163          	bnez	a0,3a3c <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    36be:	20200593          	li	a1,514
    36c2:	00004517          	auipc	a0,0x4
    36c6:	d5e50513          	addi	a0,a0,-674 # 7420 <malloc+0x152a>
    36ca:	00002097          	auipc	ra,0x2
    36ce:	41e080e7          	jalr	1054(ra) # 5ae8 <open>
    36d2:	84aa                	mv	s1,a0
  if(fd < 0){
    36d4:	38054263          	bltz	a0,3a58 <subdir+0x42a>
  write(fd, "FF", 2);
    36d8:	4609                	li	a2,2
    36da:	00004597          	auipc	a1,0x4
    36de:	d7658593          	addi	a1,a1,-650 # 7450 <malloc+0x155a>
    36e2:	00002097          	auipc	ra,0x2
    36e6:	3e6080e7          	jalr	998(ra) # 5ac8 <write>
  close(fd);
    36ea:	8526                	mv	a0,s1
    36ec:	00002097          	auipc	ra,0x2
    36f0:	3e4080e7          	jalr	996(ra) # 5ad0 <close>
  fd = open("dd/dd/../ff", 0);
    36f4:	4581                	li	a1,0
    36f6:	00004517          	auipc	a0,0x4
    36fa:	d6250513          	addi	a0,a0,-670 # 7458 <malloc+0x1562>
    36fe:	00002097          	auipc	ra,0x2
    3702:	3ea080e7          	jalr	1002(ra) # 5ae8 <open>
    3706:	84aa                	mv	s1,a0
  if(fd < 0){
    3708:	36054663          	bltz	a0,3a74 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    370c:	660d                	lui	a2,0x3
    370e:	00009597          	auipc	a1,0x9
    3712:	54a58593          	addi	a1,a1,1354 # cc58 <buf>
    3716:	00002097          	auipc	ra,0x2
    371a:	3aa080e7          	jalr	938(ra) # 5ac0 <read>
  if(cc != 2 || buf[0] != 'f'){
    371e:	4789                	li	a5,2
    3720:	36f51863          	bne	a0,a5,3a90 <subdir+0x462>
    3724:	00009717          	auipc	a4,0x9
    3728:	53474703          	lbu	a4,1332(a4) # cc58 <buf>
    372c:	06600793          	li	a5,102
    3730:	36f71063          	bne	a4,a5,3a90 <subdir+0x462>
  close(fd);
    3734:	8526                	mv	a0,s1
    3736:	00002097          	auipc	ra,0x2
    373a:	39a080e7          	jalr	922(ra) # 5ad0 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    373e:	00004597          	auipc	a1,0x4
    3742:	d6a58593          	addi	a1,a1,-662 # 74a8 <malloc+0x15b2>
    3746:	00004517          	auipc	a0,0x4
    374a:	cda50513          	addi	a0,a0,-806 # 7420 <malloc+0x152a>
    374e:	00002097          	auipc	ra,0x2
    3752:	3ba080e7          	jalr	954(ra) # 5b08 <link>
    3756:	34051b63          	bnez	a0,3aac <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    375a:	00004517          	auipc	a0,0x4
    375e:	cc650513          	addi	a0,a0,-826 # 7420 <malloc+0x152a>
    3762:	00002097          	auipc	ra,0x2
    3766:	396080e7          	jalr	918(ra) # 5af8 <unlink>
    376a:	34051f63          	bnez	a0,3ac8 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    376e:	4581                	li	a1,0
    3770:	00004517          	auipc	a0,0x4
    3774:	cb050513          	addi	a0,a0,-848 # 7420 <malloc+0x152a>
    3778:	00002097          	auipc	ra,0x2
    377c:	370080e7          	jalr	880(ra) # 5ae8 <open>
    3780:	36055263          	bgez	a0,3ae4 <subdir+0x4b6>
  if(chdir("dd") != 0){
    3784:	00004517          	auipc	a0,0x4
    3788:	bfc50513          	addi	a0,a0,-1028 # 7380 <malloc+0x148a>
    378c:	00002097          	auipc	ra,0x2
    3790:	38c080e7          	jalr	908(ra) # 5b18 <chdir>
    3794:	36051663          	bnez	a0,3b00 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    3798:	00004517          	auipc	a0,0x4
    379c:	da850513          	addi	a0,a0,-600 # 7540 <malloc+0x164a>
    37a0:	00002097          	auipc	ra,0x2
    37a4:	378080e7          	jalr	888(ra) # 5b18 <chdir>
    37a8:	36051a63          	bnez	a0,3b1c <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    37ac:	00004517          	auipc	a0,0x4
    37b0:	dc450513          	addi	a0,a0,-572 # 7570 <malloc+0x167a>
    37b4:	00002097          	auipc	ra,0x2
    37b8:	364080e7          	jalr	868(ra) # 5b18 <chdir>
    37bc:	36051e63          	bnez	a0,3b38 <subdir+0x50a>
  if(chdir("./..") != 0){
    37c0:	00004517          	auipc	a0,0x4
    37c4:	de050513          	addi	a0,a0,-544 # 75a0 <malloc+0x16aa>
    37c8:	00002097          	auipc	ra,0x2
    37cc:	350080e7          	jalr	848(ra) # 5b18 <chdir>
    37d0:	38051263          	bnez	a0,3b54 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    37d4:	4581                	li	a1,0
    37d6:	00004517          	auipc	a0,0x4
    37da:	cd250513          	addi	a0,a0,-814 # 74a8 <malloc+0x15b2>
    37de:	00002097          	auipc	ra,0x2
    37e2:	30a080e7          	jalr	778(ra) # 5ae8 <open>
    37e6:	84aa                	mv	s1,a0
  if(fd < 0){
    37e8:	38054463          	bltz	a0,3b70 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    37ec:	660d                	lui	a2,0x3
    37ee:	00009597          	auipc	a1,0x9
    37f2:	46a58593          	addi	a1,a1,1130 # cc58 <buf>
    37f6:	00002097          	auipc	ra,0x2
    37fa:	2ca080e7          	jalr	714(ra) # 5ac0 <read>
    37fe:	4789                	li	a5,2
    3800:	38f51663          	bne	a0,a5,3b8c <subdir+0x55e>
  close(fd);
    3804:	8526                	mv	a0,s1
    3806:	00002097          	auipc	ra,0x2
    380a:	2ca080e7          	jalr	714(ra) # 5ad0 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    380e:	4581                	li	a1,0
    3810:	00004517          	auipc	a0,0x4
    3814:	c1050513          	addi	a0,a0,-1008 # 7420 <malloc+0x152a>
    3818:	00002097          	auipc	ra,0x2
    381c:	2d0080e7          	jalr	720(ra) # 5ae8 <open>
    3820:	38055463          	bgez	a0,3ba8 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3824:	20200593          	li	a1,514
    3828:	00004517          	auipc	a0,0x4
    382c:	e0850513          	addi	a0,a0,-504 # 7630 <malloc+0x173a>
    3830:	00002097          	auipc	ra,0x2
    3834:	2b8080e7          	jalr	696(ra) # 5ae8 <open>
    3838:	38055663          	bgez	a0,3bc4 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    383c:	20200593          	li	a1,514
    3840:	00004517          	auipc	a0,0x4
    3844:	e2050513          	addi	a0,a0,-480 # 7660 <malloc+0x176a>
    3848:	00002097          	auipc	ra,0x2
    384c:	2a0080e7          	jalr	672(ra) # 5ae8 <open>
    3850:	38055863          	bgez	a0,3be0 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3854:	20000593          	li	a1,512
    3858:	00004517          	auipc	a0,0x4
    385c:	b2850513          	addi	a0,a0,-1240 # 7380 <malloc+0x148a>
    3860:	00002097          	auipc	ra,0x2
    3864:	288080e7          	jalr	648(ra) # 5ae8 <open>
    3868:	38055a63          	bgez	a0,3bfc <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    386c:	4589                	li	a1,2
    386e:	00004517          	auipc	a0,0x4
    3872:	b1250513          	addi	a0,a0,-1262 # 7380 <malloc+0x148a>
    3876:	00002097          	auipc	ra,0x2
    387a:	272080e7          	jalr	626(ra) # 5ae8 <open>
    387e:	38055d63          	bgez	a0,3c18 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3882:	4585                	li	a1,1
    3884:	00004517          	auipc	a0,0x4
    3888:	afc50513          	addi	a0,a0,-1284 # 7380 <malloc+0x148a>
    388c:	00002097          	auipc	ra,0x2
    3890:	25c080e7          	jalr	604(ra) # 5ae8 <open>
    3894:	3a055063          	bgez	a0,3c34 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3898:	00004597          	auipc	a1,0x4
    389c:	e5858593          	addi	a1,a1,-424 # 76f0 <malloc+0x17fa>
    38a0:	00004517          	auipc	a0,0x4
    38a4:	d9050513          	addi	a0,a0,-624 # 7630 <malloc+0x173a>
    38a8:	00002097          	auipc	ra,0x2
    38ac:	260080e7          	jalr	608(ra) # 5b08 <link>
    38b0:	3a050063          	beqz	a0,3c50 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    38b4:	00004597          	auipc	a1,0x4
    38b8:	e3c58593          	addi	a1,a1,-452 # 76f0 <malloc+0x17fa>
    38bc:	00004517          	auipc	a0,0x4
    38c0:	da450513          	addi	a0,a0,-604 # 7660 <malloc+0x176a>
    38c4:	00002097          	auipc	ra,0x2
    38c8:	244080e7          	jalr	580(ra) # 5b08 <link>
    38cc:	3a050063          	beqz	a0,3c6c <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    38d0:	00004597          	auipc	a1,0x4
    38d4:	bd858593          	addi	a1,a1,-1064 # 74a8 <malloc+0x15b2>
    38d8:	00004517          	auipc	a0,0x4
    38dc:	ac850513          	addi	a0,a0,-1336 # 73a0 <malloc+0x14aa>
    38e0:	00002097          	auipc	ra,0x2
    38e4:	228080e7          	jalr	552(ra) # 5b08 <link>
    38e8:	3a050063          	beqz	a0,3c88 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    38ec:	00004517          	auipc	a0,0x4
    38f0:	d4450513          	addi	a0,a0,-700 # 7630 <malloc+0x173a>
    38f4:	00002097          	auipc	ra,0x2
    38f8:	21c080e7          	jalr	540(ra) # 5b10 <mkdir>
    38fc:	3a050463          	beqz	a0,3ca4 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3900:	00004517          	auipc	a0,0x4
    3904:	d6050513          	addi	a0,a0,-672 # 7660 <malloc+0x176a>
    3908:	00002097          	auipc	ra,0x2
    390c:	208080e7          	jalr	520(ra) # 5b10 <mkdir>
    3910:	3a050863          	beqz	a0,3cc0 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3914:	00004517          	auipc	a0,0x4
    3918:	b9450513          	addi	a0,a0,-1132 # 74a8 <malloc+0x15b2>
    391c:	00002097          	auipc	ra,0x2
    3920:	1f4080e7          	jalr	500(ra) # 5b10 <mkdir>
    3924:	3a050c63          	beqz	a0,3cdc <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3928:	00004517          	auipc	a0,0x4
    392c:	d3850513          	addi	a0,a0,-712 # 7660 <malloc+0x176a>
    3930:	00002097          	auipc	ra,0x2
    3934:	1c8080e7          	jalr	456(ra) # 5af8 <unlink>
    3938:	3c050063          	beqz	a0,3cf8 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    393c:	00004517          	auipc	a0,0x4
    3940:	cf450513          	addi	a0,a0,-780 # 7630 <malloc+0x173a>
    3944:	00002097          	auipc	ra,0x2
    3948:	1b4080e7          	jalr	436(ra) # 5af8 <unlink>
    394c:	3c050463          	beqz	a0,3d14 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3950:	00004517          	auipc	a0,0x4
    3954:	a5050513          	addi	a0,a0,-1456 # 73a0 <malloc+0x14aa>
    3958:	00002097          	auipc	ra,0x2
    395c:	1c0080e7          	jalr	448(ra) # 5b18 <chdir>
    3960:	3c050863          	beqz	a0,3d30 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3964:	00004517          	auipc	a0,0x4
    3968:	edc50513          	addi	a0,a0,-292 # 7840 <malloc+0x194a>
    396c:	00002097          	auipc	ra,0x2
    3970:	1ac080e7          	jalr	428(ra) # 5b18 <chdir>
    3974:	3c050c63          	beqz	a0,3d4c <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3978:	00004517          	auipc	a0,0x4
    397c:	b3050513          	addi	a0,a0,-1232 # 74a8 <malloc+0x15b2>
    3980:	00002097          	auipc	ra,0x2
    3984:	178080e7          	jalr	376(ra) # 5af8 <unlink>
    3988:	3e051063          	bnez	a0,3d68 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    398c:	00004517          	auipc	a0,0x4
    3990:	a1450513          	addi	a0,a0,-1516 # 73a0 <malloc+0x14aa>
    3994:	00002097          	auipc	ra,0x2
    3998:	164080e7          	jalr	356(ra) # 5af8 <unlink>
    399c:	3e051463          	bnez	a0,3d84 <subdir+0x756>
  if(unlink("dd") == 0){
    39a0:	00004517          	auipc	a0,0x4
    39a4:	9e050513          	addi	a0,a0,-1568 # 7380 <malloc+0x148a>
    39a8:	00002097          	auipc	ra,0x2
    39ac:	150080e7          	jalr	336(ra) # 5af8 <unlink>
    39b0:	3e050863          	beqz	a0,3da0 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    39b4:	00004517          	auipc	a0,0x4
    39b8:	efc50513          	addi	a0,a0,-260 # 78b0 <malloc+0x19ba>
    39bc:	00002097          	auipc	ra,0x2
    39c0:	13c080e7          	jalr	316(ra) # 5af8 <unlink>
    39c4:	3e054c63          	bltz	a0,3dbc <subdir+0x78e>
  if(unlink("dd") < 0){
    39c8:	00004517          	auipc	a0,0x4
    39cc:	9b850513          	addi	a0,a0,-1608 # 7380 <malloc+0x148a>
    39d0:	00002097          	auipc	ra,0x2
    39d4:	128080e7          	jalr	296(ra) # 5af8 <unlink>
    39d8:	40054063          	bltz	a0,3dd8 <subdir+0x7aa>
}
    39dc:	60e2                	ld	ra,24(sp)
    39de:	6442                	ld	s0,16(sp)
    39e0:	64a2                	ld	s1,8(sp)
    39e2:	6902                	ld	s2,0(sp)
    39e4:	6105                	addi	sp,sp,32
    39e6:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    39e8:	85ca                	mv	a1,s2
    39ea:	00004517          	auipc	a0,0x4
    39ee:	99e50513          	addi	a0,a0,-1634 # 7388 <malloc+0x1492>
    39f2:	00002097          	auipc	ra,0x2
    39f6:	446080e7          	jalr	1094(ra) # 5e38 <printf>
    exit(1);
    39fa:	4505                	li	a0,1
    39fc:	00002097          	auipc	ra,0x2
    3a00:	0ac080e7          	jalr	172(ra) # 5aa8 <exit>
    printf("%s: create dd/ff failed\n", s);
    3a04:	85ca                	mv	a1,s2
    3a06:	00004517          	auipc	a0,0x4
    3a0a:	9a250513          	addi	a0,a0,-1630 # 73a8 <malloc+0x14b2>
    3a0e:	00002097          	auipc	ra,0x2
    3a12:	42a080e7          	jalr	1066(ra) # 5e38 <printf>
    exit(1);
    3a16:	4505                	li	a0,1
    3a18:	00002097          	auipc	ra,0x2
    3a1c:	090080e7          	jalr	144(ra) # 5aa8 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3a20:	85ca                	mv	a1,s2
    3a22:	00004517          	auipc	a0,0x4
    3a26:	9a650513          	addi	a0,a0,-1626 # 73c8 <malloc+0x14d2>
    3a2a:	00002097          	auipc	ra,0x2
    3a2e:	40e080e7          	jalr	1038(ra) # 5e38 <printf>
    exit(1);
    3a32:	4505                	li	a0,1
    3a34:	00002097          	auipc	ra,0x2
    3a38:	074080e7          	jalr	116(ra) # 5aa8 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3a3c:	85ca                	mv	a1,s2
    3a3e:	00004517          	auipc	a0,0x4
    3a42:	9c250513          	addi	a0,a0,-1598 # 7400 <malloc+0x150a>
    3a46:	00002097          	auipc	ra,0x2
    3a4a:	3f2080e7          	jalr	1010(ra) # 5e38 <printf>
    exit(1);
    3a4e:	4505                	li	a0,1
    3a50:	00002097          	auipc	ra,0x2
    3a54:	058080e7          	jalr	88(ra) # 5aa8 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3a58:	85ca                	mv	a1,s2
    3a5a:	00004517          	auipc	a0,0x4
    3a5e:	9d650513          	addi	a0,a0,-1578 # 7430 <malloc+0x153a>
    3a62:	00002097          	auipc	ra,0x2
    3a66:	3d6080e7          	jalr	982(ra) # 5e38 <printf>
    exit(1);
    3a6a:	4505                	li	a0,1
    3a6c:	00002097          	auipc	ra,0x2
    3a70:	03c080e7          	jalr	60(ra) # 5aa8 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3a74:	85ca                	mv	a1,s2
    3a76:	00004517          	auipc	a0,0x4
    3a7a:	9f250513          	addi	a0,a0,-1550 # 7468 <malloc+0x1572>
    3a7e:	00002097          	auipc	ra,0x2
    3a82:	3ba080e7          	jalr	954(ra) # 5e38 <printf>
    exit(1);
    3a86:	4505                	li	a0,1
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	020080e7          	jalr	32(ra) # 5aa8 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3a90:	85ca                	mv	a1,s2
    3a92:	00004517          	auipc	a0,0x4
    3a96:	9f650513          	addi	a0,a0,-1546 # 7488 <malloc+0x1592>
    3a9a:	00002097          	auipc	ra,0x2
    3a9e:	39e080e7          	jalr	926(ra) # 5e38 <printf>
    exit(1);
    3aa2:	4505                	li	a0,1
    3aa4:	00002097          	auipc	ra,0x2
    3aa8:	004080e7          	jalr	4(ra) # 5aa8 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3aac:	85ca                	mv	a1,s2
    3aae:	00004517          	auipc	a0,0x4
    3ab2:	a0a50513          	addi	a0,a0,-1526 # 74b8 <malloc+0x15c2>
    3ab6:	00002097          	auipc	ra,0x2
    3aba:	382080e7          	jalr	898(ra) # 5e38 <printf>
    exit(1);
    3abe:	4505                	li	a0,1
    3ac0:	00002097          	auipc	ra,0x2
    3ac4:	fe8080e7          	jalr	-24(ra) # 5aa8 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3ac8:	85ca                	mv	a1,s2
    3aca:	00004517          	auipc	a0,0x4
    3ace:	a1650513          	addi	a0,a0,-1514 # 74e0 <malloc+0x15ea>
    3ad2:	00002097          	auipc	ra,0x2
    3ad6:	366080e7          	jalr	870(ra) # 5e38 <printf>
    exit(1);
    3ada:	4505                	li	a0,1
    3adc:	00002097          	auipc	ra,0x2
    3ae0:	fcc080e7          	jalr	-52(ra) # 5aa8 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3ae4:	85ca                	mv	a1,s2
    3ae6:	00004517          	auipc	a0,0x4
    3aea:	a1a50513          	addi	a0,a0,-1510 # 7500 <malloc+0x160a>
    3aee:	00002097          	auipc	ra,0x2
    3af2:	34a080e7          	jalr	842(ra) # 5e38 <printf>
    exit(1);
    3af6:	4505                	li	a0,1
    3af8:	00002097          	auipc	ra,0x2
    3afc:	fb0080e7          	jalr	-80(ra) # 5aa8 <exit>
    printf("%s: chdir dd failed\n", s);
    3b00:	85ca                	mv	a1,s2
    3b02:	00004517          	auipc	a0,0x4
    3b06:	a2650513          	addi	a0,a0,-1498 # 7528 <malloc+0x1632>
    3b0a:	00002097          	auipc	ra,0x2
    3b0e:	32e080e7          	jalr	814(ra) # 5e38 <printf>
    exit(1);
    3b12:	4505                	li	a0,1
    3b14:	00002097          	auipc	ra,0x2
    3b18:	f94080e7          	jalr	-108(ra) # 5aa8 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3b1c:	85ca                	mv	a1,s2
    3b1e:	00004517          	auipc	a0,0x4
    3b22:	a3250513          	addi	a0,a0,-1486 # 7550 <malloc+0x165a>
    3b26:	00002097          	auipc	ra,0x2
    3b2a:	312080e7          	jalr	786(ra) # 5e38 <printf>
    exit(1);
    3b2e:	4505                	li	a0,1
    3b30:	00002097          	auipc	ra,0x2
    3b34:	f78080e7          	jalr	-136(ra) # 5aa8 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3b38:	85ca                	mv	a1,s2
    3b3a:	00004517          	auipc	a0,0x4
    3b3e:	a4650513          	addi	a0,a0,-1466 # 7580 <malloc+0x168a>
    3b42:	00002097          	auipc	ra,0x2
    3b46:	2f6080e7          	jalr	758(ra) # 5e38 <printf>
    exit(1);
    3b4a:	4505                	li	a0,1
    3b4c:	00002097          	auipc	ra,0x2
    3b50:	f5c080e7          	jalr	-164(ra) # 5aa8 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3b54:	85ca                	mv	a1,s2
    3b56:	00004517          	auipc	a0,0x4
    3b5a:	a5250513          	addi	a0,a0,-1454 # 75a8 <malloc+0x16b2>
    3b5e:	00002097          	auipc	ra,0x2
    3b62:	2da080e7          	jalr	730(ra) # 5e38 <printf>
    exit(1);
    3b66:	4505                	li	a0,1
    3b68:	00002097          	auipc	ra,0x2
    3b6c:	f40080e7          	jalr	-192(ra) # 5aa8 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3b70:	85ca                	mv	a1,s2
    3b72:	00004517          	auipc	a0,0x4
    3b76:	a4e50513          	addi	a0,a0,-1458 # 75c0 <malloc+0x16ca>
    3b7a:	00002097          	auipc	ra,0x2
    3b7e:	2be080e7          	jalr	702(ra) # 5e38 <printf>
    exit(1);
    3b82:	4505                	li	a0,1
    3b84:	00002097          	auipc	ra,0x2
    3b88:	f24080e7          	jalr	-220(ra) # 5aa8 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3b8c:	85ca                	mv	a1,s2
    3b8e:	00004517          	auipc	a0,0x4
    3b92:	a5250513          	addi	a0,a0,-1454 # 75e0 <malloc+0x16ea>
    3b96:	00002097          	auipc	ra,0x2
    3b9a:	2a2080e7          	jalr	674(ra) # 5e38 <printf>
    exit(1);
    3b9e:	4505                	li	a0,1
    3ba0:	00002097          	auipc	ra,0x2
    3ba4:	f08080e7          	jalr	-248(ra) # 5aa8 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3ba8:	85ca                	mv	a1,s2
    3baa:	00004517          	auipc	a0,0x4
    3bae:	a5650513          	addi	a0,a0,-1450 # 7600 <malloc+0x170a>
    3bb2:	00002097          	auipc	ra,0x2
    3bb6:	286080e7          	jalr	646(ra) # 5e38 <printf>
    exit(1);
    3bba:	4505                	li	a0,1
    3bbc:	00002097          	auipc	ra,0x2
    3bc0:	eec080e7          	jalr	-276(ra) # 5aa8 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3bc4:	85ca                	mv	a1,s2
    3bc6:	00004517          	auipc	a0,0x4
    3bca:	a7a50513          	addi	a0,a0,-1414 # 7640 <malloc+0x174a>
    3bce:	00002097          	auipc	ra,0x2
    3bd2:	26a080e7          	jalr	618(ra) # 5e38 <printf>
    exit(1);
    3bd6:	4505                	li	a0,1
    3bd8:	00002097          	auipc	ra,0x2
    3bdc:	ed0080e7          	jalr	-304(ra) # 5aa8 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3be0:	85ca                	mv	a1,s2
    3be2:	00004517          	auipc	a0,0x4
    3be6:	a8e50513          	addi	a0,a0,-1394 # 7670 <malloc+0x177a>
    3bea:	00002097          	auipc	ra,0x2
    3bee:	24e080e7          	jalr	590(ra) # 5e38 <printf>
    exit(1);
    3bf2:	4505                	li	a0,1
    3bf4:	00002097          	auipc	ra,0x2
    3bf8:	eb4080e7          	jalr	-332(ra) # 5aa8 <exit>
    printf("%s: create dd succeeded!\n", s);
    3bfc:	85ca                	mv	a1,s2
    3bfe:	00004517          	auipc	a0,0x4
    3c02:	a9250513          	addi	a0,a0,-1390 # 7690 <malloc+0x179a>
    3c06:	00002097          	auipc	ra,0x2
    3c0a:	232080e7          	jalr	562(ra) # 5e38 <printf>
    exit(1);
    3c0e:	4505                	li	a0,1
    3c10:	00002097          	auipc	ra,0x2
    3c14:	e98080e7          	jalr	-360(ra) # 5aa8 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3c18:	85ca                	mv	a1,s2
    3c1a:	00004517          	auipc	a0,0x4
    3c1e:	a9650513          	addi	a0,a0,-1386 # 76b0 <malloc+0x17ba>
    3c22:	00002097          	auipc	ra,0x2
    3c26:	216080e7          	jalr	534(ra) # 5e38 <printf>
    exit(1);
    3c2a:	4505                	li	a0,1
    3c2c:	00002097          	auipc	ra,0x2
    3c30:	e7c080e7          	jalr	-388(ra) # 5aa8 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3c34:	85ca                	mv	a1,s2
    3c36:	00004517          	auipc	a0,0x4
    3c3a:	a9a50513          	addi	a0,a0,-1382 # 76d0 <malloc+0x17da>
    3c3e:	00002097          	auipc	ra,0x2
    3c42:	1fa080e7          	jalr	506(ra) # 5e38 <printf>
    exit(1);
    3c46:	4505                	li	a0,1
    3c48:	00002097          	auipc	ra,0x2
    3c4c:	e60080e7          	jalr	-416(ra) # 5aa8 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3c50:	85ca                	mv	a1,s2
    3c52:	00004517          	auipc	a0,0x4
    3c56:	aae50513          	addi	a0,a0,-1362 # 7700 <malloc+0x180a>
    3c5a:	00002097          	auipc	ra,0x2
    3c5e:	1de080e7          	jalr	478(ra) # 5e38 <printf>
    exit(1);
    3c62:	4505                	li	a0,1
    3c64:	00002097          	auipc	ra,0x2
    3c68:	e44080e7          	jalr	-444(ra) # 5aa8 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3c6c:	85ca                	mv	a1,s2
    3c6e:	00004517          	auipc	a0,0x4
    3c72:	aba50513          	addi	a0,a0,-1350 # 7728 <malloc+0x1832>
    3c76:	00002097          	auipc	ra,0x2
    3c7a:	1c2080e7          	jalr	450(ra) # 5e38 <printf>
    exit(1);
    3c7e:	4505                	li	a0,1
    3c80:	00002097          	auipc	ra,0x2
    3c84:	e28080e7          	jalr	-472(ra) # 5aa8 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3c88:	85ca                	mv	a1,s2
    3c8a:	00004517          	auipc	a0,0x4
    3c8e:	ac650513          	addi	a0,a0,-1338 # 7750 <malloc+0x185a>
    3c92:	00002097          	auipc	ra,0x2
    3c96:	1a6080e7          	jalr	422(ra) # 5e38 <printf>
    exit(1);
    3c9a:	4505                	li	a0,1
    3c9c:	00002097          	auipc	ra,0x2
    3ca0:	e0c080e7          	jalr	-500(ra) # 5aa8 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3ca4:	85ca                	mv	a1,s2
    3ca6:	00004517          	auipc	a0,0x4
    3caa:	ad250513          	addi	a0,a0,-1326 # 7778 <malloc+0x1882>
    3cae:	00002097          	auipc	ra,0x2
    3cb2:	18a080e7          	jalr	394(ra) # 5e38 <printf>
    exit(1);
    3cb6:	4505                	li	a0,1
    3cb8:	00002097          	auipc	ra,0x2
    3cbc:	df0080e7          	jalr	-528(ra) # 5aa8 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3cc0:	85ca                	mv	a1,s2
    3cc2:	00004517          	auipc	a0,0x4
    3cc6:	ad650513          	addi	a0,a0,-1322 # 7798 <malloc+0x18a2>
    3cca:	00002097          	auipc	ra,0x2
    3cce:	16e080e7          	jalr	366(ra) # 5e38 <printf>
    exit(1);
    3cd2:	4505                	li	a0,1
    3cd4:	00002097          	auipc	ra,0x2
    3cd8:	dd4080e7          	jalr	-556(ra) # 5aa8 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3cdc:	85ca                	mv	a1,s2
    3cde:	00004517          	auipc	a0,0x4
    3ce2:	ada50513          	addi	a0,a0,-1318 # 77b8 <malloc+0x18c2>
    3ce6:	00002097          	auipc	ra,0x2
    3cea:	152080e7          	jalr	338(ra) # 5e38 <printf>
    exit(1);
    3cee:	4505                	li	a0,1
    3cf0:	00002097          	auipc	ra,0x2
    3cf4:	db8080e7          	jalr	-584(ra) # 5aa8 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3cf8:	85ca                	mv	a1,s2
    3cfa:	00004517          	auipc	a0,0x4
    3cfe:	ae650513          	addi	a0,a0,-1306 # 77e0 <malloc+0x18ea>
    3d02:	00002097          	auipc	ra,0x2
    3d06:	136080e7          	jalr	310(ra) # 5e38 <printf>
    exit(1);
    3d0a:	4505                	li	a0,1
    3d0c:	00002097          	auipc	ra,0x2
    3d10:	d9c080e7          	jalr	-612(ra) # 5aa8 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3d14:	85ca                	mv	a1,s2
    3d16:	00004517          	auipc	a0,0x4
    3d1a:	aea50513          	addi	a0,a0,-1302 # 7800 <malloc+0x190a>
    3d1e:	00002097          	auipc	ra,0x2
    3d22:	11a080e7          	jalr	282(ra) # 5e38 <printf>
    exit(1);
    3d26:	4505                	li	a0,1
    3d28:	00002097          	auipc	ra,0x2
    3d2c:	d80080e7          	jalr	-640(ra) # 5aa8 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3d30:	85ca                	mv	a1,s2
    3d32:	00004517          	auipc	a0,0x4
    3d36:	aee50513          	addi	a0,a0,-1298 # 7820 <malloc+0x192a>
    3d3a:	00002097          	auipc	ra,0x2
    3d3e:	0fe080e7          	jalr	254(ra) # 5e38 <printf>
    exit(1);
    3d42:	4505                	li	a0,1
    3d44:	00002097          	auipc	ra,0x2
    3d48:	d64080e7          	jalr	-668(ra) # 5aa8 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3d4c:	85ca                	mv	a1,s2
    3d4e:	00004517          	auipc	a0,0x4
    3d52:	afa50513          	addi	a0,a0,-1286 # 7848 <malloc+0x1952>
    3d56:	00002097          	auipc	ra,0x2
    3d5a:	0e2080e7          	jalr	226(ra) # 5e38 <printf>
    exit(1);
    3d5e:	4505                	li	a0,1
    3d60:	00002097          	auipc	ra,0x2
    3d64:	d48080e7          	jalr	-696(ra) # 5aa8 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3d68:	85ca                	mv	a1,s2
    3d6a:	00003517          	auipc	a0,0x3
    3d6e:	77650513          	addi	a0,a0,1910 # 74e0 <malloc+0x15ea>
    3d72:	00002097          	auipc	ra,0x2
    3d76:	0c6080e7          	jalr	198(ra) # 5e38 <printf>
    exit(1);
    3d7a:	4505                	li	a0,1
    3d7c:	00002097          	auipc	ra,0x2
    3d80:	d2c080e7          	jalr	-724(ra) # 5aa8 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3d84:	85ca                	mv	a1,s2
    3d86:	00004517          	auipc	a0,0x4
    3d8a:	ae250513          	addi	a0,a0,-1310 # 7868 <malloc+0x1972>
    3d8e:	00002097          	auipc	ra,0x2
    3d92:	0aa080e7          	jalr	170(ra) # 5e38 <printf>
    exit(1);
    3d96:	4505                	li	a0,1
    3d98:	00002097          	auipc	ra,0x2
    3d9c:	d10080e7          	jalr	-752(ra) # 5aa8 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3da0:	85ca                	mv	a1,s2
    3da2:	00004517          	auipc	a0,0x4
    3da6:	ae650513          	addi	a0,a0,-1306 # 7888 <malloc+0x1992>
    3daa:	00002097          	auipc	ra,0x2
    3dae:	08e080e7          	jalr	142(ra) # 5e38 <printf>
    exit(1);
    3db2:	4505                	li	a0,1
    3db4:	00002097          	auipc	ra,0x2
    3db8:	cf4080e7          	jalr	-780(ra) # 5aa8 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3dbc:	85ca                	mv	a1,s2
    3dbe:	00004517          	auipc	a0,0x4
    3dc2:	afa50513          	addi	a0,a0,-1286 # 78b8 <malloc+0x19c2>
    3dc6:	00002097          	auipc	ra,0x2
    3dca:	072080e7          	jalr	114(ra) # 5e38 <printf>
    exit(1);
    3dce:	4505                	li	a0,1
    3dd0:	00002097          	auipc	ra,0x2
    3dd4:	cd8080e7          	jalr	-808(ra) # 5aa8 <exit>
    printf("%s: unlink dd failed\n", s);
    3dd8:	85ca                	mv	a1,s2
    3dda:	00004517          	auipc	a0,0x4
    3dde:	afe50513          	addi	a0,a0,-1282 # 78d8 <malloc+0x19e2>
    3de2:	00002097          	auipc	ra,0x2
    3de6:	056080e7          	jalr	86(ra) # 5e38 <printf>
    exit(1);
    3dea:	4505                	li	a0,1
    3dec:	00002097          	auipc	ra,0x2
    3df0:	cbc080e7          	jalr	-836(ra) # 5aa8 <exit>

0000000000003df4 <rmdot>:
{
    3df4:	1101                	addi	sp,sp,-32
    3df6:	ec06                	sd	ra,24(sp)
    3df8:	e822                	sd	s0,16(sp)
    3dfa:	e426                	sd	s1,8(sp)
    3dfc:	1000                	addi	s0,sp,32
    3dfe:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3e00:	00004517          	auipc	a0,0x4
    3e04:	af050513          	addi	a0,a0,-1296 # 78f0 <malloc+0x19fa>
    3e08:	00002097          	auipc	ra,0x2
    3e0c:	d08080e7          	jalr	-760(ra) # 5b10 <mkdir>
    3e10:	e549                	bnez	a0,3e9a <rmdot+0xa6>
  if(chdir("dots") != 0){
    3e12:	00004517          	auipc	a0,0x4
    3e16:	ade50513          	addi	a0,a0,-1314 # 78f0 <malloc+0x19fa>
    3e1a:	00002097          	auipc	ra,0x2
    3e1e:	cfe080e7          	jalr	-770(ra) # 5b18 <chdir>
    3e22:	e951                	bnez	a0,3eb6 <rmdot+0xc2>
  if(unlink(".") == 0){
    3e24:	00003517          	auipc	a0,0x3
    3e28:	8fc50513          	addi	a0,a0,-1796 # 6720 <malloc+0x82a>
    3e2c:	00002097          	auipc	ra,0x2
    3e30:	ccc080e7          	jalr	-820(ra) # 5af8 <unlink>
    3e34:	cd59                	beqz	a0,3ed2 <rmdot+0xde>
  if(unlink("..") == 0){
    3e36:	00003517          	auipc	a0,0x3
    3e3a:	51250513          	addi	a0,a0,1298 # 7348 <malloc+0x1452>
    3e3e:	00002097          	auipc	ra,0x2
    3e42:	cba080e7          	jalr	-838(ra) # 5af8 <unlink>
    3e46:	c545                	beqz	a0,3eee <rmdot+0xfa>
  if(chdir("/") != 0){
    3e48:	00003517          	auipc	a0,0x3
    3e4c:	4a850513          	addi	a0,a0,1192 # 72f0 <malloc+0x13fa>
    3e50:	00002097          	auipc	ra,0x2
    3e54:	cc8080e7          	jalr	-824(ra) # 5b18 <chdir>
    3e58:	e94d                	bnez	a0,3f0a <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3e5a:	00004517          	auipc	a0,0x4
    3e5e:	afe50513          	addi	a0,a0,-1282 # 7958 <malloc+0x1a62>
    3e62:	00002097          	auipc	ra,0x2
    3e66:	c96080e7          	jalr	-874(ra) # 5af8 <unlink>
    3e6a:	cd55                	beqz	a0,3f26 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3e6c:	00004517          	auipc	a0,0x4
    3e70:	b1450513          	addi	a0,a0,-1260 # 7980 <malloc+0x1a8a>
    3e74:	00002097          	auipc	ra,0x2
    3e78:	c84080e7          	jalr	-892(ra) # 5af8 <unlink>
    3e7c:	c179                	beqz	a0,3f42 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3e7e:	00004517          	auipc	a0,0x4
    3e82:	a7250513          	addi	a0,a0,-1422 # 78f0 <malloc+0x19fa>
    3e86:	00002097          	auipc	ra,0x2
    3e8a:	c72080e7          	jalr	-910(ra) # 5af8 <unlink>
    3e8e:	e961                	bnez	a0,3f5e <rmdot+0x16a>
}
    3e90:	60e2                	ld	ra,24(sp)
    3e92:	6442                	ld	s0,16(sp)
    3e94:	64a2                	ld	s1,8(sp)
    3e96:	6105                	addi	sp,sp,32
    3e98:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3e9a:	85a6                	mv	a1,s1
    3e9c:	00004517          	auipc	a0,0x4
    3ea0:	a5c50513          	addi	a0,a0,-1444 # 78f8 <malloc+0x1a02>
    3ea4:	00002097          	auipc	ra,0x2
    3ea8:	f94080e7          	jalr	-108(ra) # 5e38 <printf>
    exit(1);
    3eac:	4505                	li	a0,1
    3eae:	00002097          	auipc	ra,0x2
    3eb2:	bfa080e7          	jalr	-1030(ra) # 5aa8 <exit>
    printf("%s: chdir dots failed\n", s);
    3eb6:	85a6                	mv	a1,s1
    3eb8:	00004517          	auipc	a0,0x4
    3ebc:	a5850513          	addi	a0,a0,-1448 # 7910 <malloc+0x1a1a>
    3ec0:	00002097          	auipc	ra,0x2
    3ec4:	f78080e7          	jalr	-136(ra) # 5e38 <printf>
    exit(1);
    3ec8:	4505                	li	a0,1
    3eca:	00002097          	auipc	ra,0x2
    3ece:	bde080e7          	jalr	-1058(ra) # 5aa8 <exit>
    printf("%s: rm . worked!\n", s);
    3ed2:	85a6                	mv	a1,s1
    3ed4:	00004517          	auipc	a0,0x4
    3ed8:	a5450513          	addi	a0,a0,-1452 # 7928 <malloc+0x1a32>
    3edc:	00002097          	auipc	ra,0x2
    3ee0:	f5c080e7          	jalr	-164(ra) # 5e38 <printf>
    exit(1);
    3ee4:	4505                	li	a0,1
    3ee6:	00002097          	auipc	ra,0x2
    3eea:	bc2080e7          	jalr	-1086(ra) # 5aa8 <exit>
    printf("%s: rm .. worked!\n", s);
    3eee:	85a6                	mv	a1,s1
    3ef0:	00004517          	auipc	a0,0x4
    3ef4:	a5050513          	addi	a0,a0,-1456 # 7940 <malloc+0x1a4a>
    3ef8:	00002097          	auipc	ra,0x2
    3efc:	f40080e7          	jalr	-192(ra) # 5e38 <printf>
    exit(1);
    3f00:	4505                	li	a0,1
    3f02:	00002097          	auipc	ra,0x2
    3f06:	ba6080e7          	jalr	-1114(ra) # 5aa8 <exit>
    printf("%s: chdir / failed\n", s);
    3f0a:	85a6                	mv	a1,s1
    3f0c:	00003517          	auipc	a0,0x3
    3f10:	3ec50513          	addi	a0,a0,1004 # 72f8 <malloc+0x1402>
    3f14:	00002097          	auipc	ra,0x2
    3f18:	f24080e7          	jalr	-220(ra) # 5e38 <printf>
    exit(1);
    3f1c:	4505                	li	a0,1
    3f1e:	00002097          	auipc	ra,0x2
    3f22:	b8a080e7          	jalr	-1142(ra) # 5aa8 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3f26:	85a6                	mv	a1,s1
    3f28:	00004517          	auipc	a0,0x4
    3f2c:	a3850513          	addi	a0,a0,-1480 # 7960 <malloc+0x1a6a>
    3f30:	00002097          	auipc	ra,0x2
    3f34:	f08080e7          	jalr	-248(ra) # 5e38 <printf>
    exit(1);
    3f38:	4505                	li	a0,1
    3f3a:	00002097          	auipc	ra,0x2
    3f3e:	b6e080e7          	jalr	-1170(ra) # 5aa8 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3f42:	85a6                	mv	a1,s1
    3f44:	00004517          	auipc	a0,0x4
    3f48:	a4450513          	addi	a0,a0,-1468 # 7988 <malloc+0x1a92>
    3f4c:	00002097          	auipc	ra,0x2
    3f50:	eec080e7          	jalr	-276(ra) # 5e38 <printf>
    exit(1);
    3f54:	4505                	li	a0,1
    3f56:	00002097          	auipc	ra,0x2
    3f5a:	b52080e7          	jalr	-1198(ra) # 5aa8 <exit>
    printf("%s: unlink dots failed!\n", s);
    3f5e:	85a6                	mv	a1,s1
    3f60:	00004517          	auipc	a0,0x4
    3f64:	a4850513          	addi	a0,a0,-1464 # 79a8 <malloc+0x1ab2>
    3f68:	00002097          	auipc	ra,0x2
    3f6c:	ed0080e7          	jalr	-304(ra) # 5e38 <printf>
    exit(1);
    3f70:	4505                	li	a0,1
    3f72:	00002097          	auipc	ra,0x2
    3f76:	b36080e7          	jalr	-1226(ra) # 5aa8 <exit>

0000000000003f7a <dirfile>:
{
    3f7a:	1101                	addi	sp,sp,-32
    3f7c:	ec06                	sd	ra,24(sp)
    3f7e:	e822                	sd	s0,16(sp)
    3f80:	e426                	sd	s1,8(sp)
    3f82:	e04a                	sd	s2,0(sp)
    3f84:	1000                	addi	s0,sp,32
    3f86:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3f88:	20000593          	li	a1,512
    3f8c:	00004517          	auipc	a0,0x4
    3f90:	a3c50513          	addi	a0,a0,-1476 # 79c8 <malloc+0x1ad2>
    3f94:	00002097          	auipc	ra,0x2
    3f98:	b54080e7          	jalr	-1196(ra) # 5ae8 <open>
  if(fd < 0){
    3f9c:	0e054d63          	bltz	a0,4096 <dirfile+0x11c>
  close(fd);
    3fa0:	00002097          	auipc	ra,0x2
    3fa4:	b30080e7          	jalr	-1232(ra) # 5ad0 <close>
  if(chdir("dirfile") == 0){
    3fa8:	00004517          	auipc	a0,0x4
    3fac:	a2050513          	addi	a0,a0,-1504 # 79c8 <malloc+0x1ad2>
    3fb0:	00002097          	auipc	ra,0x2
    3fb4:	b68080e7          	jalr	-1176(ra) # 5b18 <chdir>
    3fb8:	cd6d                	beqz	a0,40b2 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    3fba:	4581                	li	a1,0
    3fbc:	00004517          	auipc	a0,0x4
    3fc0:	a5450513          	addi	a0,a0,-1452 # 7a10 <malloc+0x1b1a>
    3fc4:	00002097          	auipc	ra,0x2
    3fc8:	b24080e7          	jalr	-1244(ra) # 5ae8 <open>
  if(fd >= 0){
    3fcc:	10055163          	bgez	a0,40ce <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3fd0:	20000593          	li	a1,512
    3fd4:	00004517          	auipc	a0,0x4
    3fd8:	a3c50513          	addi	a0,a0,-1476 # 7a10 <malloc+0x1b1a>
    3fdc:	00002097          	auipc	ra,0x2
    3fe0:	b0c080e7          	jalr	-1268(ra) # 5ae8 <open>
  if(fd >= 0){
    3fe4:	10055363          	bgez	a0,40ea <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3fe8:	00004517          	auipc	a0,0x4
    3fec:	a2850513          	addi	a0,a0,-1496 # 7a10 <malloc+0x1b1a>
    3ff0:	00002097          	auipc	ra,0x2
    3ff4:	b20080e7          	jalr	-1248(ra) # 5b10 <mkdir>
    3ff8:	10050763          	beqz	a0,4106 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3ffc:	00004517          	auipc	a0,0x4
    4000:	a1450513          	addi	a0,a0,-1516 # 7a10 <malloc+0x1b1a>
    4004:	00002097          	auipc	ra,0x2
    4008:	af4080e7          	jalr	-1292(ra) # 5af8 <unlink>
    400c:	10050b63          	beqz	a0,4122 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    4010:	00004597          	auipc	a1,0x4
    4014:	a0058593          	addi	a1,a1,-1536 # 7a10 <malloc+0x1b1a>
    4018:	00002517          	auipc	a0,0x2
    401c:	1f850513          	addi	a0,a0,504 # 6210 <malloc+0x31a>
    4020:	00002097          	auipc	ra,0x2
    4024:	ae8080e7          	jalr	-1304(ra) # 5b08 <link>
    4028:	10050b63          	beqz	a0,413e <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    402c:	00004517          	auipc	a0,0x4
    4030:	99c50513          	addi	a0,a0,-1636 # 79c8 <malloc+0x1ad2>
    4034:	00002097          	auipc	ra,0x2
    4038:	ac4080e7          	jalr	-1340(ra) # 5af8 <unlink>
    403c:	10051f63          	bnez	a0,415a <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    4040:	4589                	li	a1,2
    4042:	00002517          	auipc	a0,0x2
    4046:	6de50513          	addi	a0,a0,1758 # 6720 <malloc+0x82a>
    404a:	00002097          	auipc	ra,0x2
    404e:	a9e080e7          	jalr	-1378(ra) # 5ae8 <open>
  if(fd >= 0){
    4052:	12055263          	bgez	a0,4176 <dirfile+0x1fc>
  fd = open(".", 0);
    4056:	4581                	li	a1,0
    4058:	00002517          	auipc	a0,0x2
    405c:	6c850513          	addi	a0,a0,1736 # 6720 <malloc+0x82a>
    4060:	00002097          	auipc	ra,0x2
    4064:	a88080e7          	jalr	-1400(ra) # 5ae8 <open>
    4068:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    406a:	4605                	li	a2,1
    406c:	00002597          	auipc	a1,0x2
    4070:	03c58593          	addi	a1,a1,60 # 60a8 <malloc+0x1b2>
    4074:	00002097          	auipc	ra,0x2
    4078:	a54080e7          	jalr	-1452(ra) # 5ac8 <write>
    407c:	10a04b63          	bgtz	a0,4192 <dirfile+0x218>
  close(fd);
    4080:	8526                	mv	a0,s1
    4082:	00002097          	auipc	ra,0x2
    4086:	a4e080e7          	jalr	-1458(ra) # 5ad0 <close>
}
    408a:	60e2                	ld	ra,24(sp)
    408c:	6442                	ld	s0,16(sp)
    408e:	64a2                	ld	s1,8(sp)
    4090:	6902                	ld	s2,0(sp)
    4092:	6105                	addi	sp,sp,32
    4094:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    4096:	85ca                	mv	a1,s2
    4098:	00004517          	auipc	a0,0x4
    409c:	93850513          	addi	a0,a0,-1736 # 79d0 <malloc+0x1ada>
    40a0:	00002097          	auipc	ra,0x2
    40a4:	d98080e7          	jalr	-616(ra) # 5e38 <printf>
    exit(1);
    40a8:	4505                	li	a0,1
    40aa:	00002097          	auipc	ra,0x2
    40ae:	9fe080e7          	jalr	-1538(ra) # 5aa8 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    40b2:	85ca                	mv	a1,s2
    40b4:	00004517          	auipc	a0,0x4
    40b8:	93c50513          	addi	a0,a0,-1732 # 79f0 <malloc+0x1afa>
    40bc:	00002097          	auipc	ra,0x2
    40c0:	d7c080e7          	jalr	-644(ra) # 5e38 <printf>
    exit(1);
    40c4:	4505                	li	a0,1
    40c6:	00002097          	auipc	ra,0x2
    40ca:	9e2080e7          	jalr	-1566(ra) # 5aa8 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    40ce:	85ca                	mv	a1,s2
    40d0:	00004517          	auipc	a0,0x4
    40d4:	95050513          	addi	a0,a0,-1712 # 7a20 <malloc+0x1b2a>
    40d8:	00002097          	auipc	ra,0x2
    40dc:	d60080e7          	jalr	-672(ra) # 5e38 <printf>
    exit(1);
    40e0:	4505                	li	a0,1
    40e2:	00002097          	auipc	ra,0x2
    40e6:	9c6080e7          	jalr	-1594(ra) # 5aa8 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    40ea:	85ca                	mv	a1,s2
    40ec:	00004517          	auipc	a0,0x4
    40f0:	93450513          	addi	a0,a0,-1740 # 7a20 <malloc+0x1b2a>
    40f4:	00002097          	auipc	ra,0x2
    40f8:	d44080e7          	jalr	-700(ra) # 5e38 <printf>
    exit(1);
    40fc:	4505                	li	a0,1
    40fe:	00002097          	auipc	ra,0x2
    4102:	9aa080e7          	jalr	-1622(ra) # 5aa8 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    4106:	85ca                	mv	a1,s2
    4108:	00004517          	auipc	a0,0x4
    410c:	94050513          	addi	a0,a0,-1728 # 7a48 <malloc+0x1b52>
    4110:	00002097          	auipc	ra,0x2
    4114:	d28080e7          	jalr	-728(ra) # 5e38 <printf>
    exit(1);
    4118:	4505                	li	a0,1
    411a:	00002097          	auipc	ra,0x2
    411e:	98e080e7          	jalr	-1650(ra) # 5aa8 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    4122:	85ca                	mv	a1,s2
    4124:	00004517          	auipc	a0,0x4
    4128:	94c50513          	addi	a0,a0,-1716 # 7a70 <malloc+0x1b7a>
    412c:	00002097          	auipc	ra,0x2
    4130:	d0c080e7          	jalr	-756(ra) # 5e38 <printf>
    exit(1);
    4134:	4505                	li	a0,1
    4136:	00002097          	auipc	ra,0x2
    413a:	972080e7          	jalr	-1678(ra) # 5aa8 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    413e:	85ca                	mv	a1,s2
    4140:	00004517          	auipc	a0,0x4
    4144:	95850513          	addi	a0,a0,-1704 # 7a98 <malloc+0x1ba2>
    4148:	00002097          	auipc	ra,0x2
    414c:	cf0080e7          	jalr	-784(ra) # 5e38 <printf>
    exit(1);
    4150:	4505                	li	a0,1
    4152:	00002097          	auipc	ra,0x2
    4156:	956080e7          	jalr	-1706(ra) # 5aa8 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    415a:	85ca                	mv	a1,s2
    415c:	00004517          	auipc	a0,0x4
    4160:	96450513          	addi	a0,a0,-1692 # 7ac0 <malloc+0x1bca>
    4164:	00002097          	auipc	ra,0x2
    4168:	cd4080e7          	jalr	-812(ra) # 5e38 <printf>
    exit(1);
    416c:	4505                	li	a0,1
    416e:	00002097          	auipc	ra,0x2
    4172:	93a080e7          	jalr	-1734(ra) # 5aa8 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    4176:	85ca                	mv	a1,s2
    4178:	00004517          	auipc	a0,0x4
    417c:	96850513          	addi	a0,a0,-1688 # 7ae0 <malloc+0x1bea>
    4180:	00002097          	auipc	ra,0x2
    4184:	cb8080e7          	jalr	-840(ra) # 5e38 <printf>
    exit(1);
    4188:	4505                	li	a0,1
    418a:	00002097          	auipc	ra,0x2
    418e:	91e080e7          	jalr	-1762(ra) # 5aa8 <exit>
    printf("%s: write . succeeded!\n", s);
    4192:	85ca                	mv	a1,s2
    4194:	00004517          	auipc	a0,0x4
    4198:	97450513          	addi	a0,a0,-1676 # 7b08 <malloc+0x1c12>
    419c:	00002097          	auipc	ra,0x2
    41a0:	c9c080e7          	jalr	-868(ra) # 5e38 <printf>
    exit(1);
    41a4:	4505                	li	a0,1
    41a6:	00002097          	auipc	ra,0x2
    41aa:	902080e7          	jalr	-1790(ra) # 5aa8 <exit>

00000000000041ae <iref>:
{
    41ae:	7139                	addi	sp,sp,-64
    41b0:	fc06                	sd	ra,56(sp)
    41b2:	f822                	sd	s0,48(sp)
    41b4:	f426                	sd	s1,40(sp)
    41b6:	f04a                	sd	s2,32(sp)
    41b8:	ec4e                	sd	s3,24(sp)
    41ba:	e852                	sd	s4,16(sp)
    41bc:	e456                	sd	s5,8(sp)
    41be:	e05a                	sd	s6,0(sp)
    41c0:	0080                	addi	s0,sp,64
    41c2:	8b2a                	mv	s6,a0
    41c4:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    41c8:	00004a17          	auipc	s4,0x4
    41cc:	958a0a13          	addi	s4,s4,-1704 # 7b20 <malloc+0x1c2a>
    mkdir("");
    41d0:	00003497          	auipc	s1,0x3
    41d4:	45848493          	addi	s1,s1,1112 # 7628 <malloc+0x1732>
    link("README", "");
    41d8:	00002a97          	auipc	s5,0x2
    41dc:	038a8a93          	addi	s5,s5,56 # 6210 <malloc+0x31a>
    fd = open("xx", O_CREATE);
    41e0:	00004997          	auipc	s3,0x4
    41e4:	83898993          	addi	s3,s3,-1992 # 7a18 <malloc+0x1b22>
    41e8:	a891                	j	423c <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    41ea:	85da                	mv	a1,s6
    41ec:	00004517          	auipc	a0,0x4
    41f0:	93c50513          	addi	a0,a0,-1732 # 7b28 <malloc+0x1c32>
    41f4:	00002097          	auipc	ra,0x2
    41f8:	c44080e7          	jalr	-956(ra) # 5e38 <printf>
      exit(1);
    41fc:	4505                	li	a0,1
    41fe:	00002097          	auipc	ra,0x2
    4202:	8aa080e7          	jalr	-1878(ra) # 5aa8 <exit>
      printf("%s: chdir irefd failed\n", s);
    4206:	85da                	mv	a1,s6
    4208:	00004517          	auipc	a0,0x4
    420c:	93850513          	addi	a0,a0,-1736 # 7b40 <malloc+0x1c4a>
    4210:	00002097          	auipc	ra,0x2
    4214:	c28080e7          	jalr	-984(ra) # 5e38 <printf>
      exit(1);
    4218:	4505                	li	a0,1
    421a:	00002097          	auipc	ra,0x2
    421e:	88e080e7          	jalr	-1906(ra) # 5aa8 <exit>
      close(fd);
    4222:	00002097          	auipc	ra,0x2
    4226:	8ae080e7          	jalr	-1874(ra) # 5ad0 <close>
    422a:	a889                	j	427c <iref+0xce>
    unlink("xx");
    422c:	854e                	mv	a0,s3
    422e:	00002097          	auipc	ra,0x2
    4232:	8ca080e7          	jalr	-1846(ra) # 5af8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4236:	397d                	addiw	s2,s2,-1
    4238:	06090063          	beqz	s2,4298 <iref+0xea>
    if(mkdir("irefd") != 0){
    423c:	8552                	mv	a0,s4
    423e:	00002097          	auipc	ra,0x2
    4242:	8d2080e7          	jalr	-1838(ra) # 5b10 <mkdir>
    4246:	f155                	bnez	a0,41ea <iref+0x3c>
    if(chdir("irefd") != 0){
    4248:	8552                	mv	a0,s4
    424a:	00002097          	auipc	ra,0x2
    424e:	8ce080e7          	jalr	-1842(ra) # 5b18 <chdir>
    4252:	f955                	bnez	a0,4206 <iref+0x58>
    mkdir("");
    4254:	8526                	mv	a0,s1
    4256:	00002097          	auipc	ra,0x2
    425a:	8ba080e7          	jalr	-1862(ra) # 5b10 <mkdir>
    link("README", "");
    425e:	85a6                	mv	a1,s1
    4260:	8556                	mv	a0,s5
    4262:	00002097          	auipc	ra,0x2
    4266:	8a6080e7          	jalr	-1882(ra) # 5b08 <link>
    fd = open("", O_CREATE);
    426a:	20000593          	li	a1,512
    426e:	8526                	mv	a0,s1
    4270:	00002097          	auipc	ra,0x2
    4274:	878080e7          	jalr	-1928(ra) # 5ae8 <open>
    if(fd >= 0)
    4278:	fa0555e3          	bgez	a0,4222 <iref+0x74>
    fd = open("xx", O_CREATE);
    427c:	20000593          	li	a1,512
    4280:	854e                	mv	a0,s3
    4282:	00002097          	auipc	ra,0x2
    4286:	866080e7          	jalr	-1946(ra) # 5ae8 <open>
    if(fd >= 0)
    428a:	fa0541e3          	bltz	a0,422c <iref+0x7e>
      close(fd);
    428e:	00002097          	auipc	ra,0x2
    4292:	842080e7          	jalr	-1982(ra) # 5ad0 <close>
    4296:	bf59                	j	422c <iref+0x7e>
    4298:	03300493          	li	s1,51
    chdir("..");
    429c:	00003997          	auipc	s3,0x3
    42a0:	0ac98993          	addi	s3,s3,172 # 7348 <malloc+0x1452>
    unlink("irefd");
    42a4:	00004917          	auipc	s2,0x4
    42a8:	87c90913          	addi	s2,s2,-1924 # 7b20 <malloc+0x1c2a>
    chdir("..");
    42ac:	854e                	mv	a0,s3
    42ae:	00002097          	auipc	ra,0x2
    42b2:	86a080e7          	jalr	-1942(ra) # 5b18 <chdir>
    unlink("irefd");
    42b6:	854a                	mv	a0,s2
    42b8:	00002097          	auipc	ra,0x2
    42bc:	840080e7          	jalr	-1984(ra) # 5af8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    42c0:	34fd                	addiw	s1,s1,-1
    42c2:	f4ed                	bnez	s1,42ac <iref+0xfe>
  chdir("/");
    42c4:	00003517          	auipc	a0,0x3
    42c8:	02c50513          	addi	a0,a0,44 # 72f0 <malloc+0x13fa>
    42cc:	00002097          	auipc	ra,0x2
    42d0:	84c080e7          	jalr	-1972(ra) # 5b18 <chdir>
}
    42d4:	70e2                	ld	ra,56(sp)
    42d6:	7442                	ld	s0,48(sp)
    42d8:	74a2                	ld	s1,40(sp)
    42da:	7902                	ld	s2,32(sp)
    42dc:	69e2                	ld	s3,24(sp)
    42de:	6a42                	ld	s4,16(sp)
    42e0:	6aa2                	ld	s5,8(sp)
    42e2:	6b02                	ld	s6,0(sp)
    42e4:	6121                	addi	sp,sp,64
    42e6:	8082                	ret

00000000000042e8 <openiputtest>:
{
    42e8:	7179                	addi	sp,sp,-48
    42ea:	f406                	sd	ra,40(sp)
    42ec:	f022                	sd	s0,32(sp)
    42ee:	ec26                	sd	s1,24(sp)
    42f0:	1800                	addi	s0,sp,48
    42f2:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    42f4:	00004517          	auipc	a0,0x4
    42f8:	86450513          	addi	a0,a0,-1948 # 7b58 <malloc+0x1c62>
    42fc:	00002097          	auipc	ra,0x2
    4300:	814080e7          	jalr	-2028(ra) # 5b10 <mkdir>
    4304:	04054263          	bltz	a0,4348 <openiputtest+0x60>
  pid = fork();
    4308:	00001097          	auipc	ra,0x1
    430c:	798080e7          	jalr	1944(ra) # 5aa0 <fork>
  if(pid < 0){
    4310:	04054a63          	bltz	a0,4364 <openiputtest+0x7c>
  if(pid == 0){
    4314:	e93d                	bnez	a0,438a <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    4316:	4589                	li	a1,2
    4318:	00004517          	auipc	a0,0x4
    431c:	84050513          	addi	a0,a0,-1984 # 7b58 <malloc+0x1c62>
    4320:	00001097          	auipc	ra,0x1
    4324:	7c8080e7          	jalr	1992(ra) # 5ae8 <open>
    if(fd >= 0){
    4328:	04054c63          	bltz	a0,4380 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    432c:	85a6                	mv	a1,s1
    432e:	00004517          	auipc	a0,0x4
    4332:	84a50513          	addi	a0,a0,-1974 # 7b78 <malloc+0x1c82>
    4336:	00002097          	auipc	ra,0x2
    433a:	b02080e7          	jalr	-1278(ra) # 5e38 <printf>
      exit(1);
    433e:	4505                	li	a0,1
    4340:	00001097          	auipc	ra,0x1
    4344:	768080e7          	jalr	1896(ra) # 5aa8 <exit>
    printf("%s: mkdir oidir failed\n", s);
    4348:	85a6                	mv	a1,s1
    434a:	00004517          	auipc	a0,0x4
    434e:	81650513          	addi	a0,a0,-2026 # 7b60 <malloc+0x1c6a>
    4352:	00002097          	auipc	ra,0x2
    4356:	ae6080e7          	jalr	-1306(ra) # 5e38 <printf>
    exit(1);
    435a:	4505                	li	a0,1
    435c:	00001097          	auipc	ra,0x1
    4360:	74c080e7          	jalr	1868(ra) # 5aa8 <exit>
    printf("%s: fork failed\n", s);
    4364:	85a6                	mv	a1,s1
    4366:	00002517          	auipc	a0,0x2
    436a:	55a50513          	addi	a0,a0,1370 # 68c0 <malloc+0x9ca>
    436e:	00002097          	auipc	ra,0x2
    4372:	aca080e7          	jalr	-1334(ra) # 5e38 <printf>
    exit(1);
    4376:	4505                	li	a0,1
    4378:	00001097          	auipc	ra,0x1
    437c:	730080e7          	jalr	1840(ra) # 5aa8 <exit>
    exit(0);
    4380:	4501                	li	a0,0
    4382:	00001097          	auipc	ra,0x1
    4386:	726080e7          	jalr	1830(ra) # 5aa8 <exit>
  sleep(1);
    438a:	4505                	li	a0,1
    438c:	00001097          	auipc	ra,0x1
    4390:	7ac080e7          	jalr	1964(ra) # 5b38 <sleep>
  if(unlink("oidir") != 0){
    4394:	00003517          	auipc	a0,0x3
    4398:	7c450513          	addi	a0,a0,1988 # 7b58 <malloc+0x1c62>
    439c:	00001097          	auipc	ra,0x1
    43a0:	75c080e7          	jalr	1884(ra) # 5af8 <unlink>
    43a4:	cd19                	beqz	a0,43c2 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    43a6:	85a6                	mv	a1,s1
    43a8:	00002517          	auipc	a0,0x2
    43ac:	70850513          	addi	a0,a0,1800 # 6ab0 <malloc+0xbba>
    43b0:	00002097          	auipc	ra,0x2
    43b4:	a88080e7          	jalr	-1400(ra) # 5e38 <printf>
    exit(1);
    43b8:	4505                	li	a0,1
    43ba:	00001097          	auipc	ra,0x1
    43be:	6ee080e7          	jalr	1774(ra) # 5aa8 <exit>
  wait(&xstatus);
    43c2:	fdc40513          	addi	a0,s0,-36
    43c6:	00001097          	auipc	ra,0x1
    43ca:	6ea080e7          	jalr	1770(ra) # 5ab0 <wait>
  exit(xstatus);
    43ce:	fdc42503          	lw	a0,-36(s0)
    43d2:	00001097          	auipc	ra,0x1
    43d6:	6d6080e7          	jalr	1750(ra) # 5aa8 <exit>

00000000000043da <forkforkfork>:
{
    43da:	1101                	addi	sp,sp,-32
    43dc:	ec06                	sd	ra,24(sp)
    43de:	e822                	sd	s0,16(sp)
    43e0:	e426                	sd	s1,8(sp)
    43e2:	1000                	addi	s0,sp,32
    43e4:	84aa                	mv	s1,a0
  unlink("stopforking");
    43e6:	00003517          	auipc	a0,0x3
    43ea:	7ba50513          	addi	a0,a0,1978 # 7ba0 <malloc+0x1caa>
    43ee:	00001097          	auipc	ra,0x1
    43f2:	70a080e7          	jalr	1802(ra) # 5af8 <unlink>
  int pid = fork();
    43f6:	00001097          	auipc	ra,0x1
    43fa:	6aa080e7          	jalr	1706(ra) # 5aa0 <fork>
  if(pid < 0){
    43fe:	04054563          	bltz	a0,4448 <forkforkfork+0x6e>
  if(pid == 0){
    4402:	c12d                	beqz	a0,4464 <forkforkfork+0x8a>
  sleep(20); // two seconds
    4404:	4551                	li	a0,20
    4406:	00001097          	auipc	ra,0x1
    440a:	732080e7          	jalr	1842(ra) # 5b38 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    440e:	20200593          	li	a1,514
    4412:	00003517          	auipc	a0,0x3
    4416:	78e50513          	addi	a0,a0,1934 # 7ba0 <malloc+0x1caa>
    441a:	00001097          	auipc	ra,0x1
    441e:	6ce080e7          	jalr	1742(ra) # 5ae8 <open>
    4422:	00001097          	auipc	ra,0x1
    4426:	6ae080e7          	jalr	1710(ra) # 5ad0 <close>
  wait(0);
    442a:	4501                	li	a0,0
    442c:	00001097          	auipc	ra,0x1
    4430:	684080e7          	jalr	1668(ra) # 5ab0 <wait>
  sleep(10); // one second
    4434:	4529                	li	a0,10
    4436:	00001097          	auipc	ra,0x1
    443a:	702080e7          	jalr	1794(ra) # 5b38 <sleep>
}
    443e:	60e2                	ld	ra,24(sp)
    4440:	6442                	ld	s0,16(sp)
    4442:	64a2                	ld	s1,8(sp)
    4444:	6105                	addi	sp,sp,32
    4446:	8082                	ret
    printf("%s: fork failed", s);
    4448:	85a6                	mv	a1,s1
    444a:	00002517          	auipc	a0,0x2
    444e:	63650513          	addi	a0,a0,1590 # 6a80 <malloc+0xb8a>
    4452:	00002097          	auipc	ra,0x2
    4456:	9e6080e7          	jalr	-1562(ra) # 5e38 <printf>
    exit(1);
    445a:	4505                	li	a0,1
    445c:	00001097          	auipc	ra,0x1
    4460:	64c080e7          	jalr	1612(ra) # 5aa8 <exit>
      int fd = open("stopforking", 0);
    4464:	00003497          	auipc	s1,0x3
    4468:	73c48493          	addi	s1,s1,1852 # 7ba0 <malloc+0x1caa>
    446c:	4581                	li	a1,0
    446e:	8526                	mv	a0,s1
    4470:	00001097          	auipc	ra,0x1
    4474:	678080e7          	jalr	1656(ra) # 5ae8 <open>
      if(fd >= 0){
    4478:	02055463          	bgez	a0,44a0 <forkforkfork+0xc6>
      if(fork() < 0){
    447c:	00001097          	auipc	ra,0x1
    4480:	624080e7          	jalr	1572(ra) # 5aa0 <fork>
    4484:	fe0554e3          	bgez	a0,446c <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    4488:	20200593          	li	a1,514
    448c:	8526                	mv	a0,s1
    448e:	00001097          	auipc	ra,0x1
    4492:	65a080e7          	jalr	1626(ra) # 5ae8 <open>
    4496:	00001097          	auipc	ra,0x1
    449a:	63a080e7          	jalr	1594(ra) # 5ad0 <close>
    449e:	b7f9                	j	446c <forkforkfork+0x92>
        exit(0);
    44a0:	4501                	li	a0,0
    44a2:	00001097          	auipc	ra,0x1
    44a6:	606080e7          	jalr	1542(ra) # 5aa8 <exit>

00000000000044aa <killstatus>:
{
    44aa:	7139                	addi	sp,sp,-64
    44ac:	fc06                	sd	ra,56(sp)
    44ae:	f822                	sd	s0,48(sp)
    44b0:	f426                	sd	s1,40(sp)
    44b2:	f04a                	sd	s2,32(sp)
    44b4:	ec4e                	sd	s3,24(sp)
    44b6:	e852                	sd	s4,16(sp)
    44b8:	0080                	addi	s0,sp,64
    44ba:	8a2a                	mv	s4,a0
    44bc:	06400913          	li	s2,100
    if(xst != -1) {
    44c0:	59fd                	li	s3,-1
    int pid1 = fork();
    44c2:	00001097          	auipc	ra,0x1
    44c6:	5de080e7          	jalr	1502(ra) # 5aa0 <fork>
    44ca:	84aa                	mv	s1,a0
    if(pid1 < 0){
    44cc:	02054f63          	bltz	a0,450a <killstatus+0x60>
    if(pid1 == 0){
    44d0:	c939                	beqz	a0,4526 <killstatus+0x7c>
    sleep(1);
    44d2:	4505                	li	a0,1
    44d4:	00001097          	auipc	ra,0x1
    44d8:	664080e7          	jalr	1636(ra) # 5b38 <sleep>
    kill(pid1);
    44dc:	8526                	mv	a0,s1
    44de:	00001097          	auipc	ra,0x1
    44e2:	5fa080e7          	jalr	1530(ra) # 5ad8 <kill>
    wait(&xst);
    44e6:	fcc40513          	addi	a0,s0,-52
    44ea:	00001097          	auipc	ra,0x1
    44ee:	5c6080e7          	jalr	1478(ra) # 5ab0 <wait>
    if(xst != -1) {
    44f2:	fcc42783          	lw	a5,-52(s0)
    44f6:	03379d63          	bne	a5,s3,4530 <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    44fa:	397d                	addiw	s2,s2,-1
    44fc:	fc0913e3          	bnez	s2,44c2 <killstatus+0x18>
  exit(0);
    4500:	4501                	li	a0,0
    4502:	00001097          	auipc	ra,0x1
    4506:	5a6080e7          	jalr	1446(ra) # 5aa8 <exit>
      printf("%s: fork failed\n", s);
    450a:	85d2                	mv	a1,s4
    450c:	00002517          	auipc	a0,0x2
    4510:	3b450513          	addi	a0,a0,948 # 68c0 <malloc+0x9ca>
    4514:	00002097          	auipc	ra,0x2
    4518:	924080e7          	jalr	-1756(ra) # 5e38 <printf>
      exit(1);
    451c:	4505                	li	a0,1
    451e:	00001097          	auipc	ra,0x1
    4522:	58a080e7          	jalr	1418(ra) # 5aa8 <exit>
        getpid();
    4526:	00001097          	auipc	ra,0x1
    452a:	602080e7          	jalr	1538(ra) # 5b28 <getpid>
      while(1) {
    452e:	bfe5                	j	4526 <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    4530:	85d2                	mv	a1,s4
    4532:	00003517          	auipc	a0,0x3
    4536:	67e50513          	addi	a0,a0,1662 # 7bb0 <malloc+0x1cba>
    453a:	00002097          	auipc	ra,0x2
    453e:	8fe080e7          	jalr	-1794(ra) # 5e38 <printf>
       exit(1);
    4542:	4505                	li	a0,1
    4544:	00001097          	auipc	ra,0x1
    4548:	564080e7          	jalr	1380(ra) # 5aa8 <exit>

000000000000454c <preempt>:
{
    454c:	7139                	addi	sp,sp,-64
    454e:	fc06                	sd	ra,56(sp)
    4550:	f822                	sd	s0,48(sp)
    4552:	f426                	sd	s1,40(sp)
    4554:	f04a                	sd	s2,32(sp)
    4556:	ec4e                	sd	s3,24(sp)
    4558:	e852                	sd	s4,16(sp)
    455a:	0080                	addi	s0,sp,64
    455c:	892a                	mv	s2,a0
  pid1 = fork();
    455e:	00001097          	auipc	ra,0x1
    4562:	542080e7          	jalr	1346(ra) # 5aa0 <fork>
  if(pid1 < 0) {
    4566:	00054563          	bltz	a0,4570 <preempt+0x24>
    456a:	84aa                	mv	s1,a0
  if(pid1 == 0)
    456c:	e105                	bnez	a0,458c <preempt+0x40>
    for(;;)
    456e:	a001                	j	456e <preempt+0x22>
    printf("%s: fork failed", s);
    4570:	85ca                	mv	a1,s2
    4572:	00002517          	auipc	a0,0x2
    4576:	50e50513          	addi	a0,a0,1294 # 6a80 <malloc+0xb8a>
    457a:	00002097          	auipc	ra,0x2
    457e:	8be080e7          	jalr	-1858(ra) # 5e38 <printf>
    exit(1);
    4582:	4505                	li	a0,1
    4584:	00001097          	auipc	ra,0x1
    4588:	524080e7          	jalr	1316(ra) # 5aa8 <exit>
  pid2 = fork();
    458c:	00001097          	auipc	ra,0x1
    4590:	514080e7          	jalr	1300(ra) # 5aa0 <fork>
    4594:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    4596:	00054463          	bltz	a0,459e <preempt+0x52>
  if(pid2 == 0)
    459a:	e105                	bnez	a0,45ba <preempt+0x6e>
    for(;;)
    459c:	a001                	j	459c <preempt+0x50>
    printf("%s: fork failed\n", s);
    459e:	85ca                	mv	a1,s2
    45a0:	00002517          	auipc	a0,0x2
    45a4:	32050513          	addi	a0,a0,800 # 68c0 <malloc+0x9ca>
    45a8:	00002097          	auipc	ra,0x2
    45ac:	890080e7          	jalr	-1904(ra) # 5e38 <printf>
    exit(1);
    45b0:	4505                	li	a0,1
    45b2:	00001097          	auipc	ra,0x1
    45b6:	4f6080e7          	jalr	1270(ra) # 5aa8 <exit>
  pipe(pfds);
    45ba:	fc840513          	addi	a0,s0,-56
    45be:	00001097          	auipc	ra,0x1
    45c2:	4fa080e7          	jalr	1274(ra) # 5ab8 <pipe>
  pid3 = fork();
    45c6:	00001097          	auipc	ra,0x1
    45ca:	4da080e7          	jalr	1242(ra) # 5aa0 <fork>
    45ce:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    45d0:	02054e63          	bltz	a0,460c <preempt+0xc0>
  if(pid3 == 0){
    45d4:	e525                	bnez	a0,463c <preempt+0xf0>
    close(pfds[0]);
    45d6:	fc842503          	lw	a0,-56(s0)
    45da:	00001097          	auipc	ra,0x1
    45de:	4f6080e7          	jalr	1270(ra) # 5ad0 <close>
    if(write(pfds[1], "x", 1) != 1)
    45e2:	4605                	li	a2,1
    45e4:	00002597          	auipc	a1,0x2
    45e8:	ac458593          	addi	a1,a1,-1340 # 60a8 <malloc+0x1b2>
    45ec:	fcc42503          	lw	a0,-52(s0)
    45f0:	00001097          	auipc	ra,0x1
    45f4:	4d8080e7          	jalr	1240(ra) # 5ac8 <write>
    45f8:	4785                	li	a5,1
    45fa:	02f51763          	bne	a0,a5,4628 <preempt+0xdc>
    close(pfds[1]);
    45fe:	fcc42503          	lw	a0,-52(s0)
    4602:	00001097          	auipc	ra,0x1
    4606:	4ce080e7          	jalr	1230(ra) # 5ad0 <close>
    for(;;)
    460a:	a001                	j	460a <preempt+0xbe>
     printf("%s: fork failed\n", s);
    460c:	85ca                	mv	a1,s2
    460e:	00002517          	auipc	a0,0x2
    4612:	2b250513          	addi	a0,a0,690 # 68c0 <malloc+0x9ca>
    4616:	00002097          	auipc	ra,0x2
    461a:	822080e7          	jalr	-2014(ra) # 5e38 <printf>
     exit(1);
    461e:	4505                	li	a0,1
    4620:	00001097          	auipc	ra,0x1
    4624:	488080e7          	jalr	1160(ra) # 5aa8 <exit>
      printf("%s: preempt write error", s);
    4628:	85ca                	mv	a1,s2
    462a:	00003517          	auipc	a0,0x3
    462e:	5a650513          	addi	a0,a0,1446 # 7bd0 <malloc+0x1cda>
    4632:	00002097          	auipc	ra,0x2
    4636:	806080e7          	jalr	-2042(ra) # 5e38 <printf>
    463a:	b7d1                	j	45fe <preempt+0xb2>
  close(pfds[1]);
    463c:	fcc42503          	lw	a0,-52(s0)
    4640:	00001097          	auipc	ra,0x1
    4644:	490080e7          	jalr	1168(ra) # 5ad0 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    4648:	660d                	lui	a2,0x3
    464a:	00008597          	auipc	a1,0x8
    464e:	60e58593          	addi	a1,a1,1550 # cc58 <buf>
    4652:	fc842503          	lw	a0,-56(s0)
    4656:	00001097          	auipc	ra,0x1
    465a:	46a080e7          	jalr	1130(ra) # 5ac0 <read>
    465e:	4785                	li	a5,1
    4660:	02f50363          	beq	a0,a5,4686 <preempt+0x13a>
    printf("%s: preempt read error", s);
    4664:	85ca                	mv	a1,s2
    4666:	00003517          	auipc	a0,0x3
    466a:	58250513          	addi	a0,a0,1410 # 7be8 <malloc+0x1cf2>
    466e:	00001097          	auipc	ra,0x1
    4672:	7ca080e7          	jalr	1994(ra) # 5e38 <printf>
}
    4676:	70e2                	ld	ra,56(sp)
    4678:	7442                	ld	s0,48(sp)
    467a:	74a2                	ld	s1,40(sp)
    467c:	7902                	ld	s2,32(sp)
    467e:	69e2                	ld	s3,24(sp)
    4680:	6a42                	ld	s4,16(sp)
    4682:	6121                	addi	sp,sp,64
    4684:	8082                	ret
  close(pfds[0]);
    4686:	fc842503          	lw	a0,-56(s0)
    468a:	00001097          	auipc	ra,0x1
    468e:	446080e7          	jalr	1094(ra) # 5ad0 <close>
  printf("kill... ");
    4692:	00003517          	auipc	a0,0x3
    4696:	56e50513          	addi	a0,a0,1390 # 7c00 <malloc+0x1d0a>
    469a:	00001097          	auipc	ra,0x1
    469e:	79e080e7          	jalr	1950(ra) # 5e38 <printf>
  kill(pid1);
    46a2:	8526                	mv	a0,s1
    46a4:	00001097          	auipc	ra,0x1
    46a8:	434080e7          	jalr	1076(ra) # 5ad8 <kill>
  kill(pid2);
    46ac:	854e                	mv	a0,s3
    46ae:	00001097          	auipc	ra,0x1
    46b2:	42a080e7          	jalr	1066(ra) # 5ad8 <kill>
  kill(pid3);
    46b6:	8552                	mv	a0,s4
    46b8:	00001097          	auipc	ra,0x1
    46bc:	420080e7          	jalr	1056(ra) # 5ad8 <kill>
  printf("wait... ");
    46c0:	00003517          	auipc	a0,0x3
    46c4:	55050513          	addi	a0,a0,1360 # 7c10 <malloc+0x1d1a>
    46c8:	00001097          	auipc	ra,0x1
    46cc:	770080e7          	jalr	1904(ra) # 5e38 <printf>
  wait(0);
    46d0:	4501                	li	a0,0
    46d2:	00001097          	auipc	ra,0x1
    46d6:	3de080e7          	jalr	990(ra) # 5ab0 <wait>
  wait(0);
    46da:	4501                	li	a0,0
    46dc:	00001097          	auipc	ra,0x1
    46e0:	3d4080e7          	jalr	980(ra) # 5ab0 <wait>
  wait(0);
    46e4:	4501                	li	a0,0
    46e6:	00001097          	auipc	ra,0x1
    46ea:	3ca080e7          	jalr	970(ra) # 5ab0 <wait>
    46ee:	b761                	j	4676 <preempt+0x12a>

00000000000046f0 <sbrkfail>:
{
    46f0:	7119                	addi	sp,sp,-128
    46f2:	fc86                	sd	ra,120(sp)
    46f4:	f8a2                	sd	s0,112(sp)
    46f6:	f4a6                	sd	s1,104(sp)
    46f8:	f0ca                	sd	s2,96(sp)
    46fa:	ecce                	sd	s3,88(sp)
    46fc:	e8d2                	sd	s4,80(sp)
    46fe:	e4d6                	sd	s5,72(sp)
    4700:	0100                	addi	s0,sp,128
    4702:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    4704:	fb040513          	addi	a0,s0,-80
    4708:	00001097          	auipc	ra,0x1
    470c:	3b0080e7          	jalr	944(ra) # 5ab8 <pipe>
    4710:	e901                	bnez	a0,4720 <sbrkfail+0x30>
    4712:	f8040493          	addi	s1,s0,-128
    4716:	fa840993          	addi	s3,s0,-88
    471a:	8926                	mv	s2,s1
    if(pids[i] != -1)
    471c:	5a7d                	li	s4,-1
    471e:	a085                	j	477e <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    4720:	85d6                	mv	a1,s5
    4722:	00002517          	auipc	a0,0x2
    4726:	2a650513          	addi	a0,a0,678 # 69c8 <malloc+0xad2>
    472a:	00001097          	auipc	ra,0x1
    472e:	70e080e7          	jalr	1806(ra) # 5e38 <printf>
    exit(1);
    4732:	4505                	li	a0,1
    4734:	00001097          	auipc	ra,0x1
    4738:	374080e7          	jalr	884(ra) # 5aa8 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    473c:	00001097          	auipc	ra,0x1
    4740:	3f4080e7          	jalr	1012(ra) # 5b30 <sbrk>
    4744:	064007b7          	lui	a5,0x6400
    4748:	40a7853b          	subw	a0,a5,a0
    474c:	00001097          	auipc	ra,0x1
    4750:	3e4080e7          	jalr	996(ra) # 5b30 <sbrk>
      write(fds[1], "x", 1);
    4754:	4605                	li	a2,1
    4756:	00002597          	auipc	a1,0x2
    475a:	95258593          	addi	a1,a1,-1710 # 60a8 <malloc+0x1b2>
    475e:	fb442503          	lw	a0,-76(s0)
    4762:	00001097          	auipc	ra,0x1
    4766:	366080e7          	jalr	870(ra) # 5ac8 <write>
      for(;;) sleep(1000);
    476a:	3e800513          	li	a0,1000
    476e:	00001097          	auipc	ra,0x1
    4772:	3ca080e7          	jalr	970(ra) # 5b38 <sleep>
    4776:	bfd5                	j	476a <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4778:	0911                	addi	s2,s2,4
    477a:	03390563          	beq	s2,s3,47a4 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    477e:	00001097          	auipc	ra,0x1
    4782:	322080e7          	jalr	802(ra) # 5aa0 <fork>
    4786:	00a92023          	sw	a0,0(s2)
    478a:	d94d                	beqz	a0,473c <sbrkfail+0x4c>
    if(pids[i] != -1)
    478c:	ff4506e3          	beq	a0,s4,4778 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4790:	4605                	li	a2,1
    4792:	faf40593          	addi	a1,s0,-81
    4796:	fb042503          	lw	a0,-80(s0)
    479a:	00001097          	auipc	ra,0x1
    479e:	326080e7          	jalr	806(ra) # 5ac0 <read>
    47a2:	bfd9                	j	4778 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    47a4:	6505                	lui	a0,0x1
    47a6:	00001097          	auipc	ra,0x1
    47aa:	38a080e7          	jalr	906(ra) # 5b30 <sbrk>
    47ae:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    47b0:	597d                	li	s2,-1
    47b2:	a021                	j	47ba <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    47b4:	0491                	addi	s1,s1,4
    47b6:	01348f63          	beq	s1,s3,47d4 <sbrkfail+0xe4>
    if(pids[i] == -1)
    47ba:	4088                	lw	a0,0(s1)
    47bc:	ff250ce3          	beq	a0,s2,47b4 <sbrkfail+0xc4>
    kill(pids[i]);
    47c0:	00001097          	auipc	ra,0x1
    47c4:	318080e7          	jalr	792(ra) # 5ad8 <kill>
    wait(0);
    47c8:	4501                	li	a0,0
    47ca:	00001097          	auipc	ra,0x1
    47ce:	2e6080e7          	jalr	742(ra) # 5ab0 <wait>
    47d2:	b7cd                	j	47b4 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    47d4:	57fd                	li	a5,-1
    47d6:	04fa0163          	beq	s4,a5,4818 <sbrkfail+0x128>
  pid = fork();
    47da:	00001097          	auipc	ra,0x1
    47de:	2c6080e7          	jalr	710(ra) # 5aa0 <fork>
    47e2:	84aa                	mv	s1,a0
  if(pid < 0){
    47e4:	04054863          	bltz	a0,4834 <sbrkfail+0x144>
  if(pid == 0){
    47e8:	c525                	beqz	a0,4850 <sbrkfail+0x160>
  wait(&xstatus);
    47ea:	fbc40513          	addi	a0,s0,-68
    47ee:	00001097          	auipc	ra,0x1
    47f2:	2c2080e7          	jalr	706(ra) # 5ab0 <wait>
  if(xstatus != -1 && xstatus != 2)
    47f6:	fbc42783          	lw	a5,-68(s0)
    47fa:	577d                	li	a4,-1
    47fc:	00e78563          	beq	a5,a4,4806 <sbrkfail+0x116>
    4800:	4709                	li	a4,2
    4802:	08e79d63          	bne	a5,a4,489c <sbrkfail+0x1ac>
}
    4806:	70e6                	ld	ra,120(sp)
    4808:	7446                	ld	s0,112(sp)
    480a:	74a6                	ld	s1,104(sp)
    480c:	7906                	ld	s2,96(sp)
    480e:	69e6                	ld	s3,88(sp)
    4810:	6a46                	ld	s4,80(sp)
    4812:	6aa6                	ld	s5,72(sp)
    4814:	6109                	addi	sp,sp,128
    4816:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4818:	85d6                	mv	a1,s5
    481a:	00003517          	auipc	a0,0x3
    481e:	40650513          	addi	a0,a0,1030 # 7c20 <malloc+0x1d2a>
    4822:	00001097          	auipc	ra,0x1
    4826:	616080e7          	jalr	1558(ra) # 5e38 <printf>
    exit(1);
    482a:	4505                	li	a0,1
    482c:	00001097          	auipc	ra,0x1
    4830:	27c080e7          	jalr	636(ra) # 5aa8 <exit>
    printf("%s: fork failed\n", s);
    4834:	85d6                	mv	a1,s5
    4836:	00002517          	auipc	a0,0x2
    483a:	08a50513          	addi	a0,a0,138 # 68c0 <malloc+0x9ca>
    483e:	00001097          	auipc	ra,0x1
    4842:	5fa080e7          	jalr	1530(ra) # 5e38 <printf>
    exit(1);
    4846:	4505                	li	a0,1
    4848:	00001097          	auipc	ra,0x1
    484c:	260080e7          	jalr	608(ra) # 5aa8 <exit>
    a = sbrk(0);
    4850:	4501                	li	a0,0
    4852:	00001097          	auipc	ra,0x1
    4856:	2de080e7          	jalr	734(ra) # 5b30 <sbrk>
    485a:	892a                	mv	s2,a0
    sbrk(10*BIG);
    485c:	3e800537          	lui	a0,0x3e800
    4860:	00001097          	auipc	ra,0x1
    4864:	2d0080e7          	jalr	720(ra) # 5b30 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4868:	87ca                	mv	a5,s2
    486a:	3e800737          	lui	a4,0x3e800
    486e:	993a                	add	s2,s2,a4
    4870:	6705                	lui	a4,0x1
      n += *(a+i);
    4872:	0007c683          	lbu	a3,0(a5) # 6400000 <base+0x63f03a8>
    4876:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4878:	97ba                	add	a5,a5,a4
    487a:	ff279ce3          	bne	a5,s2,4872 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    487e:	8626                	mv	a2,s1
    4880:	85d6                	mv	a1,s5
    4882:	00003517          	auipc	a0,0x3
    4886:	3be50513          	addi	a0,a0,958 # 7c40 <malloc+0x1d4a>
    488a:	00001097          	auipc	ra,0x1
    488e:	5ae080e7          	jalr	1454(ra) # 5e38 <printf>
    exit(1);
    4892:	4505                	li	a0,1
    4894:	00001097          	auipc	ra,0x1
    4898:	214080e7          	jalr	532(ra) # 5aa8 <exit>
    exit(1);
    489c:	4505                	li	a0,1
    489e:	00001097          	auipc	ra,0x1
    48a2:	20a080e7          	jalr	522(ra) # 5aa8 <exit>

00000000000048a6 <mem>:
{
    48a6:	7139                	addi	sp,sp,-64
    48a8:	fc06                	sd	ra,56(sp)
    48aa:	f822                	sd	s0,48(sp)
    48ac:	f426                	sd	s1,40(sp)
    48ae:	f04a                	sd	s2,32(sp)
    48b0:	ec4e                	sd	s3,24(sp)
    48b2:	0080                	addi	s0,sp,64
    48b4:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    48b6:	00001097          	auipc	ra,0x1
    48ba:	1ea080e7          	jalr	490(ra) # 5aa0 <fork>
    m1 = 0;
    48be:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    48c0:	6909                	lui	s2,0x2
    48c2:	71190913          	addi	s2,s2,1809 # 2711 <rwsbrk+0x25>
  if((pid = fork()) == 0){
    48c6:	c115                	beqz	a0,48ea <mem+0x44>
    wait(&xstatus);
    48c8:	fcc40513          	addi	a0,s0,-52
    48cc:	00001097          	auipc	ra,0x1
    48d0:	1e4080e7          	jalr	484(ra) # 5ab0 <wait>
    if(xstatus == -1){
    48d4:	fcc42503          	lw	a0,-52(s0)
    48d8:	57fd                	li	a5,-1
    48da:	06f50363          	beq	a0,a5,4940 <mem+0x9a>
    exit(xstatus);
    48de:	00001097          	auipc	ra,0x1
    48e2:	1ca080e7          	jalr	458(ra) # 5aa8 <exit>
      *(char**)m2 = m1;
    48e6:	e104                	sd	s1,0(a0)
      m1 = m2;
    48e8:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    48ea:	854a                	mv	a0,s2
    48ec:	00001097          	auipc	ra,0x1
    48f0:	60a080e7          	jalr	1546(ra) # 5ef6 <malloc>
    48f4:	f96d                	bnez	a0,48e6 <mem+0x40>
    while(m1){
    48f6:	c881                	beqz	s1,4906 <mem+0x60>
      m2 = *(char**)m1;
    48f8:	8526                	mv	a0,s1
    48fa:	6084                	ld	s1,0(s1)
      free(m1);
    48fc:	00001097          	auipc	ra,0x1
    4900:	572080e7          	jalr	1394(ra) # 5e6e <free>
    while(m1){
    4904:	f8f5                	bnez	s1,48f8 <mem+0x52>
    m1 = malloc(1024*20);
    4906:	6515                	lui	a0,0x5
    4908:	00001097          	auipc	ra,0x1
    490c:	5ee080e7          	jalr	1518(ra) # 5ef6 <malloc>
    if(m1 == 0){
    4910:	c911                	beqz	a0,4924 <mem+0x7e>
    free(m1);
    4912:	00001097          	auipc	ra,0x1
    4916:	55c080e7          	jalr	1372(ra) # 5e6e <free>
    exit(0);
    491a:	4501                	li	a0,0
    491c:	00001097          	auipc	ra,0x1
    4920:	18c080e7          	jalr	396(ra) # 5aa8 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4924:	85ce                	mv	a1,s3
    4926:	00003517          	auipc	a0,0x3
    492a:	34a50513          	addi	a0,a0,842 # 7c70 <malloc+0x1d7a>
    492e:	00001097          	auipc	ra,0x1
    4932:	50a080e7          	jalr	1290(ra) # 5e38 <printf>
      exit(1);
    4936:	4505                	li	a0,1
    4938:	00001097          	auipc	ra,0x1
    493c:	170080e7          	jalr	368(ra) # 5aa8 <exit>
      exit(0);
    4940:	4501                	li	a0,0
    4942:	00001097          	auipc	ra,0x1
    4946:	166080e7          	jalr	358(ra) # 5aa8 <exit>

000000000000494a <sharedfd>:
{
    494a:	7159                	addi	sp,sp,-112
    494c:	f486                	sd	ra,104(sp)
    494e:	f0a2                	sd	s0,96(sp)
    4950:	eca6                	sd	s1,88(sp)
    4952:	e8ca                	sd	s2,80(sp)
    4954:	e4ce                	sd	s3,72(sp)
    4956:	e0d2                	sd	s4,64(sp)
    4958:	fc56                	sd	s5,56(sp)
    495a:	f85a                	sd	s6,48(sp)
    495c:	f45e                	sd	s7,40(sp)
    495e:	1880                	addi	s0,sp,112
    4960:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4962:	00003517          	auipc	a0,0x3
    4966:	32e50513          	addi	a0,a0,814 # 7c90 <malloc+0x1d9a>
    496a:	00001097          	auipc	ra,0x1
    496e:	18e080e7          	jalr	398(ra) # 5af8 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4972:	20200593          	li	a1,514
    4976:	00003517          	auipc	a0,0x3
    497a:	31a50513          	addi	a0,a0,794 # 7c90 <malloc+0x1d9a>
    497e:	00001097          	auipc	ra,0x1
    4982:	16a080e7          	jalr	362(ra) # 5ae8 <open>
  if(fd < 0){
    4986:	04054a63          	bltz	a0,49da <sharedfd+0x90>
    498a:	892a                	mv	s2,a0
  pid = fork();
    498c:	00001097          	auipc	ra,0x1
    4990:	114080e7          	jalr	276(ra) # 5aa0 <fork>
    4994:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4996:	06300593          	li	a1,99
    499a:	c119                	beqz	a0,49a0 <sharedfd+0x56>
    499c:	07000593          	li	a1,112
    49a0:	4629                	li	a2,10
    49a2:	fa040513          	addi	a0,s0,-96
    49a6:	00001097          	auipc	ra,0x1
    49aa:	f06080e7          	jalr	-250(ra) # 58ac <memset>
    49ae:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    49b2:	4629                	li	a2,10
    49b4:	fa040593          	addi	a1,s0,-96
    49b8:	854a                	mv	a0,s2
    49ba:	00001097          	auipc	ra,0x1
    49be:	10e080e7          	jalr	270(ra) # 5ac8 <write>
    49c2:	47a9                	li	a5,10
    49c4:	02f51963          	bne	a0,a5,49f6 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    49c8:	34fd                	addiw	s1,s1,-1
    49ca:	f4e5                	bnez	s1,49b2 <sharedfd+0x68>
  if(pid == 0) {
    49cc:	04099363          	bnez	s3,4a12 <sharedfd+0xc8>
    exit(0);
    49d0:	4501                	li	a0,0
    49d2:	00001097          	auipc	ra,0x1
    49d6:	0d6080e7          	jalr	214(ra) # 5aa8 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    49da:	85d2                	mv	a1,s4
    49dc:	00003517          	auipc	a0,0x3
    49e0:	2c450513          	addi	a0,a0,708 # 7ca0 <malloc+0x1daa>
    49e4:	00001097          	auipc	ra,0x1
    49e8:	454080e7          	jalr	1108(ra) # 5e38 <printf>
    exit(1);
    49ec:	4505                	li	a0,1
    49ee:	00001097          	auipc	ra,0x1
    49f2:	0ba080e7          	jalr	186(ra) # 5aa8 <exit>
      printf("%s: write sharedfd failed\n", s);
    49f6:	85d2                	mv	a1,s4
    49f8:	00003517          	auipc	a0,0x3
    49fc:	2d050513          	addi	a0,a0,720 # 7cc8 <malloc+0x1dd2>
    4a00:	00001097          	auipc	ra,0x1
    4a04:	438080e7          	jalr	1080(ra) # 5e38 <printf>
      exit(1);
    4a08:	4505                	li	a0,1
    4a0a:	00001097          	auipc	ra,0x1
    4a0e:	09e080e7          	jalr	158(ra) # 5aa8 <exit>
    wait(&xstatus);
    4a12:	f9c40513          	addi	a0,s0,-100
    4a16:	00001097          	auipc	ra,0x1
    4a1a:	09a080e7          	jalr	154(ra) # 5ab0 <wait>
    if(xstatus != 0)
    4a1e:	f9c42983          	lw	s3,-100(s0)
    4a22:	00098763          	beqz	s3,4a30 <sharedfd+0xe6>
      exit(xstatus);
    4a26:	854e                	mv	a0,s3
    4a28:	00001097          	auipc	ra,0x1
    4a2c:	080080e7          	jalr	128(ra) # 5aa8 <exit>
  close(fd);
    4a30:	854a                	mv	a0,s2
    4a32:	00001097          	auipc	ra,0x1
    4a36:	09e080e7          	jalr	158(ra) # 5ad0 <close>
  fd = open("sharedfd", 0);
    4a3a:	4581                	li	a1,0
    4a3c:	00003517          	auipc	a0,0x3
    4a40:	25450513          	addi	a0,a0,596 # 7c90 <malloc+0x1d9a>
    4a44:	00001097          	auipc	ra,0x1
    4a48:	0a4080e7          	jalr	164(ra) # 5ae8 <open>
    4a4c:	8baa                	mv	s7,a0
  nc = np = 0;
    4a4e:	8ace                	mv	s5,s3
  if(fd < 0){
    4a50:	02054563          	bltz	a0,4a7a <sharedfd+0x130>
    4a54:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4a58:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4a5c:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4a60:	4629                	li	a2,10
    4a62:	fa040593          	addi	a1,s0,-96
    4a66:	855e                	mv	a0,s7
    4a68:	00001097          	auipc	ra,0x1
    4a6c:	058080e7          	jalr	88(ra) # 5ac0 <read>
    4a70:	02a05f63          	blez	a0,4aae <sharedfd+0x164>
    4a74:	fa040793          	addi	a5,s0,-96
    4a78:	a01d                	j	4a9e <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4a7a:	85d2                	mv	a1,s4
    4a7c:	00003517          	auipc	a0,0x3
    4a80:	26c50513          	addi	a0,a0,620 # 7ce8 <malloc+0x1df2>
    4a84:	00001097          	auipc	ra,0x1
    4a88:	3b4080e7          	jalr	948(ra) # 5e38 <printf>
    exit(1);
    4a8c:	4505                	li	a0,1
    4a8e:	00001097          	auipc	ra,0x1
    4a92:	01a080e7          	jalr	26(ra) # 5aa8 <exit>
        nc++;
    4a96:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4a98:	0785                	addi	a5,a5,1
    4a9a:	fd2783e3          	beq	a5,s2,4a60 <sharedfd+0x116>
      if(buf[i] == 'c')
    4a9e:	0007c703          	lbu	a4,0(a5)
    4aa2:	fe970ae3          	beq	a4,s1,4a96 <sharedfd+0x14c>
      if(buf[i] == 'p')
    4aa6:	ff6719e3          	bne	a4,s6,4a98 <sharedfd+0x14e>
        np++;
    4aaa:	2a85                	addiw	s5,s5,1
    4aac:	b7f5                	j	4a98 <sharedfd+0x14e>
  close(fd);
    4aae:	855e                	mv	a0,s7
    4ab0:	00001097          	auipc	ra,0x1
    4ab4:	020080e7          	jalr	32(ra) # 5ad0 <close>
  unlink("sharedfd");
    4ab8:	00003517          	auipc	a0,0x3
    4abc:	1d850513          	addi	a0,a0,472 # 7c90 <malloc+0x1d9a>
    4ac0:	00001097          	auipc	ra,0x1
    4ac4:	038080e7          	jalr	56(ra) # 5af8 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4ac8:	6789                	lui	a5,0x2
    4aca:	71078793          	addi	a5,a5,1808 # 2710 <rwsbrk+0x24>
    4ace:	00f99763          	bne	s3,a5,4adc <sharedfd+0x192>
    4ad2:	6789                	lui	a5,0x2
    4ad4:	71078793          	addi	a5,a5,1808 # 2710 <rwsbrk+0x24>
    4ad8:	02fa8063          	beq	s5,a5,4af8 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4adc:	85d2                	mv	a1,s4
    4ade:	00003517          	auipc	a0,0x3
    4ae2:	23250513          	addi	a0,a0,562 # 7d10 <malloc+0x1e1a>
    4ae6:	00001097          	auipc	ra,0x1
    4aea:	352080e7          	jalr	850(ra) # 5e38 <printf>
    exit(1);
    4aee:	4505                	li	a0,1
    4af0:	00001097          	auipc	ra,0x1
    4af4:	fb8080e7          	jalr	-72(ra) # 5aa8 <exit>
    exit(0);
    4af8:	4501                	li	a0,0
    4afa:	00001097          	auipc	ra,0x1
    4afe:	fae080e7          	jalr	-82(ra) # 5aa8 <exit>

0000000000004b02 <fourfiles>:
{
    4b02:	7171                	addi	sp,sp,-176
    4b04:	f506                	sd	ra,168(sp)
    4b06:	f122                	sd	s0,160(sp)
    4b08:	ed26                	sd	s1,152(sp)
    4b0a:	e94a                	sd	s2,144(sp)
    4b0c:	e54e                	sd	s3,136(sp)
    4b0e:	e152                	sd	s4,128(sp)
    4b10:	fcd6                	sd	s5,120(sp)
    4b12:	f8da                	sd	s6,112(sp)
    4b14:	f4de                	sd	s7,104(sp)
    4b16:	f0e2                	sd	s8,96(sp)
    4b18:	ece6                	sd	s9,88(sp)
    4b1a:	e8ea                	sd	s10,80(sp)
    4b1c:	e4ee                	sd	s11,72(sp)
    4b1e:	1900                	addi	s0,sp,176
    4b20:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    4b24:	00001797          	auipc	a5,0x1
    4b28:	4bc78793          	addi	a5,a5,1212 # 5fe0 <malloc+0xea>
    4b2c:	f6f43823          	sd	a5,-144(s0)
    4b30:	00001797          	auipc	a5,0x1
    4b34:	4b878793          	addi	a5,a5,1208 # 5fe8 <malloc+0xf2>
    4b38:	f6f43c23          	sd	a5,-136(s0)
    4b3c:	00001797          	auipc	a5,0x1
    4b40:	4b478793          	addi	a5,a5,1204 # 5ff0 <malloc+0xfa>
    4b44:	f8f43023          	sd	a5,-128(s0)
    4b48:	00001797          	auipc	a5,0x1
    4b4c:	4b078793          	addi	a5,a5,1200 # 5ff8 <malloc+0x102>
    4b50:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4b54:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4b58:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    4b5a:	4481                	li	s1,0
    4b5c:	4a11                	li	s4,4
    fname = names[pi];
    4b5e:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4b62:	854e                	mv	a0,s3
    4b64:	00001097          	auipc	ra,0x1
    4b68:	f94080e7          	jalr	-108(ra) # 5af8 <unlink>
    pid = fork();
    4b6c:	00001097          	auipc	ra,0x1
    4b70:	f34080e7          	jalr	-204(ra) # 5aa0 <fork>
    if(pid < 0){
    4b74:	04054463          	bltz	a0,4bbc <fourfiles+0xba>
    if(pid == 0){
    4b78:	c12d                	beqz	a0,4bda <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    4b7a:	2485                	addiw	s1,s1,1
    4b7c:	0921                	addi	s2,s2,8
    4b7e:	ff4490e3          	bne	s1,s4,4b5e <fourfiles+0x5c>
    4b82:	4491                	li	s1,4
    wait(&xstatus);
    4b84:	f6c40513          	addi	a0,s0,-148
    4b88:	00001097          	auipc	ra,0x1
    4b8c:	f28080e7          	jalr	-216(ra) # 5ab0 <wait>
    if(xstatus != 0)
    4b90:	f6c42b03          	lw	s6,-148(s0)
    4b94:	0c0b1e63          	bnez	s6,4c70 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    4b98:	34fd                	addiw	s1,s1,-1
    4b9a:	f4ed                	bnez	s1,4b84 <fourfiles+0x82>
    4b9c:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4ba0:	00008a17          	auipc	s4,0x8
    4ba4:	0b8a0a13          	addi	s4,s4,184 # cc58 <buf>
    4ba8:	00008a97          	auipc	s5,0x8
    4bac:	0b1a8a93          	addi	s5,s5,177 # cc59 <buf+0x1>
    if(total != N*SZ){
    4bb0:	6d85                	lui	s11,0x1
    4bb2:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0x2e>
  for(i = 0; i < NCHILD; i++){
    4bb6:	03400d13          	li	s10,52
    4bba:	aa1d                	j	4cf0 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    4bbc:	f5843583          	ld	a1,-168(s0)
    4bc0:	00002517          	auipc	a0,0x2
    4bc4:	10850513          	addi	a0,a0,264 # 6cc8 <malloc+0xdd2>
    4bc8:	00001097          	auipc	ra,0x1
    4bcc:	270080e7          	jalr	624(ra) # 5e38 <printf>
      exit(1);
    4bd0:	4505                	li	a0,1
    4bd2:	00001097          	auipc	ra,0x1
    4bd6:	ed6080e7          	jalr	-298(ra) # 5aa8 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4bda:	20200593          	li	a1,514
    4bde:	854e                	mv	a0,s3
    4be0:	00001097          	auipc	ra,0x1
    4be4:	f08080e7          	jalr	-248(ra) # 5ae8 <open>
    4be8:	892a                	mv	s2,a0
      if(fd < 0){
    4bea:	04054763          	bltz	a0,4c38 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    4bee:	1f400613          	li	a2,500
    4bf2:	0304859b          	addiw	a1,s1,48
    4bf6:	00008517          	auipc	a0,0x8
    4bfa:	06250513          	addi	a0,a0,98 # cc58 <buf>
    4bfe:	00001097          	auipc	ra,0x1
    4c02:	cae080e7          	jalr	-850(ra) # 58ac <memset>
    4c06:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4c08:	00008997          	auipc	s3,0x8
    4c0c:	05098993          	addi	s3,s3,80 # cc58 <buf>
    4c10:	1f400613          	li	a2,500
    4c14:	85ce                	mv	a1,s3
    4c16:	854a                	mv	a0,s2
    4c18:	00001097          	auipc	ra,0x1
    4c1c:	eb0080e7          	jalr	-336(ra) # 5ac8 <write>
    4c20:	85aa                	mv	a1,a0
    4c22:	1f400793          	li	a5,500
    4c26:	02f51863          	bne	a0,a5,4c56 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    4c2a:	34fd                	addiw	s1,s1,-1
    4c2c:	f0f5                	bnez	s1,4c10 <fourfiles+0x10e>
      exit(0);
    4c2e:	4501                	li	a0,0
    4c30:	00001097          	auipc	ra,0x1
    4c34:	e78080e7          	jalr	-392(ra) # 5aa8 <exit>
        printf("create failed\n", s);
    4c38:	f5843583          	ld	a1,-168(s0)
    4c3c:	00003517          	auipc	a0,0x3
    4c40:	0ec50513          	addi	a0,a0,236 # 7d28 <malloc+0x1e32>
    4c44:	00001097          	auipc	ra,0x1
    4c48:	1f4080e7          	jalr	500(ra) # 5e38 <printf>
        exit(1);
    4c4c:	4505                	li	a0,1
    4c4e:	00001097          	auipc	ra,0x1
    4c52:	e5a080e7          	jalr	-422(ra) # 5aa8 <exit>
          printf("write failed %d\n", n);
    4c56:	00003517          	auipc	a0,0x3
    4c5a:	0e250513          	addi	a0,a0,226 # 7d38 <malloc+0x1e42>
    4c5e:	00001097          	auipc	ra,0x1
    4c62:	1da080e7          	jalr	474(ra) # 5e38 <printf>
          exit(1);
    4c66:	4505                	li	a0,1
    4c68:	00001097          	auipc	ra,0x1
    4c6c:	e40080e7          	jalr	-448(ra) # 5aa8 <exit>
      exit(xstatus);
    4c70:	855a                	mv	a0,s6
    4c72:	00001097          	auipc	ra,0x1
    4c76:	e36080e7          	jalr	-458(ra) # 5aa8 <exit>
          printf("wrong char\n", s);
    4c7a:	f5843583          	ld	a1,-168(s0)
    4c7e:	00003517          	auipc	a0,0x3
    4c82:	0d250513          	addi	a0,a0,210 # 7d50 <malloc+0x1e5a>
    4c86:	00001097          	auipc	ra,0x1
    4c8a:	1b2080e7          	jalr	434(ra) # 5e38 <printf>
          exit(1);
    4c8e:	4505                	li	a0,1
    4c90:	00001097          	auipc	ra,0x1
    4c94:	e18080e7          	jalr	-488(ra) # 5aa8 <exit>
      total += n;
    4c98:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4c9c:	660d                	lui	a2,0x3
    4c9e:	85d2                	mv	a1,s4
    4ca0:	854e                	mv	a0,s3
    4ca2:	00001097          	auipc	ra,0x1
    4ca6:	e1e080e7          	jalr	-482(ra) # 5ac0 <read>
    4caa:	02a05363          	blez	a0,4cd0 <fourfiles+0x1ce>
    4cae:	00008797          	auipc	a5,0x8
    4cb2:	faa78793          	addi	a5,a5,-86 # cc58 <buf>
    4cb6:	fff5069b          	addiw	a3,a0,-1
    4cba:	1682                	slli	a3,a3,0x20
    4cbc:	9281                	srli	a3,a3,0x20
    4cbe:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    4cc0:	0007c703          	lbu	a4,0(a5)
    4cc4:	fa971be3          	bne	a4,s1,4c7a <fourfiles+0x178>
      for(j = 0; j < n; j++){
    4cc8:	0785                	addi	a5,a5,1
    4cca:	fed79be3          	bne	a5,a3,4cc0 <fourfiles+0x1be>
    4cce:	b7e9                	j	4c98 <fourfiles+0x196>
    close(fd);
    4cd0:	854e                	mv	a0,s3
    4cd2:	00001097          	auipc	ra,0x1
    4cd6:	dfe080e7          	jalr	-514(ra) # 5ad0 <close>
    if(total != N*SZ){
    4cda:	03b91863          	bne	s2,s11,4d0a <fourfiles+0x208>
    unlink(fname);
    4cde:	8566                	mv	a0,s9
    4ce0:	00001097          	auipc	ra,0x1
    4ce4:	e18080e7          	jalr	-488(ra) # 5af8 <unlink>
  for(i = 0; i < NCHILD; i++){
    4ce8:	0c21                	addi	s8,s8,8
    4cea:	2b85                	addiw	s7,s7,1
    4cec:	03ab8d63          	beq	s7,s10,4d26 <fourfiles+0x224>
    fname = names[i];
    4cf0:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4cf4:	4581                	li	a1,0
    4cf6:	8566                	mv	a0,s9
    4cf8:	00001097          	auipc	ra,0x1
    4cfc:	df0080e7          	jalr	-528(ra) # 5ae8 <open>
    4d00:	89aa                	mv	s3,a0
    total = 0;
    4d02:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    4d04:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4d08:	bf51                	j	4c9c <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    4d0a:	85ca                	mv	a1,s2
    4d0c:	00003517          	auipc	a0,0x3
    4d10:	05450513          	addi	a0,a0,84 # 7d60 <malloc+0x1e6a>
    4d14:	00001097          	auipc	ra,0x1
    4d18:	124080e7          	jalr	292(ra) # 5e38 <printf>
      exit(1);
    4d1c:	4505                	li	a0,1
    4d1e:	00001097          	auipc	ra,0x1
    4d22:	d8a080e7          	jalr	-630(ra) # 5aa8 <exit>
}
    4d26:	70aa                	ld	ra,168(sp)
    4d28:	740a                	ld	s0,160(sp)
    4d2a:	64ea                	ld	s1,152(sp)
    4d2c:	694a                	ld	s2,144(sp)
    4d2e:	69aa                	ld	s3,136(sp)
    4d30:	6a0a                	ld	s4,128(sp)
    4d32:	7ae6                	ld	s5,120(sp)
    4d34:	7b46                	ld	s6,112(sp)
    4d36:	7ba6                	ld	s7,104(sp)
    4d38:	7c06                	ld	s8,96(sp)
    4d3a:	6ce6                	ld	s9,88(sp)
    4d3c:	6d46                	ld	s10,80(sp)
    4d3e:	6da6                	ld	s11,72(sp)
    4d40:	614d                	addi	sp,sp,176
    4d42:	8082                	ret

0000000000004d44 <concreate>:
{
    4d44:	7135                	addi	sp,sp,-160
    4d46:	ed06                	sd	ra,152(sp)
    4d48:	e922                	sd	s0,144(sp)
    4d4a:	e526                	sd	s1,136(sp)
    4d4c:	e14a                	sd	s2,128(sp)
    4d4e:	fcce                	sd	s3,120(sp)
    4d50:	f8d2                	sd	s4,112(sp)
    4d52:	f4d6                	sd	s5,104(sp)
    4d54:	f0da                	sd	s6,96(sp)
    4d56:	ecde                	sd	s7,88(sp)
    4d58:	1100                	addi	s0,sp,160
    4d5a:	89aa                	mv	s3,a0
  file[0] = 'C';
    4d5c:	04300793          	li	a5,67
    4d60:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4d64:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4d68:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4d6a:	4b0d                	li	s6,3
    4d6c:	4a85                	li	s5,1
      link("C0", file);
    4d6e:	00003b97          	auipc	s7,0x3
    4d72:	00ab8b93          	addi	s7,s7,10 # 7d78 <malloc+0x1e82>
  for(i = 0; i < N; i++){
    4d76:	02800a13          	li	s4,40
    4d7a:	acc1                	j	504a <concreate+0x306>
      link("C0", file);
    4d7c:	fa840593          	addi	a1,s0,-88
    4d80:	855e                	mv	a0,s7
    4d82:	00001097          	auipc	ra,0x1
    4d86:	d86080e7          	jalr	-634(ra) # 5b08 <link>
    if(pid == 0) {
    4d8a:	a45d                	j	5030 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    4d8c:	4795                	li	a5,5
    4d8e:	02f9693b          	remw	s2,s2,a5
    4d92:	4785                	li	a5,1
    4d94:	02f90b63          	beq	s2,a5,4dca <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4d98:	20200593          	li	a1,514
    4d9c:	fa840513          	addi	a0,s0,-88
    4da0:	00001097          	auipc	ra,0x1
    4da4:	d48080e7          	jalr	-696(ra) # 5ae8 <open>
      if(fd < 0){
    4da8:	26055b63          	bgez	a0,501e <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    4dac:	fa840593          	addi	a1,s0,-88
    4db0:	00003517          	auipc	a0,0x3
    4db4:	fd050513          	addi	a0,a0,-48 # 7d80 <malloc+0x1e8a>
    4db8:	00001097          	auipc	ra,0x1
    4dbc:	080080e7          	jalr	128(ra) # 5e38 <printf>
        exit(1);
    4dc0:	4505                	li	a0,1
    4dc2:	00001097          	auipc	ra,0x1
    4dc6:	ce6080e7          	jalr	-794(ra) # 5aa8 <exit>
      link("C0", file);
    4dca:	fa840593          	addi	a1,s0,-88
    4dce:	00003517          	auipc	a0,0x3
    4dd2:	faa50513          	addi	a0,a0,-86 # 7d78 <malloc+0x1e82>
    4dd6:	00001097          	auipc	ra,0x1
    4dda:	d32080e7          	jalr	-718(ra) # 5b08 <link>
      exit(0);
    4dde:	4501                	li	a0,0
    4de0:	00001097          	auipc	ra,0x1
    4de4:	cc8080e7          	jalr	-824(ra) # 5aa8 <exit>
        exit(1);
    4de8:	4505                	li	a0,1
    4dea:	00001097          	auipc	ra,0x1
    4dee:	cbe080e7          	jalr	-834(ra) # 5aa8 <exit>
  memset(fa, 0, sizeof(fa));
    4df2:	02800613          	li	a2,40
    4df6:	4581                	li	a1,0
    4df8:	f8040513          	addi	a0,s0,-128
    4dfc:	00001097          	auipc	ra,0x1
    4e00:	ab0080e7          	jalr	-1360(ra) # 58ac <memset>
  fd = open(".", 0);
    4e04:	4581                	li	a1,0
    4e06:	00002517          	auipc	a0,0x2
    4e0a:	91a50513          	addi	a0,a0,-1766 # 6720 <malloc+0x82a>
    4e0e:	00001097          	auipc	ra,0x1
    4e12:	cda080e7          	jalr	-806(ra) # 5ae8 <open>
    4e16:	892a                	mv	s2,a0
  n = 0;
    4e18:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4e1a:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4e1e:	02700b13          	li	s6,39
      fa[i] = 1;
    4e22:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4e24:	4641                	li	a2,16
    4e26:	f7040593          	addi	a1,s0,-144
    4e2a:	854a                	mv	a0,s2
    4e2c:	00001097          	auipc	ra,0x1
    4e30:	c94080e7          	jalr	-876(ra) # 5ac0 <read>
    4e34:	08a05163          	blez	a0,4eb6 <concreate+0x172>
    if(de.inum == 0)
    4e38:	f7045783          	lhu	a5,-144(s0)
    4e3c:	d7e5                	beqz	a5,4e24 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4e3e:	f7244783          	lbu	a5,-142(s0)
    4e42:	ff4791e3          	bne	a5,s4,4e24 <concreate+0xe0>
    4e46:	f7444783          	lbu	a5,-140(s0)
    4e4a:	ffe9                	bnez	a5,4e24 <concreate+0xe0>
      i = de.name[1] - '0';
    4e4c:	f7344783          	lbu	a5,-141(s0)
    4e50:	fd07879b          	addiw	a5,a5,-48
    4e54:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4e58:	00eb6f63          	bltu	s6,a4,4e76 <concreate+0x132>
      if(fa[i]){
    4e5c:	fb040793          	addi	a5,s0,-80
    4e60:	97ba                	add	a5,a5,a4
    4e62:	fd07c783          	lbu	a5,-48(a5)
    4e66:	eb85                	bnez	a5,4e96 <concreate+0x152>
      fa[i] = 1;
    4e68:	fb040793          	addi	a5,s0,-80
    4e6c:	973e                	add	a4,a4,a5
    4e6e:	fd770823          	sb	s7,-48(a4) # fd0 <linktest+0xda>
      n++;
    4e72:	2a85                	addiw	s5,s5,1
    4e74:	bf45                	j	4e24 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4e76:	f7240613          	addi	a2,s0,-142
    4e7a:	85ce                	mv	a1,s3
    4e7c:	00003517          	auipc	a0,0x3
    4e80:	f2450513          	addi	a0,a0,-220 # 7da0 <malloc+0x1eaa>
    4e84:	00001097          	auipc	ra,0x1
    4e88:	fb4080e7          	jalr	-76(ra) # 5e38 <printf>
        exit(1);
    4e8c:	4505                	li	a0,1
    4e8e:	00001097          	auipc	ra,0x1
    4e92:	c1a080e7          	jalr	-998(ra) # 5aa8 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4e96:	f7240613          	addi	a2,s0,-142
    4e9a:	85ce                	mv	a1,s3
    4e9c:	00003517          	auipc	a0,0x3
    4ea0:	f2450513          	addi	a0,a0,-220 # 7dc0 <malloc+0x1eca>
    4ea4:	00001097          	auipc	ra,0x1
    4ea8:	f94080e7          	jalr	-108(ra) # 5e38 <printf>
        exit(1);
    4eac:	4505                	li	a0,1
    4eae:	00001097          	auipc	ra,0x1
    4eb2:	bfa080e7          	jalr	-1030(ra) # 5aa8 <exit>
  close(fd);
    4eb6:	854a                	mv	a0,s2
    4eb8:	00001097          	auipc	ra,0x1
    4ebc:	c18080e7          	jalr	-1000(ra) # 5ad0 <close>
  if(n != N){
    4ec0:	02800793          	li	a5,40
    4ec4:	00fa9763          	bne	s5,a5,4ed2 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    4ec8:	4a8d                	li	s5,3
    4eca:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    4ecc:	02800a13          	li	s4,40
    4ed0:	a8c9                	j	4fa2 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4ed2:	85ce                	mv	a1,s3
    4ed4:	00003517          	auipc	a0,0x3
    4ed8:	f1450513          	addi	a0,a0,-236 # 7de8 <malloc+0x1ef2>
    4edc:	00001097          	auipc	ra,0x1
    4ee0:	f5c080e7          	jalr	-164(ra) # 5e38 <printf>
    exit(1);
    4ee4:	4505                	li	a0,1
    4ee6:	00001097          	auipc	ra,0x1
    4eea:	bc2080e7          	jalr	-1086(ra) # 5aa8 <exit>
      printf("%s: fork failed\n", s);
    4eee:	85ce                	mv	a1,s3
    4ef0:	00002517          	auipc	a0,0x2
    4ef4:	9d050513          	addi	a0,a0,-1584 # 68c0 <malloc+0x9ca>
    4ef8:	00001097          	auipc	ra,0x1
    4efc:	f40080e7          	jalr	-192(ra) # 5e38 <printf>
      exit(1);
    4f00:	4505                	li	a0,1
    4f02:	00001097          	auipc	ra,0x1
    4f06:	ba6080e7          	jalr	-1114(ra) # 5aa8 <exit>
      close(open(file, 0));
    4f0a:	4581                	li	a1,0
    4f0c:	fa840513          	addi	a0,s0,-88
    4f10:	00001097          	auipc	ra,0x1
    4f14:	bd8080e7          	jalr	-1064(ra) # 5ae8 <open>
    4f18:	00001097          	auipc	ra,0x1
    4f1c:	bb8080e7          	jalr	-1096(ra) # 5ad0 <close>
      close(open(file, 0));
    4f20:	4581                	li	a1,0
    4f22:	fa840513          	addi	a0,s0,-88
    4f26:	00001097          	auipc	ra,0x1
    4f2a:	bc2080e7          	jalr	-1086(ra) # 5ae8 <open>
    4f2e:	00001097          	auipc	ra,0x1
    4f32:	ba2080e7          	jalr	-1118(ra) # 5ad0 <close>
      close(open(file, 0));
    4f36:	4581                	li	a1,0
    4f38:	fa840513          	addi	a0,s0,-88
    4f3c:	00001097          	auipc	ra,0x1
    4f40:	bac080e7          	jalr	-1108(ra) # 5ae8 <open>
    4f44:	00001097          	auipc	ra,0x1
    4f48:	b8c080e7          	jalr	-1140(ra) # 5ad0 <close>
      close(open(file, 0));
    4f4c:	4581                	li	a1,0
    4f4e:	fa840513          	addi	a0,s0,-88
    4f52:	00001097          	auipc	ra,0x1
    4f56:	b96080e7          	jalr	-1130(ra) # 5ae8 <open>
    4f5a:	00001097          	auipc	ra,0x1
    4f5e:	b76080e7          	jalr	-1162(ra) # 5ad0 <close>
      close(open(file, 0));
    4f62:	4581                	li	a1,0
    4f64:	fa840513          	addi	a0,s0,-88
    4f68:	00001097          	auipc	ra,0x1
    4f6c:	b80080e7          	jalr	-1152(ra) # 5ae8 <open>
    4f70:	00001097          	auipc	ra,0x1
    4f74:	b60080e7          	jalr	-1184(ra) # 5ad0 <close>
      close(open(file, 0));
    4f78:	4581                	li	a1,0
    4f7a:	fa840513          	addi	a0,s0,-88
    4f7e:	00001097          	auipc	ra,0x1
    4f82:	b6a080e7          	jalr	-1174(ra) # 5ae8 <open>
    4f86:	00001097          	auipc	ra,0x1
    4f8a:	b4a080e7          	jalr	-1206(ra) # 5ad0 <close>
    if(pid == 0)
    4f8e:	08090363          	beqz	s2,5014 <concreate+0x2d0>
      wait(0);
    4f92:	4501                	li	a0,0
    4f94:	00001097          	auipc	ra,0x1
    4f98:	b1c080e7          	jalr	-1252(ra) # 5ab0 <wait>
  for(i = 0; i < N; i++){
    4f9c:	2485                	addiw	s1,s1,1
    4f9e:	0f448563          	beq	s1,s4,5088 <concreate+0x344>
    file[1] = '0' + i;
    4fa2:	0304879b          	addiw	a5,s1,48
    4fa6:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    4faa:	00001097          	auipc	ra,0x1
    4fae:	af6080e7          	jalr	-1290(ra) # 5aa0 <fork>
    4fb2:	892a                	mv	s2,a0
    if(pid < 0){
    4fb4:	f2054de3          	bltz	a0,4eee <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    4fb8:	0354e73b          	remw	a4,s1,s5
    4fbc:	00a767b3          	or	a5,a4,a0
    4fc0:	2781                	sext.w	a5,a5
    4fc2:	d7a1                	beqz	a5,4f0a <concreate+0x1c6>
    4fc4:	01671363          	bne	a4,s6,4fca <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    4fc8:	f129                	bnez	a0,4f0a <concreate+0x1c6>
      unlink(file);
    4fca:	fa840513          	addi	a0,s0,-88
    4fce:	00001097          	auipc	ra,0x1
    4fd2:	b2a080e7          	jalr	-1238(ra) # 5af8 <unlink>
      unlink(file);
    4fd6:	fa840513          	addi	a0,s0,-88
    4fda:	00001097          	auipc	ra,0x1
    4fde:	b1e080e7          	jalr	-1250(ra) # 5af8 <unlink>
      unlink(file);
    4fe2:	fa840513          	addi	a0,s0,-88
    4fe6:	00001097          	auipc	ra,0x1
    4fea:	b12080e7          	jalr	-1262(ra) # 5af8 <unlink>
      unlink(file);
    4fee:	fa840513          	addi	a0,s0,-88
    4ff2:	00001097          	auipc	ra,0x1
    4ff6:	b06080e7          	jalr	-1274(ra) # 5af8 <unlink>
      unlink(file);
    4ffa:	fa840513          	addi	a0,s0,-88
    4ffe:	00001097          	auipc	ra,0x1
    5002:	afa080e7          	jalr	-1286(ra) # 5af8 <unlink>
      unlink(file);
    5006:	fa840513          	addi	a0,s0,-88
    500a:	00001097          	auipc	ra,0x1
    500e:	aee080e7          	jalr	-1298(ra) # 5af8 <unlink>
    5012:	bfb5                	j	4f8e <concreate+0x24a>
      exit(0);
    5014:	4501                	li	a0,0
    5016:	00001097          	auipc	ra,0x1
    501a:	a92080e7          	jalr	-1390(ra) # 5aa8 <exit>
      close(fd);
    501e:	00001097          	auipc	ra,0x1
    5022:	ab2080e7          	jalr	-1358(ra) # 5ad0 <close>
    if(pid == 0) {
    5026:	bb65                	j	4dde <concreate+0x9a>
      close(fd);
    5028:	00001097          	auipc	ra,0x1
    502c:	aa8080e7          	jalr	-1368(ra) # 5ad0 <close>
      wait(&xstatus);
    5030:	f6c40513          	addi	a0,s0,-148
    5034:	00001097          	auipc	ra,0x1
    5038:	a7c080e7          	jalr	-1412(ra) # 5ab0 <wait>
      if(xstatus != 0)
    503c:	f6c42483          	lw	s1,-148(s0)
    5040:	da0494e3          	bnez	s1,4de8 <concreate+0xa4>
  for(i = 0; i < N; i++){
    5044:	2905                	addiw	s2,s2,1
    5046:	db4906e3          	beq	s2,s4,4df2 <concreate+0xae>
    file[1] = '0' + i;
    504a:	0309079b          	addiw	a5,s2,48
    504e:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    5052:	fa840513          	addi	a0,s0,-88
    5056:	00001097          	auipc	ra,0x1
    505a:	aa2080e7          	jalr	-1374(ra) # 5af8 <unlink>
    pid = fork();
    505e:	00001097          	auipc	ra,0x1
    5062:	a42080e7          	jalr	-1470(ra) # 5aa0 <fork>
    if(pid && (i % 3) == 1){
    5066:	d20503e3          	beqz	a0,4d8c <concreate+0x48>
    506a:	036967bb          	remw	a5,s2,s6
    506e:	d15787e3          	beq	a5,s5,4d7c <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    5072:	20200593          	li	a1,514
    5076:	fa840513          	addi	a0,s0,-88
    507a:	00001097          	auipc	ra,0x1
    507e:	a6e080e7          	jalr	-1426(ra) # 5ae8 <open>
      if(fd < 0){
    5082:	fa0553e3          	bgez	a0,5028 <concreate+0x2e4>
    5086:	b31d                	j	4dac <concreate+0x68>
}
    5088:	60ea                	ld	ra,152(sp)
    508a:	644a                	ld	s0,144(sp)
    508c:	64aa                	ld	s1,136(sp)
    508e:	690a                	ld	s2,128(sp)
    5090:	79e6                	ld	s3,120(sp)
    5092:	7a46                	ld	s4,112(sp)
    5094:	7aa6                	ld	s5,104(sp)
    5096:	7b06                	ld	s6,96(sp)
    5098:	6be6                	ld	s7,88(sp)
    509a:	610d                	addi	sp,sp,160
    509c:	8082                	ret

000000000000509e <bigfile>:
{
    509e:	7139                	addi	sp,sp,-64
    50a0:	fc06                	sd	ra,56(sp)
    50a2:	f822                	sd	s0,48(sp)
    50a4:	f426                	sd	s1,40(sp)
    50a6:	f04a                	sd	s2,32(sp)
    50a8:	ec4e                	sd	s3,24(sp)
    50aa:	e852                	sd	s4,16(sp)
    50ac:	e456                	sd	s5,8(sp)
    50ae:	0080                	addi	s0,sp,64
    50b0:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    50b2:	00003517          	auipc	a0,0x3
    50b6:	d6e50513          	addi	a0,a0,-658 # 7e20 <malloc+0x1f2a>
    50ba:	00001097          	auipc	ra,0x1
    50be:	a3e080e7          	jalr	-1474(ra) # 5af8 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    50c2:	20200593          	li	a1,514
    50c6:	00003517          	auipc	a0,0x3
    50ca:	d5a50513          	addi	a0,a0,-678 # 7e20 <malloc+0x1f2a>
    50ce:	00001097          	auipc	ra,0x1
    50d2:	a1a080e7          	jalr	-1510(ra) # 5ae8 <open>
    50d6:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    50d8:	4481                	li	s1,0
    memset(buf, i, SZ);
    50da:	00008917          	auipc	s2,0x8
    50de:	b7e90913          	addi	s2,s2,-1154 # cc58 <buf>
  for(i = 0; i < N; i++){
    50e2:	4a51                	li	s4,20
  if(fd < 0){
    50e4:	0a054063          	bltz	a0,5184 <bigfile+0xe6>
    memset(buf, i, SZ);
    50e8:	25800613          	li	a2,600
    50ec:	85a6                	mv	a1,s1
    50ee:	854a                	mv	a0,s2
    50f0:	00000097          	auipc	ra,0x0
    50f4:	7bc080e7          	jalr	1980(ra) # 58ac <memset>
    if(write(fd, buf, SZ) != SZ){
    50f8:	25800613          	li	a2,600
    50fc:	85ca                	mv	a1,s2
    50fe:	854e                	mv	a0,s3
    5100:	00001097          	auipc	ra,0x1
    5104:	9c8080e7          	jalr	-1592(ra) # 5ac8 <write>
    5108:	25800793          	li	a5,600
    510c:	08f51a63          	bne	a0,a5,51a0 <bigfile+0x102>
  for(i = 0; i < N; i++){
    5110:	2485                	addiw	s1,s1,1
    5112:	fd449be3          	bne	s1,s4,50e8 <bigfile+0x4a>
  close(fd);
    5116:	854e                	mv	a0,s3
    5118:	00001097          	auipc	ra,0x1
    511c:	9b8080e7          	jalr	-1608(ra) # 5ad0 <close>
  fd = open("bigfile.dat", 0);
    5120:	4581                	li	a1,0
    5122:	00003517          	auipc	a0,0x3
    5126:	cfe50513          	addi	a0,a0,-770 # 7e20 <malloc+0x1f2a>
    512a:	00001097          	auipc	ra,0x1
    512e:	9be080e7          	jalr	-1602(ra) # 5ae8 <open>
    5132:	8a2a                	mv	s4,a0
  total = 0;
    5134:	4981                	li	s3,0
  for(i = 0; ; i++){
    5136:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    5138:	00008917          	auipc	s2,0x8
    513c:	b2090913          	addi	s2,s2,-1248 # cc58 <buf>
  if(fd < 0){
    5140:	06054e63          	bltz	a0,51bc <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    5144:	12c00613          	li	a2,300
    5148:	85ca                	mv	a1,s2
    514a:	8552                	mv	a0,s4
    514c:	00001097          	auipc	ra,0x1
    5150:	974080e7          	jalr	-1676(ra) # 5ac0 <read>
    if(cc < 0){
    5154:	08054263          	bltz	a0,51d8 <bigfile+0x13a>
    if(cc == 0)
    5158:	c971                	beqz	a0,522c <bigfile+0x18e>
    if(cc != SZ/2){
    515a:	12c00793          	li	a5,300
    515e:	08f51b63          	bne	a0,a5,51f4 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    5162:	01f4d79b          	srliw	a5,s1,0x1f
    5166:	9fa5                	addw	a5,a5,s1
    5168:	4017d79b          	sraiw	a5,a5,0x1
    516c:	00094703          	lbu	a4,0(s2)
    5170:	0af71063          	bne	a4,a5,5210 <bigfile+0x172>
    5174:	12b94703          	lbu	a4,299(s2)
    5178:	08f71c63          	bne	a4,a5,5210 <bigfile+0x172>
    total += cc;
    517c:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    5180:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    5182:	b7c9                	j	5144 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    5184:	85d6                	mv	a1,s5
    5186:	00003517          	auipc	a0,0x3
    518a:	caa50513          	addi	a0,a0,-854 # 7e30 <malloc+0x1f3a>
    518e:	00001097          	auipc	ra,0x1
    5192:	caa080e7          	jalr	-854(ra) # 5e38 <printf>
    exit(1);
    5196:	4505                	li	a0,1
    5198:	00001097          	auipc	ra,0x1
    519c:	910080e7          	jalr	-1776(ra) # 5aa8 <exit>
      printf("%s: write bigfile failed\n", s);
    51a0:	85d6                	mv	a1,s5
    51a2:	00003517          	auipc	a0,0x3
    51a6:	cae50513          	addi	a0,a0,-850 # 7e50 <malloc+0x1f5a>
    51aa:	00001097          	auipc	ra,0x1
    51ae:	c8e080e7          	jalr	-882(ra) # 5e38 <printf>
      exit(1);
    51b2:	4505                	li	a0,1
    51b4:	00001097          	auipc	ra,0x1
    51b8:	8f4080e7          	jalr	-1804(ra) # 5aa8 <exit>
    printf("%s: cannot open bigfile\n", s);
    51bc:	85d6                	mv	a1,s5
    51be:	00003517          	auipc	a0,0x3
    51c2:	cb250513          	addi	a0,a0,-846 # 7e70 <malloc+0x1f7a>
    51c6:	00001097          	auipc	ra,0x1
    51ca:	c72080e7          	jalr	-910(ra) # 5e38 <printf>
    exit(1);
    51ce:	4505                	li	a0,1
    51d0:	00001097          	auipc	ra,0x1
    51d4:	8d8080e7          	jalr	-1832(ra) # 5aa8 <exit>
      printf("%s: read bigfile failed\n", s);
    51d8:	85d6                	mv	a1,s5
    51da:	00003517          	auipc	a0,0x3
    51de:	cb650513          	addi	a0,a0,-842 # 7e90 <malloc+0x1f9a>
    51e2:	00001097          	auipc	ra,0x1
    51e6:	c56080e7          	jalr	-938(ra) # 5e38 <printf>
      exit(1);
    51ea:	4505                	li	a0,1
    51ec:	00001097          	auipc	ra,0x1
    51f0:	8bc080e7          	jalr	-1860(ra) # 5aa8 <exit>
      printf("%s: short read bigfile\n", s);
    51f4:	85d6                	mv	a1,s5
    51f6:	00003517          	auipc	a0,0x3
    51fa:	cba50513          	addi	a0,a0,-838 # 7eb0 <malloc+0x1fba>
    51fe:	00001097          	auipc	ra,0x1
    5202:	c3a080e7          	jalr	-966(ra) # 5e38 <printf>
      exit(1);
    5206:	4505                	li	a0,1
    5208:	00001097          	auipc	ra,0x1
    520c:	8a0080e7          	jalr	-1888(ra) # 5aa8 <exit>
      printf("%s: read bigfile wrong data\n", s);
    5210:	85d6                	mv	a1,s5
    5212:	00003517          	auipc	a0,0x3
    5216:	cb650513          	addi	a0,a0,-842 # 7ec8 <malloc+0x1fd2>
    521a:	00001097          	auipc	ra,0x1
    521e:	c1e080e7          	jalr	-994(ra) # 5e38 <printf>
      exit(1);
    5222:	4505                	li	a0,1
    5224:	00001097          	auipc	ra,0x1
    5228:	884080e7          	jalr	-1916(ra) # 5aa8 <exit>
  close(fd);
    522c:	8552                	mv	a0,s4
    522e:	00001097          	auipc	ra,0x1
    5232:	8a2080e7          	jalr	-1886(ra) # 5ad0 <close>
  if(total != N*SZ){
    5236:	678d                	lui	a5,0x3
    5238:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrk8000+0x24>
    523c:	02f99363          	bne	s3,a5,5262 <bigfile+0x1c4>
  unlink("bigfile.dat");
    5240:	00003517          	auipc	a0,0x3
    5244:	be050513          	addi	a0,a0,-1056 # 7e20 <malloc+0x1f2a>
    5248:	00001097          	auipc	ra,0x1
    524c:	8b0080e7          	jalr	-1872(ra) # 5af8 <unlink>
}
    5250:	70e2                	ld	ra,56(sp)
    5252:	7442                	ld	s0,48(sp)
    5254:	74a2                	ld	s1,40(sp)
    5256:	7902                	ld	s2,32(sp)
    5258:	69e2                	ld	s3,24(sp)
    525a:	6a42                	ld	s4,16(sp)
    525c:	6aa2                	ld	s5,8(sp)
    525e:	6121                	addi	sp,sp,64
    5260:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    5262:	85d6                	mv	a1,s5
    5264:	00003517          	auipc	a0,0x3
    5268:	c8450513          	addi	a0,a0,-892 # 7ee8 <malloc+0x1ff2>
    526c:	00001097          	auipc	ra,0x1
    5270:	bcc080e7          	jalr	-1076(ra) # 5e38 <printf>
    exit(1);
    5274:	4505                	li	a0,1
    5276:	00001097          	auipc	ra,0x1
    527a:	832080e7          	jalr	-1998(ra) # 5aa8 <exit>

000000000000527e <fsfull>:
{
    527e:	7171                	addi	sp,sp,-176
    5280:	f506                	sd	ra,168(sp)
    5282:	f122                	sd	s0,160(sp)
    5284:	ed26                	sd	s1,152(sp)
    5286:	e94a                	sd	s2,144(sp)
    5288:	e54e                	sd	s3,136(sp)
    528a:	e152                	sd	s4,128(sp)
    528c:	fcd6                	sd	s5,120(sp)
    528e:	f8da                	sd	s6,112(sp)
    5290:	f4de                	sd	s7,104(sp)
    5292:	f0e2                	sd	s8,96(sp)
    5294:	ece6                	sd	s9,88(sp)
    5296:	e8ea                	sd	s10,80(sp)
    5298:	e4ee                	sd	s11,72(sp)
    529a:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    529c:	00003517          	auipc	a0,0x3
    52a0:	c6c50513          	addi	a0,a0,-916 # 7f08 <malloc+0x2012>
    52a4:	00001097          	auipc	ra,0x1
    52a8:	b94080e7          	jalr	-1132(ra) # 5e38 <printf>
  for(nfiles = 0; ; nfiles++){
    52ac:	4481                	li	s1,0
    name[0] = 'f';
    52ae:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    52b2:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    52b6:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    52ba:	4b29                	li	s6,10
    printf("writing %s\n", name);
    52bc:	00003c97          	auipc	s9,0x3
    52c0:	c5cc8c93          	addi	s9,s9,-932 # 7f18 <malloc+0x2022>
    int total = 0;
    52c4:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    52c6:	00008a17          	auipc	s4,0x8
    52ca:	992a0a13          	addi	s4,s4,-1646 # cc58 <buf>
    name[0] = 'f';
    52ce:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    52d2:	0384c7bb          	divw	a5,s1,s8
    52d6:	0307879b          	addiw	a5,a5,48
    52da:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    52de:	0384e7bb          	remw	a5,s1,s8
    52e2:	0377c7bb          	divw	a5,a5,s7
    52e6:	0307879b          	addiw	a5,a5,48
    52ea:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    52ee:	0374e7bb          	remw	a5,s1,s7
    52f2:	0367c7bb          	divw	a5,a5,s6
    52f6:	0307879b          	addiw	a5,a5,48
    52fa:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    52fe:	0364e7bb          	remw	a5,s1,s6
    5302:	0307879b          	addiw	a5,a5,48
    5306:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    530a:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    530e:	f5040593          	addi	a1,s0,-176
    5312:	8566                	mv	a0,s9
    5314:	00001097          	auipc	ra,0x1
    5318:	b24080e7          	jalr	-1244(ra) # 5e38 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    531c:	20200593          	li	a1,514
    5320:	f5040513          	addi	a0,s0,-176
    5324:	00000097          	auipc	ra,0x0
    5328:	7c4080e7          	jalr	1988(ra) # 5ae8 <open>
    532c:	892a                	mv	s2,a0
    if(fd < 0){
    532e:	0a055663          	bgez	a0,53da <fsfull+0x15c>
      printf("open %s failed\n", name);
    5332:	f5040593          	addi	a1,s0,-176
    5336:	00003517          	auipc	a0,0x3
    533a:	bf250513          	addi	a0,a0,-1038 # 7f28 <malloc+0x2032>
    533e:	00001097          	auipc	ra,0x1
    5342:	afa080e7          	jalr	-1286(ra) # 5e38 <printf>
  while(nfiles >= 0){
    5346:	0604c363          	bltz	s1,53ac <fsfull+0x12e>
    name[0] = 'f';
    534a:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    534e:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    5352:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    5356:	4929                	li	s2,10
  while(nfiles >= 0){
    5358:	5afd                	li	s5,-1
    name[0] = 'f';
    535a:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    535e:	0344c7bb          	divw	a5,s1,s4
    5362:	0307879b          	addiw	a5,a5,48
    5366:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    536a:	0344e7bb          	remw	a5,s1,s4
    536e:	0337c7bb          	divw	a5,a5,s3
    5372:	0307879b          	addiw	a5,a5,48
    5376:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    537a:	0334e7bb          	remw	a5,s1,s3
    537e:	0327c7bb          	divw	a5,a5,s2
    5382:	0307879b          	addiw	a5,a5,48
    5386:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    538a:	0324e7bb          	remw	a5,s1,s2
    538e:	0307879b          	addiw	a5,a5,48
    5392:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    5396:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    539a:	f5040513          	addi	a0,s0,-176
    539e:	00000097          	auipc	ra,0x0
    53a2:	75a080e7          	jalr	1882(ra) # 5af8 <unlink>
    nfiles--;
    53a6:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    53a8:	fb5499e3          	bne	s1,s5,535a <fsfull+0xdc>
  printf("fsfull test finished\n");
    53ac:	00003517          	auipc	a0,0x3
    53b0:	b9c50513          	addi	a0,a0,-1124 # 7f48 <malloc+0x2052>
    53b4:	00001097          	auipc	ra,0x1
    53b8:	a84080e7          	jalr	-1404(ra) # 5e38 <printf>
}
    53bc:	70aa                	ld	ra,168(sp)
    53be:	740a                	ld	s0,160(sp)
    53c0:	64ea                	ld	s1,152(sp)
    53c2:	694a                	ld	s2,144(sp)
    53c4:	69aa                	ld	s3,136(sp)
    53c6:	6a0a                	ld	s4,128(sp)
    53c8:	7ae6                	ld	s5,120(sp)
    53ca:	7b46                	ld	s6,112(sp)
    53cc:	7ba6                	ld	s7,104(sp)
    53ce:	7c06                	ld	s8,96(sp)
    53d0:	6ce6                	ld	s9,88(sp)
    53d2:	6d46                	ld	s10,80(sp)
    53d4:	6da6                	ld	s11,72(sp)
    53d6:	614d                	addi	sp,sp,176
    53d8:	8082                	ret
    int total = 0;
    53da:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    53dc:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    53e0:	40000613          	li	a2,1024
    53e4:	85d2                	mv	a1,s4
    53e6:	854a                	mv	a0,s2
    53e8:	00000097          	auipc	ra,0x0
    53ec:	6e0080e7          	jalr	1760(ra) # 5ac8 <write>
      if(cc < BSIZE)
    53f0:	00aad563          	bge	s5,a0,53fa <fsfull+0x17c>
      total += cc;
    53f4:	00a989bb          	addw	s3,s3,a0
    while(1){
    53f8:	b7e5                	j	53e0 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    53fa:	85ce                	mv	a1,s3
    53fc:	00003517          	auipc	a0,0x3
    5400:	b3c50513          	addi	a0,a0,-1220 # 7f38 <malloc+0x2042>
    5404:	00001097          	auipc	ra,0x1
    5408:	a34080e7          	jalr	-1484(ra) # 5e38 <printf>
    close(fd);
    540c:	854a                	mv	a0,s2
    540e:	00000097          	auipc	ra,0x0
    5412:	6c2080e7          	jalr	1730(ra) # 5ad0 <close>
    if(total == 0)
    5416:	f20988e3          	beqz	s3,5346 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    541a:	2485                	addiw	s1,s1,1
    541c:	bd4d                	j	52ce <fsfull+0x50>

000000000000541e <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    541e:	7179                	addi	sp,sp,-48
    5420:	f406                	sd	ra,40(sp)
    5422:	f022                	sd	s0,32(sp)
    5424:	ec26                	sd	s1,24(sp)
    5426:	e84a                	sd	s2,16(sp)
    5428:	1800                	addi	s0,sp,48
    542a:	84aa                	mv	s1,a0
    542c:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    542e:	00003517          	auipc	a0,0x3
    5432:	b3250513          	addi	a0,a0,-1230 # 7f60 <malloc+0x206a>
    5436:	00001097          	auipc	ra,0x1
    543a:	a02080e7          	jalr	-1534(ra) # 5e38 <printf>
  if((pid = fork()) < 0) {
    543e:	00000097          	auipc	ra,0x0
    5442:	662080e7          	jalr	1634(ra) # 5aa0 <fork>
    5446:	02054e63          	bltz	a0,5482 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    544a:	c929                	beqz	a0,549c <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    544c:	fdc40513          	addi	a0,s0,-36
    5450:	00000097          	auipc	ra,0x0
    5454:	660080e7          	jalr	1632(ra) # 5ab0 <wait>
    if(xstatus != 0) 
    5458:	fdc42783          	lw	a5,-36(s0)
    545c:	c7b9                	beqz	a5,54aa <run+0x8c>
      printf("FAILED\n");
    545e:	00003517          	auipc	a0,0x3
    5462:	b2a50513          	addi	a0,a0,-1238 # 7f88 <malloc+0x2092>
    5466:	00001097          	auipc	ra,0x1
    546a:	9d2080e7          	jalr	-1582(ra) # 5e38 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    546e:	fdc42503          	lw	a0,-36(s0)
  }
}
    5472:	00153513          	seqz	a0,a0
    5476:	70a2                	ld	ra,40(sp)
    5478:	7402                	ld	s0,32(sp)
    547a:	64e2                	ld	s1,24(sp)
    547c:	6942                	ld	s2,16(sp)
    547e:	6145                	addi	sp,sp,48
    5480:	8082                	ret
    printf("runtest: fork error\n");
    5482:	00003517          	auipc	a0,0x3
    5486:	aee50513          	addi	a0,a0,-1298 # 7f70 <malloc+0x207a>
    548a:	00001097          	auipc	ra,0x1
    548e:	9ae080e7          	jalr	-1618(ra) # 5e38 <printf>
    exit(1);
    5492:	4505                	li	a0,1
    5494:	00000097          	auipc	ra,0x0
    5498:	614080e7          	jalr	1556(ra) # 5aa8 <exit>
    f(s);
    549c:	854a                	mv	a0,s2
    549e:	9482                	jalr	s1
    exit(0);
    54a0:	4501                	li	a0,0
    54a2:	00000097          	auipc	ra,0x0
    54a6:	606080e7          	jalr	1542(ra) # 5aa8 <exit>
      printf("OK\n");
    54aa:	00003517          	auipc	a0,0x3
    54ae:	ae650513          	addi	a0,a0,-1306 # 7f90 <malloc+0x209a>
    54b2:	00001097          	auipc	ra,0x1
    54b6:	986080e7          	jalr	-1658(ra) # 5e38 <printf>
    54ba:	bf55                	j	546e <run+0x50>

00000000000054bc <runtests>:

int
runtests(struct test *tests, char *justone) {
    54bc:	1101                	addi	sp,sp,-32
    54be:	ec06                	sd	ra,24(sp)
    54c0:	e822                	sd	s0,16(sp)
    54c2:	e426                	sd	s1,8(sp)
    54c4:	e04a                	sd	s2,0(sp)
    54c6:	1000                	addi	s0,sp,32
    54c8:	84aa                	mv	s1,a0
    54ca:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++) {
    54cc:	6508                	ld	a0,8(a0)
    54ce:	ed09                	bnez	a0,54e8 <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    54d0:	4501                	li	a0,0
    54d2:	a82d                	j	550c <runtests+0x50>
      if(!run(t->f, t->s)){
    54d4:	648c                	ld	a1,8(s1)
    54d6:	6088                	ld	a0,0(s1)
    54d8:	00000097          	auipc	ra,0x0
    54dc:	f46080e7          	jalr	-186(ra) # 541e <run>
    54e0:	cd09                	beqz	a0,54fa <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++) {
    54e2:	04c1                	addi	s1,s1,16
    54e4:	6488                	ld	a0,8(s1)
    54e6:	c11d                	beqz	a0,550c <runtests+0x50>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    54e8:	fe0906e3          	beqz	s2,54d4 <runtests+0x18>
    54ec:	85ca                	mv	a1,s2
    54ee:	00000097          	auipc	ra,0x0
    54f2:	368080e7          	jalr	872(ra) # 5856 <strcmp>
    54f6:	f575                	bnez	a0,54e2 <runtests+0x26>
    54f8:	bff1                	j	54d4 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    54fa:	00003517          	auipc	a0,0x3
    54fe:	a9e50513          	addi	a0,a0,-1378 # 7f98 <malloc+0x20a2>
    5502:	00001097          	auipc	ra,0x1
    5506:	936080e7          	jalr	-1738(ra) # 5e38 <printf>
        return 1;
    550a:	4505                	li	a0,1
}
    550c:	60e2                	ld	ra,24(sp)
    550e:	6442                	ld	s0,16(sp)
    5510:	64a2                	ld	s1,8(sp)
    5512:	6902                	ld	s2,0(sp)
    5514:	6105                	addi	sp,sp,32
    5516:	8082                	ret

0000000000005518 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    5518:	7139                	addi	sp,sp,-64
    551a:	fc06                	sd	ra,56(sp)
    551c:	f822                	sd	s0,48(sp)
    551e:	f426                	sd	s1,40(sp)
    5520:	f04a                	sd	s2,32(sp)
    5522:	ec4e                	sd	s3,24(sp)
    5524:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    5526:	fc840513          	addi	a0,s0,-56
    552a:	00000097          	auipc	ra,0x0
    552e:	58e080e7          	jalr	1422(ra) # 5ab8 <pipe>
    5532:	06054763          	bltz	a0,55a0 <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    5536:	00000097          	auipc	ra,0x0
    553a:	56a080e7          	jalr	1386(ra) # 5aa0 <fork>

  if(pid < 0){
    553e:	06054e63          	bltz	a0,55ba <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    5542:	ed51                	bnez	a0,55de <countfree+0xc6>
    close(fds[0]);
    5544:	fc842503          	lw	a0,-56(s0)
    5548:	00000097          	auipc	ra,0x0
    554c:	588080e7          	jalr	1416(ra) # 5ad0 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    5550:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    5552:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    5554:	00001997          	auipc	s3,0x1
    5558:	b5498993          	addi	s3,s3,-1196 # 60a8 <malloc+0x1b2>
      uint64 a = (uint64) sbrk(4096);
    555c:	6505                	lui	a0,0x1
    555e:	00000097          	auipc	ra,0x0
    5562:	5d2080e7          	jalr	1490(ra) # 5b30 <sbrk>
      if(a == 0xffffffffffffffff){
    5566:	07250763          	beq	a0,s2,55d4 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    556a:	6785                	lui	a5,0x1
    556c:	953e                	add	a0,a0,a5
    556e:	fe950fa3          	sb	s1,-1(a0) # fff <linktest+0x109>
      if(write(fds[1], "x", 1) != 1){
    5572:	8626                	mv	a2,s1
    5574:	85ce                	mv	a1,s3
    5576:	fcc42503          	lw	a0,-52(s0)
    557a:	00000097          	auipc	ra,0x0
    557e:	54e080e7          	jalr	1358(ra) # 5ac8 <write>
    5582:	fc950de3          	beq	a0,s1,555c <countfree+0x44>
        printf("write() failed in countfree()\n");
    5586:	00003517          	auipc	a0,0x3
    558a:	a6a50513          	addi	a0,a0,-1430 # 7ff0 <malloc+0x20fa>
    558e:	00001097          	auipc	ra,0x1
    5592:	8aa080e7          	jalr	-1878(ra) # 5e38 <printf>
        exit(1);
    5596:	4505                	li	a0,1
    5598:	00000097          	auipc	ra,0x0
    559c:	510080e7          	jalr	1296(ra) # 5aa8 <exit>
    printf("pipe() failed in countfree()\n");
    55a0:	00003517          	auipc	a0,0x3
    55a4:	a1050513          	addi	a0,a0,-1520 # 7fb0 <malloc+0x20ba>
    55a8:	00001097          	auipc	ra,0x1
    55ac:	890080e7          	jalr	-1904(ra) # 5e38 <printf>
    exit(1);
    55b0:	4505                	li	a0,1
    55b2:	00000097          	auipc	ra,0x0
    55b6:	4f6080e7          	jalr	1270(ra) # 5aa8 <exit>
    printf("fork failed in countfree()\n");
    55ba:	00003517          	auipc	a0,0x3
    55be:	a1650513          	addi	a0,a0,-1514 # 7fd0 <malloc+0x20da>
    55c2:	00001097          	auipc	ra,0x1
    55c6:	876080e7          	jalr	-1930(ra) # 5e38 <printf>
    exit(1);
    55ca:	4505                	li	a0,1
    55cc:	00000097          	auipc	ra,0x0
    55d0:	4dc080e7          	jalr	1244(ra) # 5aa8 <exit>
      }
    }

    exit(0);
    55d4:	4501                	li	a0,0
    55d6:	00000097          	auipc	ra,0x0
    55da:	4d2080e7          	jalr	1234(ra) # 5aa8 <exit>
  }

  close(fds[1]);
    55de:	fcc42503          	lw	a0,-52(s0)
    55e2:	00000097          	auipc	ra,0x0
    55e6:	4ee080e7          	jalr	1262(ra) # 5ad0 <close>

  int n = 0;
    55ea:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    55ec:	4605                	li	a2,1
    55ee:	fc740593          	addi	a1,s0,-57
    55f2:	fc842503          	lw	a0,-56(s0)
    55f6:	00000097          	auipc	ra,0x0
    55fa:	4ca080e7          	jalr	1226(ra) # 5ac0 <read>
    if(cc < 0){
    55fe:	00054563          	bltz	a0,5608 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    5602:	c105                	beqz	a0,5622 <countfree+0x10a>
      break;
    n += 1;
    5604:	2485                	addiw	s1,s1,1
  while(1){
    5606:	b7dd                	j	55ec <countfree+0xd4>
      printf("read() failed in countfree()\n");
    5608:	00003517          	auipc	a0,0x3
    560c:	a0850513          	addi	a0,a0,-1528 # 8010 <malloc+0x211a>
    5610:	00001097          	auipc	ra,0x1
    5614:	828080e7          	jalr	-2008(ra) # 5e38 <printf>
      exit(1);
    5618:	4505                	li	a0,1
    561a:	00000097          	auipc	ra,0x0
    561e:	48e080e7          	jalr	1166(ra) # 5aa8 <exit>
  }

  close(fds[0]);
    5622:	fc842503          	lw	a0,-56(s0)
    5626:	00000097          	auipc	ra,0x0
    562a:	4aa080e7          	jalr	1194(ra) # 5ad0 <close>
  wait((int*)0);
    562e:	4501                	li	a0,0
    5630:	00000097          	auipc	ra,0x0
    5634:	480080e7          	jalr	1152(ra) # 5ab0 <wait>
  
  return n;
}
    5638:	8526                	mv	a0,s1
    563a:	70e2                	ld	ra,56(sp)
    563c:	7442                	ld	s0,48(sp)
    563e:	74a2                	ld	s1,40(sp)
    5640:	7902                	ld	s2,32(sp)
    5642:	69e2                	ld	s3,24(sp)
    5644:	6121                	addi	sp,sp,64
    5646:	8082                	ret

0000000000005648 <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    5648:	711d                	addi	sp,sp,-96
    564a:	ec86                	sd	ra,88(sp)
    564c:	e8a2                	sd	s0,80(sp)
    564e:	e4a6                	sd	s1,72(sp)
    5650:	e0ca                	sd	s2,64(sp)
    5652:	fc4e                	sd	s3,56(sp)
    5654:	f852                	sd	s4,48(sp)
    5656:	f456                	sd	s5,40(sp)
    5658:	f05a                	sd	s6,32(sp)
    565a:	ec5e                	sd	s7,24(sp)
    565c:	e862                	sd	s8,16(sp)
    565e:	e466                	sd	s9,8(sp)
    5660:	e06a                	sd	s10,0(sp)
    5662:	1080                	addi	s0,sp,96
    5664:	8a2a                	mv	s4,a0
    5666:	89ae                	mv	s3,a1
    5668:	8932                	mv	s2,a2
  do {
    printf("usertests starting\n");
    566a:	00003b97          	auipc	s7,0x3
    566e:	9c6b8b93          	addi	s7,s7,-1594 # 8030 <malloc+0x213a>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone)) {
    5672:	00004b17          	auipc	s6,0x4
    5676:	99eb0b13          	addi	s6,s6,-1634 # 9010 <quicktests>
      if(continuous != 2) {
    567a:	4a89                	li	s5,2
          return 1;
        }
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    567c:	00003c97          	auipc	s9,0x3
    5680:	9ecc8c93          	addi	s9,s9,-1556 # 8068 <malloc+0x2172>
      if (runtests(slowtests, justone)) {
    5684:	00004c17          	auipc	s8,0x4
    5688:	d3cc0c13          	addi	s8,s8,-708 # 93c0 <slowtests>
        printf("usertests slow tests starting\n");
    568c:	00003d17          	auipc	s10,0x3
    5690:	9bcd0d13          	addi	s10,s10,-1604 # 8048 <malloc+0x2152>
    5694:	a839                	j	56b2 <drivetests+0x6a>
    5696:	856a                	mv	a0,s10
    5698:	00000097          	auipc	ra,0x0
    569c:	7a0080e7          	jalr	1952(ra) # 5e38 <printf>
    56a0:	a081                	j	56e0 <drivetests+0x98>
    if((free1 = countfree()) < free0) {
    56a2:	00000097          	auipc	ra,0x0
    56a6:	e76080e7          	jalr	-394(ra) # 5518 <countfree>
    56aa:	06954263          	blt	a0,s1,570e <drivetests+0xc6>
      if(continuous != 2) {
        return 1;
      }
    }
  } while(continuous);
    56ae:	06098f63          	beqz	s3,572c <drivetests+0xe4>
    printf("usertests starting\n");
    56b2:	855e                	mv	a0,s7
    56b4:	00000097          	auipc	ra,0x0
    56b8:	784080e7          	jalr	1924(ra) # 5e38 <printf>
    int free0 = countfree();
    56bc:	00000097          	auipc	ra,0x0
    56c0:	e5c080e7          	jalr	-420(ra) # 5518 <countfree>
    56c4:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone)) {
    56c6:	85ca                	mv	a1,s2
    56c8:	855a                	mv	a0,s6
    56ca:	00000097          	auipc	ra,0x0
    56ce:	df2080e7          	jalr	-526(ra) # 54bc <runtests>
    56d2:	c119                	beqz	a0,56d8 <drivetests+0x90>
      if(continuous != 2) {
    56d4:	05599863          	bne	s3,s5,5724 <drivetests+0xdc>
    if(!quick) {
    56d8:	fc0a15e3          	bnez	s4,56a2 <drivetests+0x5a>
      if (justone == 0)
    56dc:	fa090de3          	beqz	s2,5696 <drivetests+0x4e>
      if (runtests(slowtests, justone)) {
    56e0:	85ca                	mv	a1,s2
    56e2:	8562                	mv	a0,s8
    56e4:	00000097          	auipc	ra,0x0
    56e8:	dd8080e7          	jalr	-552(ra) # 54bc <runtests>
    56ec:	d95d                	beqz	a0,56a2 <drivetests+0x5a>
        if(continuous != 2) {
    56ee:	03599d63          	bne	s3,s5,5728 <drivetests+0xe0>
    if((free1 = countfree()) < free0) {
    56f2:	00000097          	auipc	ra,0x0
    56f6:	e26080e7          	jalr	-474(ra) # 5518 <countfree>
    56fa:	fa955ae3          	bge	a0,s1,56ae <drivetests+0x66>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    56fe:	8626                	mv	a2,s1
    5700:	85aa                	mv	a1,a0
    5702:	8566                	mv	a0,s9
    5704:	00000097          	auipc	ra,0x0
    5708:	734080e7          	jalr	1844(ra) # 5e38 <printf>
      if(continuous != 2) {
    570c:	b75d                	j	56b2 <drivetests+0x6a>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    570e:	8626                	mv	a2,s1
    5710:	85aa                	mv	a1,a0
    5712:	8566                	mv	a0,s9
    5714:	00000097          	auipc	ra,0x0
    5718:	724080e7          	jalr	1828(ra) # 5e38 <printf>
      if(continuous != 2) {
    571c:	f9598be3          	beq	s3,s5,56b2 <drivetests+0x6a>
        return 1;
    5720:	4505                	li	a0,1
    5722:	a031                	j	572e <drivetests+0xe6>
        return 1;
    5724:	4505                	li	a0,1
    5726:	a021                	j	572e <drivetests+0xe6>
          return 1;
    5728:	4505                	li	a0,1
    572a:	a011                	j	572e <drivetests+0xe6>
  return 0;
    572c:	854e                	mv	a0,s3
}
    572e:	60e6                	ld	ra,88(sp)
    5730:	6446                	ld	s0,80(sp)
    5732:	64a6                	ld	s1,72(sp)
    5734:	6906                	ld	s2,64(sp)
    5736:	79e2                	ld	s3,56(sp)
    5738:	7a42                	ld	s4,48(sp)
    573a:	7aa2                	ld	s5,40(sp)
    573c:	7b02                	ld	s6,32(sp)
    573e:	6be2                	ld	s7,24(sp)
    5740:	6c42                	ld	s8,16(sp)
    5742:	6ca2                	ld	s9,8(sp)
    5744:	6d02                	ld	s10,0(sp)
    5746:	6125                	addi	sp,sp,96
    5748:	8082                	ret

000000000000574a <main>:

int
main(int argc, char *argv[])
{
    574a:	1101                	addi	sp,sp,-32
    574c:	ec06                	sd	ra,24(sp)
    574e:	e822                	sd	s0,16(sp)
    5750:	e426                	sd	s1,8(sp)
    5752:	e04a                	sd	s2,0(sp)
    5754:	1000                	addi	s0,sp,32
    5756:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5758:	4789                	li	a5,2
    575a:	02f50363          	beq	a0,a5,5780 <main+0x36>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    575e:	4785                	li	a5,1
    5760:	06a7cd63          	blt	a5,a0,57da <main+0x90>
  char *justone = 0;
    5764:	4601                	li	a2,0
  int quick = 0;
    5766:	4501                	li	a0,0
  int continuous = 0;
    5768:	4481                	li	s1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    576a:	85a6                	mv	a1,s1
    576c:	00000097          	auipc	ra,0x0
    5770:	edc080e7          	jalr	-292(ra) # 5648 <drivetests>
    5774:	c949                	beqz	a0,5806 <main+0xbc>
    exit(1);
    5776:	4505                	li	a0,1
    5778:	00000097          	auipc	ra,0x0
    577c:	330080e7          	jalr	816(ra) # 5aa8 <exit>
    5780:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5782:	00003597          	auipc	a1,0x3
    5786:	91658593          	addi	a1,a1,-1770 # 8098 <malloc+0x21a2>
    578a:	00893503          	ld	a0,8(s2)
    578e:	00000097          	auipc	ra,0x0
    5792:	0c8080e7          	jalr	200(ra) # 5856 <strcmp>
    5796:	cd39                	beqz	a0,57f4 <main+0xaa>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5798:	00003597          	auipc	a1,0x3
    579c:	95858593          	addi	a1,a1,-1704 # 80f0 <malloc+0x21fa>
    57a0:	00893503          	ld	a0,8(s2)
    57a4:	00000097          	auipc	ra,0x0
    57a8:	0b2080e7          	jalr	178(ra) # 5856 <strcmp>
    57ac:	c931                	beqz	a0,5800 <main+0xb6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    57ae:	00003597          	auipc	a1,0x3
    57b2:	93a58593          	addi	a1,a1,-1734 # 80e8 <malloc+0x21f2>
    57b6:	00893503          	ld	a0,8(s2)
    57ba:	00000097          	auipc	ra,0x0
    57be:	09c080e7          	jalr	156(ra) # 5856 <strcmp>
    57c2:	cd0d                	beqz	a0,57fc <main+0xb2>
  } else if(argc == 2 && argv[1][0] != '-'){
    57c4:	00893603          	ld	a2,8(s2)
    57c8:	00064703          	lbu	a4,0(a2) # 3000 <fourteen+0x4a>
    57cc:	02d00793          	li	a5,45
    57d0:	00f70563          	beq	a4,a5,57da <main+0x90>
  int quick = 0;
    57d4:	4501                	li	a0,0
  int continuous = 0;
    57d6:	4481                	li	s1,0
    57d8:	bf49                	j	576a <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    57da:	00003517          	auipc	a0,0x3
    57de:	8c650513          	addi	a0,a0,-1850 # 80a0 <malloc+0x21aa>
    57e2:	00000097          	auipc	ra,0x0
    57e6:	656080e7          	jalr	1622(ra) # 5e38 <printf>
    exit(1);
    57ea:	4505                	li	a0,1
    57ec:	00000097          	auipc	ra,0x0
    57f0:	2bc080e7          	jalr	700(ra) # 5aa8 <exit>
  int continuous = 0;
    57f4:	84aa                	mv	s1,a0
  char *justone = 0;
    57f6:	4601                	li	a2,0
    quick = 1;
    57f8:	4505                	li	a0,1
    57fa:	bf85                	j	576a <main+0x20>
  char *justone = 0;
    57fc:	4601                	li	a2,0
    57fe:	b7b5                	j	576a <main+0x20>
    5800:	4601                	li	a2,0
    continuous = 1;
    5802:	4485                	li	s1,1
    5804:	b79d                	j	576a <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    5806:	00003517          	auipc	a0,0x3
    580a:	8ca50513          	addi	a0,a0,-1846 # 80d0 <malloc+0x21da>
    580e:	00000097          	auipc	ra,0x0
    5812:	62a080e7          	jalr	1578(ra) # 5e38 <printf>
  exit(0);
    5816:	4501                	li	a0,0
    5818:	00000097          	auipc	ra,0x0
    581c:	290080e7          	jalr	656(ra) # 5aa8 <exit>

0000000000005820 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    5820:	1141                	addi	sp,sp,-16
    5822:	e406                	sd	ra,8(sp)
    5824:	e022                	sd	s0,0(sp)
    5826:	0800                	addi	s0,sp,16
  extern int main();
  main();
    5828:	00000097          	auipc	ra,0x0
    582c:	f22080e7          	jalr	-222(ra) # 574a <main>
  exit(0);
    5830:	4501                	li	a0,0
    5832:	00000097          	auipc	ra,0x0
    5836:	276080e7          	jalr	630(ra) # 5aa8 <exit>

000000000000583a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    583a:	1141                	addi	sp,sp,-16
    583c:	e422                	sd	s0,8(sp)
    583e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5840:	87aa                	mv	a5,a0
    5842:	0585                	addi	a1,a1,1
    5844:	0785                	addi	a5,a5,1
    5846:	fff5c703          	lbu	a4,-1(a1)
    584a:	fee78fa3          	sb	a4,-1(a5) # fff <linktest+0x109>
    584e:	fb75                	bnez	a4,5842 <strcpy+0x8>
    ;
  return os;
}
    5850:	6422                	ld	s0,8(sp)
    5852:	0141                	addi	sp,sp,16
    5854:	8082                	ret

0000000000005856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5856:	1141                	addi	sp,sp,-16
    5858:	e422                	sd	s0,8(sp)
    585a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    585c:	00054783          	lbu	a5,0(a0)
    5860:	cb91                	beqz	a5,5874 <strcmp+0x1e>
    5862:	0005c703          	lbu	a4,0(a1)
    5866:	00f71763          	bne	a4,a5,5874 <strcmp+0x1e>
    p++, q++;
    586a:	0505                	addi	a0,a0,1
    586c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    586e:	00054783          	lbu	a5,0(a0)
    5872:	fbe5                	bnez	a5,5862 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5874:	0005c503          	lbu	a0,0(a1)
}
    5878:	40a7853b          	subw	a0,a5,a0
    587c:	6422                	ld	s0,8(sp)
    587e:	0141                	addi	sp,sp,16
    5880:	8082                	ret

0000000000005882 <strlen>:

uint
strlen(const char *s)
{
    5882:	1141                	addi	sp,sp,-16
    5884:	e422                	sd	s0,8(sp)
    5886:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5888:	00054783          	lbu	a5,0(a0)
    588c:	cf91                	beqz	a5,58a8 <strlen+0x26>
    588e:	0505                	addi	a0,a0,1
    5890:	87aa                	mv	a5,a0
    5892:	4685                	li	a3,1
    5894:	9e89                	subw	a3,a3,a0
    5896:	00f6853b          	addw	a0,a3,a5
    589a:	0785                	addi	a5,a5,1
    589c:	fff7c703          	lbu	a4,-1(a5)
    58a0:	fb7d                	bnez	a4,5896 <strlen+0x14>
    ;
  return n;
}
    58a2:	6422                	ld	s0,8(sp)
    58a4:	0141                	addi	sp,sp,16
    58a6:	8082                	ret
  for(n = 0; s[n]; n++)
    58a8:	4501                	li	a0,0
    58aa:	bfe5                	j	58a2 <strlen+0x20>

00000000000058ac <memset>:

void*
memset(void *dst, int c, uint n)
{
    58ac:	1141                	addi	sp,sp,-16
    58ae:	e422                	sd	s0,8(sp)
    58b0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    58b2:	ca19                	beqz	a2,58c8 <memset+0x1c>
    58b4:	87aa                	mv	a5,a0
    58b6:	1602                	slli	a2,a2,0x20
    58b8:	9201                	srli	a2,a2,0x20
    58ba:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    58be:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    58c2:	0785                	addi	a5,a5,1
    58c4:	fee79de3          	bne	a5,a4,58be <memset+0x12>
  }
  return dst;
}
    58c8:	6422                	ld	s0,8(sp)
    58ca:	0141                	addi	sp,sp,16
    58cc:	8082                	ret

00000000000058ce <strchr>:

char*
strchr(const char *s, char c)
{
    58ce:	1141                	addi	sp,sp,-16
    58d0:	e422                	sd	s0,8(sp)
    58d2:	0800                	addi	s0,sp,16
  for(; *s; s++)
    58d4:	00054783          	lbu	a5,0(a0)
    58d8:	cb99                	beqz	a5,58ee <strchr+0x20>
    if(*s == c)
    58da:	00f58763          	beq	a1,a5,58e8 <strchr+0x1a>
  for(; *s; s++)
    58de:	0505                	addi	a0,a0,1
    58e0:	00054783          	lbu	a5,0(a0)
    58e4:	fbfd                	bnez	a5,58da <strchr+0xc>
      return (char*)s;
  return 0;
    58e6:	4501                	li	a0,0
}
    58e8:	6422                	ld	s0,8(sp)
    58ea:	0141                	addi	sp,sp,16
    58ec:	8082                	ret
  return 0;
    58ee:	4501                	li	a0,0
    58f0:	bfe5                	j	58e8 <strchr+0x1a>

00000000000058f2 <gets>:

char*
gets(char *buf, int max)
{
    58f2:	711d                	addi	sp,sp,-96
    58f4:	ec86                	sd	ra,88(sp)
    58f6:	e8a2                	sd	s0,80(sp)
    58f8:	e4a6                	sd	s1,72(sp)
    58fa:	e0ca                	sd	s2,64(sp)
    58fc:	fc4e                	sd	s3,56(sp)
    58fe:	f852                	sd	s4,48(sp)
    5900:	f456                	sd	s5,40(sp)
    5902:	f05a                	sd	s6,32(sp)
    5904:	ec5e                	sd	s7,24(sp)
    5906:	1080                	addi	s0,sp,96
    5908:	8baa                	mv	s7,a0
    590a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    590c:	892a                	mv	s2,a0
    590e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5910:	4aa9                	li	s5,10
    5912:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5914:	89a6                	mv	s3,s1
    5916:	2485                	addiw	s1,s1,1
    5918:	0344d863          	bge	s1,s4,5948 <gets+0x56>
    cc = read(0, &c, 1);
    591c:	4605                	li	a2,1
    591e:	faf40593          	addi	a1,s0,-81
    5922:	4501                	li	a0,0
    5924:	00000097          	auipc	ra,0x0
    5928:	19c080e7          	jalr	412(ra) # 5ac0 <read>
    if(cc < 1)
    592c:	00a05e63          	blez	a0,5948 <gets+0x56>
    buf[i++] = c;
    5930:	faf44783          	lbu	a5,-81(s0)
    5934:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5938:	01578763          	beq	a5,s5,5946 <gets+0x54>
    593c:	0905                	addi	s2,s2,1
    593e:	fd679be3          	bne	a5,s6,5914 <gets+0x22>
  for(i=0; i+1 < max; ){
    5942:	89a6                	mv	s3,s1
    5944:	a011                	j	5948 <gets+0x56>
    5946:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5948:	99de                	add	s3,s3,s7
    594a:	00098023          	sb	zero,0(s3)
  return buf;
}
    594e:	855e                	mv	a0,s7
    5950:	60e6                	ld	ra,88(sp)
    5952:	6446                	ld	s0,80(sp)
    5954:	64a6                	ld	s1,72(sp)
    5956:	6906                	ld	s2,64(sp)
    5958:	79e2                	ld	s3,56(sp)
    595a:	7a42                	ld	s4,48(sp)
    595c:	7aa2                	ld	s5,40(sp)
    595e:	7b02                	ld	s6,32(sp)
    5960:	6be2                	ld	s7,24(sp)
    5962:	6125                	addi	sp,sp,96
    5964:	8082                	ret

0000000000005966 <stat>:

int
stat(const char *n, struct stat *st)
{
    5966:	1101                	addi	sp,sp,-32
    5968:	ec06                	sd	ra,24(sp)
    596a:	e822                	sd	s0,16(sp)
    596c:	e426                	sd	s1,8(sp)
    596e:	e04a                	sd	s2,0(sp)
    5970:	1000                	addi	s0,sp,32
    5972:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5974:	4581                	li	a1,0
    5976:	00000097          	auipc	ra,0x0
    597a:	172080e7          	jalr	370(ra) # 5ae8 <open>
  if(fd < 0)
    597e:	02054563          	bltz	a0,59a8 <stat+0x42>
    5982:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5984:	85ca                	mv	a1,s2
    5986:	00000097          	auipc	ra,0x0
    598a:	17a080e7          	jalr	378(ra) # 5b00 <fstat>
    598e:	892a                	mv	s2,a0
  close(fd);
    5990:	8526                	mv	a0,s1
    5992:	00000097          	auipc	ra,0x0
    5996:	13e080e7          	jalr	318(ra) # 5ad0 <close>
  return r;
}
    599a:	854a                	mv	a0,s2
    599c:	60e2                	ld	ra,24(sp)
    599e:	6442                	ld	s0,16(sp)
    59a0:	64a2                	ld	s1,8(sp)
    59a2:	6902                	ld	s2,0(sp)
    59a4:	6105                	addi	sp,sp,32
    59a6:	8082                	ret
    return -1;
    59a8:	597d                	li	s2,-1
    59aa:	bfc5                	j	599a <stat+0x34>

00000000000059ac <atoi>:

int
atoi(const char *s)
{
    59ac:	1141                	addi	sp,sp,-16
    59ae:	e422                	sd	s0,8(sp)
    59b0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    59b2:	00054603          	lbu	a2,0(a0)
    59b6:	fd06079b          	addiw	a5,a2,-48
    59ba:	0ff7f793          	andi	a5,a5,255
    59be:	4725                	li	a4,9
    59c0:	02f76963          	bltu	a4,a5,59f2 <atoi+0x46>
    59c4:	86aa                	mv	a3,a0
  n = 0;
    59c6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    59c8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    59ca:	0685                	addi	a3,a3,1
    59cc:	0025179b          	slliw	a5,a0,0x2
    59d0:	9fa9                	addw	a5,a5,a0
    59d2:	0017979b          	slliw	a5,a5,0x1
    59d6:	9fb1                	addw	a5,a5,a2
    59d8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    59dc:	0006c603          	lbu	a2,0(a3)
    59e0:	fd06071b          	addiw	a4,a2,-48
    59e4:	0ff77713          	andi	a4,a4,255
    59e8:	fee5f1e3          	bgeu	a1,a4,59ca <atoi+0x1e>
  return n;
}
    59ec:	6422                	ld	s0,8(sp)
    59ee:	0141                	addi	sp,sp,16
    59f0:	8082                	ret
  n = 0;
    59f2:	4501                	li	a0,0
    59f4:	bfe5                	j	59ec <atoi+0x40>

00000000000059f6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    59f6:	1141                	addi	sp,sp,-16
    59f8:	e422                	sd	s0,8(sp)
    59fa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    59fc:	02b57463          	bgeu	a0,a1,5a24 <memmove+0x2e>
    while(n-- > 0)
    5a00:	00c05f63          	blez	a2,5a1e <memmove+0x28>
    5a04:	1602                	slli	a2,a2,0x20
    5a06:	9201                	srli	a2,a2,0x20
    5a08:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5a0c:	872a                	mv	a4,a0
      *dst++ = *src++;
    5a0e:	0585                	addi	a1,a1,1
    5a10:	0705                	addi	a4,a4,1
    5a12:	fff5c683          	lbu	a3,-1(a1)
    5a16:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5a1a:	fee79ae3          	bne	a5,a4,5a0e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5a1e:	6422                	ld	s0,8(sp)
    5a20:	0141                	addi	sp,sp,16
    5a22:	8082                	ret
    dst += n;
    5a24:	00c50733          	add	a4,a0,a2
    src += n;
    5a28:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5a2a:	fec05ae3          	blez	a2,5a1e <memmove+0x28>
    5a2e:	fff6079b          	addiw	a5,a2,-1
    5a32:	1782                	slli	a5,a5,0x20
    5a34:	9381                	srli	a5,a5,0x20
    5a36:	fff7c793          	not	a5,a5
    5a3a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5a3c:	15fd                	addi	a1,a1,-1
    5a3e:	177d                	addi	a4,a4,-1
    5a40:	0005c683          	lbu	a3,0(a1)
    5a44:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5a48:	fee79ae3          	bne	a5,a4,5a3c <memmove+0x46>
    5a4c:	bfc9                	j	5a1e <memmove+0x28>

0000000000005a4e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5a4e:	1141                	addi	sp,sp,-16
    5a50:	e422                	sd	s0,8(sp)
    5a52:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5a54:	ca05                	beqz	a2,5a84 <memcmp+0x36>
    5a56:	fff6069b          	addiw	a3,a2,-1
    5a5a:	1682                	slli	a3,a3,0x20
    5a5c:	9281                	srli	a3,a3,0x20
    5a5e:	0685                	addi	a3,a3,1
    5a60:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5a62:	00054783          	lbu	a5,0(a0)
    5a66:	0005c703          	lbu	a4,0(a1)
    5a6a:	00e79863          	bne	a5,a4,5a7a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5a6e:	0505                	addi	a0,a0,1
    p2++;
    5a70:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5a72:	fed518e3          	bne	a0,a3,5a62 <memcmp+0x14>
  }
  return 0;
    5a76:	4501                	li	a0,0
    5a78:	a019                	j	5a7e <memcmp+0x30>
      return *p1 - *p2;
    5a7a:	40e7853b          	subw	a0,a5,a4
}
    5a7e:	6422                	ld	s0,8(sp)
    5a80:	0141                	addi	sp,sp,16
    5a82:	8082                	ret
  return 0;
    5a84:	4501                	li	a0,0
    5a86:	bfe5                	j	5a7e <memcmp+0x30>

0000000000005a88 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5a88:	1141                	addi	sp,sp,-16
    5a8a:	e406                	sd	ra,8(sp)
    5a8c:	e022                	sd	s0,0(sp)
    5a8e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5a90:	00000097          	auipc	ra,0x0
    5a94:	f66080e7          	jalr	-154(ra) # 59f6 <memmove>
}
    5a98:	60a2                	ld	ra,8(sp)
    5a9a:	6402                	ld	s0,0(sp)
    5a9c:	0141                	addi	sp,sp,16
    5a9e:	8082                	ret

0000000000005aa0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5aa0:	4885                	li	a7,1
 ecall
    5aa2:	00000073          	ecall
 ret
    5aa6:	8082                	ret

0000000000005aa8 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5aa8:	4889                	li	a7,2
 ecall
    5aaa:	00000073          	ecall
 ret
    5aae:	8082                	ret

0000000000005ab0 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5ab0:	488d                	li	a7,3
 ecall
    5ab2:	00000073          	ecall
 ret
    5ab6:	8082                	ret

0000000000005ab8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5ab8:	4891                	li	a7,4
 ecall
    5aba:	00000073          	ecall
 ret
    5abe:	8082                	ret

0000000000005ac0 <read>:
.global read
read:
 li a7, SYS_read
    5ac0:	4895                	li	a7,5
 ecall
    5ac2:	00000073          	ecall
 ret
    5ac6:	8082                	ret

0000000000005ac8 <write>:
.global write
write:
 li a7, SYS_write
    5ac8:	48c1                	li	a7,16
 ecall
    5aca:	00000073          	ecall
 ret
    5ace:	8082                	ret

0000000000005ad0 <close>:
.global close
close:
 li a7, SYS_close
    5ad0:	48d5                	li	a7,21
 ecall
    5ad2:	00000073          	ecall
 ret
    5ad6:	8082                	ret

0000000000005ad8 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5ad8:	4899                	li	a7,6
 ecall
    5ada:	00000073          	ecall
 ret
    5ade:	8082                	ret

0000000000005ae0 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5ae0:	489d                	li	a7,7
 ecall
    5ae2:	00000073          	ecall
 ret
    5ae6:	8082                	ret

0000000000005ae8 <open>:
.global open
open:
 li a7, SYS_open
    5ae8:	48bd                	li	a7,15
 ecall
    5aea:	00000073          	ecall
 ret
    5aee:	8082                	ret

0000000000005af0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5af0:	48c5                	li	a7,17
 ecall
    5af2:	00000073          	ecall
 ret
    5af6:	8082                	ret

0000000000005af8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5af8:	48c9                	li	a7,18
 ecall
    5afa:	00000073          	ecall
 ret
    5afe:	8082                	ret

0000000000005b00 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5b00:	48a1                	li	a7,8
 ecall
    5b02:	00000073          	ecall
 ret
    5b06:	8082                	ret

0000000000005b08 <link>:
.global link
link:
 li a7, SYS_link
    5b08:	48cd                	li	a7,19
 ecall
    5b0a:	00000073          	ecall
 ret
    5b0e:	8082                	ret

0000000000005b10 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5b10:	48d1                	li	a7,20
 ecall
    5b12:	00000073          	ecall
 ret
    5b16:	8082                	ret

0000000000005b18 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5b18:	48a5                	li	a7,9
 ecall
    5b1a:	00000073          	ecall
 ret
    5b1e:	8082                	ret

0000000000005b20 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5b20:	48a9                	li	a7,10
 ecall
    5b22:	00000073          	ecall
 ret
    5b26:	8082                	ret

0000000000005b28 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5b28:	48ad                	li	a7,11
 ecall
    5b2a:	00000073          	ecall
 ret
    5b2e:	8082                	ret

0000000000005b30 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5b30:	48b1                	li	a7,12
 ecall
    5b32:	00000073          	ecall
 ret
    5b36:	8082                	ret

0000000000005b38 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5b38:	48b5                	li	a7,13
 ecall
    5b3a:	00000073          	ecall
 ret
    5b3e:	8082                	ret

0000000000005b40 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5b40:	48b9                	li	a7,14
 ecall
    5b42:	00000073          	ecall
 ret
    5b46:	8082                	ret

0000000000005b48 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
    5b48:	48d9                	li	a7,22
 ecall
    5b4a:	00000073          	ecall
 ret
    5b4e:	8082                	ret

0000000000005b50 <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
    5b50:	48dd                	li	a7,23
 ecall
    5b52:	00000073          	ecall
 ret
    5b56:	8082                	ret

0000000000005b58 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
    5b58:	48e1                	li	a7,24
 ecall
    5b5a:	00000073          	ecall
 ret
    5b5e:	8082                	ret

0000000000005b60 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5b60:	1101                	addi	sp,sp,-32
    5b62:	ec06                	sd	ra,24(sp)
    5b64:	e822                	sd	s0,16(sp)
    5b66:	1000                	addi	s0,sp,32
    5b68:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5b6c:	4605                	li	a2,1
    5b6e:	fef40593          	addi	a1,s0,-17
    5b72:	00000097          	auipc	ra,0x0
    5b76:	f56080e7          	jalr	-170(ra) # 5ac8 <write>
}
    5b7a:	60e2                	ld	ra,24(sp)
    5b7c:	6442                	ld	s0,16(sp)
    5b7e:	6105                	addi	sp,sp,32
    5b80:	8082                	ret

0000000000005b82 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5b82:	7139                	addi	sp,sp,-64
    5b84:	fc06                	sd	ra,56(sp)
    5b86:	f822                	sd	s0,48(sp)
    5b88:	f426                	sd	s1,40(sp)
    5b8a:	f04a                	sd	s2,32(sp)
    5b8c:	ec4e                	sd	s3,24(sp)
    5b8e:	0080                	addi	s0,sp,64
    5b90:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5b92:	c299                	beqz	a3,5b98 <printint+0x16>
    5b94:	0805c863          	bltz	a1,5c24 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5b98:	2581                	sext.w	a1,a1
  neg = 0;
    5b9a:	4881                	li	a7,0
    5b9c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5ba0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5ba2:	2601                	sext.w	a2,a2
    5ba4:	00003517          	auipc	a0,0x3
    5ba8:	89c50513          	addi	a0,a0,-1892 # 8440 <digits>
    5bac:	883a                	mv	a6,a4
    5bae:	2705                	addiw	a4,a4,1
    5bb0:	02c5f7bb          	remuw	a5,a1,a2
    5bb4:	1782                	slli	a5,a5,0x20
    5bb6:	9381                	srli	a5,a5,0x20
    5bb8:	97aa                	add	a5,a5,a0
    5bba:	0007c783          	lbu	a5,0(a5)
    5bbe:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5bc2:	0005879b          	sext.w	a5,a1
    5bc6:	02c5d5bb          	divuw	a1,a1,a2
    5bca:	0685                	addi	a3,a3,1
    5bcc:	fec7f0e3          	bgeu	a5,a2,5bac <printint+0x2a>
  if(neg)
    5bd0:	00088b63          	beqz	a7,5be6 <printint+0x64>
    buf[i++] = '-';
    5bd4:	fd040793          	addi	a5,s0,-48
    5bd8:	973e                	add	a4,a4,a5
    5bda:	02d00793          	li	a5,45
    5bde:	fef70823          	sb	a5,-16(a4)
    5be2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5be6:	02e05863          	blez	a4,5c16 <printint+0x94>
    5bea:	fc040793          	addi	a5,s0,-64
    5bee:	00e78933          	add	s2,a5,a4
    5bf2:	fff78993          	addi	s3,a5,-1
    5bf6:	99ba                	add	s3,s3,a4
    5bf8:	377d                	addiw	a4,a4,-1
    5bfa:	1702                	slli	a4,a4,0x20
    5bfc:	9301                	srli	a4,a4,0x20
    5bfe:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5c02:	fff94583          	lbu	a1,-1(s2)
    5c06:	8526                	mv	a0,s1
    5c08:	00000097          	auipc	ra,0x0
    5c0c:	f58080e7          	jalr	-168(ra) # 5b60 <putc>
  while(--i >= 0)
    5c10:	197d                	addi	s2,s2,-1
    5c12:	ff3918e3          	bne	s2,s3,5c02 <printint+0x80>
}
    5c16:	70e2                	ld	ra,56(sp)
    5c18:	7442                	ld	s0,48(sp)
    5c1a:	74a2                	ld	s1,40(sp)
    5c1c:	7902                	ld	s2,32(sp)
    5c1e:	69e2                	ld	s3,24(sp)
    5c20:	6121                	addi	sp,sp,64
    5c22:	8082                	ret
    x = -xx;
    5c24:	40b005bb          	negw	a1,a1
    neg = 1;
    5c28:	4885                	li	a7,1
    x = -xx;
    5c2a:	bf8d                	j	5b9c <printint+0x1a>

0000000000005c2c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5c2c:	7119                	addi	sp,sp,-128
    5c2e:	fc86                	sd	ra,120(sp)
    5c30:	f8a2                	sd	s0,112(sp)
    5c32:	f4a6                	sd	s1,104(sp)
    5c34:	f0ca                	sd	s2,96(sp)
    5c36:	ecce                	sd	s3,88(sp)
    5c38:	e8d2                	sd	s4,80(sp)
    5c3a:	e4d6                	sd	s5,72(sp)
    5c3c:	e0da                	sd	s6,64(sp)
    5c3e:	fc5e                	sd	s7,56(sp)
    5c40:	f862                	sd	s8,48(sp)
    5c42:	f466                	sd	s9,40(sp)
    5c44:	f06a                	sd	s10,32(sp)
    5c46:	ec6e                	sd	s11,24(sp)
    5c48:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5c4a:	0005c903          	lbu	s2,0(a1)
    5c4e:	18090f63          	beqz	s2,5dec <vprintf+0x1c0>
    5c52:	8aaa                	mv	s5,a0
    5c54:	8b32                	mv	s6,a2
    5c56:	00158493          	addi	s1,a1,1
  state = 0;
    5c5a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5c5c:	02500a13          	li	s4,37
      if(c == 'd'){
    5c60:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5c64:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5c68:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5c6c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5c70:	00002b97          	auipc	s7,0x2
    5c74:	7d0b8b93          	addi	s7,s7,2000 # 8440 <digits>
    5c78:	a839                	j	5c96 <vprintf+0x6a>
        putc(fd, c);
    5c7a:	85ca                	mv	a1,s2
    5c7c:	8556                	mv	a0,s5
    5c7e:	00000097          	auipc	ra,0x0
    5c82:	ee2080e7          	jalr	-286(ra) # 5b60 <putc>
    5c86:	a019                	j	5c8c <vprintf+0x60>
    } else if(state == '%'){
    5c88:	01498f63          	beq	s3,s4,5ca6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5c8c:	0485                	addi	s1,s1,1
    5c8e:	fff4c903          	lbu	s2,-1(s1)
    5c92:	14090d63          	beqz	s2,5dec <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5c96:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5c9a:	fe0997e3          	bnez	s3,5c88 <vprintf+0x5c>
      if(c == '%'){
    5c9e:	fd479ee3          	bne	a5,s4,5c7a <vprintf+0x4e>
        state = '%';
    5ca2:	89be                	mv	s3,a5
    5ca4:	b7e5                	j	5c8c <vprintf+0x60>
      if(c == 'd'){
    5ca6:	05878063          	beq	a5,s8,5ce6 <vprintf+0xba>
      } else if(c == 'l') {
    5caa:	05978c63          	beq	a5,s9,5d02 <vprintf+0xd6>
      } else if(c == 'x') {
    5cae:	07a78863          	beq	a5,s10,5d1e <vprintf+0xf2>
      } else if(c == 'p') {
    5cb2:	09b78463          	beq	a5,s11,5d3a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5cb6:	07300713          	li	a4,115
    5cba:	0ce78663          	beq	a5,a4,5d86 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5cbe:	06300713          	li	a4,99
    5cc2:	0ee78e63          	beq	a5,a4,5dbe <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5cc6:	11478863          	beq	a5,s4,5dd6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5cca:	85d2                	mv	a1,s4
    5ccc:	8556                	mv	a0,s5
    5cce:	00000097          	auipc	ra,0x0
    5cd2:	e92080e7          	jalr	-366(ra) # 5b60 <putc>
        putc(fd, c);
    5cd6:	85ca                	mv	a1,s2
    5cd8:	8556                	mv	a0,s5
    5cda:	00000097          	auipc	ra,0x0
    5cde:	e86080e7          	jalr	-378(ra) # 5b60 <putc>
      }
      state = 0;
    5ce2:	4981                	li	s3,0
    5ce4:	b765                	j	5c8c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5ce6:	008b0913          	addi	s2,s6,8
    5cea:	4685                	li	a3,1
    5cec:	4629                	li	a2,10
    5cee:	000b2583          	lw	a1,0(s6)
    5cf2:	8556                	mv	a0,s5
    5cf4:	00000097          	auipc	ra,0x0
    5cf8:	e8e080e7          	jalr	-370(ra) # 5b82 <printint>
    5cfc:	8b4a                	mv	s6,s2
      state = 0;
    5cfe:	4981                	li	s3,0
    5d00:	b771                	j	5c8c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5d02:	008b0913          	addi	s2,s6,8
    5d06:	4681                	li	a3,0
    5d08:	4629                	li	a2,10
    5d0a:	000b2583          	lw	a1,0(s6)
    5d0e:	8556                	mv	a0,s5
    5d10:	00000097          	auipc	ra,0x0
    5d14:	e72080e7          	jalr	-398(ra) # 5b82 <printint>
    5d18:	8b4a                	mv	s6,s2
      state = 0;
    5d1a:	4981                	li	s3,0
    5d1c:	bf85                	j	5c8c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5d1e:	008b0913          	addi	s2,s6,8
    5d22:	4681                	li	a3,0
    5d24:	4641                	li	a2,16
    5d26:	000b2583          	lw	a1,0(s6)
    5d2a:	8556                	mv	a0,s5
    5d2c:	00000097          	auipc	ra,0x0
    5d30:	e56080e7          	jalr	-426(ra) # 5b82 <printint>
    5d34:	8b4a                	mv	s6,s2
      state = 0;
    5d36:	4981                	li	s3,0
    5d38:	bf91                	j	5c8c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5d3a:	008b0793          	addi	a5,s6,8
    5d3e:	f8f43423          	sd	a5,-120(s0)
    5d42:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5d46:	03000593          	li	a1,48
    5d4a:	8556                	mv	a0,s5
    5d4c:	00000097          	auipc	ra,0x0
    5d50:	e14080e7          	jalr	-492(ra) # 5b60 <putc>
  putc(fd, 'x');
    5d54:	85ea                	mv	a1,s10
    5d56:	8556                	mv	a0,s5
    5d58:	00000097          	auipc	ra,0x0
    5d5c:	e08080e7          	jalr	-504(ra) # 5b60 <putc>
    5d60:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5d62:	03c9d793          	srli	a5,s3,0x3c
    5d66:	97de                	add	a5,a5,s7
    5d68:	0007c583          	lbu	a1,0(a5)
    5d6c:	8556                	mv	a0,s5
    5d6e:	00000097          	auipc	ra,0x0
    5d72:	df2080e7          	jalr	-526(ra) # 5b60 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5d76:	0992                	slli	s3,s3,0x4
    5d78:	397d                	addiw	s2,s2,-1
    5d7a:	fe0914e3          	bnez	s2,5d62 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5d7e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5d82:	4981                	li	s3,0
    5d84:	b721                	j	5c8c <vprintf+0x60>
        s = va_arg(ap, char*);
    5d86:	008b0993          	addi	s3,s6,8
    5d8a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5d8e:	02090163          	beqz	s2,5db0 <vprintf+0x184>
        while(*s != 0){
    5d92:	00094583          	lbu	a1,0(s2)
    5d96:	c9a1                	beqz	a1,5de6 <vprintf+0x1ba>
          putc(fd, *s);
    5d98:	8556                	mv	a0,s5
    5d9a:	00000097          	auipc	ra,0x0
    5d9e:	dc6080e7          	jalr	-570(ra) # 5b60 <putc>
          s++;
    5da2:	0905                	addi	s2,s2,1
        while(*s != 0){
    5da4:	00094583          	lbu	a1,0(s2)
    5da8:	f9e5                	bnez	a1,5d98 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5daa:	8b4e                	mv	s6,s3
      state = 0;
    5dac:	4981                	li	s3,0
    5dae:	bdf9                	j	5c8c <vprintf+0x60>
          s = "(null)";
    5db0:	00002917          	auipc	s2,0x2
    5db4:	68890913          	addi	s2,s2,1672 # 8438 <malloc+0x2542>
        while(*s != 0){
    5db8:	02800593          	li	a1,40
    5dbc:	bff1                	j	5d98 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5dbe:	008b0913          	addi	s2,s6,8
    5dc2:	000b4583          	lbu	a1,0(s6)
    5dc6:	8556                	mv	a0,s5
    5dc8:	00000097          	auipc	ra,0x0
    5dcc:	d98080e7          	jalr	-616(ra) # 5b60 <putc>
    5dd0:	8b4a                	mv	s6,s2
      state = 0;
    5dd2:	4981                	li	s3,0
    5dd4:	bd65                	j	5c8c <vprintf+0x60>
        putc(fd, c);
    5dd6:	85d2                	mv	a1,s4
    5dd8:	8556                	mv	a0,s5
    5dda:	00000097          	auipc	ra,0x0
    5dde:	d86080e7          	jalr	-634(ra) # 5b60 <putc>
      state = 0;
    5de2:	4981                	li	s3,0
    5de4:	b565                	j	5c8c <vprintf+0x60>
        s = va_arg(ap, char*);
    5de6:	8b4e                	mv	s6,s3
      state = 0;
    5de8:	4981                	li	s3,0
    5dea:	b54d                	j	5c8c <vprintf+0x60>
    }
  }
}
    5dec:	70e6                	ld	ra,120(sp)
    5dee:	7446                	ld	s0,112(sp)
    5df0:	74a6                	ld	s1,104(sp)
    5df2:	7906                	ld	s2,96(sp)
    5df4:	69e6                	ld	s3,88(sp)
    5df6:	6a46                	ld	s4,80(sp)
    5df8:	6aa6                	ld	s5,72(sp)
    5dfa:	6b06                	ld	s6,64(sp)
    5dfc:	7be2                	ld	s7,56(sp)
    5dfe:	7c42                	ld	s8,48(sp)
    5e00:	7ca2                	ld	s9,40(sp)
    5e02:	7d02                	ld	s10,32(sp)
    5e04:	6de2                	ld	s11,24(sp)
    5e06:	6109                	addi	sp,sp,128
    5e08:	8082                	ret

0000000000005e0a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5e0a:	715d                	addi	sp,sp,-80
    5e0c:	ec06                	sd	ra,24(sp)
    5e0e:	e822                	sd	s0,16(sp)
    5e10:	1000                	addi	s0,sp,32
    5e12:	e010                	sd	a2,0(s0)
    5e14:	e414                	sd	a3,8(s0)
    5e16:	e818                	sd	a4,16(s0)
    5e18:	ec1c                	sd	a5,24(s0)
    5e1a:	03043023          	sd	a6,32(s0)
    5e1e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5e22:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5e26:	8622                	mv	a2,s0
    5e28:	00000097          	auipc	ra,0x0
    5e2c:	e04080e7          	jalr	-508(ra) # 5c2c <vprintf>
}
    5e30:	60e2                	ld	ra,24(sp)
    5e32:	6442                	ld	s0,16(sp)
    5e34:	6161                	addi	sp,sp,80
    5e36:	8082                	ret

0000000000005e38 <printf>:

void
printf(const char *fmt, ...)
{
    5e38:	711d                	addi	sp,sp,-96
    5e3a:	ec06                	sd	ra,24(sp)
    5e3c:	e822                	sd	s0,16(sp)
    5e3e:	1000                	addi	s0,sp,32
    5e40:	e40c                	sd	a1,8(s0)
    5e42:	e810                	sd	a2,16(s0)
    5e44:	ec14                	sd	a3,24(s0)
    5e46:	f018                	sd	a4,32(s0)
    5e48:	f41c                	sd	a5,40(s0)
    5e4a:	03043823          	sd	a6,48(s0)
    5e4e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5e52:	00840613          	addi	a2,s0,8
    5e56:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5e5a:	85aa                	mv	a1,a0
    5e5c:	4505                	li	a0,1
    5e5e:	00000097          	auipc	ra,0x0
    5e62:	dce080e7          	jalr	-562(ra) # 5c2c <vprintf>
}
    5e66:	60e2                	ld	ra,24(sp)
    5e68:	6442                	ld	s0,16(sp)
    5e6a:	6125                	addi	sp,sp,96
    5e6c:	8082                	ret

0000000000005e6e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5e6e:	1141                	addi	sp,sp,-16
    5e70:	e422                	sd	s0,8(sp)
    5e72:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5e74:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5e78:	00003797          	auipc	a5,0x3
    5e7c:	5b87b783          	ld	a5,1464(a5) # 9430 <freep>
    5e80:	a805                	j	5eb0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5e82:	4618                	lw	a4,8(a2)
    5e84:	9db9                	addw	a1,a1,a4
    5e86:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5e8a:	6398                	ld	a4,0(a5)
    5e8c:	6318                	ld	a4,0(a4)
    5e8e:	fee53823          	sd	a4,-16(a0)
    5e92:	a091                	j	5ed6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5e94:	ff852703          	lw	a4,-8(a0)
    5e98:	9e39                	addw	a2,a2,a4
    5e9a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5e9c:	ff053703          	ld	a4,-16(a0)
    5ea0:	e398                	sd	a4,0(a5)
    5ea2:	a099                	j	5ee8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5ea4:	6398                	ld	a4,0(a5)
    5ea6:	00e7e463          	bltu	a5,a4,5eae <free+0x40>
    5eaa:	00e6ea63          	bltu	a3,a4,5ebe <free+0x50>
{
    5eae:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5eb0:	fed7fae3          	bgeu	a5,a3,5ea4 <free+0x36>
    5eb4:	6398                	ld	a4,0(a5)
    5eb6:	00e6e463          	bltu	a3,a4,5ebe <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5eba:	fee7eae3          	bltu	a5,a4,5eae <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5ebe:	ff852583          	lw	a1,-8(a0)
    5ec2:	6390                	ld	a2,0(a5)
    5ec4:	02059713          	slli	a4,a1,0x20
    5ec8:	9301                	srli	a4,a4,0x20
    5eca:	0712                	slli	a4,a4,0x4
    5ecc:	9736                	add	a4,a4,a3
    5ece:	fae60ae3          	beq	a2,a4,5e82 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5ed2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5ed6:	4790                	lw	a2,8(a5)
    5ed8:	02061713          	slli	a4,a2,0x20
    5edc:	9301                	srli	a4,a4,0x20
    5ede:	0712                	slli	a4,a4,0x4
    5ee0:	973e                	add	a4,a4,a5
    5ee2:	fae689e3          	beq	a3,a4,5e94 <free+0x26>
  } else
    p->s.ptr = bp;
    5ee6:	e394                	sd	a3,0(a5)
  freep = p;
    5ee8:	00003717          	auipc	a4,0x3
    5eec:	54f73423          	sd	a5,1352(a4) # 9430 <freep>
}
    5ef0:	6422                	ld	s0,8(sp)
    5ef2:	0141                	addi	sp,sp,16
    5ef4:	8082                	ret

0000000000005ef6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5ef6:	7139                	addi	sp,sp,-64
    5ef8:	fc06                	sd	ra,56(sp)
    5efa:	f822                	sd	s0,48(sp)
    5efc:	f426                	sd	s1,40(sp)
    5efe:	f04a                	sd	s2,32(sp)
    5f00:	ec4e                	sd	s3,24(sp)
    5f02:	e852                	sd	s4,16(sp)
    5f04:	e456                	sd	s5,8(sp)
    5f06:	e05a                	sd	s6,0(sp)
    5f08:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5f0a:	02051493          	slli	s1,a0,0x20
    5f0e:	9081                	srli	s1,s1,0x20
    5f10:	04bd                	addi	s1,s1,15
    5f12:	8091                	srli	s1,s1,0x4
    5f14:	0014899b          	addiw	s3,s1,1
    5f18:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5f1a:	00003517          	auipc	a0,0x3
    5f1e:	51653503          	ld	a0,1302(a0) # 9430 <freep>
    5f22:	c515                	beqz	a0,5f4e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5f24:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5f26:	4798                	lw	a4,8(a5)
    5f28:	02977f63          	bgeu	a4,s1,5f66 <malloc+0x70>
    5f2c:	8a4e                	mv	s4,s3
    5f2e:	0009871b          	sext.w	a4,s3
    5f32:	6685                	lui	a3,0x1
    5f34:	00d77363          	bgeu	a4,a3,5f3a <malloc+0x44>
    5f38:	6a05                	lui	s4,0x1
    5f3a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5f3e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5f42:	00003917          	auipc	s2,0x3
    5f46:	4ee90913          	addi	s2,s2,1262 # 9430 <freep>
  if(p == (char*)-1)
    5f4a:	5afd                	li	s5,-1
    5f4c:	a88d                	j	5fbe <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5f4e:	0000a797          	auipc	a5,0xa
    5f52:	d0a78793          	addi	a5,a5,-758 # fc58 <base>
    5f56:	00003717          	auipc	a4,0x3
    5f5a:	4cf73d23          	sd	a5,1242(a4) # 9430 <freep>
    5f5e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5f60:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5f64:	b7e1                	j	5f2c <malloc+0x36>
      if(p->s.size == nunits)
    5f66:	02e48b63          	beq	s1,a4,5f9c <malloc+0xa6>
        p->s.size -= nunits;
    5f6a:	4137073b          	subw	a4,a4,s3
    5f6e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5f70:	1702                	slli	a4,a4,0x20
    5f72:	9301                	srli	a4,a4,0x20
    5f74:	0712                	slli	a4,a4,0x4
    5f76:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5f78:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5f7c:	00003717          	auipc	a4,0x3
    5f80:	4aa73a23          	sd	a0,1204(a4) # 9430 <freep>
      return (void*)(p + 1);
    5f84:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5f88:	70e2                	ld	ra,56(sp)
    5f8a:	7442                	ld	s0,48(sp)
    5f8c:	74a2                	ld	s1,40(sp)
    5f8e:	7902                	ld	s2,32(sp)
    5f90:	69e2                	ld	s3,24(sp)
    5f92:	6a42                	ld	s4,16(sp)
    5f94:	6aa2                	ld	s5,8(sp)
    5f96:	6b02                	ld	s6,0(sp)
    5f98:	6121                	addi	sp,sp,64
    5f9a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5f9c:	6398                	ld	a4,0(a5)
    5f9e:	e118                	sd	a4,0(a0)
    5fa0:	bff1                	j	5f7c <malloc+0x86>
  hp->s.size = nu;
    5fa2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5fa6:	0541                	addi	a0,a0,16
    5fa8:	00000097          	auipc	ra,0x0
    5fac:	ec6080e7          	jalr	-314(ra) # 5e6e <free>
  return freep;
    5fb0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5fb4:	d971                	beqz	a0,5f88 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5fb6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5fb8:	4798                	lw	a4,8(a5)
    5fba:	fa9776e3          	bgeu	a4,s1,5f66 <malloc+0x70>
    if(p == freep)
    5fbe:	00093703          	ld	a4,0(s2)
    5fc2:	853e                	mv	a0,a5
    5fc4:	fef719e3          	bne	a4,a5,5fb6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    5fc8:	8552                	mv	a0,s4
    5fca:	00000097          	auipc	ra,0x0
    5fce:	b66080e7          	jalr	-1178(ra) # 5b30 <sbrk>
  if(p == (char*)-1)
    5fd2:	fd5518e3          	bne	a0,s5,5fa2 <malloc+0xac>
        return 0;
    5fd6:	4501                	li	a0,0
    5fd8:	bf45                	j	5f88 <malloc+0x92>
