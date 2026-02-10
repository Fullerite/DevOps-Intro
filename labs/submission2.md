# Lab 2 Submission

## Task 1 — Git Object Model Exploration

### Object Inspection Outputs
- **Commit Hash:** `ba6c4d8`
- **Commit Object Content:**
```text
tree 38395815755309860839913e6bf64e07dc475b14
parent 488c24f039507814e24b994e3d1e26c4cd7c2917
author Fullerite <sh.ramil2005@gmail.com> 1770744998 +0300
committer Fullerite <sh.ramil2005@gmail.com> 1770744998 +0300
(Signed via SSH)
```

- **Tree Object Content:**
```text
040000 tree 99b06950f8c7e5c2b27c30cd520bd6f169992197    .github
100644 blob 6e60bebec0724892a7c82c52183d0a7b467cb6bb    README.md
100644 blob 95e6553499136010fa34e1d9f0f12d1a917b8f40    test.txt
```

- **Blob Object Content:**
```text
Learning Git internals
```

### Explanations
- **Blob:** Stores the actual file data (like the text in test.txt). It doesn't store filenames or permissions.
- **Tree:** Acts like a directory. It maps filenames to blob hashes and lists file permissions.
- **Commit:** A snapshot of the repository. It points to a specific tree object and records the author, date, and parent commit(s) for history.

---

## Task 2 — Reset and Reflog Recovery

### Commands Executed
1. `git reset --soft HEAD~1`: Moved HEAD back one commit, but kept changes in the staging area.
2. `git reset --hard HEAD~1`: Moved HEAD back and wiped the changes from the working directory.
3. `git reflog`: Used to find the "lost" commit hash (`67e7a61`).
4. `git reset --hard 67e7a61`: Successfully recovered the third commit.

### Evidence of Recovery (Reflog Snippet)
```text
9f69f4b HEAD@{0}: reset: moving to HEAD~1
6e0fd30 HEAD@{1}: reset: moving to HEAD~1
67e7a61 HEAD@{2}: commit: Third commit
```

### Analysis
Git's history is rarely truly "lost" as long as it was committed. The reflog tracks every movement of HEAD, allowing us to undo accidental hard resets by jumping back to a previous commit hash.

---

## Task 3 — Visualize Commit History

### Commit History Graph
```text
* 4e5d222 (side-branch) Side branch commit
| * 67e7a61 (git-reset-practice) Third commit
| * 6e0fd30 Second commit
| * 9f69f4b First commit
|/  
* ba6c4d8 (HEAD -> feature/lab2) Task 1: add test file
```

### Reflection
The `--graph` visualization is essential for understanding complex workflows. It shows exactly where branches diverged and helps identify which features are merged and which are still isolated on side branches.

---

## Task 4 — Tagging Commits

### Commands and Metadata
- **Command used:** `git tag v1.0.0`
- **Associated Commit Hash:** ba6c4d8
- **Push command:** `git push origin v1.0.0`

### Importance of Tags
Tags are used to mark specific release points (like v1.0) in a project's history. Unlike branches, tags are permanent and do not change. In DevOps, tags are frequently used to trigger CI/CD pipelines to build and deploy production-ready software.

---

## Task 5 — git switch vs git checkout vs git restore

### Commands and Observations
- **Switching:** Used `git switch -c cmd-compare` to create a branch. Unlike `checkout`, `switch` is dedicated only to branch management, making it safer to use.
- **Restoring Files:** Used `git restore test.txt` to discard uncommitted changes. This successfully removed the "mistake" line without needing to touch branches.
- **Unstaging:** Used `git restore --staged test.txt` to remove the file from the index. `git status` showed the file moved from "Changes to be committed" back to "Changes not staged for commit."

### Analysis
- **git switch:** Best used for branch operations. It is clearer than checkout because it won't accidentally modify files.
- **git restore:** Best used for undoing mistakes in your code or "un-adding" files you staged by accident.
- **git checkout:** A legacy command that is "overloaded." It's better to use the modern specific commands to avoid unintended side effects.

---

## Task 6 — GitHub Community Engagement

### Social Actions
- Starred the course repository and `simple-container-com/api`.
- Followed the professor and TAs.
- Followed 3 classmates.

### Reflection
- **Starring:** Starring repositories serves as a bookmarking system and a signal of community trust. In open source, stars help projects gain visibility and indicate to maintainers that their work is valued.
- **Following:** Following developers allows for professional networking and discovery. It helps stay updated on best practices and new tools used by peers and mentors in the industry.
