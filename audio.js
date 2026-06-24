/**
 * ByeBye Buddy - Native Web Audio API Sound Synthesizer
 * Generates gentle, warm sounds without external audio file dependencies.
 */

class AudioSynthesizer {
  constructor() {
    this.ctx = null;
  }

  init() {
    if (!this.ctx) {
      this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  // Create a gentle sine chime with an envelope
  createChime(frequency, startTime, duration, type = 'sine', volume = 0.3) {
    if (!this.ctx) this.init();
    
    const osc = this.ctx.createOscillator();
    const gainNode = this.ctx.createGain();
    
    osc.type = type;
    osc.frequency.setValueAtTime(frequency, startTime);
    
    // Smooth volume envelope: quick attack, smooth exponential decay
    gainNode.gain.setValueAtTime(0, startTime);
    gainNode.gain.linearRampToValueAtTime(volume, startTime + 0.04);
    gainNode.gain.exponentialRampToValueAtTime(0.001, startTime + duration);
    
    osc.connect(gainNode);
    gainNode.connect(this.ctx.destination);
    
    osc.start(startTime);
    osc.stop(startTime + duration);
  }

  // Sound 1: Gentle ascending chime for start screen time
  playStart() {
    this.init();
    const now = this.ctx.currentTime;
    // Ascending arpeggio (C major: C5, E5, G5, C6)
    this.createChime(523.25, now, 0.6, 'sine', 0.15); // C5
    this.createChime(659.25, now + 0.12, 0.6, 'sine', 0.15); // E5
    this.createChime(783.99, now + 0.24, 0.6, 'sine', 0.15); // G5
    this.createChime(1046.50, now + 0.36, 0.8, 'sine', 0.2); // C6
  }

  // Sound 2: Soft warning chime (double bell)
  playWarning() {
    this.init();
    const now = this.ctx.currentTime;
    // A-flat major/minor sweet bells (Ab5, C6)
    this.createChime(830.61, now, 0.8, 'sine', 0.2); // Ab5
    this.createChime(830.61, now + 0.25, 0.8, 'sine', 0.2); // Ab5
    this.createChime(1046.50, now + 0.1, 0.6, 'sine', 0.1); // C6 (harmonic layer)
  }

  // Sound 3: Time's up chime (gentle transition warning melody)
  playTimesUp() {
    this.init();
    const now = this.ctx.currentTime;
    // Descending warm melody (G5, F5, Eb5, Bb4)
    this.createChime(783.99, now, 0.5, 'sine', 0.2); // G5
    this.createChime(698.46, now + 0.25, 0.5, 'sine', 0.2); // F5
    this.createChime(622.25, now + 0.5, 0.7, 'sine', 0.2); // Eb5
    this.createChime(466.16, now + 0.75, 1.0, 'sine', 0.25); // Bb4
  }

  // Sound 4: Magical star reward twinkling sound
  playCelebration() {
    this.init();
    const now = this.ctx.currentTime;
    // Sparkling random bells going up rapidly
    const notes = [523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77, 1046.50, 1174.66, 1318.51];
    notes.forEach((freq, index) => {
      this.createChime(freq, now + index * 0.07, 0.4, 'sine', 0.12);
    });
  }
}

export const audio = new AudioSynthesizer();
