#!/bin/bash
# Auto-switch between Speaker and Headphones on 3.5mm jack plug/unplug
# Laptop: Acer Nitro V 15 (sof-hda-dsp)

CARD_NAME="alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
PROFILE_HP="HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic1)"
PROFILE_SPK="HiFi (HDMI1, HDMI2, HDMI3, Mic1, Speaker)"

update_profile() {
    local jack_state
    jack_state=$(amixer -c 1 cget numid=8 2>/dev/null | grep -o "values=.*" | cut -d= -f2)

    if [ "$jack_state" = "on" ]; then
        # Headphone plugged in
        pactl set-card-profile "$CARD_NAME" "$PROFILE_HP" 2>/dev/null
    elif [ "$jack_state" = "off" ]; then
        # Headphone unplugged
        pactl set-card-profile "$CARD_NAME" "$PROFILE_SPK" 2>/dev/null
    fi
}

# Run once at startup
update_profile

# Monitor jack events with alsa/amixer
# stdbuf -oL ensures unbuffered line output
stdbuf -oL amixer -c 1 events 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "Headphone Jack"; then
        update_profile
    fi
done
