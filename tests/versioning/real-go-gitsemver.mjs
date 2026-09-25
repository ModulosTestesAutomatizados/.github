import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const tool = process.env.GO_GITSEMVER_BIN || 'go-gitsemver';
const repo = mkdtempSync(join(tmpdir(), 'real-go-gitsemver-'));
const git = (...args) => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const calculate = () => {
  const sha = git('rev-parse', 'HEAD');
  const raw = execFileSync(tool, ['--branch', 'master', '--commit', sha, '-o', 'json', '--explain'],
    { cwd: repo, encoding: 'utf8' });
  const result = JSON.parse(raw);
  assert.equal(result.Sha, sha);
  assert.match(result.SemVer, /^\d+\.\d+\.\d+$/);
  return result.SemVer;
};
let count = 0;
const commit = message => {
  writeFileSync(join(repo, 'payload.txt'), String(++count));
  git('add', '.');
  git('commit', '-m', message);
};

try {
  git('init', '-b', 'master');
  git('config', 'user.name', 'Fixture');
  git('config', 'user.email', 'fixture@example.test');
  git('config', 'core.autocrlf', 'false');
  mkdirSync(join(repo, '.github'));
  writeFileSync(join(repo, '.github', 'GitVersion.yml'), `mode: Mainline
base-version: 0.0.0
next-version: 0.0.1
commit-message-incrementing: Disabled
branches:
  main:
    regex: ^master$
    is-mainline: true
    increment: Patch
    tag: ''
  release:
    regex: ^release[/-]
    is-release-branch: false
`);
  commit('feat: bootstrap');
  assert.equal(calculate(), '0.0.1', 'native bootstrap version');
  git('tag', 'v0.0.1');

  writeFileSync(join(repo, '.github', 'GitVersion.yml'), `mode: Mainline
base-version: 0.0.0
branches:
  main:
    regex: ^master$
    is-mainline: true
    increment: Patch
    tag: ''
  release:
    regex: ^release[/-]
    is-release-branch: false
`);
  git('add', '.github/GitVersion.yml');
  git('commit', '-m', 'chore: remove bootstrap overrides');
  commit('fix: correct behavior');
  const fix = calculate();
  assert.equal(fix, '0.0.2');
  git('tag', `v${fix}`);
  commit('feat: add feature');
  const feature = calculate();
  assert.equal(feature, '0.1.0');
  git('tag', 'v1.0.0');
  commit('feat!: change contract');
  const breaking = calculate();
  assert.equal(breaking, '2.0.0');
  git('tag', `v${breaking}`);
  commit('fix: first delivery');
  commit('feat: second delivery');
  const multiple = calculate();
  assert.equal(multiple, '2.1.0', 'the highest increment across one sprint is applied once');
  assert.notEqual(multiple, '9.9.9', 'milestone label must not drive application version');
  console.log('Real go-gitsemver: bootstrap, fix, feat, breaking change and combined sprint passed');
} finally {
  rmSync(repo, { recursive: true, force: true });
}
