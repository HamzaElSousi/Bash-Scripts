#!/bin/bash

# Hamza El Sousi
# 040982818
# Lab 9 


# Function to print the welcome message with the current date and time
print_welcome_message() {
  local user=$(whoami)
  local date_time=$(date)
  ./banner.sh -c'#' "Welcome $user" --text-color=green
  echo "Today's Date: $date_time"
  echo -e "\nPlease note that you need the administrator password to run these functions properly.\n"
}

# Function to print the menu header
print_menu_header() {
  ./banner.sh "  System Administration Menu" -w100 --text-color=blue
  echo -e "\e[32m1. Print System Users\e[39m"
  echo -e "\e[32m2. List User-Related Groups\e[39m"
  echo -e "\e[32m3. Add a New User\e[39m"
  echo -e "\e[32m4. Send Welcome Message to User\e[39m"
  echo -e "\e[32m5. Set User Expiry Date\e[39m"
  echo -e "\e[32m6. Delete User\e[39m"
  echo -e "\e[35m7. Group Management\e[39m"
  echo -e "\e[31m8. Quit\e[39m"
}

# Function to print all actual users of the system (excluding system accounts)
print_system_users() {
  ./banner.sh "Actual Users of the System:" -w100
  grep -E 'home/.+:' /etc/passwd | cut -d':' -f1,5 | while IFS=: read -r user full_name; do
    if [[ ! "$user" =~ ^(_|nologin|halt|syslog|shutdown|cups-pk-helper)$ ]]; then
      echo "$user  $full_name"
    fi
  done
}

# Function to list user-related groups on the system
list_user_related_groups() {
  ./banner.sh "User-Related Groups on the System:" -w100
  compgen -g | while read -r group; do
    if [[ $(getent group "$group" | cut -d':' -f4) ]]; then
      echo "$group"
    fi
  done
}

# Function to add a new user to the system
add_new_user() {
  read -p "Enter the username of the new user: " new_user
  sudo adduser "$new_user"
  echo "$new_user $(date)" >> useradmin.log
}

# Function to send the welcome message to a user
send_welcome_message() {
  read -p "Enter the username of the user to send the welcome message: " target_user
  if [ -f "welcome.txt" ]; then
    # Replace "{USERNAME}" with the actual username in the welcome message
    sed "s/{USERNAME}/$target_user/g" "welcome.txt" > "/home/$target_user/welcome.txt"
    echo "Welcome message sent to $target_user at $(date)" >> useradmin.log
  else
    echo "Error: 'welcome.txt' file not found!"
  fi
}

# Function to set an expiry date for a user account
set_user_expiry_date() {
  read -p "Enter the username of the user: " target_user
  read -p "Enter the expiry date (YYYY-MM-DD): " expiry_date
  sudo usermod --expiredate "$expiry_date" "$target_user"
  echo "$target_user account expiry set to $expiry_date at $(date)" >> useradmin.log
}

# Function to delete a user account
delete_user() {
  read -p "Enter the username of the user to delete: " target_user
  read -p "Are you sure you want to delete $target_user? (yes/no): " confirmation
  if [ "$confirmation" = "yes" ]; then
    sudo userdel "$target_user"
    echo "$target_user deleted at $(date)" >> useradmin.log
    echo "Orphaned home directory: $(getent passwd "$target_user" | cut -d':' -f6)" >> useradmin.log
  fi
}

# Function to manage user groups
manage_user_groups() {
  ./banner.sh "Group Management" -w100 --text-color=magenta
  echo "1. Create a New Group"
  echo "2. List Users of a Group"
  echo "3. Add User to a Group"
  echo "4. Remove User from a Group"
  echo "5. Delete a group"
  echo "6. Back to Main Menu"
  read -p "Enter your choice: " group_choice
  
  case "$group_choice" in
    1)
      read -p "Enter the name of the new group: " new_group
      sudo groupadd "$new_group"
      echo "Group '$new_group' created at $(date)" >> useradmin.log
      ;;
    2)
      read -p "Enter the name of the group to list users: " target_group
      echo "Users in Group '$target_group':"
      getent group "$target_group" | cut -d':' -f4 | tr ',' '\n'
      ;;
    3)
      read -p "Enter the username of the user to add: " user_to_add
      read -p "Enter the name of the group to add the user: " target_group
      sudo usermod -aG "$target_group" "$user_to_add"
      echo "User '$user_to_add' added to Group '$target_group' at $(date)" >> useradmin.log
      ;;
    4)
      read -p "Enter the username of the user to remove: " user_to_remove
      read -p "Enter the name of the group to remove the user from: " target_group
      sudo gpasswd -d "$user_to_remove" "$target_group"
      echo "User '$user_to_remove' removed from Group '$target_group' at $(date)" >> useradmin.log
      ;;
    
    5)
      read -p "Enter the name of the group to delete: " group_to_delete
      sudo groupdel "$group_to_delete"
      echo "Group '$group_to_delete' deleted at $(date)" >> useradmin.log
    ;;
    6)
      echo "Returning to Main Menu..."
      ;;
    *)
      echo "Invalid choice. Please enter a valid option (1-6)."
      ;;
  esac
}

# Main script
print_welcome_message

choice=""
while [ "$choice" != "8" ]; do
  print_menu_header
  read -p "Enter your choice: " choice
  case "$choice" in
    1)
      print_system_users
      ;;
    2)
      list_user_related_groups
      ;;
    3)
      add_new_user
      ;;
    4)
      send_welcome_message
      ;;
    5)
      set_user_expiry_date
      ;;
    6)
      delete_user
      ;;
    7)
      manage_user_groups
      ;;
    8)
      echo "Goodbye! Have a great day!"
      ;;
    *)
      echo "Invalid choice. Please enter a valid option (1-8)."
      ;;
  esac
done