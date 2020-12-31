import { commands, ExtensionContext, workspace, snippetManager } from 'coc.nvim';

export async function activate(context: ExtensionContext): Promise<void> {
  // workspace.showMessage(`coc-exposejump works!`);
  const config = workspace.getConfiguration('coc-exposejump');
  const isEnable = config.get<boolean>('enable', true);
  if (!isEnable) {
    return;
  }

  context.subscriptions.push(
    commands.registerCommand('coc-fusiontab.info', async (direction: string) => {
      const session = snippetManager.getSession(workspace.bufnr);
      const cur_tabstop = session?.placeholder;
      const target_tabstop =
        direction == 'forward'
          ? session?.snippet.getNextPlaceholder(cur_tabstop.index)
          : direction == 'backward'
          ? session?.snippet.getPrevPlaceholder(cur_tabstop.index)
          : null;
      const target_range = session?.snippet.range;
      return target_tabstop
        ? {
            cur: {
              ls: cur_tabstop.range.start.line,
              le: cur_tabstop.range.end.line,
              cs: cur_tabstop.range.start.character,
              ce: cur_tabstop.range.end.character,
            },
            tgt: {
              ls: target_tabstop.range.start.line,
              le: target_tabstop.range.end.line,
              cs: target_tabstop.range.start.character,
              ce: target_tabstop.range.end.character,
            },
            range: {
              ls: target_range.start.line,
              le: target_range.end.line,
              cs: target_range.start.character,
              ce: target_range.end.character,
            },
          }
        : null;
    }),
    commands.registerCommand('coc-fusiontab.backward-jumpable', async () => {
      const session = snippetManager.getSession(workspace.bufnr);
      if (!session) {
        return false;
      }
      const placeholder = session.placeholder;
      if (placeholder && placeholder.index != 0) {
        return true;
      }
      return false;
    })
  );
}
// vim: set tabstop=2 softtabstop=2 shiftwidth=2:
