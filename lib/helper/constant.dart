import 'package:flutter/material.dart';

// The version of the client
const clientVersion = '1.0.0';
// The version of the local database
const databaseVersion = 1;

const settingAPIServerToken = 'api-token';
const settingUserInfo = 'user-info';
const settingUsingGuestMode = 'using-guest-mode';

const chatAnywhereModel = 'openai:gpt-3.5-turbo';
const chatAnywhereRoomId = 1;

// Used to identify whether the guide page has been loaded
// The guide page will only be loaded when the app is first installed
const settingOnBoardingLoaded = 'on-boarding-loaded';
const settingLanguage = 'language';
const settingServerURL = 'server-url';

// Background image
const settingBackgroundImage = 'background-image';
const settingBackgroundImageBlur = 'background-image-blur';

const settingThemeMode = "dark-mode";


// Image type
const imageTypeAvatar = 'avatar';
const imageTypeThumb = 'thumb';
const imageTypeThumbMedium = 'thumb_500';

const chatMessagePerPage = 300;
const contextBreakKey = 'context-break';
const defaultChatModel = 'gpt-3.5-turbo';
const defaultChatModelName = 'GPT-3.5';
const defaultImageModel = 'DALL·E';
