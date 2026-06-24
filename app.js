import { audio } from './audio.js';

// Default Settings
const DEFAULT_ACTIVITIES = [
  { label: 'Read a Book', icon: '📚' },
  { label: 'Play Blocks', icon: '🧱' },
  { label: 'Draw & Color', icon: '🎨' },
  { label: 'Play Outside', icon: '🌳' }
];

const DEFAULT_SETTINGS = {
  characterColor: 'hsl(190, 85%, 65%)', // Bright sky blue
  characterEyeColor: '#2C3E50',
  durationMinutes: 5,
  activities: [...DEFAULT_ACTIVITIES],
  stars: 0
};

class ByeByeBuddyApp {
  constructor() {
    this.settings = this.loadSettings();
    this.timer = null;
    this.timeTotal = 0; // In seconds
    this.timeLeft = 0;  // In seconds
    this.currentScreen = 'home';
    
    // Gate state
    this.gateAnswer = 0;
    
    // Canvas celebration references
    this.confettiActive = false;
    this.particles = [];
  }

  loadSettings() {
    const raw = localStorage.getItem('byebyebuddy_settings');
    if (raw) {
      try {
        return JSON.parse(raw);
      } catch (e) {
        console.error('Failed to parse settings', e);
      }
    }
    return { ...DEFAULT_SETTINGS };
  }

  saveSettings() {
    localStorage.setItem('byebyebuddy_settings', JSON.stringify(this.settings));
    this.updateStarsDisplay();
    this.applyCharacterColors();
  }

  init() {
    // UI Bindings
    this.bindEvents();
    this.applyCharacterColors();
    this.updateStarsDisplay();
    this.populateSettingsForm();
    
    // Render transition activities
    this.renderActivities();
    
    // Render testing drawer toggling
    document.getElementById('test-drawer-toggle').addEventListener('click', () => {
      document.getElementById('testing-drawer').classList.toggle('open');
    });

    // Handle canvas resize
    window.addEventListener('resize', () => this.resizeCanvas());
    this.resizeCanvas();
  }

  bindEvents() {
    // Screen transitions
    document.getElementById('start-btn').addEventListener('click', () => this.startSession());
    document.getElementById('parent-settings-btn').addEventListener('click', () => this.openParentGate());
    document.getElementById('close-gate-btn').addEventListener('click', () => this.closeParentGate());
    document.getElementById('gate-form').addEventListener('submit', (e) => {
      e.preventDefault();
      this.verifyParentGate();
    });
    
    document.getElementById('settings-form').addEventListener('submit', (e) => {
      e.preventDefault();
      this.saveSettingsFromForm();
    });
    document.getElementById('back-settings-btn').addEventListener('click', () => this.goToScreen('home'));
    
    // Activity choices
    document.getElementById('activities-container').addEventListener('click', (e) => {
      const card = e.target.closest('.activity-card');
      if (card) {
        this.selectActivity(card.dataset.label);
      }
    });

    // Celebration reset
    document.getElementById('celebration-done-btn').addEventListener('click', () => {
      this.goToScreen('home');
      this.stopConfetti();
    });

    // Test actions
    document.getElementById('test-5m').addEventListener('click', () => this.triggerWarning(5));
    document.getElementById('test-1m').addEventListener('click', () => this.triggerWarning(1));
    document.getElementById('test-finish').addEventListener('click', () => this.forceTimesUp());
  }

  goToScreen(screenId) {
    document.querySelectorAll('.screen').forEach(scr => {
      scr.classList.remove('active');
    });
    const targetScreen = document.getElementById(`screen-${screenId}`);
    if (targetScreen) {
      targetScreen.classList.add('active');
      this.currentScreen = screenId;
      
      // Dynamic page background colors based on state
      document.body.style.backgroundColor = `var(--bg-${screenId})`;
    }
  }

  applyCharacterColors() {
    document.querySelectorAll('.buddy-body').forEach(el => {
      el.setAttribute('fill', this.settings.characterColor);
    });
    document.querySelectorAll('.buddy-eye-fill').forEach(el => {
      el.setAttribute('fill', this.settings.characterEyeColor);
    });
  }

  updateStarsDisplay() {
    document.getElementById('stars-count').innerText = this.settings.stars;
  }

  // SVG character mouth/eyes states
  setCharacterState(state) {
    const mouth = document.getElementById('buddy-mouth');
    const leftArm = document.getElementById('buddy-left-arm');
    const rightArm = document.getElementById('buddy-right-arm');
    const leftEyebrow = document.getElementById('buddy-left-eyebrow');
    const rightEyebrow = document.getElementById('buddy-right-eyebrow');
    
    // Reset classes
    leftArm.className.baseVal = "left-arm";
    rightArm.className.baseVal = "right-arm";
    
    if (state === 'happy') {
      mouth.setAttribute('d', 'M 90 120 Q 100 135 110 120'); // Smile
      leftEyebrow.setAttribute('d', 'M 80 75 Q 90 75 95 78');
      rightEyebrow.setAttribute('d', 'M 105 78 Q 110 75 120 75');
    } else if (state === 'warning') {
      mouth.setAttribute('d', 'M 92 122 H 108'); // Straight mouth / concerned but calm
      leftArm.className.baseVal = "left-arm waving-arm";
      leftEyebrow.setAttribute('d', 'M 80 78 Q 90 74 95 76');
      rightEyebrow.setAttribute('d', 'M 105 76 Q 110 74 120 78');
    } else if (state === 'transition') {
      mouth.setAttribute('d', 'M 90 120 Q 100 130 110 120');
      rightArm.className.baseVal = "right-arm waving-arm";
    } else if (state === 'cheering') {
      mouth.setAttribute('d', 'M 88 118 Q 100 140 112 118 Z'); // Wide happy smile
      leftArm.className.baseVal = "left-arm cheering-arms";
      rightArm.className.baseVal = "right-arm cheering-arms";
      leftEyebrow.setAttribute('d', 'M 80 72 Q 90 75 95 72');
      rightEyebrow.setAttribute('d', 'M 105 72 Q 110 75 120 72');
    }
  }

  // Timer Session Management
  startSession() {
    audio.playStart();
    this.timeTotal = this.settings.durationMinutes * 60;
    this.timeLeft = this.timeTotal;
    
    this.setCharacterState('happy');
    this.goToScreen('countdown');
    this.updateTimerRing();
    
    // Clear warning box initially
    document.getElementById('warning-overlay').style.display = 'none';

    if (this.timer) clearInterval(this.timer);
    this.timer = setInterval(() => this.tick(), 1000);
  }

  tick() {
    this.timeLeft--;
    this.updateTimerRing();

    // Check warning thresholds
    // Standard warnings: 5m (300s) and 1m (60s)
    // Dynamic scaling for shorter timers (testing/demo):
    // If timer total is under 6 minutes, warning 1 at 50% left, warning 2 at 20% left.
    const isShort = this.timeTotal < 360;
    const warn1Time = isShort ? Math.floor(this.timeTotal * 0.5) : 300;
    const warn2Time = isShort ? Math.floor(this.timeTotal * 0.2) : 60;

    if (this.timeLeft === warn1Time) {
      this.triggerWarning(5);
    } else if (this.timeLeft === warn2Time) {
      this.triggerWarning(1);
    } else if (this.timeLeft <= 0) {
      this.forceTimesUp();
    }
  }

  updateTimerRing() {
    const min = Math.floor(this.timeLeft / 60);
    const sec = this.timeLeft % 60;
    document.getElementById('timer-time').innerText = `${min}:${sec.toString().padStart(2, '0')}`;
    
    const ring = document.getElementById('timer-progress');
    const percent = this.timeLeft / this.timeTotal;
    const offset = 628 * (1 - percent);
    ring.style.strokeDashoffset = offset;
    
    // Smooth transition from blue to coral as timer ticks down
    if (percent < 0.2) {
      ring.style.stroke = 'hsl(10, 90%, 65%)'; // Red/Coral close to ending
    } else if (percent < 0.5) {
      ring.style.stroke = 'hsl(35, 100%, 60%)'; // Orange warn
    } else {
      ring.style.stroke = 'var(--primary-color)';
    }
  }

