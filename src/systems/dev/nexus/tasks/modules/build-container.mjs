export default async (execa) => {
    console.log('\nInstalling ournexus...')

    const imageName = `${process.env.OURNEXUS_IMAGE_NAME}:${process.env.OURNEXUS_IMAGE_TAG}`

    const buildArgv = [
        'build',
        `--file=./containerfile`,
        '--network=host',
        `--tag=${imageName}`,
        './',
    ]

    const buildContainerCommandResult = await execa('docker', buildArgv, {
        cleanup: true,
        env: process.env,
        shell: false,
        stderr: process.stderr,
        stdout: process.stdout,
        stripFinalNewline: true,
    })

    if (buildContainerCommandResult.failed) {
        throw new Error('Failed to build the container.')
    }

    console.log('Successfully installed ournexus.')
}
