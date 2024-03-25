import buildContainer from './modules/build-container.mjs'
import buildStorageVolume from './modules/create-storage-volume.mjs'

const main = async (argv) => {
    ;(await import('dotenv')).config()

    const execa = (await import('execa')).execa

    await buildStorageVolume(execa)
    await buildContainer(execa)
}

;(async () => {
    await main(process.argv.slice(2))
})()
