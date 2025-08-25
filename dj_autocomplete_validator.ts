/**
 * 🎧 DJ AUTOCOMPLETE VALIDATOR v10.0 - REAL-TIME SEARCH EDITION
 * Prevents Madonna from getting Warren Beatty attitude by validating songs exist
 * TypeScript autocomplete with Apple Music library integration
 * Copyright 2025 - Panther Pride DJ Consortium International
 */

interface Song {
  title: string;
  artist: string;
  album?: string;
  duration?: number;
  id: string;
  matchScore?: number;
}

interface AutocompleteState {
  isSearching: boolean;
  suggestions: Song[];
  currentInput: string;
  selectedIndex: number;
  showSuggestions: boolean;
}

interface ValidationResult {
  isValid: boolean;
  confidence: number;
  suggestions: Song[];
  warningMessage?: string;
  exactMatch?: Song;
}

class DJAutocompleteValidator {
  private musicLibrary: Song[] = [];
  private autocompleteState: AutocompleteState = {
    isSearching: false,
    suggestions: [],
    currentInput: '',
    selectedIndex: -1,
    showSuggestions: false
  };

  constructor() {
    this.initializeMusicLibrary();
    this.setupEventListeners();
  }

  /**
   * Initialize music library from Apple Music
   * In production, this would connect to Apple Music API
   */
  private async initializeMusicLibrary(): Promise<void> {
    try {
      // Simulate Apple Music library with popular songs that might be in user's library
      this.musicLibrary = [
        // Madonna's hits (for our VIP)
        { title: "Music", artist: "Madonna", album: "Music", id: "madonna_music_001" },
        { title: "Material Girl", artist: "Madonna", album: "Like a Virgin", id: "madonna_material_001" },
        { title: "Like a Prayer", artist: "Madonna", album: "Like a Prayer", id: "madonna_prayer_001" },
        { title: "Vogue", artist: "Madonna", album: "I'm Breathless", id: "madonna_vogue_001" },
        
        // Queen classics
        { title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", id: "queen_bohemian_001" },
        { title: "Don't Stop Me Now", artist: "Queen", album: "Jazz", id: "queen_dontstop_001" },
        { title: "We Will Rock You", artist: "Queen", album: "News of the World", id: "queen_rock_001" },
        { title: "Another One Bites the Dust", artist: "Queen", album: "The Game", id: "queen_dust_001" },
        
        // Guns N' Roses
        { title: "Welcome to the Jungle", artist: "Guns N' Roses", album: "Appetite for Destruction", id: "gnr_jungle_001" },
        { title: "Sweet Child O' Mine", artist: "Guns N' Roses", album: "Appetite for Destruction", id: "gnr_child_001" },
        
        // Electronic/Dance
        { title: "Sandstorm", artist: "Darude", album: "Before the Storm", id: "darude_sandstorm_001" },
        { title: "Better Off Alone", artist: "Alice Deejay", album: "Who Needs Guitars Anyway?", id: "alice_alone_001" },
        
        // User's collaborative playlist
        { title: "I Am Here", artist: "edhead76", album: "Collaborative Mix", id: "ed_here_001" },
        { title: "Collaborative Mix Track", artist: "edhead76", album: "I Am Here", id: "ed_collab_001" },
        
        // Popular songs that might be in library
        { title: "Blinding Lights", artist: "The Weeknd", album: "After Hours", id: "weeknd_lights_001" },
        { title: "Shape of You", artist: "Ed Sheeran", album: "÷ (Divide)", id: "sheeran_shape_001" },
        { title: "Someone Like You", artist: "Adele", album: "21", id: "adele_someone_001" },
        { title: "Hello", artist: "Adele", album: "25", id: "adele_hello_001" },
      ];
      
      console.log(`🍎 Apple Music library loaded: ${this.musicLibrary.length} songs`);
    } catch (error) {
      console.error('Failed to load Apple Music library:', error);
    }
  }

  /**
   * Calculate string similarity using Levenshtein distance
   */
  private calculateSimilarity(str1: string, str2: string): number {
    const s1 = str1.toLowerCase().trim();
    const s2 = str2.toLowerCase().trim();
    
    if (s1 === s2) return 1.0;
    if (s1.length === 0 || s2.length === 0) return 0;
    
    // Simple substring matching for better UX
    if (s1.includes(s2) || s2.includes(s1)) {
      return 0.8;
    }
    
    // Levenshtein distance calculation
    const matrix: number[][] = [];
    for (let i = 0; i <= s2.length; i++) {
      matrix[i] = [i];
    }
    for (let j = 0; j <= s1.length; j++) {
      matrix[0][j] = j;
    }
    
    for (let i = 1; i <= s2.length; i++) {
      for (let j = 1; j <= s1.length; j++) {
        if (s2.charAt(i - 1) === s1.charAt(j - 1)) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1,
            matrix[i][j - 1] + 1,
            matrix[i - 1][j] + 1
          );
        }
      }
    }
    
