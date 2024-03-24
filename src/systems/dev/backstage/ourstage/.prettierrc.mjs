import spotifyPrettierConfig from '@spotify/prettier-config'

export default {
    ...spotifyPrettierConfig,
    printWidth: 80,
    semi: false,
    singleQuote: true,
    tabWidth: 4,
    trailingComma: 'es5',
}
