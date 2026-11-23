import { Buffer } from 'node:buffer';
import { mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const info = new Uint8Array(256);
const def = (ops: number[], imm = 0, pops = 0, pushes = 0) => {
  for (const op of ops) info[op] = 128 | (imm << 4) | (pops << 2) | pushes;
};
def([0]);
def([1], 1, 0, 1);
def([2], 4, 0, 1);
def([3], 0, 1);
def([4], 0, 1, 2);
def([5], 0, 2, 2);
def([6], 0, 2, 3);
def([7], 0, 3, 3);
for (let op = 0x10; op <= 0x16; op++) def([op], 0, 2, 1);
for (let op = 0x18; op <= 0x22; op++) if (op !== 0x1b) def([op], 0, 2, 1);
def([0x17, 0x1b], 0, 1, 1);
def([0x30], 2);
def([0x31, 0x32], 2, 1);
def([0x33], 2);
def([0x34]);
def([0x40], 0, 1, 1);
def([0x41], 0, 2);
def([0x50, 0x51], 0, 1);
def([0x52], 0, 0, 1);
def([0x53], 0, 1);

function run(program: Buffer, input: Buffer): { output: Buffer; exit: number } {
  const data = new Int32Array(256), calls = new Int32Array(64), memory = new Int32Array(256);
  const output = Buffer.alloc(65536);
  let sp = 0, cp = 0, ip = 0, pc = 0, steps = 0, size = 0;
  const done = (exit: number) => ({ output: output.subarray(0, size), exit });
  for (;;) {
    if (steps === 1000000) return done(10);
    if (pc < 0 || pc >= program.length) return done(9);
    const op = program[pc], meta = info[op];
    if (!(meta & 128)) return done(5);
    const imm = (meta >> 4) & 7, pops = (meta >> 2) & 3, pushes = meta & 3;
    if (pc + imm >= program.length) return done(9);
    steps++;
    const next = pc + 1 + imm;
    if (sp < pops) return done(2);
    if (sp - pops + pushes > 256) return done(3);
    pc = next;
    if (op === 0) return done(0);
    if (op === 1) data[sp++] = (program[next - 1] << 24) >> 24;
    else if (op === 2) data[sp++] = program[next - 4] | program[next - 3] << 8 | program[next - 2] << 16 | program[next - 1] << 24;
    else if (op === 3) sp--;
    else if (op === 4) { data[sp] = data[sp - 1]; sp++; }
    else if (op === 5) { const a = data[sp - 1]; data[sp - 1] = data[sp - 2]; data[sp - 2] = a; }
    else if (op === 6) { data[sp] = data[sp - 2]; sp++; }
    else if (op === 7) { const a = data[sp - 3]; data[sp - 3] = data[sp - 2]; data[sp - 2] = data[sp - 1]; data[sp - 1] = a; }
    else if (op === 0x17) data[sp - 1] = -data[sp - 1] | 0;
    else if (op === 0x1b) data[sp - 1] = ~data[sp - 1];
    else if ((op >= 0x10 && op <= 0x16) || (op >= 0x18 && op <= 0x22 && op !== 0x1b)) {
      const b = data[sp - 1], a = data[sp - 2];
      let r = 0;
      if (op === 0x10) r = a + b | 0;
      else if (op === 0x11) r = a - b | 0;
      else if (op === 0x12) r = Math.imul(a, b);
      else if (op === 0x13) { if (!b) return done(4); r = a === -2147483648 && b === -1 ? a : Math.trunc(a / b) | 0; }
      else if (op === 0x14) { if (!b) return done(4); r = b === -1 ? 0 : a % b | 0; }
      else if (op === 0x15) { if (!b) return done(4); r = Math.floor((a >>> 0) / (b >>> 0)) | 0; }
      else if (op === 0x16) { if (!b) return done(4); r = (a >>> 0) % (b >>> 0) | 0; }
      else if (op === 0x18) r = a & b;
      else if (op === 0x19) r = a | b;
      else if (op === 0x1a) r = a ^ b;
      else if (op === 0x1c) r = a << (b & 31);
      else if (op === 0x1d) r = a >> (b & 31);
      else if (op === 0x1e) r = a >>> (b & 31);
      else if (op === 0x20) r = +(a === b);
      else if (op === 0x21) r = +(a < b);
      else if (op === 0x22) r = +((a >>> 0) < (b >>> 0));
      sp -= 2;
      data[sp++] = r;
    } else if (op >= 0x30 && op <= 0x32) {
      let take = true;
      if (op !== 0x30) { const v = data[--sp]; take = op === 0x31 ? v === 0 : v !== 0; }
      if (take) pc = next + (((program[next - 2] | program[next - 1] << 8) << 16) >> 16);
    } else if (op === 0x33) {
      if (cp === 64) return done(7);
      calls[cp++] = next;
      pc = program[next - 2] | program[next - 1] << 8;
    } else if (op === 0x34) {
      if (!cp) return done(8);
      pc = calls[--cp];
    } else if (op === 0x40) {
      const addr = data[sp - 1];
      if (addr < 0 || addr > 255) return done(6);
      data[sp - 1] = memory[addr];
    } else if (op === 0x41) {
      const addr = data[sp - 1];
      if (addr < 0 || addr > 255) return done(6);
      memory[addr] = data[sp - 2];
      sp -= 2;
    } else if (op === 0x50) {
      const bytes = Buffer.from(String(data[sp - 1]));
      if (size + bytes.length > 65536) return done(11);
      bytes.copy(output, size);
      size += bytes.length;
      sp--;
    } else if (op === 0x51) {
      if (size === 65536) return done(11);
      output[size++] = data[--sp] & 255;
    } else if (op === 0x52) data[sp++] = ip < input.length ? input[ip++] : -1;
    else if (op === 0x53) return done(data[--sp] & 255);
  }
}

const inputDir = process.env.MAKEFUN_INPUT_DIR ?? '/input';
const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';
for (const id of readdirSync(inputDir).sort()) {
  const result = run(readFileSync(join(inputDir, id, 'program.bin')), readFileSync(join(inputDir, id, 'input.bin')));
  const dir = join(outputDir, id);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, 'stdout.bin'), result.output);
  writeFileSync(join(dir, 'exit.txt'), `${result.exit}\n`);
}