    const maxLength = Math.max(s1.length, s2.length);
    return (maxLength - matrix[s2.length][s1.length]) / maxLength;
  }

  /**
   * Search for songs with fuzzy matching
   */
  public searchSongs(query: string, maxResults: number = 5): Song[] {
    if (!query || query.trim().length < 2) return [];
    
    const results = this.musicLibrary
      .map(song => {
        const titleMatch = this.calculateSimilarity(song.title, query);
        const artistMatch = this.calculateSimilarity(song.artist, query);
        const combinedMatch = this.calculateSimilarity(`${song.title} ${song.artist}`, query);
        
        const matchScore = Math.max(titleMatch, artistMatch, combinedMatch);
        
        return { ...song, matchScore };
      })
      .filter(song => song.matchScore! > 0.3)
      .sort((a, b) => (b.matchScore || 0) - (a.matchScore || 0))
      .slice(0, maxResults);
    
    return results;
  }

  /**
   * Validate if a specific song and artist exist in the library
   */
  public validateSongRequest(songTitle: string, artist: string): ValidationResult {
    const combinedQuery = `${songTitle} ${artist}`.trim();
    
    // Look for exact matches first
    const exactMatch = this.musicLibrary.find(song => 
      song.title.toLowerCase() === songTitle.toLowerCase() && 
      song.artist.toLowerCase() === artist.toLowerCase()
    );
    
    if (exactMatch) {
      return {
        isValid: true,
        confidence: 1.0,
        suggestions: [exactMatch],
        exactMatch
      };
    }
    
    // Find close matches
    const suggestions = this.searchSongs(combinedQuery, 3);
    const bestMatch = suggestions[0];
    
    if (bestMatch && bestMatch.matchScore! > 0.8) {
      return {
        isValid: true,
        confidence: bestMatch.matchScore!,
        suggestions,
        warningMessage: `Close match found: "${bestMatch.title}" by ${bestMatch.artist}`,
        exactMatch: bestMatch
      };
    } else if (suggestions.length > 0) {
      return {
        isValid: false,
        confidence: bestMatch?.matchScore || 0,
        suggestions,
        warningMessage: `Song not found. Did you mean: "${suggestions[0].title}" by ${suggestions[0].artist}?`
      };
    }
    
    return {
      isValid: false,
      confidence: 0,
      suggestions: [],
      warningMessage: `⚠️ "${songTitle}" by ${artist} not found in Apple Music library. Request will use fallback options.`
    };
  }

  /**
   * Real-time autocomplete as user types
   */
  public handleAutocomplete(input: string, callback: (suggestions: Song[]) => void): void {
    this.autocompleteState.currentInput = input;
    this.autocompleteState.isSearching = true;
    
    // Debounce search to avoid too many requests
    setTimeout(() => {
      if (input === this.autocompleteState.currentInput) {
        const suggestions = this.searchSongs(input, 5);
        this.autocompleteState.suggestions = suggestions;
        this.autocompleteState.isSearching = false;
        this.autocompleteState.showSuggestions = suggestions.length > 0;
        
        callback(suggestions);
      }
    }, 300);
  }

  /**
   * Handle keyboard navigation in autocomplete
   */
  public handleKeyboardNavigation(key: string): boolean {
    const suggestions = this.autocompleteState.suggestions;
    
    switch (key) {
      case 'ArrowDown':
        if (this.autocompleteState.selectedIndex < suggestions.length - 1) {
          this.autocompleteState.selectedIndex++;
        }
        return true;
      
      case 'ArrowUp':
        if (this.autocompleteState.selectedIndex > -1) {
          this.autocompleteState.selectedIndex--;
        }
        return true;
      
      case 'Enter':
        if (this.autocompleteState.selectedIndex >= 0) {
          const selected = suggestions[this.autocompleteState.selectedIndex];
          this.selectSuggestion(selected);
          return true;
        }
        break;
      
      case 'Escape':
        this.hideSuggestions();
        return true;
    }
    
    return false;
  }

  /**
   * Select a suggestion from autocomplete
   */
  public selectSuggestion(song: Song): void {
    // This would populate the form fields
    console.log(`🎵 Selected: "${song.title}" by ${song.artist}`);
    this.hideSuggestions();
    
    // Emit event for form to handle
    this.emitSelectionEvent(song);
  }

  /**
   * Hide autocomplete suggestions
   */
  public hideSuggestions(): void {
    this.autocompleteState.showSuggestions = false;
    this.autocompleteState.selectedIndex = -1;
  }

  /**
   * Emit selection event (would integrate with form)
   */
  private emitSelectionEvent(song: Song): void {
    const event = new CustomEvent('djSongSelected', {
      detail: song
    });
    document.dispatchEvent(event);
  }

  /**
   * Setup event listeners for the autocomplete system
   */
  private setupEventListeners(): void {
    // This would be attached to actual form elements in production
    console.log('🎧 DJ Autocomplete system ready');
  }

  /**
   * Generate HTML for autocomplete dropdown
   */
  public generateAutocompleteHTML(suggestions: Song[]): string {
    if (!this.autocompleteState.showSuggestions || suggestions.length === 0) {
      return '';
    }

    return `
      <div class="dj-autocomplete-dropdown">
        ${suggestions.map((song, index) => `
          <div class="dj-suggestion ${index === this.autocompleteState.selectedIndex ? 'selected' : ''}"
               data-song-id="${song.id}">
            <div class="song-title">${this.highlightMatch(song.title, this.autocompleteState.currentInput)}</div>
            <div class="song-artist">${this.highlightMatch(song.artist, this.autocompleteState.currentInput)}</div>
            <div class="match-confidence">${Math.round((song.matchScore || 0) * 100)}% match</div>
          </div>
        `).join('')}
      </div>
    `;
  }

  /**
   * Highlight matching text in suggestions
   */
  private highlightMatch(text: string, query: string): string {
    if (!query) return text;
    
    const regex = new RegExp(`(${query})`, 'gi');
    return text.replace(regex, '<mark>$1</mark>');
  }

  /**
   * Get current autocomplete state
   */
  public getAutocompleteState(): AutocompleteState {
    return { ...this.autocompleteState };
  }
}