  triggerWarning(minutesRemaining) {
    audio.playWarning();
    this.setCharacterState('warning');
    
    const overlay = document.getElementById('warning-overlay');
    const title = document.getElementById('warn-title');
    const desc = document.getElementById('warn-desc');
    
    overlay.style.display = 'block';
    
    // Scale text depending on demo vs standard
    if (this.timeTotal < 360) {
      title.innerText = `Buddy says: Almost Done!`;
      desc.innerText = `We have just a little time left.`;
    } else {
      title.innerText = `Buddy waves: ${minutesRemaining} Minute${minutesRemaining > 1 ? 's' : ''}!`;
      desc.innerText = minutesRemaining === 5 
        ? `Let's start finishing up our screen time game.`
        : `Just 1 more minute left! Get ready to choose what's next.`;
    }

    // Auto-dismiss warning after 4 seconds to return to countdown circle
    setTimeout(() => {
      if (this.currentScreen === 'countdown') {
        overlay.style.display = 'none';
        this.setCharacterState('happy');
      }
    }, 4500);
  }

  forceTimesUp() {
    if (this.timer) clearInterval(this.timer);
    audio.playTimesUp();
    this.setCharacterState('transition');
    this.goToScreen('transition');
  }

  // Activity Picker
  renderActivities() {
    const container = document.getElementById('activities-container');
    container.innerHTML = '';
    
    this.settings.activities.forEach(act => {
      const card = document.createElement('button');
      card.className = 'activity-card';
      card.dataset.label = act.label;
      card.innerHTML = `
        <span class="activity-icon">${act.icon}</span>
        <span class="activity-label">${act.label}</span>
      `;
      container.appendChild(card);
    });
  }

  selectActivity(label) {
    // Add star reward
    this.settings.stars++;
    this.saveSettings();
    
    // Transition to celebration screen
    this.setCharacterState('cheering');
    this.goToScreen('celebration');
    
    audio.playCelebration();
    this.startConfetti();
  }

  // Parent Settings Gate logic
  openParentGate() {
    const num1 = Math.floor(Math.random() * 5) + 3;
    const num2 = Math.floor(Math.random() * 4) + 2;
    this.gateAnswer = num1 + num2;
    
    document.getElementById('gate-num1').innerText = num1;
    document.getElementById('gate-num2').innerText = num2;
    document.getElementById('gate-answer-input').value = '';
    
    document.getElementById('parent-gate-modal').classList.add('active');
    document.getElementById('gate-answer-input').focus();
  }

  closeParentGate() {
    document.getElementById('parent-gate-modal').classList.remove('active');
  }

  verifyParentGate() {
    const inputVal = parseInt(document.getElementById('gate-answer-input').value, 10);
    const content = document.getElementById('gate-modal-content');
    
    if (inputVal === this.gateAnswer) {
      this.closeParentGate();
      this.goToScreen('parent');
    } else {
      // Wrong answer - shake the dialog
      content.classList.add('shake');
      audio.playWarning(); // Gentle fail indicator
      setTimeout(() => content.classList.remove('shake'), 400);
    }
  }

