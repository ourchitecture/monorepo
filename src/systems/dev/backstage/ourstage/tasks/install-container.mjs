import buildContainer from './modules/build-container.mjs'

const main = async (argv) => {
    ;(await import('dotenv')).config()

    const execa = (await import('execa')).execa

    await buildContainer(execa)
}

;(async () => {
    await main(process.argv.slice(2))
})()
