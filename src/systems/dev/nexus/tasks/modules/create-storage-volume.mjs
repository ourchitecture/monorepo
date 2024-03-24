export default async (execa) => {
    console.log('\nInstalling ournexus storage...')

    const volumeName = `ournexus-data`

    const volumeIsAlreadyCreatedArgv = ['volume', 'inspect', volumeName]

    const volumeIsAlreadyCreatedCommandResult = await execa(
        'docker',
        volumeIsAlreadyCreatedArgv,
        {
            cleanup: true,
            shell: false,
            reject: false,
            stripFinalNewline: true,
        }
    )

    const hasNoSuchVolumeError = volumeIsAlreadyCreatedCommandResult.stderr
        ?.toLocaleLowerCase()
        .includes('no such volume')

    if (volumeIsAlreadyCreatedCommandResult.failed && !hasNoSuchVolumeError) {
        console.error(volumeIsAlreadyCreatedCommandResult.stderr)
        throw new Error(volumeIsAlreadyCreatedCommandResult.stderr)
    }

    if (!hasNoSuchVolumeError) {
        console.log('Container volume already exists.')
    } else {
        const buildArgv = ['volume', 'create', volumeName]

        const createVolumeCommandResult = await execa('docker', buildArgv, {
            cleanup: true,
            shell: false,
            stderr: process.stderr,
            stdout: process.stdout,
            stripFinalNewline: true,
        })

        if (createVolumeCommandResult.failed) {
            throw new Error('Failed to create the container volume.')
        }
    }

    console.log('Successfully installed ournexus storage.')
}
