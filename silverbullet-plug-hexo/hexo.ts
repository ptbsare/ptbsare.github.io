import { readSetting } from "$sb/lib/settings_page.ts";
import { editor, space, shell } from "$sb/syscalls.ts";
import { UploadFile } from "$sb/types.ts";
import { resolvePath } from "$sb/lib/resolve.ts";
const maximumAttachmentSize = 100; // MiB
const defaultLinkStyle = "wikilink";

export async function saveFile(file: UploadFile) {
  const maxSize = await readSetting(
    "maximumAttachmentSize",
    maximumAttachmentSize,
  );
  if (typeof maxSize !== "number") {
    await editor.flashNotification(
      "The setting 'maximumAttachmentSize' must be a number",
      "error",
    );
  }
  if (file.content.length > maxSize * 1024 * 1024) {
    editor.flashNotification(
      `Attachment is too large, maximum is ${maxSize}MiB`,
      "error",
    );
    return;
  }

  let finalFileName = await editor.prompt(
    "File name for pasted attachment",
    file.name,
  );
  if (!finalFileName) {
    return;
  }
  finalFileName=finalFileName.split(' ').join('-');
  const attachmentPath = resolvePath(
    await editor.getCurrentPage(),
    await editor.getCurrentPage()+"/"+finalFileName,
  );
  await space.writeAttachment(attachmentPath, file.content);

//  const linkStyle = await readSetting(
//    "defaultLinkStyle",
//    defaultLinkStyle,
//  );
  const linkStyle = "";
  let attachmentMarkdown = "";
  if (linkStyle === "wikilink") {
    attachmentMarkdown = `[[${attachmentPath}]]`;
  } else {
    let folderPath = await editor.getCurrentPage();
    folderPath=folderPath.split(' ').join('-');
    attachmentMarkdown = `[${finalFileName}](${folderPath.split("/").pop()+"/"+finalFileName})`;
  }
  if (file.contentType.startsWith("image/")) {
    attachmentMarkdown = "!" + attachmentMarkdown;
  }
  editor.insertAtCursor(attachmentMarkdown);
}

export async function uploadFile(_ctx: any, accept?: string, capture?: string) {
  const uploadFile = await editor.uploadFile(accept, capture);
  await saveFile(uploadFile);
}

export async function npmInstall() {
    console.log("npm install");
  try {
    const { code } = await shell.run("npm",["install"]);
    console.log(code);
  } catch {
    // We can ignore
  }
  console.log("Npm Install Done!");
  await editor.flashNotification("Npm Install Done! ",);
}

export async function init () {
    console.log("hexo init");
  try {
    const { code } = await shell.run("hexo",["init"]);
    console.log(code);
  } catch {
    // We can ignore
  }
  console.log("Hexo Init Done!");
  await editor.flashNotification("Hexo Init Done.",);
}

export async function newArticle() {
    console.log("hexo new");
    let layout = await editor.prompt(`New article layout(void to default layout):`);
    let title = await editor.prompt(`New article title:`);
    if (!title) {
    return;
    }
  try {
    const { code } = await shell.run("hexo",["new", layout, title]);
    console.log(code);
  } catch {
    // We can ignore
  }
  console.log("Hexo New Done!");
  await editor.flashNotification("Hexo New Done!",);
}

export async function generate() {
    console.log("hexo generate");
  try {
    const { code } = await shell.run("hexo",["generate"]);
    console.log(code);
  } catch {
    // We can ignore
  }
  console.log("Hexo Generate Done!");
  await editor.flashNotification("Hexo Generate Done!",);
}

export async function clean() {
    console.log("hexo clean");
  try {
    const { code } = await shell.run("hexo",["clean"]);
    console.log(code);
  } catch {
    // We can ignore
  }
  console.log("Hexo Clean Done!");
  await editor.flashNotification("Hexo Clean Done!",);
}

export async function server() {
    console.log("hexo server");
  try {
    const { code } = await shell.run("hexo",["server", "&"]);
    console.log(code);
  } catch {
    // We can ignore
  }
  console.log("Hexo Server Done!");
  await editor.flashNotification("Hexo Server Done!",);
}
export async function deploy() {
    console.log("hexo deploy");
  try {
    const { code } = await shell.run("hexo",["deploy"]);
    console.log(code);
  } catch {
    // We can ignore
  }
  console.log("Hexo Deploy Done!");
  await editor.flashNotification("Hexo Deploy Done!",);
}
export async function generateDeploy() {
    console.log("hexo generate && hexo deploy");
  try {
    const { code1 } = await shell.run("hexo",["generate"]);
    console.log(code1);
    const { code2 } = await shell.run("hexo",["deploy"]);
    console.log(code2);
  } catch {
    // We can ignore
  }
  console.log("Hexo Generate and Deploy Done!");
  await editor.flashNotification("Hexo Generate and Deploy Done!",);
}
export async function stopServer() {
  console.log("killall hexo");
  try {
    const { code } = await shell.run("killall",["hexo"]);
    console.log(code);
  } catch {
    // We can ignore
  }
  console.log("Hexo Stop Server Done!");
  await editor.flashNotification("Hexo Stop Server Done!",);
}

export async function gitCommitPush() {
    console.log("git add . && git commit && git push");
    let revName = await editor.prompt(`Revision name:`);
    if (!revName) {
    revName = "Snapshot";
    }
    console.log("Revision name", revName);
    console.log("Snapshotting the current space to git with commit message");
    const { code1 } = await shell.run("git", ["add", "./*"]);
    console.log("Git add code", code1);
  try {
    const { code2 } = await shell.run("git", ["commit", "-a", "-m", revName]);
    console.log("Git commit code", code2);
  } catch {
    // We can ignore, this happens when there's no changes to commit
  }
    const { code3 } = await shell.run("git",["push"]);
    console.log("Git push code", code3);
  console.log("Hexo Git Commit and Push Done!");
  await editor.flashNotification("Hexo Git Commit and Push Done!",);
}
export async function gitCloneDeployRepo() {
let url = await editor.prompt(`Github Deploy(site) project URL (like: https://github.com/user/user.github.io):`);
  if (!url) {
    return;
  }
  const token = await editor.prompt(`Github token:`);
  if (!token) {
    return;
  }
  const pieces = url.split("/");
  pieces[2] = `${token}@${pieces[2]}`;
  url = pieces.join("/") + ".git";
  await editor.flashNotification("Now going to clone the deploy(site) repo, this may take some time.",);
  await shell.run("git", ["clone", url, ".deploy_git"]);
  console.log("Hexo Clone Deploy Repo Done!");
  await editor.flashNotification("Hexo Clone Deploy Repo Done!",);
}