  // Settings Save & Load
  populateSettingsForm() {
    document.getElementById('char-color').value = this.settings.characterColor;
    document.getElementById('screen-duration').value = this.settings.durationMinutes;
    
    const activityListEl = document.getElementById('activity-setup-list');
    activityListEl.innerHTML = '';
    
    this.settings.activities.forEach((act, idx) => {
      const row = document.createElement('div');
      row.className = 'activity-setup-row';
      row.innerHTML = `
        <select id="act-icon-${idx}">
          <option ${act.icon === '📚' ? 'selected' : ''}>📚</option>
          <option ${act.icon === '🧱' ? 'selected' : ''}>🧱</option>
          <option ${act.icon === '🎨' ? 'selected' : ''}>🎨</option>
          <option ${act.icon === '🌳' ? 'selected' : ''}>🌳</option>
          <option ${act.icon === '🍎' ? 'selected' : ''}>🍎</option>
          <option ${act.icon === '🧩' ? 'selected' : ''}>🧩</option>
          <option ${act.icon === '🏃' ? 'selected' : ''}>🏃</option>
          <option ${act.icon === '🧸' ? 'selected' : ''}>🧸</option>
        </select>
        <input type="text" class="settings-input" id="act-label-${idx}" value="${act.label}" placeholder="Activity Name" required>
      `;
      activityListEl.appendChild(row);
    });
  }

  saveSettingsFromForm() {
    this.settings.characterColor = document.getElementById('char-color').value;
    this.settings.durationMinutes = parseFloat(document.getElementById('screen-duration').value);
    
    const newActivities = [];
    for (let idx = 0; idx < 4; idx++) {
      const icon = document.getElementById(`act-icon-${idx}`).value;
      const label = document.getElementById(`act-label-${idx}`).value.trim();
      newActivities.push({ icon, label });
    }
    this.settings.activities = newActivities;
    
    this.saveSettings();
    this.renderActivities();
    this.goToScreen('home');
  }

  // Sparkles Confetti Animation Canvas
  resizeCanvas() {
    const canvas = document.getElementById('celebration-canvas');
    canvas.width = canvas.parentElement.clientWidth;
    canvas.height = canvas.parentElement.clientHeight;
  }

  startConfetti() {
    this.confettiActive = true;
    this.particles = [];
    const canvas = document.getElementById('celebration-canvas');
    
    // Spawn initial bunch of colorful stars
    for (let i = 0; i < 60; i++) {
      this.particles.push(this.createParticle(canvas));
    }
    
    requestAnimationFrame(() => this.drawConfetti(canvas));
  }

  createParticle(canvas) {
    return {
      x: canvas.width / 2 + (Math.random() - 0.5) * 40,
      y: canvas.height * 0.4 + (Math.random() - 0.5) * 40,
      vx: (Math.random() - 0.5) * 8,
      vy: (Math.random() - 1) * 8 - 4,
      size: Math.random() * 8 + 6,
      color: `hsl(${Math.random() * 360}, 90%, 65%)`,
      alpha: 1,
      rotation: Math.random() * 360,
      rotationSpeed: (Math.random() - 0.5) * 10
    };
  }

  drawConfetti(canvas) {
    if (!this.confettiActive) return;
    
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    this.particles.forEach((p, idx) => {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.25; // gravity
      p.alpha -= 0.015;
      p.rotation += p.rotationSpeed;
      
      if (p.alpha <= 0) {
        // Recycle or remove particle
        this.particles[idx] = this.createParticle(canvas);
        return;
      }
      
      ctx.save();
      ctx.globalAlpha = p.alpha;
      ctx.translate(p.x, p.y);
      ctx.rotate((p.rotation * Math.PI) / 180);
      ctx.fillStyle = p.color;
      
      // Draw simple star
      ctx.beginPath();
      for (let i = 0; i < 5; i++) {
        ctx.lineTo(0, 0 - p.size);
        ctx.rotate((Math.PI * 2) / 10);
        ctx.lineTo(0, 0 - p.size / 2);
        ctx.rotate((Math.PI * 2) / 10);
      }
      ctx.closePath();
      ctx.fill();
      ctx.restore();
    });
    
    requestAnimationFrame(() => this.drawConfetti(canvas));
  }

  stopConfetti() {
    this.confettiActive = false;
  }

  // Developer/parent trigger support
  triggerWarning(min) {
    if (this.currentScreen === 'countdown') {
      this.triggerWarning(min);
    }
  }
}

// Instantiate and initialize
window.addEventListener('DOMContentLoaded', () => {
  const app = new ByeByeBuddyApp();
  app.init();
});
