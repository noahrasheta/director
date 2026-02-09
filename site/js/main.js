/* Director Landing Page — Main JavaScript
   https://director.cc

   Terminal animation, scroll behaviors, and interactions.
*/

/* --------------------------------------------------------------------------
   Terminal Animation
   -------------------------------------------------------------------------- */

class TerminalAnimation {
  constructor(element, lines, options = {}) {
    this.el = element;
    this.lines = lines;
    this.typeDelay = options.typeDelay || 40;
    this.lineDelay = options.lineDelay || 600;
    this.outputDelay = options.outputDelay || 300;
    this.running = false;
  }

  async type(text, container) {
    for (const char of text) {
      container.textContent += char;
      await this.delay(this.typeDelay);
    }
  }

  async run() {
    if (this.running) return;
    this.running = true;
    this.el.innerHTML = '';

    const replayBtn = document.getElementById('replayBtn');
    if (replayBtn) replayBtn.hidden = true;

    for (const line of this.lines) {
      const lineEl = document.createElement('div');
      lineEl.className = 'terminal-line ' + line.type;

      if (line.type === 'input') {
        const prompt = document.createElement('span');
        prompt.className = 'terminal-prompt';
        prompt.textContent = '$ ';
        lineEl.appendChild(prompt);
        const text = document.createElement('span');
        lineEl.appendChild(text);
        this.el.appendChild(lineEl);
        await this.type(line.text, text);
        await this.delay(this.lineDelay);
      } else if (line.type === 'blank') {
        lineEl.innerHTML = '&nbsp;';
        this.el.appendChild(lineEl);
        await this.delay(this.outputDelay);
      } else {
        lineEl.textContent = line.text;
        this.el.appendChild(lineEl);
        lineEl.classList.add('fade-in');
        await this.delay(this.outputDelay);
      }
    }

    this.running = false;
    if (replayBtn) replayBtn.hidden = false;
  }

  showAll() {
    this.el.innerHTML = '';
    for (const line of this.lines) {
      const lineEl = document.createElement('div');
      lineEl.className = 'terminal-line ' + line.type;

      if (line.type === 'input') {
        const prompt = document.createElement('span');
        prompt.className = 'terminal-prompt';
        prompt.textContent = '$ ';
        lineEl.appendChild(prompt);
        const text = document.createElement('span');
        text.textContent = line.text;
        lineEl.appendChild(text);
      } else if (line.type === 'blank') {
        lineEl.innerHTML = '&nbsp;';
      } else {
        lineEl.textContent = line.text;
      }

      this.el.appendChild(lineEl);
    }

    const replayBtn = document.getElementById('replayBtn');
    if (replayBtn) replayBtn.hidden = false;
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/* --------------------------------------------------------------------------
   Terminal Content — Three-Act Walkthrough
   -------------------------------------------------------------------------- */

const terminalLines = [
  { type: 'input', text: '/director:onboard' },
  { type: 'output', text: 'What do you want to build?' },
  { type: 'input', text: 'A task management app with team collaboration' },
  { type: 'output', text: 'Got it. Vision captured. Run /director:blueprint when ready.' },
  { type: 'blank' },
  { type: 'input', text: '/director:blueprint' },
  { type: 'output', text: 'Breaking your vision into steps...' },
  { type: 'output', text: '  Goal 1: Core App \u2014 4 steps, 12 tasks' },
  { type: 'output', text: '  Step 1: Database and auth (3 tasks, ready to build)' },
  { type: 'output', text: 'Gameplan created. Ready to build.' },
  { type: 'blank' },
  { type: 'input', text: '/director:build' },
  { type: 'output', text: 'Working on: Set up the database...' },
  { type: 'output', text: 'Progress saved. Next up: Create user authentication.' },
];

/* --------------------------------------------------------------------------
   Initialize Terminal
   -------------------------------------------------------------------------- */

const terminal = document.getElementById('terminal');

if (terminal) {
  const anim = new TerminalAnimation(terminal, terminalLines);

  // Respect prefers-reduced-motion
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    anim.showAll();
  } else {
    const terminalObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          anim.run();
          terminalObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.3 });

    terminalObserver.observe(terminal);
  }

  document.getElementById('replayBtn')?.addEventListener('click', () => anim.run());
}