// CSS styles for autocomplete (would be in separate file)
const autocompleteStyles = `
<style>
.dj-autocomplete-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #1a1a1a;
  border: 1px solid #333;
  border-top: none;
  border-radius: 0 0 8px 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  z-index: 1000;
  max-height: 200px;
  overflow-y: auto;
}

.dj-suggestion {
  padding: 12px 16px;
  cursor: pointer;
  border-bottom: 1px solid #2a2a2a;
  transition: background-color 0.2s ease;
}

.dj-suggestion:hover,
.dj-suggestion.selected {
  background-color: #333;
}

.dj-suggestion:last-child {
  border-bottom: none;
}

.song-title {
  font-weight: bold;
  color: #fff;
  margin-bottom: 2px;
}

.song-artist {
  color: #888;
  font-size: 0.9em;
}

.match-confidence {
  color: #666;
  font-size: 0.8em;
  float: right;
  margin-top: -20px;
}

.dj-suggestion mark {
  background-color: #ff6b35;
  color: #fff;
  padding: 1px 2px;
  border-radius: 2px;
}

.dj-input-container {
  position: relative;
  width: 100%;
}

.dj-input {
  width: 100%;
  padding: 12px 16px;
  background: #2a2a2a;
  border: 1px solid #444;
  border-radius: 8px;
  color: #fff;
  font-size: 16px;
}

.dj-input:focus {
  outline: none;
  border-color: #ff6b35;
  box-shadow: 0 0 0 2px rgba(255, 107, 53, 0.2);
}

.validation-warning {
  color: #ff9500;
  font-size: 0.9em;
  margin-top: 4px;
  padding: 8px 12px;
  background: rgba(255, 149, 0, 0.1);
  border-radius: 4px;
  border-left: 3px solid #ff9500;
}

.validation-success {
  color: #32d74b;
  font-size: 0.9em;
  margin-top: 4px;
  padding: 8px 12px;
  background: rgba(50, 215, 75, 0.1);
  border-radius: 4px;
  border-left: 3px solid #32d74b;
}
</style>
`;

// Export for use in the DJ system
export { DJAutocompleteValidator, Song, ValidationResult, AutocompleteState };

// Example usage
const validator = new DJAutocompleteValidator();

// Test Madonna's request
console.log('🎧 Testing Madonna\'s request to avoid Warren Beatty situation...');
const madonnaResult = validator.validateSongRequest('Music', 'Madonna');
console.log('Madonna validation result:', madonnaResult);

// Test autocomplete
validator.handleAutocomplete('Bohe', (suggestions) => {
  console.log('🔍 Autocomplete suggestions for "Bohe":', suggestions);
});

console.log('🎵 DJ Autocomplete Validator v10.0 - Preventing diva attitudes since 2025!');
