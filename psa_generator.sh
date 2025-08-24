#!/bin/bash

# 🌟 THE MORE YOU KNOW - PSA GENERATOR 🌟
# Educational fun facts about government mishaps, NBC style!

generate_psa() {
    # Array of hilarious government mishaps
    FACTS=(
        "🌟 The More You Know: In 1999, NASA lost a \$125 million Mars orbiter because one team used metric units and another used imperial. Oops! ☄️"
        "🌟 The More You Know: The US military spent \$7,600 on a coffee maker in the 1980s. It was for aircraft, but still... that's expensive coffee! ☕"
        "🌟 The More You Know: In 2013, Healthcare.gov launched at a cost of \$2.1 billion and crashed immediately. Have you tried turning it off and on again? 💻"
        "🌟 The More You Know: The Pentagon once spent \$640 on toilet seats. That's one royal throne! 🚽"
        "🌟 The More You Know: In 1962, a missing hyphen in code caused NASA's Mariner 1 to explode. The \$80 million typo! 🚀"
        "🌟 The More You Know: The IRS still uses programming language from 1959 (COBOL). Your tax dollars at work! 🖥️"
        "🌟 The More You Know: The US Postal Service printed 1 billion 'Forever' stamps with the wrong Statue of Liberty (Vegas version). Viva Las Vegas! 🗽"
        "🌟 The More You Know: In 1981, the Air Force spent \$7,622 on a coffee pot. Inflation-adjusted, that's \$24,000 today! ☕"
        "🌟 The More You Know: The Army spent \$5 billion developing new camouflage that turned out too similar to the old one. Spot the difference! 🎨"
        "🌟 The More You Know: In 2018, Hawaii's emergency system sent 'BALLISTIC MISSILE THREAT' to everyone. It was just a wrong button. Aloha! 🌺"
        "🌟 The More You Know: The FBI spent 10 years and \$170 million on a computer system they never used. Ctrl+Alt+Delete! 💾"
        "🌟 The More You Know: In 1999, the UK spent £470 million on a passport system that never worked. Papers, please? 📄"
        "🌟 The More You Know: The TSA's \$160 million 'behavior detection' program caught 0 terrorists. But they're really good at finding water bottles! 💧"
        "🌟 The More You Know: In 2006, the Census Bureau lost 1,100 laptops. Hopefully they weren't counting those! 💻"
        "🌟 The More You Know: The Pentagon has never passed an audit. They've 'misplaced' \$21 trillion since 1998. Check under the couch cushions! 💰"
        "🌟 The More You Know: In 1985, the Navy paid \$435 for a hammer. Thor would be proud! 🔨"
        "🌟 The More You Know: The DMV in California accidentally registered 23,000 people to vote incorrectly. Democracy in action! 🗳️"
        "🌟 The More You Know: The Air Force spent \$1,200 on a cup holder in 2018. But it was a REALLY nice cup holder! ☕"
        "🌟 The More You Know: In 2014, Oregon spent \$248 million on a healthcare website that never launched. 404 Error: Healthcare not found! 🏥"
        "🌟 The More You Know: The Navy built a \$4.4 billion destroyer that breaks down in warm water. Maybe try sailing in Alaska? 🚢"
    )
    
    # Get current hour for time-based variety
    HOUR=$(date +%H)
    
    # Select a random fact
    RANDOM_INDEX=$((RANDOM % ${#FACTS[@]}))
    echo "${FACTS[$RANDOM_INDEX]}"
    
    # Add contextual bonus facts
    if [ $((RANDOM % 3)) -eq 0 ]; then
        echo "💫 Remember: Your tax dollars made this dashboard possible! (Just kidding, it's free on GitHub!)"
    fi
}

# Main execution
case "$1" in
    get)
        generate_psa
        ;;
    *)
        generate_psa
        ;;
esac
